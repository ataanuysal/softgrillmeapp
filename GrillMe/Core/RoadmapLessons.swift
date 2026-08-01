extension XRayLesson {
  public static let roadmapContinuation = roadmapBlueprints.map(\.lesson)
}

/// Rehberli örneğin tek bir yürütme adımı.
///
/// Adımlar elle yazılır çünkü dersin vaadi tam olarak budur: hangi satırda
/// hangi değerin değiştiğini görmek. Şablondan üretilen "başlangıç → sonuç"
/// atlaması bu vaadi karşılamaz.
private struct Step {
  let line: Int
  let note: String
  let memory: [String: String]
  let output: String?
  let callStack: [CallFrame]
  let architecture: ArchitectureSnapshot?

  init(
    _ line: Int,
    _ note: String,
    memory: [String: String] = [:],
    output: String? = nil,
    callStack: [CallFrame] = [],
    architecture: ArchitectureSnapshot? = nil
  ) {
    self.line = line
    self.note = note
    self.memory = memory
    self.output = output
    self.callStack = callStack
    self.architecture = architecture
  }
}

/// Havuzdaki ek quiz sorusu.
///
/// Her soru aynı kavramı farklı bir kodda ölçer; tekrar denemede sıradaki
/// soru sorulur.
private struct Quiz {
  let code: [String]
  let choices: [String]
  let answer: String
  let explanation: String

  init(_ code: [String], choices: [String], answer: String, explanation: String) {
    self.code = code
    self.choices = choices
    self.answer = answer
    self.explanation = explanation
  }
}

private struct RoadmapBlueprint {
  let id: String
  let order: Int
  let section: CurriculumSection
  let topic: String
  let title: String
  let objective: String
  let takeaway: String
  let teaching: LessonTeaching
  let code: [String]
  let choices: [String]
  let answer: String
  let steps: [Step]
  let debugKind: DebugErrorKind?
  /// Hata avı için ayrı, kasıtlı olarak bozuk bir varyant.
  ///
  /// Debugging bölümü dışındaki derslerin kendi kodu doğrudur; içinde
  /// aranacak hata yoktur. Bu alan verilmezse ders kodu kullanılır.
  let debugCode: [String]
  let debugLine: Int
  let expected: String
  let actual: String
  let practices: [PracticeChallenge]
  let assessmentTasks: [AssessmentTask]
  let languageVariants: [CodeVariant]
  let languageComparison: LanguageComparison?
  let transferCode: [String]
  let transferChoices: [String]
  let transferAnswer: String
  let extraQuizzes: [Quiz]
  let estimatedMinutes: Int

  init(
    id: String,
    order: Int,
    section: CurriculumSection,
    topic: String,
    title: String,
    objective: String,
    takeaway: String,
    teaching: LessonTeaching,
    code: [String],
    choices: [String],
    answer: String,
    steps: [Step],
    debugKind: DebugErrorKind? = nil,
    debugCode: [String] = [],
    debugLine: Int = 1,
    expected: String = "",
    actual: String = "",
    practices: [PracticeChallenge] = [],
    assessmentTasks: [AssessmentTask] = [],
    languageVariants: [CodeVariant] = [],
    languageComparison: LanguageComparison? = nil,
    transferCode: [String] = [],
    transferChoices: [String] = [],
    transferAnswer: String = "",
    extraQuizzes: [Quiz] = [],
    estimatedMinutes: Int = 7
  ) {
    self.id = id
    self.order = order
    self.section = section
    self.topic = topic
    self.title = title
    self.objective = objective
    self.takeaway = takeaway
    self.teaching = teaching
    self.code = code
    self.choices = choices
    self.answer = answer
    self.steps = steps
    self.debugKind = debugKind
    self.debugCode = debugCode
    self.debugLine = debugLine
    self.expected = expected
    self.actual = actual
    self.practices = practices
    self.assessmentTasks = assessmentTasks
    self.languageVariants = languageVariants
    self.languageComparison = languageComparison
    self.transferCode = transferCode
    self.transferChoices = transferChoices
    self.transferAnswer = transferAnswer
    self.extraQuizzes = extraQuizzes
    self.estimatedMinutes = estimatedMinutes
  }

  var lesson: XRayLesson {
    let source = numbered(code)
    let outcome = programOutcome
    let transferSource = numbered(transferCode.isEmpty ? code : transferCode)
    let resolvedTransferChoices = transferChoices.isEmpty ? choices : transferChoices
    let resolvedTransferAnswer = transferAnswer.isEmpty ? answer : transferAnswer

    return XRayLesson(
      id: id,
      order: order,
      topic: topic,
      objective: objective,
      takeaway: takeaway,
      title: title,
      question: "Bu kodun sonucu nedir?",
      code: source,
      choices: choices,
      correctAnswer: answer,
      trace: steps.map {
        TraceStep(
          lineNumber: $0.line,
          explanation: $0.note,
          memory: $0.memory,
          output: $0.output,
          callStack: $0.callStack,
          architecture: $0.architecture
        )
      },
      transferChallenges: [
        TransferChallenge(
          prompt: "Aynı zihinsel modeli yeni durumda uygula. Sonuç nedir?",
          code: transferSource,
          choices: resolvedTransferChoices,
          correctAnswer: resolvedTransferAnswer,
          explanation: takeaway
        )
      ] + extraQuizzes.map(challenge),
      estimatedMinutes: estimatedMinutes,
      debugChallenge: debugChallenge(source: source),
      section: section,
      practiceChallenges: practices,
      assessmentTasks: assessmentTasks,
      languageVariants: languageVariants,
      languageComparison: languageComparison,
      programOutcome: outcome,
      teaching: teaching
    )
  }

  private var programOutcome: ProgramOutcome {
    switch debugKind {
    case .syntax:
      .compileError(actual)
    case .runtime, .edgeCase, .optional, .stackTrace:
      .runtimeError(actual)
    case .logic, nil:
      .output(answer)
    }
  }

  private func debugChallenge(source: [CodeLine]) -> DebugChallenge? {
    guard let debugKind else { return nil }
    return DebugChallenge(
      kind: debugKind,
      prompt: "Önce bir hipotez kur, sonra sorunu üreten satırı seç.",
      code: debugCode.isEmpty ? source : numbered(debugCode),
      correctLineNumber: debugLine,
      expected: expected,
      actual: actual.isEmpty ? answer : actual,
      explanation:
        "Beklenen \(expected), gerçek \(actual.isEmpty ? answer : actual). "
        + "\(debugLine). satır incelenmeli."
    )
  }

  private func challenge(for quiz: Quiz) -> TransferChallenge {
    TransferChallenge(
      prompt: "Aynı zihinsel modeli yeni durumda uygula. Sonuç nedir?",
      code: numbered(quiz.code),
      choices: quiz.choices,
      correctAnswer: quiz.answer,
      explanation: quiz.explanation
    )
  }

  private func numbered(_ lines: [String]) -> [CodeLine] {
    lines.enumerated().map { CodeLine(number: $0.offset + 1, text: $0.element) }
  }
}

private let roadmapBlueprints: [RoadmapBlueprint] = [
  RoadmapBlueprint(
    id: "scope",
    order: 8,
    section: .functions,
    topic: "SCOPE",
    title: "Hangi değer görünür?",
    objective: "Yerel ve dış kapsamdaki aynı adlı değerleri ayır.",
    takeaway: "Fonksiyon içindeki yerel değer, yalnızca o fonksiyonun kapsamında görünür.",
    teaching: LessonTeaching(
      whyItMatters:
        "Aynı adı taşıyan iki değer aynı anda bellekte olabilir. Hangisinin okunduğunu bilmeden bir fonksiyonun sonucunu tahmin edemezsin.",
      commonMistake:
        "Fonksiyon içinde aynı adla tanımlanan değerin dıştakini güncellediğini sanmak; oysa yeni ve ayrı bir değer oluşur.",
      realWorldUse:
        "Ekran modelinde geçici hesaplar yerelde tutulur, kalıcı durum dışarıda yaşar. İkisini karıştırmak 'değer neden eski kaldı' hatasının en sık kaynağıdır."
    ),
    code: [
      "let puan = 10",
      "func goster() {",
      "    let puan = 20",
      "    print(puan)",
      "}",
      "goster()",
      "print(puan)",
    ],
    choices: ["20 → 10", "10 → 20", "20 → 20", "10 → 10"],
    answer: "20 → 10",
    steps: [
      Step(
        1, "Dış kapsamda puan tanımlanır. Program bittiğinde bu değer hâlâ burada olacak.",
        memory: ["puan (dış)": "10"],
        callStack: [CallFrame(functionName: "program", locals: ["puan": "10"])]
      ),
      Step(
        6,
        "goster() çağrılır. Yürütme fonksiyonun içine girer ve yeni bir kapsam açılır; henüz boş.",
        memory: ["puan (dış)": "10", "puan (yerel)": "henüz oluşmadı"],
        callStack: [
          CallFrame(functionName: "program", locals: ["puan": "10"]),
          CallFrame(functionName: "goster", locals: [:]),
        ]
      ),
      Step(
        3,
        "Fonksiyonun kendi kapsamında ayrı bir puan oluşur. Dıştaki 10 değişmedi; artık iki puan var.",
        memory: ["puan (dış)": "10", "puan (yerel)": "20"],
        callStack: [
          CallFrame(functionName: "program", locals: ["puan": "10"]),
          CallFrame(functionName: "goster", locals: ["puan": "20"]),
        ]
      ),
      Step(
        4, "print en yakın kapsamdaki puanı görür: yerel değer olan 20 yazılır.",
        memory: ["puan (dış)": "10", "puan (yerel)": "20"],
        output: "20",
        callStack: [
          CallFrame(functionName: "program", locals: ["puan": "10"]),
          CallFrame(functionName: "goster", locals: ["puan": "20"]),
        ]
      ),
      Step(
        5, "Fonksiyon biter. Yerel puan bellekten silinir; geriye yalnızca dış puan kalır.",
        memory: ["puan (dış)": "10"],
        callStack: [CallFrame(functionName: "program", locals: ["puan": "10"])]
      ),
      Step(
        7, "Dış kapsamdaki puan hiç değişmediği için ikinci satır 10 yazar.",
        memory: ["puan (dış)": "10"],
        output: "20 → 10",
        callStack: [CallFrame(functionName: "program", locals: ["puan": "10"])]
      ),
    ],
    debugKind: .logic,
    debugCode: [
      "var toplam = 0",
      "func ekle(_ x: Int) {",
      "    var toplam = 0",
      "    toplam = toplam + x",
      "}",
      "ekle(5)",
      "print(toplam)",
    ],
    debugLine: 3,
    expected: "5",
    actual: "0",
    transferCode: [
      "let ad = \"Dış\"",
      "func yaz() {",
      "    let ad = \"İç\"",
      "    print(ad)",
      "}",
      "yaz()",
      "print(ad)",
    ],
    transferChoices: ["İç → Dış", "Dış → İç", "İç → İç", "Dış → Dış"],
    transferAnswer: "İç → Dış",
    extraQuizzes: [
      Quiz(
        [
          "var sayac = 1", "func artir() {", "    var sayac = 5", "    sayac += 1", "}", "artir()",
          "print(sayac)",
        ],
        choices: ["1", "6", "2", "5"],
        answer: "1",
        explanation:
          "artir kendi yerel sayac'ını 6 yapar; dıştaki sayac hiç değişmediği için 1 kalır."
      ),
      Quiz(
        ["let mesaj = \"dış\"", "func yaz() {", "    print(mesaj)", "}", "yaz()"],
        choices: ["dış", "Boş satır", "Derlenmez", "nil"],
        answer: "dış",
        explanation: "Fonksiyonun kendi mesaj'ı yok; dıştaki kapsamda bulduğu değeri okur."
      ),
    ],
    estimatedMinutes: 8
  ),
  RoadmapBlueprint(
    id: "pure-side-effects",
    order: 9,
    section: .functions,
    topic: "PURE VE SIDE EFFECT",
    title: "Fonksiyon dışarıyı değiştiriyor mu?",
    objective: "Değer döndüren saf fonksiyonla dış durumu değiştiren fonksiyonu ayır.",
    takeaway:
      "Saf fonksiyon girdiden sonuç üretir; side effect dış dünyada gözlenebilir değişiklik yapar.",
    teaching: LessonTeaching(
      whyItMatters:
        "Bir fonksiyonun döndürdüğü değere bakarak güvenli olduğunu söyleyemezsin. Dışarıda neyi değiştirdiği en az sonucu kadar önemlidir.",
      commonMistake:
        "Dönüş değeri olmayan fonksiyonu 'hiçbir şey yapmıyor' saymak; oysa asıl işi dışarıdaki durumu değiştirmektir.",
      realWorldUse:
        "Saf hesaplama fonksiyonları tek satırla test edilir. Ağa giden, dosyaya yazan veya global durumu değiştiren fonksiyonlar için test double gerekir."
    ),
    code: [
      "func ikiKat(_ x: Int) -> Int { x * 2 }",
      "var sayac = 0",
      "func arttir() { sayac += 1 }",
      "print(ikiKat(3))",
      "arttir()",
      "print(sayac)",
    ],
    choices: ["6 → 1", "3 → 0", "6 → 0", "3 → 1"],
    answer: "6 → 1",
    steps: [
      Step(
        2, "Tanımlar yüklenir ve sayac 0 değeriyle bellekte yer alır.",
        memory: ["sayac": "0"],
        callStack: [CallFrame(functionName: "program", locals: ["sayac": "0"])]
      ),
      Step(
        4, "ikiKat(3) çağrılır. Parametre x, çağrıdaki 3 değerini kopyalayarak alır.",
        memory: ["sayac": "0", "x (yerel)": "3"],
        callStack: [
          CallFrame(functionName: "program", locals: ["sayac": "0"]),
          CallFrame(functionName: "ikiKat", locals: ["x": "3"]),
        ]
      ),
      Step(
        1, "Fonksiyon 6 üretip döner. Dışarıda hiçbir şeye dokunmadı: sayac hâlâ 0.",
        memory: ["sayac": "0"],
        output: "6",
        callStack: [CallFrame(functionName: "program", locals: ["sayac": "0"])]
      ),
      Step(
        5, "arttir() çağrılır. Parametre almaz ve değer döndürmez; işi dışarıdaki sayac'tır.",
        memory: ["sayac": "0"],
        callStack: [
          CallFrame(functionName: "program", locals: ["sayac": "0"]),
          CallFrame(functionName: "arttir", locals: [:]),
        ]
      ),
      Step(
        3, "sayac += 1 dış durumu değiştirir. Side effect tam olarak bu satırda oluşur.",
        memory: ["sayac": "1"],
        callStack: [
          CallFrame(functionName: "program", locals: ["sayac": "1"]),
          CallFrame(functionName: "arttir", locals: [:]),
        ]
      ),
      Step(
        6, "Değişmiş dış durum okunur; ikinci çıktı 1 olur.",
        memory: ["sayac": "1"],
        output: "6 → 1",
        callStack: [CallFrame(functionName: "program", locals: ["sayac": "1"])]
      ),
    ],
    practices: [
      PracticeChallenge(
        kind: .concept,
        prompt: "Hangisi side effect örneğidir?",
        choices: ["Yeni değer döndürmek", "Global sayacı değiştirmek", "Parametre okumak"],
        correctAnswer: "Global sayacı değiştirmek",
        explanation: "Global durumdaki değişiklik fonksiyonun dışından gözlenebilir."
      )
    ],
    transferCode: [
      "func kare(_ x: Int) -> Int { x * x }",
      "print(kare(4))",
    ],
    transferChoices: ["4", "8", "16", "2"],
    transferAnswer: "16",
    extraQuizzes: [
      Quiz(
        [
          "var toplam = 5", "func ekle(_ x: Int) -> Int { x + 1 }", "print(ekle(2))",
          "print(toplam)",
        ],
        choices: ["3 → 5", "3 → 6", "2 → 5", "6 → 5"],
        answer: "3 → 5",
        explanation: "ekle yalnızca değer döndürür; toplam'a dokunmadığı için 5 kalır."
      ),
      Quiz(
        ["var log = 0", "func kaydet() { log += 1 }", "kaydet()", "kaydet()", "print(log)"],
        choices: ["2", "0", "1", "Hata"],
        answer: "2",
        explanation: "Her çağrı dış durumu bir arttırır; iki side effect birikir."
      ),
    ],
    estimatedMinutes: 8
  ),
  RoadmapBlueprint(
    id: "map-intro",
    order: 10,
    section: .functions,
    topic: "MAP",
    title: "Her elemanı dönüştür",
    objective: "map ile her girdinin yeni bir çıktıya dönüştüğünü izle.",
    takeaway: "map eleman sayısını korur ve her elemandan yeni bir değer üretir.",
    teaching: LessonTeaching(
      whyItMatters:
        "map'i 'döngünün kısa yazımı' olarak değil, 'her elemana aynı kuralı uygulayıp yeni bir koleksiyon üretme' olarak okursan sonucu tahmin edebilirsin.",
      commonMistake:
        "map'in kaynak diziyi değiştirdiğini sanmak. map yeni bir dizi üretir; kaynak olduğu gibi kalır.",
      realWorldUse:
        "Sunucudan gelen ham kayıtları ekranda gösterilecek modellere çevirmek neredeyse her uygulamada bir map adımıdır."
    ),
    code: [
      "let sayilar = [1, 2, 3]",
      "let ikiler = sayilar.map { $0 * 2 }",
      "print(ikiler)",
      "print(sayilar)",
    ],
    choices: [
      "[2, 4, 6] → [1, 2, 3]", "[2, 4, 6] → [2, 4, 6]", "[1, 2, 3] → [2, 4, 6]", "[2, 4, 6]",
    ],
    answer: "[2, 4, 6] → [1, 2, 3]",
    steps: [
      Step(
        1, "Kaynak dizi üç elemanla bellekte oluşur.",
        memory: ["sayilar": "[1, 2, 3]", "ikiler": "henüz yok"],
        callStack: [CallFrame(functionName: "program", locals: ["sayilar": "[1, 2, 3]"])]
      ),
      Step(
        2, "map ilk elemanı closure'a verir: $0 = 1 olur ve 1 * 2 sonucu yeni diziye eklenir.",
        memory: ["sayilar": "[1, 2, 3]", "ikiler (oluşuyor)": "[2]"],
        callStack: [
          CallFrame(functionName: "program", locals: ["sayilar": "[1, 2, 3]"]),
          CallFrame(functionName: "map closure", locals: ["$0": "1", "sonuç": "2"]),
        ]
      ),
      Step(
        2, "Aynı closure ikinci elemanla yeniden çalışır: $0 = 2 → 4.",
        memory: ["sayilar": "[1, 2, 3]", "ikiler (oluşuyor)": "[2, 4]"],
        callStack: [
          CallFrame(functionName: "program", locals: ["sayilar": "[1, 2, 3]"]),
          CallFrame(functionName: "map closure", locals: ["$0": "2", "sonuç": "4"]),
        ]
      ),
      Step(
        2, "Üçüncü ve son eleman: $0 = 3 → 6. Kaynak dizi bu süre boyunca hiç değişmedi.",
        memory: ["sayilar": "[1, 2, 3]", "ikiler": "[2, 4, 6]"],
        callStack: [
          CallFrame(functionName: "program", locals: ["sayilar": "[1, 2, 3]"]),
          CallFrame(functionName: "map closure", locals: ["$0": "3", "sonuç": "6"]),
        ]
      ),
      Step(
        3, "Yeni dizi yazdırılır. Eleman sayısı kaynakla aynı, değerler dönüşmüş durumda.",
        memory: ["sayilar": "[1, 2, 3]", "ikiler": "[2, 4, 6]"],
        output: "[2, 4, 6]",
        callStack: [CallFrame(functionName: "program", locals: ["ikiler": "[2, 4, 6]"])]
      ),
      Step(
        4,
        "Kaynak dizi yazdırılır ve hiç değişmediği görülür: map dönüştürmez, yeni bir dizi üretir.",
        memory: ["sayilar": "[1, 2, 3]", "ikiler": "[2, 4, 6]", "kaynak değişti mi": "hayır"],
        output: "[2, 4, 6] → [1, 2, 3]",
        callStack: [CallFrame(functionName: "program", locals: ["sayilar": "[1, 2, 3]"])]
      ),
    ],
    transferCode: [
      "let adlar = [\"ada\", \"can\"]",
      "let buyuk = adlar.map { $0.uppercased() }",
      "print(buyuk)",
    ],
    transferChoices: [
      "[\"ada\", \"can\"]", "[\"ADA\", \"CAN\"]", "[\"ADA\"]", "[\"Ada\", \"Can\"]",
    ],
    transferAnswer: "[\"ADA\", \"CAN\"]",
    extraQuizzes: [
      Quiz(
        ["let sayilar = [3, 4]", "let kareler = sayilar.map { $0 * $0 }", "print(kareler)"],
        choices: ["[9, 16]", "[6, 8]", "[3, 4]", "25"],
        answer: "[9, 16]",
        explanation: "Her eleman kendisiyle çarpılır; eleman sayısı korunur."
      ),
      Quiz(
        [
          "let harfler = [\"a\", \"b\", \"c\"]", "let sonuc = harfler.map { $0 + \"!\" }",
          "print(sonuc.count)",
        ],
        choices: ["3", "1", "6", "0"],
        answer: "3",
        explanation: "map eleman sayısını değiştirmez; üç elemandan üç eleman üretir."
      ),
    ],
  ),
  RoadmapBlueprint(
    id: "filter-intro",
    order: 11,
    section: .functions,
    topic: "FILTER",
    title: "Yalnızca uyanları seç",
    objective: "filter koşulunu geçen elemanların yeni koleksiyona taşındığını gör.",
    takeaway: "filter değerleri değiştirmez; koşula uymayanları dışarıda bırakır.",
    teaching: LessonTeaching(
      whyItMatters:
        "filter sonucunu tahmin etmek, koşulu her eleman için tek tek çalıştırıp doğru/yanlış cevabını yazabilmek demektir.",
      commonMistake:
        "Sınır değerini yanlış saymak: `> 2` koşulunda 2'nin kendisi elenir, `>= 2` olsaydı kalırdı.",
      realWorldUse:
        "Arama sonuçlarını daraltmak, okunmamış bildirimleri ayıklamak ve süresi geçmiş kayıtları elemek hep filter adımıdır."
    ),
    code: [
      "let sayilar = [1, 2, 3, 4]",
      "let buyukler = sayilar.filter { $0 > 2 }",
      "print(buyukler)",
      "print(buyukler.count)",
    ],
    choices: ["[3, 4] → 2", "[3, 4] → 4", "[1, 2] → 2", "[3, 4]"],
    answer: "[3, 4] → 2",
    steps: [
      Step(
        1, "Kaynak dizi dört elemanla oluşur.",
        memory: ["sayilar": "[1, 2, 3, 4]", "buyukler": "henüz yok"],
        callStack: [CallFrame(functionName: "program", locals: ["sayilar": "[1, 2, 3, 4]"])]
      ),
      Step(
        2, "İlk eleman denenir: 1 > 2 yanlış. Eleman yeni diziye alınmaz.",
        memory: ["sayilar": "[1, 2, 3, 4]", "buyukler (oluşuyor)": "[]"],
        callStack: [
          CallFrame(functionName: "program", locals: ["sayilar": "[1, 2, 3, 4]"]),
          CallFrame(functionName: "filter closure", locals: ["$0": "1", "koşul": "yanlış"]),
        ]
      ),
      Step(
        2, "Sınır değeri: 2 > 2 yanlış. Eşitlik koşulu geçmediği için 2 de elenir.",
        memory: ["sayilar": "[1, 2, 3, 4]", "buyukler (oluşuyor)": "[]"],
        callStack: [
          CallFrame(functionName: "program", locals: ["sayilar": "[1, 2, 3, 4]"]),
          CallFrame(functionName: "filter closure", locals: ["$0": "2", "koşul": "yanlış"]),
        ]
      ),
      Step(
        2, "3 > 2 doğru. Eleman değeri değiştirilmeden yeni diziye taşınır.",
        memory: ["sayilar": "[1, 2, 3, 4]", "buyukler (oluşuyor)": "[3]"],
        callStack: [
          CallFrame(functionName: "program", locals: ["sayilar": "[1, 2, 3, 4]"]),
          CallFrame(functionName: "filter closure", locals: ["$0": "3", "koşul": "doğru"]),
        ]
      ),
      Step(
        2, "4 > 2 doğru. Seçim biter; sonuç iki elemanlı.",
        memory: ["sayilar": "[1, 2, 3, 4]", "buyukler": "[3, 4]"],
        callStack: [
          CallFrame(functionName: "program", locals: ["sayilar": "[1, 2, 3, 4]"]),
          CallFrame(functionName: "filter closure", locals: ["$0": "4", "koşul": "doğru"]),
        ]
      ),
      Step(
        3, "map'ten farkı burada görünür: değerler aynı kaldı, yalnızca eleman sayısı azaldı.",
        memory: ["sayilar": "[1, 2, 3, 4]", "buyukler": "[3, 4]"],
        output: "[3, 4]",
        callStack: [CallFrame(functionName: "program", locals: ["buyukler": "[3, 4]"])]
      ),
      Step(
        4, "Eleman sayısı dörtten ikiye düştü. map olsaydı bu sayı dört kalırdı.",
        memory: ["kaynak sayısı": "4", "sonuç sayısı": "2", "buyukler": "[3, 4]"],
        output: "[3, 4] → 2",
        callStack: [CallFrame(functionName: "program", locals: ["buyukler.count": "2"])]
      ),
    ],
    transferCode: [
      "let adlar = [\"Ada\", \"Can\", \"Ece\"]",
      "let kisa = adlar.filter { $0.count == 3 }",
      "print(kisa)",
    ],
    transferChoices: [
      "[\"Ada\", \"Can\", \"Ece\"]", "[\"Ada\", \"Can\"]", "[\"Ece\"]", "[]",
    ],
    transferAnswer: "[\"Ada\", \"Can\", \"Ece\"]",
    extraQuizzes: [
      Quiz(
        [
          "let sayilar = [5, 10, 15]", "let kucukler = sayilar.filter { $0 < 10 }",
          "print(kucukler)",
        ],
        choices: ["[5]", "[5, 10]", "[10, 15]", "[]"],
        answer: "[5]",
        explanation: "10 < 10 yanlış olduğu için sınır değeri elenir; yalnızca 5 kalır."
      ),
      Quiz(
        ["let sayilar = [1, 2, 3]", "let hepsi = sayilar.filter { $0 > 0 }", "print(hepsi.count)"],
        choices: ["3", "0", "1", "6"],
        answer: "3",
        explanation: "Koşulu bütün elemanlar geçtiği için hiçbiri elenmez."
      ),
    ],
  ),
  RoadmapBlueprint(
    id: "arrays-index",
    order: 12,
    section: .collections,
    topic: "ARRAY VE INDEX",
    title: "Sıra sıfırdan başlar",
    objective: "Array elemanına index ile güvenle eriş ve son elemanı doğru hesapla.",
    takeaway:
      "Array index'i sıfırdan başlar; bu yüzden son elemanın index'i eleman sayısının bir eksiğidir.",
    teaching: LessonTeaching(
      whyItMatters:
        "Index'i sıfırdan saymak bir kural değil, dizinin bellekteki yerleşiminin sonucudur. Bunu bilmeden son elemana erişen her kod çökme riski taşır.",
      commonMistake:
        "Son elemana `renkler[renkler.count]` ile ulaşmaya çalışmak. O index dizinin dışındadır ve program çöker.",
      realWorldUse:
        "Listenin son satırını seçmek, sayfalamada son sayfayı bulmak ve döngü sınırı yazmak hep count - 1 hesabına dayanır."
    ),
    code: [
      "let renkler = [\"Kırmızı\", \"Mavi\", \"Yeşil\"]",
      "let sonIndex = renkler.count - 1",
      "print(renkler[1])",
      "print(renkler[sonIndex])",
    ],
    choices: ["Mavi → Yeşil", "Kırmızı → Yeşil", "Mavi → Mavi", "Kırmızı → Mavi"],
    answer: "Mavi → Yeşil",
    steps: [
      Step(
        1, "Dizi bellekte sırayla yerleşir. Sayma sıfırdan başlar: 0, 1, 2.",
        memory: [
          "renkler[0]": "\"Kırmızı\"", "renkler[1]": "\"Mavi\"", "renkler[2]": "\"Yeşil\"",
        ]
      ),
      Step(
        2, "count üç eleman sayar; son index bunun bir eksiği, yani 2 olur.",
        memory: [
          "renkler[0]": "\"Kırmızı\"", "renkler[1]": "\"Mavi\"", "renkler[2]": "\"Yeşil\"",
          "renkler.count": "3", "sonIndex": "2",
        ]
      ),
      Step(
        3, "renkler[1] 'ikinci kutu' demek değildir; index'i 1 olan kutuyu okur.",
        memory: ["okunan index": "1", "okunan değer": "\"Mavi\"", "sonIndex": "2"],
        output: "Mavi"
      ),
      Step(
        4,
        "sonIndex 2 olduğu için son eleman okunur. count kullanılsaydı 3'e erişilir ve program çökerdi.",
        memory: ["okunan index": "2", "okunan değer": "\"Yeşil\"", "sonIndex": "2"],
        output: "Mavi → Yeşil"
      ),
    ],
    debugKind: .logic,
    debugCode: [
      "let renkler = [\"Kırmızı\", \"Mavi\", \"Yeşil\"]",
      "func ikinciRengi(_ liste: [String]) -> String {",
      "    return liste[2]",
      "}",
      "print(ikinciRengi(renkler))",
    ],
    debugLine: 3,
    expected: "Mavi",
    actual: "Yeşil",
    practices: [
      PracticeChallenge(
        kind: .concept,
        prompt: "Üç elemanlı bir dizide son elemanın index'i kaçtır?",
        choices: ["2", "3", "1", "0"],
        correctAnswer: "2",
        explanation: "Sayma sıfırdan başladığı için son index eleman sayısının bir eksiğidir."
      ),
      PracticeChallenge(
        kind: .naming,
        prompt: "Kullanıcı adlarını tutan bir dizi için en açıklayıcı ad hangisi?",
        choices: ["kullaniciAdlari", "arr", "liste", "d"],
        correctAnswer: "kullaniciAdlari",
        explanation: "İyi bir ad neyin saklandığını okuyana söyler; tür bilgisini tekrarlamaz."
      ),
    ],
    transferCode: [
      "let harfler = [\"A\", \"B\", \"C\", \"D\"]",
      "print(harfler[0])",
      "print(harfler[harfler.count - 1])",
    ],
    transferChoices: ["A → D", "A → C", "B → D", "B → C"],
    transferAnswer: "A → D",
    extraQuizzes: [
      Quiz(
        ["let sayilar = [10, 20, 30]", "print(sayilar[sayilar.count - 2])"],
        choices: ["20", "30", "10", "Hata"],
        answer: "20",
        explanation: "count 3, iki eksiği 1; index 1 ikinci elemandır."
      ),
      Quiz(
        ["let sayilar = [10, 20, 30]", "print(sayilar[sayilar.count])"],
        choices: ["Hata", "30", "nil", "0"],
        answer: "Hata",
        explanation: "Geçerli index'ler 0, 1 ve 2; count olan 3 dizinin dışındadır."
      ),
    ],
  ),
  RoadmapBlueprint(
    id: "dictionary-key",
    order: 13,
    section: .collections,
    topic: "DICTIONARY VE KEY",
    title: "Değeri anahtarla bul",
    objective: "Anlamlı bir key ile değere eriş ve olmayan key'in ne döndürdüğünü gör.",
    takeaway:
      "Dictionary'de değer konumla değil key ile bulunur; olmayan key hata değil, nil döndürür.",
    teaching: LessonTeaching(
      whyItMatters:
        "Dictionary aramasının sonucu her zaman 'belki var' anlamındadır. Bu belirsizliği görmezden gelen kod, veri eksik geldiği gün çöker.",
      commonMistake:
        "Her aramaya `!` koyup değerin kesin var olduğunu varsaymak. Key yoksa bu satır programı düşürür.",
      realWorldUse:
        "Ayar okuma, çeviri sözlüğü ve API cevabındaki alanlar hep key ile aranır ve hepsinde 'ya yoksa' sorusunun cevabı gerekir."
    ),
    code: [
      "let baskentler = [\"TR\": \"Ankara\", \"FR\": \"Paris\"]",
      "print(baskentler[\"TR\"]!)",
      "let bilinmeyen = baskentler[\"DE\"]",
      "print(bilinmeyen == nil)",
    ],
    choices: ["Ankara → true", "Ankara → false", "Paris → true", "Ankara → Hata"],
    answer: "Ankara → true",
    steps: [
      Step(
        1, "İki çift bellekte tutulur. Sıra değil, key önemlidir.",
        memory: ["baskentler[\"TR\"]": "\"Ankara\"", "baskentler[\"FR\"]": "\"Paris\""]
      ),
      Step(
        2, "\"TR\" key'i aranır ve bulunur. `!` işareti 'değerin var olduğuna eminim' demektir.",
        memory: ["aranan key": "\"TR\"", "bulunan": "\"Ankara\""],
        output: "Ankara"
      ),
      Step(
        3, "\"DE\" key'i sözlükte yok. Program çökmez; arama sonucu nil olur.",
        memory: ["aranan key": "\"DE\"", "bulunan": "nil", "bilinmeyen": "nil"]
      ),
      Step(
        4, "Sonuç nil ile karşılaştırılır. Burada `!` kullanılsaydı program bu satırda çökerdi.",
        memory: ["bilinmeyen": "nil", "bilinmeyen == nil": "true"],
        output: "Ankara → true"
      ),
    ],
    practices: [
      PracticeChallenge(
        kind: .concept,
        prompt: "Sözlükte olmayan bir key arandığında ne olur?",
        choices: ["nil döner", "Program çöker", "Boş metin döner", "Sıfır döner"],
        correctAnswer: "nil döner",
        explanation: "Arama sonucu optional'dır; yokluk hata değil, ayrı bir durumdur."
      )
    ],
    transferCode: [
      "let puanlar = [\"Ada\": 9, \"Can\": 7]",
      "print(puanlar[\"Can\"]!)",
      "print(puanlar[\"Ece\"] == nil)",
    ],
    transferChoices: ["7 → true", "9 → true", "7 → false", "7 → Hata"],
    transferAnswer: "7 → true",
    extraQuizzes: [
      Quiz(
        ["let stok = [\"kalem\": 4]", "print(stok[\"defter\"] ?? 0)"],
        choices: ["0", "4", "nil", "Hata"],
        answer: "0",
        explanation: "Key bulunamaz, arama nil döner ve ?? varsayılan değeri verir."
      ),
      Quiz(
        ["let stok = [\"kalem\": 4]", "print(stok[\"defter\"]!)"],
        choices: ["Hata", "0", "nil", "4"],
        answer: "Hata",
        explanation: "Olmayan key'in sonucu nil'dir; `!` bunu açmaya çalışınca program durur."
      ),
    ],
  ),
  RoadmapBlueprint(
    id: "collections-challenge",
    order: 14,
    section: .collections,
    topic: "KOLEKSİYON MEYDAN OKUMASI",
    title: "Seç, dönüştür, topla",
    objective: "Array, filter ve reduce akışını birlikte takip et.",
    takeaway: "Koleksiyon zincirini her ara sonucu ayrı yazarak okuyabilirsin.",
    teaching: LessonTeaching(
      whyItMatters:
        "Zincirlenmiş koleksiyon kodu tek bakışta anlaşılmaz. Her adımın ara sonucunu yazmak, uzun zinciri okunabilir hale getiren tek güvenilir yöntemdir.",
      commonMistake:
        "Zinciri tek bir işlem sanıp filter'ın elediği elemanların reduce'a hâlâ girdiğini düşünmek.",
      realWorldUse:
        "Sepet toplamı, aylık rapor ve istatistik ekranları neredeyse her zaman filtrele-dönüştür-topla zinciriyle hesaplanır."
    ),
    code: [
      "let sayilar = [1, 2, 3, 4]",
      "let ciftler = sayilar.filter { $0 % 2 == 0 }",
      "let toplam = ciftler.reduce(0, +)",
      "print(toplam)",
    ],
    choices: ["4", "6", "10", "2"],
    answer: "6",
    steps: [
      Step(
        1, "Zincir başlamadan önceki tek gerçek: dört elemanlı kaynak dizi.",
        memory: ["sayilar": "[1, 2, 3, 4]"]
      ),
      Step(
        2, "filter tek tek dener: 1 ve 3 kalanlı olduğu için elenir, 2 alınır.",
        memory: ["sayilar": "[1, 2, 3, 4]", "ciftler (oluşuyor)": "[2]"],
        callStack: [
          CallFrame(functionName: "program", locals: ["sayilar": "[1, 2, 3, 4]"]),
          CallFrame(functionName: "filter closure", locals: ["$0": "2", "koşul": "doğru"]),
        ]
      ),
      Step(
        2,
        "4 de kalansız bölünür. Seçim biter ve elenen elemanlar zincirin geri kalanına hiç girmez.",
        memory: ["sayilar": "[1, 2, 3, 4]", "ciftler": "[2, 4]"],
        callStack: [
          CallFrame(functionName: "program", locals: ["sayilar": "[1, 2, 3, 4]"]),
          CallFrame(functionName: "filter closure", locals: ["$0": "4", "koşul": "doğru"]),
        ]
      ),
      Step(
        3, "reduce 0 ile başlar ve ilk elemanı ekler: 0 + 2 = 2.",
        memory: ["ciftler": "[2, 4]", "biriken": "2"],
        callStack: [
          CallFrame(functionName: "program", locals: ["ciftler": "[2, 4]"]),
          CallFrame(functionName: "reduce", locals: ["biriken": "2", "eleman": "2"]),
        ]
      ),
      Step(
        3, "İkinci eleman eklenir: 2 + 4 = 6. Biriken değer sonucu olur.",
        memory: ["ciftler": "[2, 4]", "biriken": "6", "toplam": "6"],
        callStack: [
          CallFrame(functionName: "program", locals: ["ciftler": "[2, 4]"]),
          CallFrame(functionName: "reduce", locals: ["biriken": "6", "eleman": "4"]),
        ]
      ),
      Step(
        4, "Yalnızca son değer yazdırılır; ara sonuçlar bellekte kalır ama görünmez.",
        memory: ["ciftler": "[2, 4]", "toplam": "6"],
        output: "6"
      ),
    ],
    practices: [
      PracticeChallenge(
        kind: .concept,
        prompt: "filter'ın elediği elemanlar reduce'a girer mi?",
        choices: [
          "Hayır, zincirden çıkarlar", "Evet, hepsi girer", "Yalnızca ilki girer",
          "Reduce onları sıfır sayar",
        ],
        correctAnswer: "Hayır, zincirden çıkarlar",
        explanation: "Her adım bir sonrakine yalnızca kendi sonucunu verir."
      )
    ],
    transferCode: [
      "let sayilar = [2, 3, 5]",
      "let toplam = sayilar.reduce(0, +)",
      "print(toplam)",
    ],
    transferChoices: ["5", "8", "10", "0"],
    transferAnswer: "10",
    extraQuizzes: [
      Quiz(
        [
          "let sayilar = [1, 2, 3, 4, 5]", "let tekler = sayilar.filter { $0 % 2 == 1 }",
          "let toplam = tekler.reduce(0, +)", "print(toplam)",
        ],
        choices: ["9", "15", "6", "3"],
        answer: "9",
        explanation: "Tekler [1, 3, 5]; toplamı 9'dur. Elenen çiftler reduce'a hiç girmez."
      ),
      Quiz(
        ["let sayilar: [Int] = []", "let toplam = sayilar.reduce(0, +)", "print(toplam)"],
        choices: ["0", "Hata", "nil", "1"],
        answer: "0",
        explanation: "Boş koleksiyonda reduce başlangıç değerini döndürür; çökme olmaz."
      ),
    ],
    estimatedMinutes: 9
  ),
  RoadmapBlueprint(
    id: "class-instance",
    order: 15,
    section: .objects,
    topic: "CLASS VE INSTANCE",
    title: "Şablondan nesneye",
    objective: "Class tanımıyla ondan üretilen instance'ı ayır.",
    takeaway: "Class şablondur; instance bellekte o şablona göre oluşturulan somut nesnedir.",
    teaching: LessonTeaching(
      whyItMatters:
        "Class satırını okumak bellekte bir şey oluşturmaz. Nesnenin ne zaman var olduğunu bilmeden 'değer neden hâlâ eski' sorusunu cevaplayamazsın.",
      commonMistake:
        "Class tanımındaki başlangıç değerini tüm nesnelerin paylaştığı tek bir değer sanmak. Her instance kendi kopyasını alır.",
      realWorldUse:
        "Kullanıcı, sipariş ve ayar gibi kavramlar bir kez class olarak tanımlanır, uygulama boyunca yüzlerce instance üretilir."
    ),
    code: [
      "class Kutu { var deger = 5 }",
      "let kutu = Kutu()",
      "let ikinci = Kutu()",
      "kutu.deger = 9",
      "print(ikinci.deger)",
    ],
    choices: ["5", "9", "0", "nil"],
    answer: "5",
    steps: [
      Step(
        1,
        "Şablon tanımlanır. Bu satır bellekte hiçbir nesne oluşturmaz; yalnızca 'Kutu neye benzer' bilgisidir.",
        memory: ["Kutu": "şablon (henüz nesne yok)"]
      ),
      Step(
        2, "Kutu() çağrısı şablonu kullanarak somut bir nesne üretir ve deger alanı 5 ile başlar.",
        memory: ["Kutu": "şablon", "kutu.deger": "5"],
        architecture: objectSnapshot(
          className: "Kutu",
          instanceName: "kutu",
          valueLabel: "deger = 5"
        )
      ),
      Step(
        3,
        "İkinci çağrı ayrı bir nesne üretir. Şablondaki 5 paylaşılmaz; her nesne kendi kopyasını alır.",
        memory: ["kutu.deger": "5", "ikinci.deger": "5", "bellekteki nesne": "2"]
      ),
      Step(
        4, "Yalnızca ilk nesnenin alanı değişir. İkincisine bu satırda dokunulmadı.",
        memory: ["kutu.deger": "9", "ikinci.deger": "5", "bellekteki nesne": "2"],
        architecture: objectSnapshot(
          className: "Kutu",
          instanceName: "kutu",
          valueLabel: "deger = 9"
        )
      ),
      Step(
        5, "Okunan değer şablonun değil, o nesnenin kendi alanıdır: ikinci hâlâ 5.",
        memory: ["kutu.deger": "9", "ikinci.deger": "5"],
        output: "5",
        architecture: objectSnapshot(
          className: "Kutu",
          instanceName: "ikinci",
          valueLabel: "deger = 5"
        )
      ),
    ],
    transferCode: [
      "class Lamba { var acik = true }",
      "let lamba = Lamba()",
      "print(lamba.acik)",
    ],
    transferChoices: ["true", "false", "Lamba", "nil"],
    transferAnswer: "true",
    extraQuizzes: [
      Quiz(
        [
          "class Kutu { var deger = 5 }", "let a = Kutu()", "let b = Kutu()", "a.deger = 9",
          "print(b.deger)",
        ],
        choices: ["5", "9", "0", "Hata"],
        answer: "5",
        explanation: "Her instance şablondan kendi kopyasını alır; a'daki değişiklik b'ye geçmez."
      ),
      Quiz(
        ["class Sepet { var adet = 0 }", "let sepet = Sepet()", "print(sepet.adet)"],
        choices: ["0", "nil", "Sepet", "Hata"],
        answer: "0",
        explanation: "Instance oluştuğunda alan şablondaki başlangıç değeriyle gelir."
      ),
    ],
  ),
  RoadmapBlueprint(
    id: "property-method",
    order: 16,
    section: .objects,
    topic: "PROPERTY VE METHOD",
    title: "Nesne kendi verisini değiştirir",
    objective: "Bir method çağrısının instance property’sini nasıl değiştirdiğini izle.",
    takeaway: "Property nesnenin durumudur; method bu durum üzerinde davranış uygular.",
    teaching: LessonTeaching(
      whyItMatters:
        "Method çağrısı ekranda hiçbir şey göstermeyebilir ama nesnenin içindeki değeri kalıcı olarak değiştirir. Bu görünmez değişimi izleyemezsen sonucu tahmin edemezsin.",
      commonMistake:
        "Method'un dönüş değeri olmadığı için 'bir şey yapmadığını' düşünmek; oysa değişiklik nesnenin içinde kalır.",
      realWorldUse:
        "Sepete ürün eklemek, okundu işaretlemek ve sayaç arttırmak hep nesnenin kendi durumunu değiştiren method çağrılarıdır."
    ),
    code: [
      "class Sayac {",
      "    var deger = 0",
      "    func arttir() { deger += 1 }",
      "}",
      "let sayac = Sayac()",
      "sayac.arttir()",
      "print(sayac.deger)",
    ],
    choices: ["0", "1", "2", "Hata"],
    answer: "1",
    steps: [
      Step(
        5, "Sayac() çağrılır; nesne oluşur ve deger alanı 0 ile başlar.",
        memory: ["sayac": "Sayac nesnesi", "sayac.deger": "0"],
        callStack: [CallFrame(functionName: "program", locals: ["sayac.deger": "0"])],
        architecture: objectSnapshot(
          className: "Sayac",
          instanceName: "sayac",
          valueLabel: "deger = 0"
        )
      ),
      Step(
        6, "arttir() çağrılır. Yürütme method gövdesine geçer; henüz hiçbir değer değişmedi.",
        memory: ["sayac.deger": "0"],
        callStack: [
          CallFrame(functionName: "program", locals: ["sayac.deger": "0"]),
          CallFrame(functionName: "sayac.arttir", locals: [:]),
        ]
      ),
      Step(
        3,
        "deger += 1 nesnenin kendi alanını değiştirir. Değişiklik method bittikten sonra da kalıcıdır.",
        memory: ["sayac.deger": "1"],
        callStack: [
          CallFrame(functionName: "program", locals: ["sayac.deger": "1"]),
          CallFrame(functionName: "sayac.arttir", locals: [:]),
        ],
        architecture: objectSnapshot(
          className: "Sayac",
          instanceName: "sayac",
          valueLabel: "deger = 1"
        )
      ),
      Step(
        7, "Method dönüş değeri üretmedi ama bıraktığı iz okunuyor.",
        memory: ["sayac": "Sayac nesnesi", "sayac.deger": "1"],
        output: "1",
        callStack: [CallFrame(functionName: "program", locals: ["sayac.deger": "1"])],
        architecture: objectSnapshot(
          className: "Sayac",
          instanceName: "sayac",
          valueLabel: "deger = 1"
        )
      ),
    ],
    transferCode: [
      "let sayac = Sayac()",
      "sayac.arttir()",
      "sayac.arttir()",
      "print(sayac.deger)",
    ],
    transferChoices: ["0", "1", "2", "3"],
    transferAnswer: "2",
    extraQuizzes: [
      Quiz(
        [
          "class Kova {", "    var su = 10", "    func bosalt() { su = 0 }", "}",
          "let kova = Kova()", "kova.bosalt()", "print(kova.su)",
        ],
        choices: ["0", "10", "nil", "Hata"],
        answer: "0",
        explanation: "Method dönüş değeri üretmez ama nesnenin alanını kalıcı olarak değiştirir."
      ),
      Quiz(
        [
          "class Kova {", "    var su = 10", "    func bosalt() { su = 0 }", "}",
          "let kova = Kova()", "print(kova.su)",
        ],
        choices: ["10", "0", "nil", "Hata"],
        answer: "10",
        explanation: "Method çağrılmadığı için alan başlangıç değerinde kalır."
      ),
    ],
  ),
  RoadmapBlueprint(
    id: "initializer",
    order: 17,
    section: .objects,
    topic: "INITIALIZER",
    title: "Nesne ilk değerini alır",
    objective: "Initializer argümanının yeni instance'ın property’sine taşınmasını izle.",
    takeaway: "Initializer, instance kullanılmadan önce gerekli başlangıç durumunu kurar.",
    teaching: LessonTeaching(
      whyItMatters:
        "Initializer, nesnenin eksik durumda kullanılmasını engelleyen tek noktadır. Buradan çıkan her nesne kullanılmaya hazırdır.",
      commonMistake:
        "`self.ad = ad` satırındaki iki adı aynı şey sanmak. Soldaki nesnenin alanı, sağdaki initializer'a gelen parametredir.",
      realWorldUse:
        "Bir ekran modelinin hangi servisle çalışacağı, bir siparişin hangi kullanıcıya ait olduğu genelde initializer'da verilir."
    ),
    code: [
      "class Kullanici {",
      "    let ad: String",
      "    init(ad: String) { self.ad = ad }",
      "}",
      "let kisi = Kullanici(ad: \"Ada\")",
      "print(kisi.ad)",
    ],
    choices: ["Kullanici", "ad", "Ada", "Boş metin"],
    answer: "Ada",
    steps: [
      Step(
        2,
        "Şablon 'her Kullanici bir ad taşır' der ama değeri vermez. Alan şu an bir söz, veri değil.",
        memory: ["Kullanici.ad": "değeri initializer verecek"]
      ),
      Step(
        5, "Kullanici(ad: \"Ada\") çağrılır. Argüman, initializer'ın ad parametresine kopyalanır.",
        memory: ["ad (parametre)": "\"Ada\"", "kisi": "henüz kurulmadı"],
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "Kullanici.init", locals: ["ad": "\"Ada\""]),
        ]
      ),
      Step(
        3,
        "self.ad soldaki nesnenin alanı, ad sağdaki parametredir. Değer bu satırda nesneye yazılır.",
        memory: ["ad (parametre)": "\"Ada\"", "kisi.ad": "\"Ada\""],
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "Kullanici.init", locals: ["ad": "\"Ada\""]),
        ],
        architecture: objectSnapshot(
          className: "Kullanici",
          instanceName: "kisi",
          valueLabel: "ad = Ada"
        )
      ),
      Step(
        6, "Initializer bittiği için nesne eksiksiz. Ancak bu noktadan sonra alan okunabilir.",
        memory: ["kisi.ad": "\"Ada\""],
        output: "Ada",
        callStack: [CallFrame(functionName: "program", locals: ["kisi.ad": "\"Ada\""])],
        architecture: objectSnapshot(
          className: "Kullanici",
          instanceName: "kisi",
          valueLabel: "ad = Ada"
        )
      ),
    ],
    practices: [
      PracticeChallenge(
        kind: .naming,
        prompt: "Bir siparişin ürün sayısını tutan alan için en iyi ad hangisi?",
        choices: ["adet", "x", "sayi2", "veri"],
        correctAnswer: "adet",
        explanation: "Ad, alanın ne saydığını çağrı noktasında açıklamalı."
      )
    ],
    transferCode: [
      "let kisi = Kullanici(ad: \"Can\")",
      "print(kisi.ad)",
    ],
    transferChoices: ["Ada", "Can", "Kullanici", "Boş metin"],
    transferAnswer: "Can",
    extraQuizzes: [
      Quiz(
        [
          "struct Urun {", "    let ad: String", "    let adet: Int", "}",
          "let urun = Urun(ad: \"Kalem\", adet: 3)", "print(urun.adet)",
        ],
        choices: ["3", "Kalem", "0", "Hata"],
        answer: "3",
        explanation: "Her argüman kendi adındaki alana yazılır; adet 3 değerini alır."
      ),
      Quiz(
        ["class Oda {", "    var kisi: Int", "    init() { kisi = 2 }", "}", "print(Oda().kisi)"],
        choices: ["2", "0", "nil", "Hata"],
        answer: "2",
        explanation: "Argüman almayan initializer da alanı kullanılmadan önce kurmak zorundadır."
      ),
    ],
  ),
  RoadmapBlueprint(
    id: "value-reference",
    order: 18,
    section: .objects,
    topic: "VALUE VE REFERENCE",
    title: "Kopya mı, aynı nesne mi?",
    objective: "Struct kopyasının bağımsız değer taşıdığını gözlemle.",
    takeaway: "Struct atamada değeri kopyalar; bir kopyadaki değişiklik diğerini değiştirmez.",
    teaching: LessonTeaching(
      whyItMatters:
        "Atama satırı bazen kopya, bazen aynı nesneye ikinci bir isim üretir. Hangisi olduğunu bilmeden bir değişikliğin nereye yayılacağını kestiremezsin.",
      commonMistake:
        "`b = a` satırını her zaman 'aynı şeyi işaret etsinler' diye okumak. Struct'ta bu satır bağımsız bir kopya üretir.",
      realWorldUse:
        "Bir formu düzenlerken taslak kopya üzerinde çalışıp iptalde orijinali korumak tam olarak bu davranışa dayanır."
    ),
    code: [
      "struct Nokta { var x: Int }",
      "let a = Nokta(x: 1)",
      "var b = a",
      "b.x = 9",
      "print(a.x)",
    ],
    choices: ["1", "9", "Hata", "10"],
    answer: "1",
    steps: [
      Step(
        2, "İlk nokta oluşur. Bellekte tek bir değer var.",
        memory: ["a.x": "1"]
      ),
      Step(
        3,
        "b = a satırı struct olduğu için değeri kopyalar. Artık bellekte birbirinden bağımsız iki nokta var.",
        memory: ["a.x": "1", "b.x": "1"],
        architecture: valueCopySnapshot()
      ),
      Step(
        4, "Yalnızca kopyanın alanı değişir. a'ya bu satırda hiç dokunulmadı.",
        memory: ["a.x": "1", "b.x": "9"],
        architecture: valueCopySnapshot()
      ),
      Step(
        5, "a hâlâ ilk değerini taşıyor. Class olsaydı ikisi aynı nesne olur ve 9 yazılırdı.",
        memory: ["a.x": "1", "b.x": "9"],
        output: "1",
        architecture: valueCopySnapshot()
      ),
    ],
    debugKind: .logic,
    debugCode: [
      "struct Ayar { var ses: Int }",
      "func sessizeAl(_ ayar: Ayar) {",
      "    var kopya = ayar",
      "    kopya.ses = 0",
      "}",
      "var ayar = Ayar(ses: 7)",
      "sessizeAl(ayar)",
      "print(ayar.ses)",
    ],
    debugLine: 3,
    expected: "0",
    actual: "7",
    transferCode: [
      "var ilk = Nokta(x: 2)",
      "var ikinci = ilk",
      "ikinci.x = 7",
      "print(ilk.x)",
    ],
    transferChoices: ["2", "7", "Hata", "9"],
    transferAnswer: "2",
    extraQuizzes: [
      Quiz(
        ["class Kutu { var x = 1 }", "let a = Kutu()", "let b = a", "b.x = 9", "print(a.x)"],
        choices: ["9", "1", "Hata", "0"],
        answer: "9",
        explanation:
          "Class referans taşır: a ve b aynı nesneyi işaret eder, değişiklik ikisinde de görünür."
      ),
      Quiz(
        ["struct Kutu { var x = 1 }", "var a = Kutu()", "var b = a", "b.x = 9", "print(b.x)"],
        choices: ["9", "1", "Hata", "0"],
        answer: "9",
        explanation: "Kopya bağımsızdır; değiştirilen kopyanın kendi değeri okunur."
      ),
    ],
    estimatedMinutes: 8
  ),
  RoadmapBlueprint(
    id: "composition",
    order: 19,
    section: .objects,
    topic: "COMPOSITION",
    title: "Nesne başka nesneye sahip olur",
    objective: "Bir nesnenin davranışı başka bir nesneyi içererek kazanmasını gör.",
    takeaway: "Composition, büyük davranışı küçük ve bağımsız parçaları birleştirerek kurar.",
    teaching: LessonTeaching(
      whyItMatters:
        "Nokta ile bağlanan uzun ifadeler korkutucu görünür. Sahiplik zincirini soldan sağa okumayı öğrenirsen her biri tek tek çözülür.",
      commonMistake:
        "İçerilen parçanın dıştaki türün bir çeşidi olduğunu sanmak. Araba bir Motor değildir; bir Motor'a sahiptir.",
      realWorldUse:
        "Ekran modelinin bir servise, servisin bir veri deposuna sahip olması aynı kalıptır ve her parçayı ayrı ayrı değiştirilebilir kılar."
    ),
    code: [
      "struct Motor { let tur = \"Elektrik\" }",
      "struct Araba { let motor: Motor }",
      "let araba = Araba(motor: Motor())",
      "print(araba.motor.tur)",
    ],
    choices: ["Araba", "Motor", "Elektrik", "Benzin"],
    answer: "Elektrik",
    steps: [
      Step(
        3,
        "En içteki parça önce üretilir: Motor() kendi başına var olabilen bağımsız bir nesnedir.",
        memory: ["motor.tur": "\"Elektrik\""]
      ),
      Step(
        3,
        "Üretilen motor, Araba'nın motor alanına yerleştirilir. Araba motoru içerir, motor olmaz.",
        memory: ["araba.motor": "Motor nesnesi", "araba.motor.tur": "\"Elektrik\""],
        architecture: compositionSnapshot()
      ),
      Step(
        4, "Zincir soldan sağa okunur: önce araba, sonra onun motoru, sonra motorun türü.",
        memory: ["araba.motor.tur": "\"Elektrik\"", "okunan zincir": "araba → motor → tur"],
        output: "Elektrik",
        architecture: compositionSnapshot()
      ),
    ],
    practices: [
      PracticeChallenge(
        kind: .architecture,
        prompt: "Araba ile Motor arasındaki ilişki hangisidir?",
        choices: ["Araba Motor'a sahiptir", "Motor Araba'dan kalıtılır", "İkisi aynıdır"],
        correctAnswer: "Araba Motor'a sahiptir",
        explanation: "Motor, Araba'nın içinde tutulan ayrı bir bileşendir."
      )
    ],
    transferCode: [
      "struct Pil { let seviye = 80 }",
      "struct Telefon { let pil: Pil }",
      "print(Telefon(pil: Pil()).pil.seviye)",
    ],
    transferChoices: ["Pil", "Telefon", "80", "100"],
    transferAnswer: "80",
    extraQuizzes: [
      Quiz(
        [
          "struct Kalem { let renk = \"Mavi\" }", "struct Kutu { let kalem: Kalem }",
          "struct Canta { let kutu: Kutu }",
          "print(Canta(kutu: Kutu(kalem: Kalem())).kutu.kalem.renk)",
        ],
        choices: ["Mavi", "Kutu", "Kalem", "Canta"],
        answer: "Mavi",
        explanation: "Zincir soldan sağa okunur: çanta → kutu → kalem → renk."
      ),
      Quiz(
        [
          "struct Motor { let guc = 90 }", "struct Araba { let motor = Motor() }",
          "print(Araba().motor.guc)",
        ],
        choices: ["90", "Motor", "Araba", "0"],
        answer: "90",
        explanation: "Araba motoru içerir; içteki parçanın değeri zincir üzerinden okunur."
      ),
    ],
  ),
  RoadmapBlueprint(
    id: "inheritance",
    order: 20,
    section: .objects,
    topic: "INHERITANCE",
    title: "Davranışı özelleştir",
    objective: "Alt class'ın miras aldığı methodu nasıl değiştirdiğini izle.",
    takeaway: "Inheritance ortak bir tür ilişkisi kurar; override özel davranışı seçer.",
    teaching: LessonTeaching(
      whyItMatters:
        "Değişkenin yazılı türü ile bellekteki gerçek nesnenin türü farklı olabilir. Hangi gövdenin çalıştığını gerçek tür belirler.",
      commonMistake:
        "`let hayvan: Hayvan` yazdığı için Hayvan'daki gövdenin çalışacağını sanmak. Karar çalışma anında nesneye göre verilir.",
      realWorldUse:
        "Aynı arayüzü uygulayan farklı ödeme veya bildirim sağlayıcıları bu sayede tek bir çağrı noktasından kullanılabilir."
    ),
    code: [
      "class Hayvan { func ses() -> String { \"?\" } }",
      "class Kedi: Hayvan {",
      "    override func ses() -> String { \"Miyav\" }",
      "}",
      "let hayvan: Hayvan = Kedi()",
      "print(hayvan.ses())",
    ],
    choices: ["?", "Miyav", "Kedi", "Hayvan"],
    answer: "Miyav",
    steps: [
      Step(
        5,
        "Değişkenin yazılı türü Hayvan, ama bellekte üretilen nesne bir Kedi. İki tür aynı anda geçerli.",
        memory: ["görünen tür": "Hayvan", "gerçek tür": "Kedi"],
        architecture: inheritanceSnapshot()
      ),
      Step(
        6,
        "ses() çağrılır. Hangi gövdenin çalışacağına yazılı tür değil, nesnenin gerçek türü karar verir.",
        memory: ["görünen tür": "Hayvan", "gerçek tür": "Kedi", "seçilen gövde": "Kedi.ses"],
        callStack: [
          CallFrame(functionName: "program", locals: ["hayvan": "Kedi nesnesi"]),
          CallFrame(functionName: "Kedi.ses", locals: [:]),
        ]
      ),
      Step(
        3, "Kedi'nin override ettiği gövde çalışır. Hayvan'daki \"?\" bu programda hiç çalışmaz.",
        memory: ["dönen değer": "\"Miyav\""],
        callStack: [
          CallFrame(functionName: "program", locals: ["hayvan": "Kedi nesnesi"]),
          CallFrame(functionName: "Kedi.ses", locals: ["sonuç": "\"Miyav\""]),
        ]
      ),
      Step(
        6, "Dönen değer yazdırılır.",
        memory: ["görünen tür": "Hayvan", "gerçek tür": "Kedi", "dönen değer": "\"Miyav\""],
        output: "Miyav",
        architecture: inheritanceSnapshot()
      ),
    ],
    transferCode: [
      "class Kopek: Hayvan {",
      "    override func ses() -> String { \"Hav\" }",
      "}",
      "print(Kopek().ses())",
    ],
    transferChoices: ["?", "Miyav", "Hav", "Kopek"],
    transferAnswer: "Hav",
    extraQuizzes: [
      Quiz(
        [
          "class Sekil { func ad() -> String { \"Şekil\" } }", "class Kare: Sekil {}",
          "print(Kare().ad())",
        ],
        choices: ["Şekil", "Kare", "Hata", "nil"],
        answer: "Şekil",
        explanation: "Kare override etmediği için üst class'tan miras aldığı gövde çalışır."
      ),
      Quiz(
        [
          "class Sekil { func ad() -> String { \"Şekil\" } }", "class Kare: Sekil {",
          "    override func ad() -> String { \"Kare\" }", "}", "let s: Sekil = Kare()",
          "print(s.ad())",
        ],
        choices: ["Kare", "Şekil", "Sekil", "Hata"],
        answer: "Kare",
        explanation:
          "Yazılı tür Sekil olsa da nesne Kare olduğu için override edilen gövde çalışır."
      ),
    ],
    estimatedMinutes: 8
  ),
  RoadmapBlueprint(
    id: "architecture-challenge",
    order: 21,
    section: .objects,
    topic: "MİMARİ MEYDAN OKUMASI",
    title: "Veri hangi katmandan gelir?",
    objective: "View, servis ve veri deposu arasındaki sahiplik zincirini takip et.",
    takeaway:
      "Bağımlılık zincirini okurken her nesnenin kimi çağırdığını ve veriyi kimin tuttuğunu ayır.",
    teaching: LessonTeaching(
      whyItMatters:
        "Bir hatanın hangi katmana ait olduğunu bulmak, veriyi kimin tuttuğunu ve kimin yalnızca ilettiğini ayırmakla başlar.",
      commonMistake:
        "Zinciri yukarıdan aşağı kurulmuş sanmak. Kurulum en içteki parçadan dışa doğru ilerler, okuma ise ters yönde.",
      realWorldUse:
        "View → ViewModel → Repository zincirinde yanlış görünen bir sayının hangi katmanda bozulduğu tam olarak böyle aranır."
    ),
    code: [
      "struct Depo { let puan = 3 }",
      "struct Servis { let depo: Depo }",
      "struct EkranModeli { let servis: Servis }",
      "let model = EkranModeli(servis: Servis(depo: Depo()))",
      "print(model.servis.depo.puan)",
    ],
    choices: ["Depo", "Servis", "3", "EkranModeli"],
    answer: "3",
    steps: [
      Step(
        4, "Kurulum en içten başlar: Depo() üretilir. Veriyi gerçekten tutan katman budur.",
        memory: ["depo.puan": "3"]
      ),
      Step(
        4, "Depo bir Servis'e verilir. Servis veriyi kendi tutmaz; sorulduğunda deposuna sorar.",
        memory: ["depo.puan": "3", "servis.depo": "Depo nesnesi"]
      ),
      Step(
        4, "Servis ekran modeline verilir ve zincir tamamlanır: model → servis → depo.",
        memory: [
          "depo.puan": "3", "servis.depo": "Depo nesnesi", "model.servis": "Servis nesnesi",
        ],
        architecture: architectureChallengeSnapshot()
      ),
      Step(
        5, "Okuma kurulumun tersine, dıştan içe ilerler. Değer en alttaki depodan gelir.",
        memory: ["okunan zincir": "model → servis → depo → puan", "sonuç": "3"],
        output: "3",
        architecture: architectureChallengeSnapshot()
      ),
    ],
    transferCode: [
      "let servis = Servis(depo: Depo())",
      "print(servis.depo.puan)",
    ],
    transferChoices: ["3", "Servis", "Depo", "0"],
    transferAnswer: "3",
    extraQuizzes: [
      Quiz(
        [
          "struct Depo { let ad = \"Ada\" }", "struct Servis { let depo: Depo }",
          "let servis = Servis(depo: Depo())", "print(servis.depo.ad)",
        ],
        choices: ["Ada", "Depo", "Servis", "nil"],
        answer: "Ada",
        explanation: "Servis veriyi kendi tutmaz; değeri deposundan okur."
      ),
      Quiz(
        [
          "struct Depo { let puan = 7 }", "struct Servis { let depo = Depo() }",
          "struct Ekran { let servis = Servis() }", "print(Ekran().servis.depo.puan)",
        ],
        choices: ["7", "0", "Depo", "Ekran"],
        answer: "7",
        explanation:
          "Katmanlar iç içe kurulur; okuma dıştan içe ilerleyip en alttaki değere ulaşır."
      ),
    ],
    estimatedMinutes: 10
  ),
  RoadmapBlueprint(
    id: "error-types",
    order: 22,
    section: .debugging,
    topic: "HATA TÜRLERİ",
    title: "Kod neden başlayamıyor?",
    objective: "Syntax hatasını runtime ve logic hatasından ayır.",
    takeaway: "Syntax hatasında dil kuralları bozulduğu için program çalışmaya başlayamaz.",
    teaching: LessonTeaching(
      whyItMatters:
        "Hatanın hangi aşamada oluştuğunu bilmek aramayı yarıya indirir: syntax hatasında hiçbir satır çalışmadığı için değerleri incelemek anlamsızdır.",
      commonMistake:
        "Derleyici hatasını 'kod çalıştı ama yanlış sonuç verdi' sanıp değişken değerlerini aramak.",
      realWorldUse:
        "Kırmızı derleyici mesajı okumayı öğrenmek, çalışma anı çökmelerini ve mantık hatalarını ayrı yöntemlerle aramanın ilk adımıdır."
    ),
    code: [
      "func indirimliFiyat(_ fiyat: Int) -> Int {",
      "    let oran =",
      "    return fiyat - oran",
      "}",
      "let sonuc = indirimliFiyat(200)",
      "print(sonuc)",
    ],
    choices: ["Derlenmez", "200", "nil", "Boş satır"],
    answer: "Derlenmez",
    steps: [
      Step(
        2,
        "Derleyici ikinci satırı okur ve eşittir işaretinden sonra bir değer bekler; hiçbir şey bulamaz.",
        memory: ["oran": "tür ve değer belirlenemedi"]
      ),
      Step(
        2, "İfade tamamlanmadığı için oran'ın ne türü ne değeri oluşur. Derleme burada durur.",
        memory: ["oran": "yok", "derleme": "başarısız"]
      ),
      Step(
        2,
        "Aktif satır burada kalır. Fonksiyon gövdesi, çağrı ve print dahil hiçbir satır çalışmaz; syntax hatasında çalışma anı hiç başlamaz.",
        memory: ["program durumu": "hiç başlamadı", "çalışan satır sayısı": "0"]
      ),
    ],
    debugKind: .syntax,
    debugLine: 2,
    expected: "bir başlangıç değeri",
    actual: "eksik ifade",
    practices: [
      PracticeChallenge(
        kind: .concept,
        prompt: "Derleyici hatası ile çalışma anı hatası arasındaki fark nedir?",
        choices: [
          "Derleyici hatasında program hiç başlamaz", "İkisi de programı yarıda keser",
          "Çalışma anı hatası daha önce oluşur", "Fark yalnızca mesajın rengidir",
        ],
        correctAnswer: "Derleyici hatasında program hiç başlamaz",
        explanation:
          "Syntax hatasında hiçbir satır çalışmaz; çalışma anı hatası ise akış sırasında oluşur."
      )
    ],
    transferCode: [
      "func selamla(ad: String) -> String {",
      "    return \"Merhaba \" +",
      "}",
      "print(selamla(ad: \"Ada\"))",
    ],
    transferChoices: ["Derlenmez", "Merhaba Ada", "Merhaba", "nil"],
    transferAnswer: "Derlenmez",
    extraQuizzes: [
      Quiz(
        ["let sayi: Int = \"beş\"", "print(sayi)"],
        choices: ["Derlenmez", "beş", "5", "nil"],
        answer: "Derlenmez",
        explanation: "Tür uyuşmazlığı derleme anında yakalanır; program hiç başlamaz."
      ),
      Quiz(
        ["let sayilar = [1, 2]", "print(sayilar[5])"],
        choices: ["Çalışır ama çöker", "Derlenmez", "nil", "2"],
        answer: "Çalışır ama çöker",
        explanation: "Sözdizimi doğru olduğu için derlenir; hata çalışma anında ortaya çıkar."
      ),
    ],
  ),
  RoadmapBlueprint(
    id: "logic-errors",
    order: 23,
    section: .debugging,
    topic: "LOGIC ERROR",
    title: "Çalışıyor ama yanlış",
    objective: "Derlenen kodda beklenen ve gerçek değer farkından hatalı satırı bul.",
    takeaway: "Logic error programı durdurmaz; yanlış varsayım yanlış sonuç üretir.",
    teaching: LessonTeaching(
      whyItMatters:
        "En pahalı hatalar çökmeyenlerdir. Program sorunsuz görünürken yanlış sayıyı üretir ve bunu ancak sonucu kontrol eden fark eder.",
      commonMistake:
        "Kod çalıştığı ve hata vermediği için doğru kabul etmek. Doğruluk ölçüsü çalışması değil, beklenen sonucu vermesidir.",
      realWorldUse:
        "İndirim, vergi ve puan hesaplarında işaret veya sıra hatası hep bu türdendir; testler tam olarak bunu yakalamak için yazılır."
    ),
    code: [
      "func odenecek(fiyat: Int, oran: Int) -> Int {",
      "    let indirim = fiyat * oran / 100",
      "    return fiyat + indirim",
      "}",
      "let tutar = odenecek(fiyat: 200, oran: 25)",
      "print(tutar)",
    ],
    choices: ["250", "150", "200", "50"],
    answer: "250",
    steps: [
      Step(
        5, "Fonksiyon 200 lira ve %25 indirimle çağrılır. Buraya kadar her şey beklendiği gibi.",
        memory: ["fiyat": "200", "oran": "25"]
      ),
      Step(
        2, "İndirim tutarı doğru hesaplanır: 200 * 25 / 100 = 50.",
        memory: ["fiyat": "200", "oran": "25", "indirim": "50"]
      ),
      Step(
        3,
        "Dönüş satırında `+` yazılmış. Kod hatasız derlenir ve çalışır ama indirim düşülmek yerine eklenir.",
        memory: ["fiyat": "200", "indirim": "50", "dönen": "250", "beklenen": "150"]
      ),
      Step(
        6, "Program çökmeden 250 yazar. Hata ancak sonucu beklentiyle karşılaştırınca görünür.",
        memory: ["tutar": "250", "beklenen": "150", "fark": "100"],
        output: "250"
      ),
    ],
    debugKind: .logic,
    debugLine: 3,
    expected: "150",
    actual: "250",
    transferCode: [
      "let sepet = 300",
      "let kargo = 40",
      "let toplam = sepet - kargo",
      "print(toplam)",
    ],
    transferChoices: ["260", "340", "300", "40"],
    transferAnswer: "260",
    extraQuizzes: [
      Quiz(
        ["let toplam = 10", "let adet = 4", "let ortalama = toplam + adet", "print(ortalama)"],
        choices: ["14", "2", "2.5", "40"],
        answer: "14",
        explanation:
          "Kod çöker gibi görünmez ama bölme yerine toplama yazıldığı için sonuç anlamsızdır."
      ),
      Quiz(
        ["var puan = 10", "puan = puan - 2", "puan = puan - 2", "print(puan)"],
        choices: ["6", "8", "10", "4"],
        answer: "6",
        explanation:
          "İki çıkarma da çalışır; beklenen tek indirimse hata sonucu okuyunca anlaşılır."
      ),
    ],
  ),
  RoadmapBlueprint(
    id: "edge-cases",
    order: 24,
    section: .debugging,
    topic: "EDGE CASE",
    title: "Boş liste gelirse?",
    objective: "Normal örneklerin sakladığı boş koleksiyon durumunu incele.",
    takeaway:
      "Edge case, ana akıştan önce sınır ve boşluk durumlarını açıkça ele almayı gerektirir.",
    teaching: LessonTeaching(
      whyItMatters:
        "Kod çoğu girdiyle doğru çalışıp yalnızca sınırda çöker. Sınırı önceden düşünmezsen hatayı kullanıcı bulur.",
      commonMistake:
        "Fonksiyonu yazarken yalnızca dolu listeyi hayal etmek ve boş listeyi 'olmaz' diye geçmek.",
      realWorldUse:
        "Boş arama sonucu, ilk kez açılan hesap ve sıfır adetli sepet üçü de aynı sınıf sınır durumudur."
    ),
    code: [
      "struct Sepet {",
      "    let fiyatlar: [Int]",
      "    func enPahali() -> Int {",
      "        fiyatlar.max()!",
      "    }",
      "}",
      "let sepet = Sepet(fiyatlar: [])",
      "print(sepet.enPahali())",
    ],
    choices: ["0", "nil", "Hata", "Boş dizi"],
    answer: "Hata",
    steps: [
      Step(
        7, "Sepet boş bir fiyat listesiyle kurulur. Dolu sepetle aynı kod yolu izlenecek.",
        memory: ["sepet.fiyatlar": "[]", "eleman sayısı": "0"],
        callStack: [CallFrame(functionName: "program", locals: [:])]
      ),
      Step(
        8, "enPahali() çağrılır. Yürütme method gövdesine geçer; henüz sorun görünmüyor.",
        memory: ["sepet.fiyatlar": "[]", "eleman sayısı": "0", "çağrılan": "enPahali()"],
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "Sepet.enPahali", locals: ["fiyatlar": "[]"]),
        ]
      ),
      Step(
        4,
        "max() boş listede nil döner ve `!` bunu açmaya çalışır. Geçersiz erişim programı durdurur; return hiç tamamlanmaz.",
        memory: ["max() sonucu": "nil", "program durumu": "çöktü", "üretilen çıktı": "yok"],
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "Sepet.enPahali", locals: ["durum": "nil açma hatası"]),
        ]
      ),
    ],
    debugKind: .edgeCase,
    debugLine: 4,
    expected: "boş sepeti güvenle ele almak",
    actual: "nil açma hatası",
    transferCode: [
      "let fiyatlar: [Int] = []",
      "let enPahali = fiyatlar.max() ?? 0",
      "print(enPahali)",
    ],
    transferChoices: ["0", "nil", "Hata", "[]"],
    transferAnswer: "0",
    extraQuizzes: [
      Quiz(
        ["let sayilar: [Int] = []", "print(sayilar.count)"],
        choices: ["0", "Hata", "nil", "1"],
        answer: "0",
        explanation:
          "Boş dizinin uzunluğunu sormak güvenlidir; çöken şey olmayan elemana erişmektir."
      ),
      Quiz(
        ["func ortala(_ s: [Int]) -> Int { s.reduce(0, +) / s.count }", "print(ortala([]))"],
        choices: ["Hata", "0", "nil", "1"],
        answer: "Hata",
        explanation: "Boş listede eleman sayısı sıfırdır; sıfıra bölme programı durdurur."
      ),
    ],
    estimatedMinutes: 8
  ),
  RoadmapBlueprint(
    id: "optionals",
    order: 25,
    section: .debugging,
    topic: "OPTIONAL",
    title: "Değer olmayabilir",
    objective: "Optional değerin yokluğunu zorla açmadan önce kontrol et.",
    takeaway:
      "Optional, değerin olmayabileceğini tür sisteminde görünür kılar; `!` bu güvenliği kaldırır.",
    teaching: LessonTeaching(
      whyItMatters:
        "Optional, 'burada değer olmayabilir' uyarısını türün içine yazar. Bu uyarıyı `!` ile susturduğunda sorumluluğu sen alırsın.",
      commonMistake:
        "Derleyici şikâyet ettiği için `!` eklemek. Bu, hatayı çözmez; yalnızca derleme anından çalışma anına erteler.",
      realWorldUse:
        "Henüz yüklenmemiş profil, boş bırakılmış form alanı ve bulunamayan kayıt üçü de optional olarak gelir."
    ),
    code: [
      "struct Profil {",
      "    let takmaAd: String?",
      "}",
      "func basligiYaz(_ profil: Profil) {",
      "    print(profil.takmaAd!)",
      "}",
      "basligiYaz(Profil(takmaAd: nil))",
    ],
    choices: ["nil", "Boş", "Hata", "Optional(nil)"],
    answer: "Hata",
    steps: [
      Step(
        2,
        "Türdeki soru işareti 'değer olmayabilir' demektir. Bu bir olasılık değil, sözleşmenin parçası.",
        memory: ["takmaAd'ın türü": "String?", "takmaAd": "henüz verilmedi"]
      ),
      Step(
        7, "Profil takma ad olmadan kurulup fonksiyona verilir. Sözleşmenin izin verdiği durum.",
        memory: ["profil.takmaAd": "nil", "çağrılan": "basligiYaz"],
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "basligiYaz", locals: ["profil.takmaAd": "nil"]),
        ]
      ),
      Step(
        5,
        "`!` hiçbir kontrol yapmadan 'içinde kesin değer var' der. İddia yanlış çıkar; nil açılamaz ve program durur.",
        memory: ["iddia": "değer var", "gerçek": "nil", "program durumu": "çöktü"],
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "basligiYaz", locals: ["durum": "nil açma hatası"]),
        ]
      ),
    ],
    debugKind: .optional,
    debugLine: 5,
    expected: "güvenli varsayılan",
    actual: "nil zorla açma",
    practices: [
      PracticeChallenge(
        kind: .concept,
        prompt: "Optional bir değeri güvenle kullanmanın yolu hangisidir?",
        choices: [
          "`if let` ile açmak", "`!` ile zorlamak", "Türü değiştirmek", "Değeri metne çevirmek",
        ],
        correctAnswer: "`if let` ile açmak",
        explanation: "`if let` değer varsa açar, yoksa çökmek yerine diğer kola geçer."
      )
    ],
    transferCode: [
      "struct Profil {",
      "    let takmaAd: String?",
      "}",
      "func basligiYaz(_ profil: Profil) {",
      "    print(profil.takmaAd ?? \"Misafir\")",
      "}",
      "basligiYaz(Profil(takmaAd: nil))",
    ],
    transferChoices: ["nil", "Misafir", "Hata", "Optional(\"Misafir\")"],
    transferAnswer: "Misafir",
    extraQuizzes: [
      Quiz(
        ["let ad: String? = \"Ada\"", "print(ad ?? \"Misafir\")"],
        choices: ["Ada", "Misafir", "nil", "Hata"],
        answer: "Ada",
        explanation: "Değer varken ?? sağdaki varsayılana hiç bakmaz."
      ),
      Quiz(
        [
          "let yas: Int? = nil", "if let kesin = yas {", "    print(kesin)", "} else {",
          "    print(\"Bilinmiyor\")", "}",
        ],
        choices: ["Bilinmiyor", "nil", "Hata", "0"],
        answer: "Bilinmiyor",
        explanation: "if let değeri güvenle açar; yoksa çökmek yerine else koluna geçer."
      ),
    ],
  ),
  RoadmapBlueprint(
    id: "stack-traces",
    order: 26,
    section: .debugging,
    topic: "STACK TRACE",
    title: "Çökmeden çağrıya geri yürü",
    objective: "Stack trace'in en yakın uygulama satırından çağıranlara doğru okunmasını öğren.",
    takeaway:
      "Stack trace, hatanın oluştuğu çerçeveden başlayıp çağrı zincirini geriye doğru gösterir.",
    teaching: LessonTeaching(
      whyItMatters:
        "Stack trace'in en üstündeki satır çöktüğü yeri, altındakiler oraya nasıl gelindiğini söyler. İkisini ayırmadan yanlış fonksiyonu düzeltirsin.",
      commonMistake:
        "Listenin en altındaki ilk çağrıyı suçlu sanmak. Hata en üstteki çerçevede oluşur; alttakiler yalnızca yoldur.",
      realWorldUse:
        "Çökme raporlarında yığının tepesinden başlayıp kendi kodunun geçtiği ilk satırı bulmak standart yöntemdir."
    ),
    code: [
      "func ekranAc() { veriYukle() }",
      "func veriYukle() { kayitCoz() }",
      "func kayitCoz() {",
      "    fatalError(\"Bozuk kayıt\")",
      "}",
      "ekranAc()",
    ],
    choices: ["kayitCoz()", "ekranAc()", "veriYukle()", "program"],
    answer: "kayitCoz()",
    steps: [
      Step(
        6, "Ekran açılır. Yığında tek çerçeve var.",
        memory: ["yığın derinliği": "1"],
        callStack: [CallFrame(functionName: "ekranAc", locals: [:])]
      ),
      Step(
        1, "ekranAc veriYukle'yi çağırır. Yeni çerçeve üste yığılır; ekranAc hâlâ bekliyor.",
        memory: ["yığın derinliği": "2", "bekleyenler": "ekranAc"],
        callStack: [
          CallFrame(functionName: "ekranAc", locals: [:]),
          CallFrame(functionName: "veriYukle", locals: [:]),
        ]
      ),
      Step(
        2, "veriYukle kayitCoz'u çağırır. Yığın üç çerçeve derinliğinde ve hiçbiri dönmedi.",
        memory: ["yığın derinliği": "3", "bekleyenler": "ekranAc, veriYukle"],
        callStack: [
          CallFrame(functionName: "ekranAc", locals: [:]),
          CallFrame(functionName: "veriYukle", locals: [:]),
          CallFrame(functionName: "kayitCoz", locals: [:]),
        ]
      ),
      Step(
        4,
        "Hata en üstteki çerçevede oluşur. Trace'te kayitCoz en üstte, ekranAc en altta görünür.",
        memory: [
          "çöken çerçeve": "kayitCoz", "trace sırası": "kayitCoz → veriYukle → ekranAc",
          "program durumu": "çöktü",
        ],
        callStack: [
          CallFrame(functionName: "ekranAc", locals: [:]),
          CallFrame(functionName: "veriYukle", locals: [:]),
          CallFrame(functionName: "kayitCoz", locals: ["durum": "fatalError"]),
        ]
      ),
    ],
    debugKind: .stackTrace,
    debugLine: 4,
    expected: "normal dönüş",
    actual: "fatalError",
    transferCode: [
      "func indir() { ac() }",
      "func ac() { oku() }",
      "func oku() { fatalError(\"Bozuk veri\") }",
      "indir()",
    ],
    transferChoices: ["oku()", "indir()", "ac()", "program"],
    transferAnswer: "oku()",
    extraQuizzes: [
      Quiz(
        ["func x() { y() }", "func y() { fatalError(\"Dur\") }", "x()"],
        choices: ["y()", "x()", "program", "fatalError()"],
        answer: "y()",
        explanation: "Hata en üstteki çerçevede oluşur; x yalnızca oraya giden yoldur."
      ),
      Quiz(
        ["func disari() { iceri() }", "func iceri() { print(\"tamam\") }", "disari()"],
        choices: ["tamam", "Hata", "Boş satır", "iceri()"],
        answer: "tamam",
        explanation: "Zincir sorunsuz tamamlanırsa yığın geriye sarılır ve trace hiç oluşmaz."
      ),
    ],
    estimatedMinutes: 8
  ),
  RoadmapBlueprint(
    id: "debug-hypothesis",
    order: 27,
    section: .debugging,
    topic: "HİPOTEZ VE KANIT",
    title: "Rastgele değiştirme, kanıt ara",
    objective: "Beklenen ve gerçek sonucu karşılaştırıp test edilebilir hipotez kur.",
    takeaway: "İyi debugging döngüsü hipotez, gözlem ve tek değişkenli doğrulamadan oluşur.",
    teaching: LessonTeaching(
      whyItMatters:
        "Hipotez yazmak aramayı rastgele denemeden ölçülebilir bir işe çevirir: yanlış çıkarsa da bir olasılığı kesin olarak elemiş olursun.",
      commonMistake:
        "Aynı anda birden fazla şeyi değiştirmek. Sonuç düzelse bile hangi değişikliğin işe yaradığı bilinmez.",
      realWorldUse:
        "Hata kaydı incelemesi 'şunu bekliyordum, şu oldu, sebebi şu olabilir' cümlesiyle başlar; bu cümle bir hipotezdir."
    ),
    code: [
      "func ortalama(_ notlar: [Int]) -> Int {",
      "    let toplam = notlar.reduce(0, +)",
      "    return toplam / notlar.count",
      "}",
      "let bosSinif: [Int] = []",
      "print(ortalama(bosSinif))",
    ],
    choices: ["Hata", "0", "nil", "1"],
    answer: "Hata",
    steps: [
      Step(
        5, "Sınıf listesi boş. Fonksiyon dolu listeyle çalışıyordu, aynı yol izlenecek.",
        memory: ["bosSinif": "[]", "eleman sayısı": "0"]
      ),
      Step(
        6,
        "Hipotez: 'boş listenin ortalaması 0 çıkar.' Bu, bölmenin bölenine bakmayan bir varsayım.",
        memory: ["hipotez": "sonuç 0 olur", "eleman sayısı": "0"]
      ),
      Step(
        2, "Toplam sorunsuz hesaplanır: boş listede reduce başlangıç değerini döndürür.",
        memory: ["toplam": "0", "eleman sayısı": "0"]
      ),
      Step(
        3,
        "Gözlem hipotezi çürütür: bölen sıfır olduğu için bölme yapılamaz ve program durur.",
        memory: ["toplam": "0", "bölen": "0", "program durumu": "çöktü"]
      ),
    ],
    debugKind: .runtime,
    debugLine: 3,
    expected: "boş sınıfta güvenli sonuç",
    actual: "sıfıra bölme",
    transferCode: [
      "func ortalama(_ notlar: [Int]) -> Int {",
      "    guard !notlar.isEmpty else { return 0 }",
      "    return notlar.reduce(0, +) / notlar.count",
      "}",
      "print(ortalama([]))",
    ],
    transferChoices: ["0", "Hata", "nil", "1"],
    transferAnswer: "0",
    extraQuizzes: [
      Quiz(
        ["let harfler = [\"a\", \"b\"]", "print(harfler[1])"],
        choices: ["b", "a", "Hata", "nil"],
        answer: "b",
        explanation: "İki elemanlı dizide geçerli index'ler 0 ve 1'dir; hipotez burada doğrulanır."
      ),
      Quiz(
        ["var sayilar = [1, 2]", "sayilar.append(3)", "print(sayilar[2])"],
        choices: ["3", "Hata", "2", "nil"],
        answer: "3",
        explanation: "Ekleme geçerli index aralığını büyütür; artık 2 de okunabilir."
      ),
    ],
    estimatedMinutes: 9
  ),
  RoadmapBlueprint(
    id: "async-order",
    order: 28,
    section: .asynchronous,
    topic: "ASENKRON AKIŞ",
    title: "Sonra çalışacak işi ayır",
    objective: "Task içindeki işin mevcut senkron akıştan ayrı planlandığını gör.",
    takeaway:
      "Asenkron iş başlatılabilir; sonucu kullanacağın yerde `await task.value` ile açık bir bekleme noktası kurarsın.",
    teaching: LessonTeaching(
      whyItMatters:
        "Bir işi önce başlatmak, önce bitmesini garanti etmez. Sonuç ancak beklendiği satırda hazır olur.",
      commonMistake:
        "Kodu yukarıdan aşağı okuyup Task içindeki satırın hemen orada çalıştığını sanmak.",
      realWorldUse:
        "Ağdan veri gelirken arayüzü göstermek ve veri geldiğinde ekranı tazelemek tam olarak bu sıralamadır."
    ),
    code: [
      "let task = Task { \"B\" }",
      "print(\"A\")",
      "print(\"C\")",
      "print(await task.value)",
    ],
    choices: ["A → B → C", "A → C → B", "B → A → C", "C → A → B"],
    answer: "A → C → B",
    steps: [
      Step(
        1, "Task oluşturulur. İş planlanır ama bu satırda çalışmaz; akış durmadan devam eder.",
        memory: ["task": "planlandı", "task sonucu": "henüz yok"],
        callStack: [CallFrame(functionName: "program", locals: ["task": "planlandı"])]
      ),
      Step(
        2, "Senkron akış kesintisiz sürer ve ilk çıktı burada üretilir.",
        memory: ["task sonucu": "henüz yok", "yazılan": "A"],
        output: "A",
        callStack: [CallFrame(functionName: "program", locals: [:])]
      ),
      Step(
        3, "İkinci senkron satır da task'ı beklemeden çalışır. Sıralamanın anahtarı burasıdır.",
        memory: ["task sonucu": "henüz yok", "yazılan": "A, C"],
        output: "A → C",
        callStack: [CallFrame(functionName: "program", locals: [:])]
      ),
      Step(
        4, "await açık bir bekleme noktasıdır: akış burada durur ve task'ın sonucunu alır.",
        memory: ["task sonucu": "\"B\"", "yazılan": "A, C, B"],
        output: "A → C → B",
        callStack: [
          CallFrame(functionName: "program", locals: ["beklenen": "task.value"]),
          CallFrame(functionName: "Task gövdesi", locals: ["sonuç": "\"B\""]),
        ]
      ),
    ],
    practices: [
      PracticeChallenge(
        kind: .concept,
        prompt: "Bir işi önce başlatmak, önce bitmesini garanti eder mi?",
        choices: [
          "Hayır, bitme sırası ayrıdır", "Evet, sıra korunur",
          "Yalnızca tek çekirdekte garanti eder", "Task kullanılmazsa garanti eder",
        ],
        correctAnswer: "Hayır, bitme sırası ayrıdır",
        explanation:
          "Başlatma sırası ile tamamlanma sırası farklı olabilir; sonucu await beklediğin yerde alırsın."
      )
    ],
    transferCode: [
      "let task = Task { \"Yüklendi\" }",
      "print(\"Başla\")",
      "print(\"Arayüz hazır\")",
      "print(await task.value)",
    ],
    transferChoices: [
      "Başla → Yüklendi → Arayüz hazır",
      "Başla → Arayüz hazır → Yüklendi",
      "Yüklendi → Başla → Arayüz hazır",
      "Arayüz hazır → Başla → Yüklendi",
    ],
    transferAnswer: "Başla → Arayüz hazır → Yüklendi",
    extraQuizzes: [
      Quiz(
        ["let task = Task { \"X\" }", "print(await task.value)", "print(\"Y\")"],
        choices: ["X → Y", "Y → X", "X", "Y"],
        answer: "X → Y",
        explanation:
          "await hemen ilk satırda kullanıldığı için akış burada bekler ve sıra değişmez."
      ),
      Quiz(
        ["let task = Task { \"Geç\" }", "print(\"Önce\")", "print(await task.value)"],
        choices: ["Önce → Geç", "Geç → Önce", "Önce", "Geç"],
        answer: "Önce → Geç",
        explanation: "Task planlanır ama senkron satır beklemeden çalışır; sonuç await'te alınır."
      ),
    ],
    estimatedMinutes: 9
  ),
  RoadmapBlueprint(
    id: "app-flow",
    order: 29,
    section: .appArchitecture,
    topic: "UYGULAMA AKIŞI",
    title: "Ekrandan veriye giden yol",
    objective:
      "Bir kullanıcı eyleminin View, ViewModel ve Repository katmanlarından geçişini izle.",
    takeaway:
      "Gerçek uygulamada sorumluluk katmanlara ayrılır; veri isteği aşağı iner, sonuç yukarı döner.",
    teaching: LessonTeaching(
      whyItMatters:
        "Gerçek uygulamalarda hiçbir ekran veriyi kendi üretmez. İsteğin hangi katmana indiğini bilmek, hatanın nerede aranacağını da söyler.",
      commonMistake:
        "ViewModel'i verinin sahibi sanmak. ViewModel yalnızca ister ve gelen sonucu ekranın anlayacağı biçime çevirir.",
      realWorldUse:
        "Yenile düğmesine basıldığında istek aşağı iner, veri yukarı döner; bu döngü hemen her uygulamanın omurgasıdır."
    ),
    code: [
      "struct Repository { func yukle() -> Int { 4 } }",
      "struct ViewModel {",
      "    let repository: Repository",
      "    func yenile() -> Int { repository.yukle() }",
      "}",
      "let model = ViewModel(repository: Repository())",
      "print(model.yenile())",
    ],
    choices: ["Repository", "ViewModel", "4", "0"],
    answer: "4",
    steps: [
      Step(
        6, "Katmanlar bağlanır: ViewModel hangi repository ile çalışacağını kurulumda öğrenir.",
        memory: ["model.repository": "Repository nesnesi", "yüklenen değer": "henüz yok"],
        callStack: [CallFrame(functionName: "View", locals: [:])],
        architecture: appFlowSnapshot()
      ),
      Step(
        7,
        "Ekran yenile() çağırır. İstek bir katman aşağı iner; View verinin nereden geldiğini bilmez.",
        memory: ["yüklenen değer": "henüz yok"],
        callStack: [
          CallFrame(functionName: "View", locals: [:]),
          CallFrame(functionName: "ViewModel.yenile", locals: [:]),
        ]
      ),
      Step(
        4, "ViewModel veriyi kendi üretmez; repository'sine sorar. İstek en alt katmana ulaşır.",
        memory: ["yüklenen değer": "henüz yok", "istek yönü": "aşağı"],
        callStack: [
          CallFrame(functionName: "View", locals: [:]),
          CallFrame(functionName: "ViewModel.yenile", locals: [:]),
          CallFrame(functionName: "Repository.yukle", locals: [:]),
        ]
      ),
      Step(
        1, "Veriyi tutan katman değeri üretir ve döndürür. Sonuç artık yukarı doğru ilerleyecek.",
        memory: ["yüklenen değer": "4", "istek yönü": "yukarı"],
        callStack: [
          CallFrame(functionName: "View", locals: [:]),
          CallFrame(functionName: "ViewModel.yenile", locals: [:]),
          CallFrame(functionName: "Repository.yukle", locals: ["sonuç": "4"]),
        ]
      ),
      Step(
        7, "Sonuç çağrı zincirini geri tırmanıp ekrana ulaşır.",
        memory: ["yüklenen değer": "4", "ekrana giden": "4"],
        output: "4",
        callStack: [CallFrame(functionName: "View", locals: ["gösterilen": "4"])],
        architecture: appFlowSnapshot()
      ),
    ],
    practices: [
      PracticeChallenge(
        kind: .architecture,
        prompt: "Ekranda yanlış bir sayı görünüyor. İlk nereye bakarsın?",
        choices: [
          "Veriyi üreten katmana", "Ekranın rengine", "Uygulama ikonuna", "Kullanıcının ayarlarına",
        ],
        correctAnswer: "Veriyi üreten katmana",
        explanation: "Veri aşağıdan yukarı gelir; hatalı değer kaynağında ya da yolda bozulmuştur."
      )
    ],
    transferCode: [
      "let repository = Repository()",
      "print(repository.yukle())",
    ],
    transferChoices: ["4", "Repository", "ViewModel", "nil"],
    transferAnswer: "4",
    extraQuizzes: [
      Quiz(
        [
          "struct Repository { func yukle() -> Int { 9 } }", "struct ViewModel {",
          "    let repository: Repository", "    func yenile() -> Int { repository.yukle() * 2 }",
          "}", "print(ViewModel(repository: Repository()).yenile())",
        ],
        choices: ["18", "9", "2", "Repository"],
        answer: "18",
        explanation: "Repository ham veriyi verir; ViewModel onu ekrana uygun biçime çevirir."
      ),
      Quiz(
        [
          "struct Repository { func yukle() -> Int { 4 } }", "let repository = Repository()",
          "print(repository.yukle())",
        ],
        choices: ["4", "0", "Repository", "nil"],
        answer: "4",
        explanation: "Veriyi tutan katmana doğrudan sorulduğunda ara katman devreye girmez."
      ),
    ],
    estimatedMinutes: 10
  ),
  RoadmapBlueprint(
    id: "capstone",
    order: 30,
    section: .assessment,
    topic: "ÇIKIŞ DEĞERLENDİRMESİ",
    title: "Yeni kodu kendi başına çöz",
    objective: "Otuz günlük yolun bütün okuma becerilerini yeni bir kodda göster.",
    takeaway:
      "Kodu bloklara ayır, değerleri izle, çağrıları sırala ve her iddianı bir satırla kanıtla.",
    teaching: LessonTeaching(
      whyItMatters:
        "Yirmi satırlık kod, kısa örneklerden farklı bir beceri ister: önce blokları ayırmak, sonra yalnızca çalışan yolu izlemek.",
      commonMistake:
        "Tanımları yukarıdan aşağı sırayla çalışıyor sanmak. Tanımlar beklemede durur; yürütme en alttaki ilk gerçek satırdan başlar.",
      realWorldUse:
        "Kod incelemesinde ve teknik mülakatta ölçülen şey tam olarak budur: sonucu değil, sonuca hangi kanıtla vardığını göstermek."
    ),
    code: [
      "struct Gorev {",
      "    let sure: Int",
      "}",
      "class Planlayici {",
      "    private var gorevler: [Gorev] = []",
      "    func ekle(_ gorev: Gorev) {",
      "        gorevler.append(gorev)",
      "    }",
      "    func toplamSure() -> Int {",
      "        gorevler.map(\\.sure).reduce(0, +)",
      "    }",
      "}",
      "func durum(_ sure: Int) -> String {",
      "    if sure > 5 { return \"Yoğun\" }",
      "    return \"Uygun\"",
      "}",
      "let plan = Planlayici()",
      "plan.ekle(Gorev(sure: 2))",
      "plan.ekle(Gorev(sure: 4))",
      "print(\"\\(durum(plan.toplamSure())): \\(plan.toplamSure())\")",
    ],
    choices: ["Uygun: 4", "Uygun: 6", "Yoğun: 6", "Yoğun: 8"],
    answer: "Yoğun: 6",
    steps: [
      Step(
        17,
        "İlk gerçek yürütme burada başlar. Üstteki tanımlar yalnızca şablon; bellekte tek nesne var ve listesi boş.",
        memory: ["plan.gorevler": "[]", "görev sayısı": "0"],
        callStack: [CallFrame(functionName: "program", locals: ["plan": "Planlayici nesnesi"])],
        architecture: capstoneSnapshot()
      ),
      Step(
        7, "İlk ekle çağrısı süresi 2 olan görevi listeye ekler.",
        memory: ["plan.gorevler": "[2]", "görev sayısı": "1"],
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "Planlayici.ekle", locals: ["gorev.sure": "2"]),
        ]
      ),
      Step(
        7, "İkinci çağrı listeyi büyütür. Nesnenin durumu çağrılar arasında korunuyor.",
        memory: ["plan.gorevler": "[2, 4]", "görev sayısı": "2"],
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "Planlayici.ekle", locals: ["gorev.sure": "4"]),
        ]
      ),
      Step(
        10, "toplamSure çalışır. Önce map her görevden yalnızca süreyi çıkarır.",
        memory: ["plan.gorevler": "[2, 4]", "map sonucu": "[2, 4]"],
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "Planlayici.toplamSure", locals: ["süreler": "[2, 4]"]),
        ]
      ),
      Step(
        10, "Sonra reduce 0'dan başlayarak toplar: 0 + 2 = 2, ardından 2 + 4 = 6.",
        memory: ["map sonucu": "[2, 4]", "biriken": "6", "toplamSure()": "6"],
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "Planlayici.toplamSure", locals: ["biriken": "6"]),
        ]
      ),
      Step(
        14, "Üretilen 6, durum fonksiyonuna girer. 6 > 5 doğru olduğu için ilk return çalışır.",
        memory: ["sure (parametre)": "6", "koşul 6 > 5": "doğru", "dönen değer": "\"Yoğun\""],
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "durum", locals: ["sure": "6"]),
        ]
      ),
      Step(
        20, "Son satırdaki ikinci toplamSure() çağrısı aynı hesabı baştan yapar ve yine 6 üretir.",
        memory: ["durum sonucu": "\"Yoğun\"", "ikinci toplamSure()": "6"],
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "Planlayici.toplamSure", locals: ["biriken": "6"]),
        ]
      ),
      Step(
        20, "İki parça metinde birleşir ve tek satır olarak yazılır.",
        memory: ["plan.gorevler": "[2, 4]", "toplam": "6", "durum": "\"Yoğun\""],
        output: "Yoğun: 6",
        callStack: [CallFrame(functionName: "program", locals: ["çıktı": "Yoğun: 6"])],
        architecture: capstoneSnapshot()
      ),
    ],
    practices: [
      PracticeChallenge(
        kind: .naming,
        prompt: "toplamSure fonksiyonunun adı davranışını açıklıyor mu?",
        choices: ["Evet", "Hayır", "Yalnızca kısa olduğu için iyi"],
        correctAnswer: "Evet",
        explanation: "Ad, hangi toplamın üretildiğini çağrı noktasında açıkça söyler."
      )
    ],
    assessmentTasks: [
      AssessmentTask(
        kind: .outputPrediction,
        prompt: "Programın son çıktısını tahmin et.",
        rubric: AssessmentRubric(
          requiredConcepts: ["Yoğun", "6"],
          modelAnswer: "İki görevin toplam süresi 6 olduğu için çıktı Yoğun: 6 olur."
        )
      ),
      AssessmentTask(
        kind: .valueTrace,
        prompt: "gorevler ve toplam değerlerini izle.",
        rubric: AssessmentRubric(
          requiredConcepts: ["2", "4", "6"],
          modelAnswer: "gorevler 2 ve 4 sürelerini tutar; toplam değer 6 olur."
        )
      ),
      AssessmentTask(
        kind: .callOrder,
        prompt: "Fonksiyon ve method çağrı sırasını açıkla.",
        rubric: AssessmentRubric(
          requiredConcepts: ["toplamSure", "durum"],
          modelAnswer: "Önce toplamSure 6 üretir, sonra durum bu değeri Yoğun sonucuna çevirir."
        )
      ),
      AssessmentTask(
        kind: .errorLocation,
        prompt: "Boş görev edge case'inde davranışı kanıtla.",
        rubric: AssessmentRubric(
          requiredConcepts: ["boş", "reduce", "0"],
          modelAnswer: "Boş listede reduce başlangıç değeri olan 0'ı döndürür; sonuç güvenlidir."
        )
      ),
      AssessmentTask(
        kind: .freeExplanation,
        prompt: "Kodun amacını kendi cümlenle açıkla.",
        rubric: AssessmentRubric(
          requiredConcepts: ["görev", "toplam", "durum"],
          modelAnswer:
            "Planlayıcı görev sürelerini toplar ve durum fonksiyonu toplamı sınıflandırır."
        )
      ),
    ],
    transferCode: [
      "let sure = 4",
      "print(durum(sure))",
    ],
    transferChoices: ["Uygun", "Yoğun", "4", "Çıktı yok"],
    transferAnswer: "Uygun",
    extraQuizzes: [
      Quiz(
        [
          "struct Gorev { let sure: Int }", "class Plan {",
          "    private var gorevler: [Gorev] = []",
          "    func ekle(_ g: Gorev) { gorevler.append(g) }",
          "    func toplam() -> Int { gorevler.map(\\.sure).reduce(0, +) }", "}",
          "let plan = Plan()", "plan.ekle(Gorev(sure: 1))", "plan.ekle(Gorev(sure: 2))",
          "print(plan.toplam())",
        ],
        choices: ["3", "2", "1", "0"],
        answer: "3",
        explanation: "İki görev eklenir, süreleri çıkarılır ve toplanır: 1 + 2 = 3."
      ),
      Quiz(
        [
          "func durum(_ sure: Int) -> String {", "    if sure > 5 { return \"Yoğun\" }",
          "    return \"Uygun\"", "}", "print(durum(5))",
        ],
        choices: ["Uygun", "Yoğun", "5", "Çıktı yok"],
        answer: "Uygun",
        explanation:
          "5 > 5 yanlış olduğu için ilk return atlanır; sınır değeri Uygun tarafında kalır."
      ),
    ],
    estimatedMinutes: 10
  ),
  RoadmapBlueprint(
    id: "test-anatomy",
    order: 31,
    section: .softwareTesting,
    topic: "TESTİN ANATOMİSİ",
    title: "Arrange, Act, Assert",
    objective: "Bir testi hazırlık, çalıştırma ve doğrulama adımlarına ayır.",
    takeaway:
      "Okunabilir bir test önce girdiyi hazırlar, davranışı çalıştırır ve tek bir beklentiyi doğrular.",
    teaching: LessonTeaching(
      whyItMatters:
        "Üç adımı ayırmak testi belgeye çevirir: hazırlığa bakan girdiyi, doğrulamaya bakan beklentiyi tek bakışta görür.",
      commonMistake:
        "Beklenen değeri test edilen kodun kendisiyle hesaplamak. O zaman test kodu değil, kendini doğrular.",
      realWorldUse:
        "Başarısız bir test raporunda ilk bakılan şey beklenen ile gerçek değerin farkıdır; bu ayrımı Assert adımı üretir."
    ),
    code: [
      "func topla(_ a: Int, _ b: Int) -> Int { a + b }",
      "let beklenen = 5",
      "let gercek = topla(2, 3)",
      "print(gercek == beklenen)",
    ],
    choices: ["true", "false", "5", "gercek == beklenen"],
    answer: "true",
    steps: [
      Step(
        2, "Arrange: beklenen sonuç, test edilen koda hiç bakmadan elle yazılır.",
        memory: ["beklenen": "5", "gercek": "henüz yok"]
      ),
      Step(
        3, "Act: davranış tek bir çağrıyla çalıştırılır. Test bu satırda kodu kullanır.",
        memory: ["beklenen": "5", "gercek": "5"],
        callStack: [
          CallFrame(functionName: "test", locals: ["beklenen": "5"]),
          CallFrame(functionName: "topla", locals: ["a": "2", "b": "3"]),
        ]
      ),
      Step(
        4, "Assert: iki değer karşılaştırılır. Eşitlerse test geçer, değilse fark rapor edilir.",
        memory: ["beklenen": "5", "gercek": "5", "karşılaştırma": "true"],
        output: "true"
      ),
    ],
    transferCode: [
      "let beklenen = 9",
      "let gercek = topla(4, 5)",
      "print(gercek == beklenen)",
    ],
    transferChoices: ["true", "false", "9", "9 == 9"],
    transferAnswer: "true",
    extraQuizzes: [
      Quiz(
        [
          "func topla(_ a: Int, _ b: Int) -> Int { a + b }", "let beklenen = 7",
          "let gercek = topla(3, 3)", "print(gercek == beklenen)",
        ],
        choices: ["false", "true", "6", "7"],
        answer: "false",
        explanation: "Act 6 üretir, Assert 7 bekler. Test kırılır ve fark hemen görünür."
      ),
      Quiz(
        [
          "func topla(_ a: Int, _ b: Int) -> Int { a + b }", "let beklenen = topla(2, 3)",
          "let gercek = topla(2, 3)", "print(gercek == beklenen)",
        ],
        choices: ["true", "false", "5", "Hata"],
        answer: "true",
        explanation:
          "Test geçer ama değersizdir: beklenen değer test edilen kodun kendisinden üretilmiştir."
      ),
    ],
    estimatedMinutes: 7
  ),
  RoadmapBlueprint(
    id: "unit-testing",
    order: 32,
    section: .softwareTesting,
    topic: "UNIT TEST",
    title: "Bir davranışı izole et",
    objective: "Tek bir fonksiyonun davranışını dış sistemlere ihtiyaç duymadan doğrula.",
    takeaway:
      "Unit test küçük ve izole bir davranışı ölçer; başarısız olduğunda sorunun yerini daraltır.",
    teaching: LessonTeaching(
      whyItMatters:
        "İzole bir test kırıldığında hatanın yeri zaten bellidir. Testin değeri yalnızca yakalamasında değil, yeri daraltmasındadır.",
      commonMistake:
        "Tek testte birden çok davranışı doğrulamak. Test kırıldığında hangi davranışın bozulduğu anlaşılmaz.",
      realWorldUse:
        "Fiyat, vergi ve indirim kuralları ayrı ayrı test edilirse bir kuralın değişmesi diğerlerinin testini kırmaz."
    ),
    code: [
      "func indirimliFiyat(_ fiyat: Int) -> Int {",
      "    fiyat - 20",
      "}",
      "let sonuc = indirimliFiyat(100)",
      "print(sonuc == 80)",
    ],
    choices: ["true", "false", "80", "100"],
    answer: "true",
    steps: [
      Step(
        4, "Fonksiyon tek bir girdiyle, hiçbir dış sisteme ihtiyaç duymadan çağrılır.",
        memory: ["girdi": "100", "sonuc": "henüz yok"],
        callStack: [
          CallFrame(functionName: "test", locals: [:]),
          CallFrame(functionName: "indirimliFiyat", locals: ["fiyat": "100"]),
        ]
      ),
      Step(
        2, "Tek satırlık kural uygulanır: 100 - 20 = 80.",
        memory: ["girdi": "100", "sonuc": "80"],
        callStack: [
          CallFrame(functionName: "test", locals: [:]),
          CallFrame(functionName: "indirimliFiyat", locals: ["fiyat": "100", "sonuç": "80"]),
        ]
      ),
      Step(
        5,
        "Sonuç beklenen değerle karşılaştırılır. Test kırılsaydı şüpheli tek bir fonksiyon olurdu.",
        memory: ["sonuc": "80", "beklenen": "80", "karşılaştırma": "true"],
        output: "true"
      ),
    ],
    practices: [
      PracticeChallenge(
        kind: .concept,
        prompt: "Bir unit test kırıldığında en büyük faydası nedir?",
        choices: [
          "Hatanın yerini daraltması", "Uygulamayı hızlandırması", "Kodu otomatik düzeltmesi",
          "Kullanıcıyı uyarması",
        ],
        correctAnswer: "Hatanın yerini daraltması",
        explanation: "İzole test kırıldığında şüpheli tek bir davranış kalır."
      )
    ],
    transferCode: [
      "let sonuc = indirimliFiyat(70)",
      "print(sonuc == 50)",
    ],
    transferChoices: ["true", "false", "50", "70"],
    transferAnswer: "true",
    extraQuizzes: [
      Quiz(
        ["func kdvEkle(_ fiyat: Int) -> Int { fiyat + fiyat / 10 }", "print(kdvEkle(100) == 110)"],
        choices: ["true", "false", "110", "100"],
        answer: "true",
        explanation: "Tek fonksiyon, tek girdi, tek beklenti: kırılırsa şüpheli tek yer vardır."
      ),
      Quiz(
        ["func kdvEkle(_ fiyat: Int) -> Int { fiyat + fiyat / 10 }", "print(kdvEkle(0) == 0)"],
        choices: ["true", "false", "0", "Hata"],
        answer: "true",
        explanation: "Sıfır girdisi de izole biçimde doğrulanabilir; dış sisteme ihtiyaç yoktur."
      ),
    ],
    estimatedMinutes: 7
  ),
  RoadmapBlueprint(
    id: "boundary-testing",
    order: 33,
    section: .softwareTesting,
    topic: "SINIR DEĞER TESTİ",
    title: "Tam sınırda ne olur?",
    objective: "Bir kuralın değiştiği sınırın hemen altını, kendisini ve üstünü test et.",
    takeaway:
      "Hatalar çoğunlukla karar sınırlarında saklanır; 17, 18 ve 19 gibi komşu değerler birlikte düşünülür.",
    teaching: LessonTeaching(
      whyItMatters:
        "Sınırdan uzak değerler `>` ile `>=` arasındaki farkı göstermez. Hatayı yalnızca sınırın kendisi ortaya çıkarır.",
      commonMistake:
        "Yalnızca rahat değerlerle test etmek: 30 ve 40 geçtiği için kuralın doğru olduğunu sanmak.",
      realWorldUse:
        "Yaş sınırı, ücretsiz kargo eşiği ve kota limitleri hep sınırın bir altı, kendisi ve bir üstüyle test edilir."
    ),
    code: [
      "func kayitOlabilir(yas: Int) -> Bool {",
      "    yas >= 18",
      "}",
      "print(kayitOlabilir(yas: 18))",
    ],
    choices: ["true", "false", "18", "Hata"],
    answer: "true",
    steps: [
      Step(
        4, "Test tam sınırın kendisiyle çağrılır: 18. En bilgilendirici değer budur.",
        memory: ["yas": "18", "alt sınır": "18"],
        callStack: [
          CallFrame(functionName: "test", locals: [:]),
          CallFrame(functionName: "kayitOlabilir", locals: ["yas": "18"]),
        ]
      ),
      Step(
        2, "Karşılaştırma `>=` olduğu için sınırın kendisi kuralı geçer: 18 >= 18 doğru.",
        memory: ["yas": "18", "koşul": "18 >= 18", "sonuç": "true"],
        callStack: [
          CallFrame(functionName: "test", locals: [:]),
          CallFrame(functionName: "kayitOlabilir", locals: ["yas": "18", "sonuç": "true"]),
        ]
      ),
      Step(
        4,
        "Sonuç true. Kural `>` yazılsaydı aynı girdi false verirdi; farkı yalnızca bu değer gösterir.",
        memory: ["yas": "18", "sonuç": "true", "`>` olsaydı": "false"],
        output: "true"
      ),
    ],
    debugKind: .logic,
    debugCode: [
      "func kayitOlabilir(yas: Int) -> Bool {",
      "    yas > 18",
      "}",
      "print(kayitOlabilir(yas: 18))",
    ],
    debugLine: 2,
    expected: "true",
    actual: "false",
    practices: [
      PracticeChallenge(
        kind: .concept,
        prompt: "18 alt sınırı için en değerli komşu test hangisidir?",
        choices: ["17", "30", "100"],
        correctAnswer: "17",
        explanation: "Sınırın hemen altındaki 17, karşılaştırmanın iki tarafını ayırır."
      )
    ],
    transferCode: [
      "print(kayitOlabilir(yas: 17))"
    ],
    transferChoices: ["true", "false", "17", "Hata"],
    transferAnswer: "false",
    extraQuizzes: [
      Quiz(
        ["func kayitOlabilir(yas: Int) -> Bool { yas >= 18 }", "print(kayitOlabilir(yas: 19))"],
        choices: ["true", "false", "19", "Hata"],
        answer: "true",
        explanation:
          "Sınırın üstü zaten geçer; asıl bilgi veren değer sınırın kendisi ve bir altıdır."
      ),
      Quiz(
        ["func indirimVar(tutar: Int) -> Bool { tutar > 100 }", "print(indirimVar(tutar: 100))"],
        choices: ["false", "true", "100", "Hata"],
        answer: "false",
        explanation:
          "`>` kullanıldığı için sınırın kendisi dışarıda kalır; `>=` olsaydı true olurdu."
      ),
    ],
    estimatedMinutes: 8
  ),
  RoadmapBlueprint(
    id: "test-doubles",
    order: 34,
    section: .softwareTesting,
    topic: "TEST DOUBLE",
    title: "Kontrol edemediğini değiştir",
    objective: "Zaman gibi dış bir bağımlılığı sabit bir test double ile kontrol et.",
    takeaway:
      "Test double, dış bağımlılığın kontrollü bir temsilidir; testin hızlı ve tekrarlanabilir kalmasını sağlar.",
    teaching: LessonTeaching(
      whyItMatters:
        "Gerçek saate, ağa veya rastgeleliğe bağlı kod her çalıştırmada farklı sonuç verir. Test double bu belirsizliği sabitler.",
      commonMistake:
        "Bağımlılığı fonksiyonun içinde üretmek. Dışarıdan verilmeyen bir bağımlılık testte değiştirilemez.",
      realWorldUse:
        "Ödeme sağlayıcısı, tarih ve konum servisleri testlerde neredeyse her zaman sahte bir temsille değiştirilir."
    ),
    code: [
      "protocol SaatSaglayan { var saat: Int { get } }",
      "struct SabitSaat: SaatSaglayan { let saat: Int }",
      "func mesaj(saat: SaatSaglayan) -> String {",
      "    saat.saat < 12 ? \"Günaydın\" : \"Merhaba\"",
      "}",
      "print(mesaj(saat: SabitSaat(saat: 9)))",
    ],
    choices: ["Günaydın", "Merhaba", "9", "Gerçek saate göre değişir"],
    answer: "Günaydın",
    steps: [
      Step(
        6, "Fonksiyon gerçek saati sormaz; saati dışarıdan alır. Test bu yüzden değeri seçebilir.",
        memory: ["verilen saat": "9", "bağımlılık": "SabitSaat"],
        callStack: [CallFrame(functionName: "test", locals: ["saat": "9"])],
        architecture: dependencySnapshot(
          owner: "mesaj",
          contract: "SaatSaglayan",
          implementation: "SabitSaat"
        )
      ),
      Step(
        4, "Koşul sabit değerle çalışır: 9 < 12 doğru.",
        memory: ["saat.saat": "9", "koşul": "9 < 12", "sonuç": "doğru"],
        callStack: [
          CallFrame(functionName: "test", locals: [:]),
          CallFrame(functionName: "mesaj", locals: ["saat.saat": "9"]),
        ]
      ),
      Step(
        6, "Sonuç her çalıştırmada aynı. Gerçek saat kullanılsaydı test öğleden sonra kırılırdı.",
        memory: ["saat.saat": "9", "mesaj": "\"Günaydın\"", "tekrarlanabilir": "evet"],
        output: "Günaydın",
        architecture: dependencySnapshot(
          owner: "mesaj",
          contract: "SaatSaglayan",
          implementation: "SabitSaat"
        )
      ),
    ],
    transferCode: [
      "print(mesaj(saat: SabitSaat(saat: 15)))"
    ],
    transferChoices: [
      "Günaydın", "Merhaba", "15", "Gerçek saate göre değişir",
    ],
    transferAnswer: "Merhaba",
    extraQuizzes: [
      Quiz(
        [
          "protocol Rastgele { var sayi: Int { get } }",
          "struct SabitSayi: Rastgele { let sayi: Int }",
          "func kazandiMi(_ r: Rastgele) -> Bool { r.sayi == 7 }",
          "print(kazandiMi(SabitSayi(sayi: 7)))",
        ],
        choices: ["true", "false", "7", "Her çalıştırmada değişir"],
        answer: "true",
        explanation: "Rastgelelik dışarıdan verildiği için test sonucu sabitlenebilir."
      ),
      Quiz(
        [
          "protocol Saat { var saat: Int { get } }", "struct Sabit: Saat { let saat: Int }",
          "func gece(_ s: Saat) -> Bool { s.saat >= 22 }", "print(gece(Sabit(saat: 21)))",
        ],
        choices: ["false", "true", "21", "Gerçek saate göre değişir"],
        answer: "false",
        explanation: "Sahte bağımlılık sayesinde sınır davranışı istediğin saatte denenebilir."
      ),
    ],
    estimatedMinutes: 9
  ),
  RoadmapBlueprint(
    id: "integration-regression",
    order: 35,
    section: .softwareTesting,
    topic: "INTEGRATION VE REGRESSION",
    title: "Parçalar birlikte çalışıyor mu?",
    objective: "Birden fazla parçanın anlaşmasını ve eski davranışın korunmasını doğrula.",
    takeaway:
      "Integration testi parçaların birlikte çalışmasını, regression testi daha önce çalışan davranışın bozulmamasını korur.",
    teaching: LessonTeaching(
      whyItMatters:
        "Her parça tek başına doğru olduğu halde birleşim yanlış olabilir. Hatalar çoğunlukla parçaların anlaştığı yerde saklanır.",
      commonMistake:
        "Bütün unit testler geçtiği için sistemin çalıştığını varsaymak. Unit testler parçalar arasındaki anlaşmayı ölçmez.",
      realWorldUse:
        "Bir hata düzeltildikten sonra o senaryo için yazılan test, aynı hatanın geri gelmesini engelleyen regression testidir."
    ),
    code: [
      "struct Depo {",
      "    func sayilar() -> [Int] { [2, 3] }",
      "}",
      "func toplam(depo: Depo) -> Int {",
      "    depo.sayilar().reduce(0, +)",
      "}",
      "print(toplam(depo: Depo()) == 5)",
    ],
    choices: ["true", "false", "5", "[2, 3]"],
    answer: "true",
    steps: [
      Step(
        7, "Test iki parçayı birlikte çalıştırır: veriyi üreten depo ve onu toplayan fonksiyon.",
        memory: ["test edilen": "Depo + toplam", "sonuç": "henüz yok"],
        callStack: [
          CallFrame(functionName: "test", locals: [:]),
          CallFrame(functionName: "toplam", locals: ["depo": "Depo nesnesi"]),
        ]
      ),
      Step(
        2, "Alt parça kendi verisini üretir. Anlaşma noktası burası: dönen tür bir Int dizisi.",
        memory: ["depo.sayilar()": "[2, 3]"],
        callStack: [
          CallFrame(functionName: "test", locals: [:]),
          CallFrame(functionName: "toplam", locals: [:]),
          CallFrame(functionName: "Depo.sayilar", locals: ["sonuç": "[2, 3]"]),
        ]
      ),
      Step(
        5, "Üst parça gelen diziyi toplar: 0 + 2 + 3 = 5.",
        memory: ["depo.sayilar()": "[2, 3]", "toplam": "5"],
        callStack: [
          CallFrame(functionName: "test", locals: [:]),
          CallFrame(functionName: "toplam", locals: ["biriken": "5"]),
        ]
      ),
      Step(
        7,
        "Beklenen 5 doğrulanır. Bu test bir kez geçtikten sonra saklanırsa regression testi olur.",
        memory: ["toplam": "5", "beklenen": "5", "karşılaştırma": "true"],
        output: "true"
      ),
    ],
    transferCode: [
      "struct BosDepo { func sayilar() -> [Int] { [] } }",
      "print(BosDepo().sayilar().reduce(0, +) == 0)",
    ],
    transferChoices: ["true", "false", "Hata", "0"],
    transferAnswer: "true",
    extraQuizzes: [
      Quiz(
        [
          "struct Depo { func sayilar() -> [Int] { [1, 1, 1] } }",
          "func toplam(depo: Depo) -> Int { depo.sayilar().reduce(0, +) }",
          "print(toplam(depo: Depo()))",
        ],
        choices: ["3", "1", "0", "[1, 1, 1]"],
        answer: "3",
        explanation: "İki parça birlikte çalışır: depo veriyi verir, toplam onu birleştirir."
      ),
      Quiz(
        [
          "struct Depo { func sayilar() -> [Int] { [] } }",
          "func toplam(depo: Depo) -> Int { depo.sayilar().reduce(0, +) }",
          "print(toplam(depo: Depo()) == 0)",
        ],
        choices: ["true", "false", "Hata", "0"],
        answer: "true",
        explanation: "Bir kez düzeltilen boş liste davranışını koruyan test regression testidir."
      ),
    ],
    estimatedMinutes: 9
  ),
  RoadmapBlueprint(
    id: "acceptance-criteria",
    order: 36,
    section: .technicalAnalysis,
    topic: "KABUL KRİTERİ",
    title: "İsteği ölçülebilir hale getir",
    objective: "Belirsiz bir ürün isteğini örneklerle doğrulanabilir kurala dönüştür.",
    takeaway:
      "İyi kabul kriteri belirli bir girdi, gözlenebilir davranış ve net bir beklenen sonuç taşır.",
    teaching: LessonTeaching(
      whyItMatters:
        "'Kargo bedava olsun' cümlesi kodlanamaz. Kriter ancak somut bir girdi ve beklenen sonuçla ölçülebilir hale gelir.",
      commonMistake:
        "Eşiği belirsiz bırakmak: '500 üzerinde' ifadesi 500'ün kendisinin dahil olup olmadığını söylemez.",
      realWorldUse:
        "Kabul kriterleri hem geliştiricinin ne yazacağını hem de test edenin neyi doğrulayacağını aynı cümleyle belirler."
    ),
    code: [
      "func kargoUcreti(sepet: Int) -> Int {",
      "    sepet >= 500 ? 0 : 50",
      "}",
      "let kriterSaglandi = kargoUcreti(sepet: 500) == 0",
      "print(kriterSaglandi)",
    ],
    choices: ["true", "false", "500", "0"],
    answer: "true",
    steps: [
      Step(
        4, "Kriter tam eşik değeriyle denenir: 500. Belirsizliğin çözüldüğü tek girdi budur.",
        memory: ["sepet": "500", "eşik": "500"],
        callStack: [
          CallFrame(functionName: "kriter testi", locals: [:]),
          CallFrame(functionName: "kargoUcreti", locals: ["sepet": "500"]),
        ]
      ),
      Step(
        2, "Kural `>=` yazıldığı için eşiğin kendisi de bedava kargoya dahil: sonuç 0.",
        memory: ["sepet": "500", "koşul": "500 >= 500", "kargo": "0"],
        callStack: [
          CallFrame(functionName: "kriter testi", locals: [:]),
          CallFrame(functionName: "kargoUcreti", locals: ["sonuç": "0"]),
        ]
      ),
      Step(
        5, "Kriter sağlandı. Kural `>` olsaydı aynı sepet 50 öderdi; kriter bu farkı yazıya döker.",
        memory: ["kriterSaglandi": "true", "`>` olsaydı": "50"],
        output: "true"
      ),
    ],
    debugKind: .logic,
    debugCode: [
      "func kargoUcreti(sepet: Int) -> Int {",
      "    sepet > 500 ? 0 : 50",
      "}",
      "let kriterSaglandi = kargoUcreti(sepet: 500) == 0",
      "print(kriterSaglandi)",
    ],
    debugLine: 2,
    expected: "true",
    actual: "false",
    practices: [
      PracticeChallenge(
        kind: .concept,
        prompt: "\"500 ve üzeri\" ifadesi hangi karşılaştırmaya karşılık gelir?",
        choices: [">=", ">", "<", "<="],
        correctAnswer: ">=",
        explanation: "\"ve üzeri\" sınırın kendisini de kapsar; bu yüzden eşitlik dahil edilir."
      )
    ],
    transferCode: [
      "print(kargoUcreti(sepet: 499) == 50)"
    ],
    transferChoices: ["true", "false", "50", "0"],
    transferAnswer: "true",
    extraQuizzes: [
      Quiz(
        [
          "func kargoUcreti(sepet: Int) -> Int { sepet >= 500 ? 0 : 50 }",
          "print(kargoUcreti(sepet: 501))",
        ],
        choices: ["0", "50", "501", "true"],
        answer: "0",
        explanation: "Eşiğin üstü kriteri sağlar; asıl belirsizlik tam eşikte çözülür."
      ),
      Quiz(
        [
          "func kargoUcreti(sepet: Int) -> Int { sepet > 500 ? 0 : 50 }",
          "print(kargoUcreti(sepet: 500))",
        ],
        choices: ["50", "0", "500", "true"],
        answer: "50",
        explanation: "`>` yazıldığında 500 eşiğin dışında kalır; kriter bu farkı açıkça yazmalıdır."
      ),
    ],
    estimatedMinutes: 8
  ),
  RoadmapBlueprint(
    id: "system-flow",
    order: 37,
    section: .technicalAnalysis,
    topic: "SİSTEM AKIŞI",
    title: "Eylem hangi adımlardan geçer?",
    objective: "Kullanıcı eylemini arayüzden iş kuralına ve sonuca kadar sırala.",
    takeaway:
      "Teknik analiz, mutlu yol kadar hata yolunu da girişten son kullanıcı sonucuna kadar görünür kılar.",
    teaching: LessonTeaching(
      whyItMatters:
        "Bir eylemin hangi adımlardan geçtiğini yazmadan hangi adımın çökebileceğini de bilemezsin. Akış, risk analizinin haritasıdır.",
      commonMistake:
        "Yalnızca her şeyin yolunda gittiği yolu çizmek. Hata yolu yazılmazsa kullanıcı boş ekranla karşılaşır.",
      realWorldUse:
        "Giriş, ödeme ve dosya yükleme akışlarının her adımı için 'burada başarısız olursa kullanıcı ne görür' sorusu cevaplanır."
    ),
    code: [
      "func kimlikDogrula(token: String) -> Bool { !token.isEmpty }",
      "func profilYukle(girisVar: Bool) -> String {",
      "    girisVar ? \"Profil\" : \"Giriş gerekli\"",
      "}",
      "let girisVar = kimlikDogrula(token: \"abc\")",
      "print(profilYukle(girisVar: girisVar))",
    ],
    choices: ["Profil", "Giriş gerekli", "abc", "true"],
    answer: "Profil",
    steps: [
      Step(
        4, "Akış girdiyle başlar: elde dolu bir token var.",
        memory: ["token": "\"abc\"", "girisVar": "henüz yok"],
        callStack: [CallFrame(functionName: "ekran", locals: ["token": "\"abc\""])]
      ),
      Step(
        1, "Birinci adım kimliği doğrular. Token boş olmadığı için kapı açılır.",
        memory: ["token": "\"abc\"", "girisVar": "true"],
        callStack: [
          CallFrame(functionName: "ekran", locals: [:]),
          CallFrame(functionName: "kimlikDogrula", locals: ["token": "\"abc\"", "sonuç": "true"]),
        ]
      ),
      Step(
        3,
        "İkinci adım birincinin kararına bakar. Buradaki çatal, mutlu yol ile hata yolunu ayırır.",
        memory: ["girisVar": "true", "seçilen yol": "mutlu yol"],
        callStack: [
          CallFrame(functionName: "ekran", locals: [:]),
          CallFrame(functionName: "profilYukle", locals: ["girisVar": "true"]),
        ]
      ),
      Step(
        5,
        "Kullanıcının gördüğü sonuç budur. Token boş olsaydı aynı akış 'Giriş gerekli' ile biterdi.",
        memory: ["girisVar": "true", "ekran sonucu": "\"Profil\""],
        output: "Profil",
        callStack: [CallFrame(functionName: "ekran", locals: ["gösterilen": "Profil"])]
      ),
    ],
    transferCode: [
      "let girisVar = kimlikDogrula(token: \"\")",
      "print(profilYukle(girisVar: girisVar))",
    ],
    transferChoices: ["Profil", "Giriş gerekli", "Boş", "false"],
    transferAnswer: "Giriş gerekli",
    extraQuizzes: [
      Quiz(
        [
          "func dogrula(_ sifre: String) -> Bool { sifre.count >= 6 }",
          "func sonuc(_ gecti: Bool) -> String { gecti ? \"Açıldı\" : \"Kısa şifre\" }",
          "print(sonuc(dogrula(\"12345\")))",
        ],
        choices: ["Kısa şifre", "Açıldı", "false", "12345"],
        answer: "Kısa şifre",
        explanation: "Beş karakter kuralı geçemez; akış hata yoluna sapar ve kullanıcı bunu görür."
      ),
      Quiz(
        [
          "func dogrula(_ sifre: String) -> Bool { sifre.count >= 6 }",
          "func sonuc(_ gecti: Bool) -> String { gecti ? \"Açıldı\" : \"Kısa şifre\" }",
          "print(sonuc(dogrula(\"123456\")))",
        ],
        choices: ["Açıldı", "Kısa şifre", "true", "123456"],
        answer: "Açıldı",
        explanation: "Tam sınır kuralı sağlar; mutlu yol buradan devam eder."
      ),
    ],
    estimatedMinutes: 8
  ),
  RoadmapBlueprint(
    id: "data-contracts",
    order: 38,
    section: .technicalAnalysis,
    topic: "VERİ SÖZLEŞMESİ",
    title: "Hangi veri garanti ediliyor?",
    objective: "Alanların türünü, zorunluluğunu ve eksik veri davranışını analiz et.",
    takeaway:
      "Veri sözleşmesi alanların anlamını ve yokluk davranışını açıklar; istemci varsayım yapmak zorunda kalmaz.",
    teaching: LessonTeaching(
      whyItMatters:
        "Bir alanın zorunlu mu isteğe bağlı mı olduğu, o alanı kullanan her satırın nasıl yazılacağını belirler.",
      commonMistake:
        "Sunucu şimdiye kadar hep dolu gönderdiği için alanı zorunlu saymak. Sözleşme 'olabilir' diyorsa bir gün boş gelir.",
      realWorldUse:
        "API dokümanındaki 'nullable' işareti, istemcide varsayılan değer mi hata mesajı mı gösterileceğini belirleyen karardır."
    ),
    code: [
      "struct KullaniciDTO { let ad: String? }",
      "func baslik(_ kullanici: KullaniciDTO) -> String {",
      "    kullanici.ad ?? \"Misafir\"",
      "}",
      "print(baslik(KullaniciDTO(ad: nil)))",
    ],
    choices: ["Misafir", "nil", "Hata", "Optional(nil)"],
    answer: "Misafir",
    steps: [
      Step(
        1,
        "Sözleşme türde yazılı: ad alanı String? yani boş gelebilir. Bu bir olasılık değil, garanti edilmiş bir durum.",
        memory: ["KullaniciDTO.ad": "String? (boş olabilir)"]
      ),
      Step(
        4, "İstemci sözleşmenin izin verdiği durumu gönderir: ad yok.",
        memory: ["kullanici.ad": "nil"],
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "baslik", locals: ["kullanici.ad": "nil"]),
        ]
      ),
      Step(
        3,
        "`??` yokluk durumunu açıkça karşılar. Sözleşme okunmasaydı burada `!` yazılır ve program çökerdi.",
        memory: ["kullanici.ad": "nil", "kullanılan varsayılan": "\"Misafir\""],
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "baslik", locals: ["sonuç": "\"Misafir\""]),
        ]
      ),
      Step(
        4, "Kullanıcı boş ekran yerine anlamlı bir başlık görür.",
        memory: ["kullanici.ad": "nil", "başlık": "\"Misafir\""],
        output: "Misafir"
      ),
    ],
    practices: [
      PracticeChallenge(
        kind: .concept,
        prompt: "Sözleşmede bir alan boş gelebilir diyorsa istemci ne yapmalı?",
        choices: [
          "Yokluk durumunu karşılamalı", "`!` ile açmalı", "Alanı yok saymalı",
          "Sunucudan düzeltmesini beklemeli",
        ],
        correctAnswer: "Yokluk durumunu karşılamalı",
        explanation:
          "Sözleşme boşluğa izin veriyorsa o durum bir gün gelir; karşılanmamışsa çökme olur."
      )
    ],
    transferCode: [
      "print(baslik(KullaniciDTO(ad: \"Ada\")))"
    ],
    transferChoices: ["Ada", "Misafir", "nil", "Optional(\"Ada\")"],
    transferAnswer: "Ada",
    extraQuizzes: [
      Quiz(
        [
          "struct DTO { let adet: Int? }", "func goster(_ d: DTO) -> Int { d.adet ?? 0 }",
          "print(goster(DTO(adet: 5)))",
        ],
        choices: ["5", "0", "nil", "Hata"],
        answer: "5",
        explanation: "Alan doluyken sözleşmedeki varsayılan devreye girmez."
      ),
      Quiz(
        [
          "struct DTO { let adet: Int? }", "func goster(_ d: DTO) -> Int { d.adet! }",
          "print(goster(DTO(adet: nil)))",
        ],
        choices: ["Hata", "0", "nil", "Optional(nil)"],
        answer: "Hata",
        explanation: "Sözleşme boş gelebileceğini söylüyorken `!` yazmak çökmeyi kabul etmektir."
      ),
    ],
    estimatedMinutes: 8
  ),
  RoadmapBlueprint(
    id: "impact-risk",
    order: 39,
    section: .technicalAnalysis,
    topic: "ETKİ VE RİSK ANALİZİ",
    title: "Bu değişiklik nereyi etkiler?",
    objective: "Bir davranış değişikliğinin bağımlı sözleşme ve çağrılara etkisini çıkar.",
    takeaway:
      "Etki analizi değişen sözleşmeyi, onu kullanan bileşenleri, veri geçişini ve geri dönüş riskini birlikte inceler.",
    teaching: LessonTeaching(
      whyItMatters:
        "Bir satırı değiştirmenin maliyeti o satırda değil, ona bağlı yerlerde ortaya çıkar. Etki alanını çıkarmadan risk tahmini yapılamaz.",
      commonMistake:
        "Yalnızca değiştirilen dosyaya bakmak. Sözleşmeyi kullanan her çağrı noktası aynı değişiklikten etkilenir.",
      realWorldUse:
        "Vergi oranı, ücret kuralı veya API alanı değişirken 'kimler bu sözleşmeye bağlı' sorusu değişikliğin gerçek kapsamını verir."
    ),
    code: [
      "protocol Vergi { func hesapla(fiyat: Int) -> Int }",
      "struct SabitVergi: Vergi {",
      "    func hesapla(fiyat: Int) -> Int { 20 }",
      "}",
      "func toplam(fiyat: Int, vergi: Vergi) -> Int {",
      "    fiyat + vergi.hesapla(fiyat: fiyat)",
      "}",
      "print(toplam(fiyat: 100, vergi: SabitVergi()))",
    ],
    choices: ["100", "120", "20", "140"],
    answer: "120",
    steps: [
      Step(
        1, "Sözleşme burada tanımlanır. Değişecek olan şey buysa, ona bağlı her yer etkilenir.",
        memory: ["Vergi sözleşmesi": "hesapla(fiyat:) -> Int", "bağlı olanlar": "toplam"],
        architecture: dependencySnapshot(
          owner: "toplam",
          contract: "Vergi",
          implementation: "SabitVergi"
        )
      ),
      Step(
        8,
        "Çağrı somut bir uygulamayla yapılır. toplam hangi uygulamanın geldiğini bilmez, yalnızca sözleşmeye güvenir.",
        memory: ["fiyat": "100", "gelen uygulama": "SabitVergi"],
        callStack: [
          CallFrame(functionName: "program", locals: ["fiyat": "100"]),
          CallFrame(functionName: "toplam", locals: ["fiyat": "100"]),
        ]
      ),
      Step(
        3, "Vergi hesabı çalışır ve 20 döner. Bu sayı değişirse toplam da sessizce değişir.",
        memory: ["fiyat": "100", "vergi": "20"],
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "toplam", locals: ["fiyat": "100"]),
          CallFrame(functionName: "SabitVergi.hesapla", locals: ["sonuç": "20"]),
        ]
      ),
      Step(
        6, "İki değer birleşir: 100 + 20 = 120.",
        memory: ["fiyat": "100", "vergi": "20", "toplam": "120"],
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "toplam", locals: ["sonuç": "120"]),
        ]
      ),
      Step(
        8,
        "Etki zinciri görünür oldu: hesapla değişirse toplam, toplamı kullanan her ekran da değişir.",
        memory: ["toplam": "120", "etki zinciri": "hesapla → toplam → çağıranlar"],
        output: "120",
        architecture: dependencySnapshot(
          owner: "toplam",
          contract: "Vergi",
          implementation: "SabitVergi"
        )
      ),
    ],
    transferCode: [
      "print(toplam(fiyat: 80, vergi: SabitVergi()))"
    ],
    transferChoices: ["80", "100", "20", "160"],
    transferAnswer: "100",
    extraQuizzes: [
      Quiz(
        [
          "protocol Vergi { func hesapla(fiyat: Int) -> Int }", "struct OranliVergi: Vergi {",
          "    func hesapla(fiyat: Int) -> Int { fiyat / 10 }", "}",
          "func toplam(fiyat: Int, vergi: Vergi) -> Int { fiyat + vergi.hesapla(fiyat: fiyat) }",
          "print(toplam(fiyat: 200, vergi: OranliVergi()))",
        ],
        choices: ["220", "200", "20", "240"],
        answer: "220",
        explanation: "Sözleşme aynı kaldığı için toplam değişmedi; yalnızca uygulama değişti."
      ),
      Quiz(
        [
          "protocol Vergi { func hesapla(fiyat: Int) -> Int }", "struct SifirVergi: Vergi {",
          "    func hesapla(fiyat: Int) -> Int { 0 }", "}",
          "func toplam(fiyat: Int, vergi: Vergi) -> Int { fiyat + vergi.hesapla(fiyat: fiyat) }",
          "print(toplam(fiyat: 150, vergi: SifirVergi()))",
        ],
        choices: ["150", "0", "170", "300"],
        answer: "150",
        explanation:
          "Tek bir uygulamayı değiştirmek, o sözleşmeyi kullanan her çağrının sonucunu etkiler."
      ),
    ],
    estimatedMinutes: 9
  ),
  RoadmapBlueprint(
    id: "technical-analysis-capstone",
    order: 40,
    section: .technicalAnalysis,
    topic: "TEKNİK ANALİZ MEYDAN OKUMASI",
    title: "İstekten uygulanabilir plana",
    objective:
      "Kabul kriteri, sistem akışı, veri, bağımlılık, test ve riskleri tek analizde birleştir.",
    takeaway:
      "Uygulanabilir teknik plan; kapsamı, akışı, veri sözleşmesini, bağımlılıkları, riskleri ve doğrulama stratejisini birlikte taşır.",
    teaching: LessonTeaching(
      whyItMatters:
        "Uygulanabilir plan, kodu yazmadan önce hangi yolların var olduğunu ve her yolun kullanıcıya ne döndüreceğini belirler.",
      commonMistake:
        "Yalnızca onay yolunu planlayıp geçersiz girdi ile stok yokluğunu 'sonra bakarız' diye bırakmak. Bu iki yol da kullanıcı deneyiminin parçası.",
      realWorldUse:
        "Sipariş, rezervasyon ve ödeme akışlarında her guard bir kabul kriterine, her kriter de bir teste karşılık gelir."
    ),
    code: [
      "struct Siparis { let adet: Int }",
      "protocol Stok { func varMi(adet: Int) -> Bool }",
      "struct SabitStok: Stok {",
      "    let mevcut: Bool",
      "    func varMi(adet: Int) -> Bool { mevcut }",
      "}",
      "func tamamla(_ siparis: Siparis, stok: Stok) -> String {",
      "    guard siparis.adet > 0 else { return \"Geçersiz adet\" }",
      "    guard stok.varMi(adet: siparis.adet) else { return \"Stok yok\" }",
      "    return \"Onay\"",
      "}",
      "let siparis = Siparis(adet: 2)",
      "print(tamamla(siparis, stok: SabitStok(mevcut: true)))",
    ],
    choices: ["Onay", "Stok yok", "Geçersiz adet", "Program çöker"],
    answer: "Onay",
    steps: [
      Step(
        13,
        "Girdi hazırlanır: adet 2 ve stok mevcut. Plandaki üç yoldan hangisinin izleneceği bu girdiye bağlı.",
        memory: ["siparis.adet": "2", "stok.mevcut": "true", "olası sonuçlar": "3"],
        callStack: [CallFrame(functionName: "program", locals: ["adet": "2"])],
        architecture: dependencySnapshot(
          owner: "tamamla",
          contract: "Stok",
          implementation: "SabitStok"
        )
      ),
      Step(
        8,
        "Birinci guard adet kuralını sınar: 2 > 0 doğru olduğu için erken dönüş olmaz ve akış devam eder.",
        memory: ["siparis.adet": "2", "1. kriter": "geçti"],
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "tamamla", locals: ["siparis.adet": "2"]),
        ]
      ),
      Step(
        9,
        "İkinci guard stok bağımlılığına sorar. Karar dışarıdan gelir; tamamla bunu kendi bilmez.",
        memory: ["siparis.adet": "2", "1. kriter": "geçti", "2. kriter": "sorgulanıyor"],
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "tamamla", locals: [:]),
          CallFrame(functionName: "SabitStok.varMi", locals: ["adet": "2", "sonuç": "true"]),
        ]
      ),
      Step(
        10,
        "İki kriter de geçildiği için mutlu yola ulaşılır. Diğer iki dönüş bu çalıştırmada hiç görülmedi.",
        memory: ["1. kriter": "geçti", "2. kriter": "geçti", "sonuç": "\"Onay\""],
        output: "Onay",
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "tamamla", locals: ["sonuç": "\"Onay\""]),
        ],
        architecture: dependencySnapshot(
          owner: "tamamla",
          contract: "Stok",
          implementation: "SabitStok"
        )
      ),
    ],
    assessmentTasks: [
      AssessmentTask(
        kind: .outputPrediction,
        prompt: "Mutlu yol ve iki hata yolunun sonuçlarını yaz.",
        rubric: AssessmentRubric(
          requiredConcepts: ["Onay", "Geçersiz adet", "Stok yok"],
          modelAnswer:
            "Pozitif ve mevcut stokta Onay; sıfır adette Geçersiz adet; stok yoksa Stok yok."
        )
      ),
      AssessmentTask(
        kind: .callOrder,
        prompt: "Siparişten stok kontrolüne uzanan çağrı sırasını açıkla.",
        rubric: AssessmentRubric(
          requiredConcepts: ["tamamla", "varMi", "stok"],
          modelAnswer:
            "tamamla önce adedi doğrular, sonra stok.varMi çağrısıyla stok kontrolü yapar."
        )
      ),
      AssessmentTask(
        kind: .errorLocation,
        prompt: "Sıfır adet ve stok yok risklerini hangi satırların karşıladığını göster.",
        rubric: AssessmentRubric(
          requiredConcepts: ["guard", "adet", "stok"],
          modelAnswer: "İlk guard adet riskini, ikinci guard stok riskini erken dönüşle karşılar."
        )
      ),
      AssessmentTask(
        kind: .freeExplanation,
        prompt: "Bu özellik için kabul kriteri ve test planını kendi cümlenle yaz.",
        rubric: AssessmentRubric(
          requiredConcepts: ["kabul kriteri", "risk", "test"],
          modelAnswer:
            "Kabul kriteri üç sonucu tanımlar; adet ve stok riskleri ayrı testlerle doğrulanır."
        )
      ),
    ],
    transferCode: [
      "let siparis = Siparis(adet: 1)",
      "print(tamamla(siparis, stok: SabitStok(mevcut: false)))",
    ],
    transferChoices: ["Onay", "Stok yok", "Geçersiz adet", "Program çöker"],
    transferAnswer: "Stok yok",
    extraQuizzes: [
      Quiz(
        [
          "struct Siparis { let adet: Int }", "protocol Stok { func varMi(adet: Int) -> Bool }",
          "struct SabitStok: Stok {", "    let mevcut: Bool",
          "    func varMi(adet: Int) -> Bool { mevcut }", "}",
          "func tamamla(_ s: Siparis, stok: Stok) -> String {",
          "    guard s.adet > 0 else { return \"Geçersiz adet\" }",
          "    guard stok.varMi(adet: s.adet) else { return \"Stok yok\" }", "    return \"Onay\"",
          "}", "print(tamamla(Siparis(adet: 0), stok: SabitStok(mevcut: true)))",
        ],
        choices: ["Geçersiz adet", "Onay", "Stok yok", "Program çöker"],
        answer: "Geçersiz adet",
        explanation: "İlk guard geçilemez; stok hiç sorulmadan erken dönüş yapılır."
      ),
      Quiz(
        [
          "struct Siparis { let adet: Int }", "protocol Stok { func varMi(adet: Int) -> Bool }",
          "struct SabitStok: Stok {", "    let mevcut: Bool",
          "    func varMi(adet: Int) -> Bool { mevcut }", "}",
          "func tamamla(_ s: Siparis, stok: Stok) -> String {",
          "    guard s.adet > 0 else { return \"Geçersiz adet\" }",
          "    guard stok.varMi(adet: s.adet) else { return \"Stok yok\" }", "    return \"Onay\"",
          "}", "print(tamamla(Siparis(adet: 2), stok: SabitStok(mevcut: false)))",
        ],
        choices: ["Stok yok", "Onay", "Geçersiz adet", "Program çöker"],
        answer: "Stok yok",
        explanation: "Adet kuralı geçilir ama stok bağımlılığı hayır der; ikinci hata yolu çalışır."
      ),
    ],
    estimatedMinutes: 10
  ),
]

private func objectSnapshot(
  className: String,
  instanceName: String,
  valueLabel: String
) -> ArchitectureSnapshot {
  ArchitectureSnapshot(
    entities: [
      ArchitectureEntity(id: "class", label: className, kind: .class),
      ArchitectureEntity(id: "instance", label: instanceName, kind: .instance),
      ArchitectureEntity(id: "value", label: valueLabel, kind: .value),
    ],
    relationships: [
      ArchitectureRelationship(sourceID: "instance", targetID: "class", label: "örneğidir"),
      ArchitectureRelationship(sourceID: "instance", targetID: "value", label: "sahiptir"),
    ]
  )
}

private func valueCopySnapshot() -> ArchitectureSnapshot {
  ArchitectureSnapshot(
    entities: [
      ArchitectureEntity(id: "a", label: "a.x = 1", kind: .value),
      ArchitectureEntity(id: "b", label: "b.x = 9", kind: .value),
    ],
    relationships: [
      ArchitectureRelationship(sourceID: "b", targetID: "a", label: "bağımsız kopyasıdır")
    ]
  )
}

private func compositionSnapshot() -> ArchitectureSnapshot {
  ArchitectureSnapshot(
    entities: [
      ArchitectureEntity(id: "araba", label: "Araba", kind: .instance),
      ArchitectureEntity(id: "motor", label: "Motor", kind: .instance),
    ],
    relationships: [
      ArchitectureRelationship(sourceID: "araba", targetID: "motor", label: "sahiptir")
    ]
  )
}

private func inheritanceSnapshot() -> ArchitectureSnapshot {
  ArchitectureSnapshot(
    entities: [
      ArchitectureEntity(id: "hayvan", label: "Hayvan", kind: .class),
      ArchitectureEntity(id: "kedi", label: "Kedi", kind: .class),
      ArchitectureEntity(id: "instance", label: "Kedi instance", kind: .instance),
    ],
    relationships: [
      ArchitectureRelationship(sourceID: "kedi", targetID: "hayvan", label: "miras alır"),
      ArchitectureRelationship(sourceID: "instance", targetID: "kedi", label: "örneğidir"),
    ]
  )
}

private func architectureChallengeSnapshot() -> ArchitectureSnapshot {
  ArchitectureSnapshot(
    entities: [
      ArchitectureEntity(id: "model", label: "EkranModeli", kind: .instance),
      ArchitectureEntity(id: "servis", label: "Servis", kind: .instance),
      ArchitectureEntity(id: "depo", label: "Depo", kind: .instance),
    ],
    relationships: [
      ArchitectureRelationship(sourceID: "model", targetID: "servis", label: "kullanır"),
      ArchitectureRelationship(sourceID: "servis", targetID: "depo", label: "kullanır"),
    ]
  )
}

private func appFlowSnapshot() -> ArchitectureSnapshot {
  ArchitectureSnapshot(
    entities: [
      ArchitectureEntity(id: "view", label: "View", kind: .instance),
      ArchitectureEntity(id: "viewModel", label: "ViewModel", kind: .instance),
      ArchitectureEntity(id: "repository", label: "Repository", kind: .instance),
    ],
    relationships: [
      ArchitectureRelationship(sourceID: "view", targetID: "viewModel", label: "eylem gönderir"),
      ArchitectureRelationship(
        sourceID: "viewModel",
        targetID: "repository",
        label: "veri ister"
      ),
    ]
  )
}

private func capstoneSnapshot() -> ArchitectureSnapshot {
  ArchitectureSnapshot(
    entities: [
      ArchitectureEntity(id: "plan", label: "Planlayici", kind: .instance),
      ArchitectureEntity(id: "gorev1", label: "Gorev(2)", kind: .value),
      ArchitectureEntity(id: "gorev2", label: "Gorev(4)", kind: .value),
    ],
    relationships: [
      ArchitectureRelationship(sourceID: "plan", targetID: "gorev1", label: "tutar"),
      ArchitectureRelationship(sourceID: "plan", targetID: "gorev2", label: "tutar"),
    ]
  )
}

private func dependencySnapshot(
  owner: String,
  contract: String,
  implementation: String
) -> ArchitectureSnapshot {
  ArchitectureSnapshot(
    entities: [
      ArchitectureEntity(id: "owner", label: owner, kind: .function),
      ArchitectureEntity(id: "contract", label: contract, kind: .class),
      ArchitectureEntity(id: "implementation", label: implementation, kind: .instance),
    ],
    relationships: [
      ArchitectureRelationship(sourceID: "owner", targetID: "contract", label: "kullanır"),
      ArchitectureRelationship(
        sourceID: "implementation",
        targetID: "contract",
        label: "uygular"
      ),
    ]
  )
}
