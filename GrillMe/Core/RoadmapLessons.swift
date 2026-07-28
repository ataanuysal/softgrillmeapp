extension XRayLesson {
  public static let roadmapContinuation = roadmapBlueprints.map(\.lesson)
}

private struct RoadmapBlueprint {
  let id: String
  let order: Int
  let section: CurriculumSection
  let topic: String
  let title: String
  let objective: String
  let takeaway: String
  let code: [String]
  let choices: [String]
  let answer: String
  let memory: [String: String]
  let callStack: [CallFrame]
  let architecture: ArchitectureSnapshot?
  let debugKind: DebugErrorKind?
  let debugLine: Int
  let expected: String
  let actual: String
  let practices: [PracticeChallenge]
  let assessmentTasks: [AssessmentTask]
  let transferCode: [String]
  let transferChoices: [String]
  let transferAnswer: String
  let estimatedMinutes: Int

  init(
    id: String,
    order: Int,
    section: CurriculumSection,
    topic: String,
    title: String,
    objective: String,
    takeaway: String,
    code: [String],
    choices: [String],
    answer: String,
    memory: [String: String] = [:],
    callStack: [CallFrame] = [],
    architecture: ArchitectureSnapshot? = nil,
    debugKind: DebugErrorKind? = nil,
    debugLine: Int = 1,
    expected: String = "",
    actual: String = "",
    practices: [PracticeChallenge] = [],
    assessmentTasks: [AssessmentTask] = [],
    transferCode: [String] = [],
    transferChoices: [String] = [],
    transferAnswer: String = "",
    estimatedMinutes: Int = 7
  ) {
    self.id = id
    self.order = order
    self.section = section
    self.topic = topic
    self.title = title
    self.objective = objective
    self.takeaway = takeaway
    self.code = code
    self.choices = choices
    self.answer = answer
    self.memory = memory
    self.callStack = callStack
    self.architecture = architecture
    self.debugKind = debugKind
    self.debugLine = debugLine
    self.expected = expected
    self.actual = actual
    self.practices = practices
    self.assessmentTasks = assessmentTasks
    self.transferCode = transferCode
    self.transferChoices = transferChoices
    self.transferAnswer = transferAnswer
    self.estimatedMinutes = estimatedMinutes
  }

  var lesson: XRayLesson {
    let source = numbered(code)
    let finalLine = source.last?.number ?? 1
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
      trace: [
        TraceStep(
          lineNumber: source.first?.number ?? 1,
          explanation: "Önce giriş değerleri ve çalışacak yapılar hazırlanır.",
          memory: [:],
          output: nil,
          callStack: callStack.first.map { [$0] } ?? [],
          architecture: nil
        ),
        TraceStep(
          lineNumber: finalLine,
          explanation: takeaway,
          memory: memory,
          output: answer,
          callStack: callStack,
          architecture: architecture
        ),
      ],
      transferChallenge: TransferChallenge(
        prompt: "Aynı zihinsel modeli yeni durumda uygula. Sonuç nedir?",
        code: transferSource,
        choices: resolvedTransferChoices,
        correctAnswer: resolvedTransferAnswer,
        explanation: takeaway
      ),
      estimatedMinutes: estimatedMinutes,
      debugChallenge: debugChallenge(source: source),
      section: section,
      practiceChallenges: practices,
      assessmentTasks: assessmentTasks
    )
  }

  private func debugChallenge(source: [CodeLine]) -> DebugChallenge? {
    guard let debugKind else { return nil }
    return DebugChallenge(
      kind: debugKind,
      prompt: "Önce bir hipotez kur, sonra sorunu üreten satırı seç.",
      code: source,
      correctLineNumber: debugLine,
      expected: expected,
      actual: actual.isEmpty ? answer : actual,
      explanation:
        "Beklenen \(expected), gerçek \(actual.isEmpty ? answer : actual). "
        + "\(debugLine). satır incelenmeli."
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
    code: [
      "let puan = 10",
      "func goster() {",
      "    let puan = 20",
      "    print(puan)",
      "}",
      "goster()",
      "print(puan)",
    ],
    choices: ["20 → 10", "10 → 20", "20 → 20"],
    answer: "20 → 10",
    memory: ["dış puan": "10", "yerel puan": "20"],
    callStack: [
      CallFrame(functionName: "program", locals: ["puan": "10"]),
      CallFrame(functionName: "goster", locals: ["puan": "20"]),
    ],
    transferCode: [
      "let ad = \"Dış\"",
      "func yaz() {",
      "    let ad = \"İç\"",
      "    print(ad)",
      "}",
      "yaz()",
      "print(ad)",
    ],
    transferChoices: ["İç → Dış", "Dış → İç", "İç → İç"],
    transferAnswer: "İç → Dış",
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
    code: [
      "func ikiKat(_ x: Int) -> Int { x * 2 }",
      "var sayac = 0",
      "func arttir() { sayac += 1 }",
      "print(ikiKat(3))",
      "arttir()",
      "print(sayac)",
    ],
    choices: ["6 → 1", "3 → 0", "6 → 0"],
    answer: "6 → 1",
    memory: ["sayac": "1"],
    callStack: [
      CallFrame(functionName: "program", locals: ["sayac": "1"]),
      CallFrame(functionName: "arttir", locals: [:]),
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
    transferChoices: ["4", "8", "16"],
    transferAnswer: "16",
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
    code: [
      "let sayilar = [1, 2, 3]",
      "let ikiler = sayilar.map { $0 * 2 }",
      "print(ikiler)",
    ],
    choices: ["[1, 2, 3]", "[2, 4, 6]", "[2, 3]"],
    answer: "[2, 4, 6]",
    memory: ["ikiler": "[2, 4, 6]"],
    callStack: [
      CallFrame(functionName: "program", locals: ["sayilar": "[1, 2, 3]"]),
      CallFrame(functionName: "map closure", locals: ["$0": "1, sonra 2, sonra 3"]),
    ],
    transferCode: [
      "let adlar = [\"ada\", \"can\"]",
      "let buyuk = adlar.map { $0.uppercased() }",
      "print(buyuk)",
    ],
    transferChoices: ["[\"ada\", \"can\"]", "[\"ADA\", \"CAN\"]", "[\"ADA\"]"],
    transferAnswer: "[\"ADA\", \"CAN\"]"
  ),
  RoadmapBlueprint(
    id: "filter-intro",
    order: 11,
    section: .functions,
    topic: "FILTER",
    title: "Yalnızca uyanları seç",
    objective: "filter koşulunu geçen elemanların yeni koleksiyona taşındığını gör.",
    takeaway: "filter değerleri değiştirmez; koşula uymayanları dışarıda bırakır.",
    code: [
      "let sayilar = [1, 2, 3, 4]",
      "let buyukler = sayilar.filter { $0 > 2 }",
      "print(buyukler)",
    ],
    choices: ["[1, 2]", "[3, 4]", "[2, 3, 4]"],
    answer: "[3, 4]",
    memory: ["buyukler": "[3, 4]"],
    callStack: [
      CallFrame(functionName: "program", locals: ["sayilar": "[1, 2, 3, 4]"]),
      CallFrame(functionName: "filter closure", locals: ["koşul": "$0 > 2"]),
    ],
    transferCode: [
      "let adlar = [\"Ada\", \"Can\", \"Ece\"]",
      "let kisa = adlar.filter { $0.count == 3 }",
      "print(kisa)",
    ],
    transferChoices: ["[\"Ada\", \"Can\", \"Ece\"]", "[\"Ada\", \"Can\"]", "[\"Ece\"]"],
    transferAnswer: "[\"Ada\", \"Can\", \"Ece\"]"
  ),
  RoadmapBlueprint(
    id: "arrays-index",
    order: 12,
    section: .collections,
    topic: "ARRAY VE INDEX",
    title: "Sıra sıfırdan başlar",
    objective: "Array elemanına index ile güvenle eriş.",
    takeaway: "Array index'i sıfırdan başlar; ikinci elemanın index'i 1'dir.",
    code: [
      "let renkler = [\"Kırmızı\", \"Mavi\", \"Yeşil\"]",
      "print(renkler[1])",
    ],
    choices: ["Kırmızı", "Mavi", "Yeşil"],
    answer: "Mavi",
    memory: ["renkler[1]": "\"Mavi\""],
    transferCode: [
      "let harfler = [\"A\", \"B\", \"C\"]",
      "print(harfler[0])",
    ],
    transferChoices: ["A", "B", "C"],
    transferAnswer: "A"
  ),
  RoadmapBlueprint(
    id: "dictionary-key",
    order: 13,
    section: .collections,
    topic: "DICTIONARY VE KEY",
    title: "Değeri anahtarla bul",
    objective: "Sıra yerine anlamlı bir key kullanarak değere eriş.",
    takeaway: "Dictionary'de değer konumla değil, benzersiz key ile bulunur.",
    code: [
      "let baskentler = [\"TR\": \"Ankara\", \"FR\": \"Paris\"]",
      "print(baskentler[\"TR\"]!)",
    ],
    choices: ["TR", "Ankara", "Paris"],
    answer: "Ankara",
    memory: ["baskentler[\"TR\"]": "\"Ankara\""],
    transferCode: [
      "let puanlar = [\"Ada\": 9, \"Can\": 7]",
      "print(puanlar[\"Can\"]!)",
    ],
    transferChoices: ["7", "9", "Can"],
    transferAnswer: "7"
  ),
  RoadmapBlueprint(
    id: "collections-challenge",
    order: 14,
    section: .collections,
    topic: "KOLEKSİYON MEYDAN OKUMASI",
    title: "Seç, dönüştür, topla",
    objective: "Array, filter ve reduce akışını birlikte takip et.",
    takeaway: "Koleksiyon zincirini her ara sonucu ayrı yazarak okuyabilirsin.",
    code: [
      "let sayilar = [1, 2, 3, 4]",
      "let ciftler = sayilar.filter { $0 % 2 == 0 }",
      "let toplam = ciftler.reduce(0, +)",
      "print(toplam)",
    ],
    choices: ["4", "6", "10"],
    answer: "6",
    memory: ["ciftler": "[2, 4]", "toplam": "6"],
    transferCode: [
      "let sayilar = [2, 3, 5]",
      "let toplam = sayilar.reduce(0, +)",
      "print(toplam)",
    ],
    transferChoices: ["5", "8", "10"],
    transferAnswer: "10",
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
    code: [
      "class Kutu { var deger = 5 }",
      "let kutu = Kutu()",
      "print(kutu.deger)",
    ],
    choices: ["Kutu", "0", "5"],
    answer: "5",
    memory: ["kutu.deger": "5"],
    architecture: objectSnapshot(
      className: "Kutu",
      instanceName: "kutu",
      valueLabel: "deger = 5"
    ),
    transferCode: [
      "class Lamba { var acik = true }",
      "let lamba = Lamba()",
      "print(lamba.acik)",
    ],
    transferChoices: ["true", "false", "Lamba"],
    transferAnswer: "true"
  ),
  RoadmapBlueprint(
    id: "property-method",
    order: 16,
    section: .objects,
    topic: "PROPERTY VE METHOD",
    title: "Nesne kendi verisini değiştirir",
    objective: "Bir method çağrısının instance property’sini nasıl değiştirdiğini izle.",
    takeaway: "Property nesnenin durumudur; method bu durum üzerinde davranış uygular.",
    code: [
      "class Sayac {",
      "    var deger = 0",
      "    func arttir() { deger += 1 }",
      "}",
      "let sayac = Sayac()",
      "sayac.arttir()",
      "print(sayac.deger)",
    ],
    choices: ["0", "1", "2"],
    answer: "1",
    memory: ["sayac.deger": "1"],
    architecture: objectSnapshot(
      className: "Sayac",
      instanceName: "sayac",
      valueLabel: "deger = 1"
    ),
    transferCode: [
      "let sayac = Sayac()",
      "sayac.arttir()",
      "sayac.arttir()",
      "print(sayac.deger)",
    ],
    transferChoices: ["0", "1", "2"],
    transferAnswer: "2"
  ),
  RoadmapBlueprint(
    id: "initializer",
    order: 17,
    section: .objects,
    topic: "INITIALIZER",
    title: "Nesne ilk değerini alır",
    objective: "Initializer argümanının yeni instance'ın property’sine taşınmasını izle.",
    takeaway: "Initializer, instance kullanılmadan önce gerekli başlangıç durumunu kurar.",
    code: [
      "class Kullanici {",
      "    let ad: String",
      "    init(ad: String) { self.ad = ad }",
      "}",
      "let kisi = Kullanici(ad: \"Ada\")",
      "print(kisi.ad)",
    ],
    choices: ["Kullanici", "ad", "Ada"],
    answer: "Ada",
    memory: ["kisi.ad": "\"Ada\""],
    architecture: objectSnapshot(
      className: "Kullanici",
      instanceName: "kisi",
      valueLabel: "ad = Ada"
    ),
    transferCode: [
      "let kisi = Kullanici(ad: \"Can\")",
      "print(kisi.ad)",
    ],
    transferChoices: ["Ada", "Can", "Kullanici"],
    transferAnswer: "Can"
  ),
  RoadmapBlueprint(
    id: "value-reference",
    order: 18,
    section: .objects,
    topic: "VALUE VE REFERENCE",
    title: "Kopya mı, aynı nesne mi?",
    objective: "Struct kopyasının bağımsız değer taşıdığını gözlemle.",
    takeaway: "Struct atamada değeri kopyalar; bir kopyadaki değişiklik diğerini değiştirmez.",
    code: [
      "struct Nokta { var x: Int }",
      "let a = Nokta(x: 1)",
      "var b = a",
      "b.x = 9",
      "print(a.x)",
    ],
    choices: ["1", "9", "Hata"],
    answer: "1",
    memory: ["a.x": "1", "b.x": "9"],
    architecture: valueCopySnapshot(),
    transferCode: [
      "var ilk = Nokta(x: 2)",
      "var ikinci = ilk",
      "ikinci.x = 7",
      "print(ilk.x)",
    ],
    transferChoices: ["2", "7", "Hata"],
    transferAnswer: "2",
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
    code: [
      "struct Motor { let tur = \"Elektrik\" }",
      "struct Araba { let motor: Motor }",
      "let araba = Araba(motor: Motor())",
      "print(araba.motor.tur)",
    ],
    choices: ["Araba", "Motor", "Elektrik"],
    answer: "Elektrik",
    memory: ["araba.motor.tur": "\"Elektrik\""],
    architecture: compositionSnapshot(),
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
    transferChoices: ["Pil", "Telefon", "80"],
    transferAnswer: "80"
  ),
  RoadmapBlueprint(
    id: "inheritance",
    order: 20,
    section: .objects,
    topic: "INHERITANCE",
    title: "Davranışı özelleştir",
    objective: "Alt class'ın miras aldığı methodu nasıl değiştirdiğini izle.",
    takeaway: "Inheritance ortak bir tür ilişkisi kurar; override özel davranışı seçer.",
    code: [
      "class Hayvan { func ses() -> String { \"?\" } }",
      "class Kedi: Hayvan {",
      "    override func ses() -> String { \"Miyav\" }",
      "}",
      "let hayvan: Hayvan = Kedi()",
      "print(hayvan.ses())",
    ],
    choices: ["?", "Miyav", "Kedi"],
    answer: "Miyav",
    memory: ["gerçek tür": "Kedi", "görünen tür": "Hayvan"],
    architecture: inheritanceSnapshot(),
    transferCode: [
      "class Kopek: Hayvan {",
      "    override func ses() -> String { \"Hav\" }",
      "}",
      "print(Kopek().ses())",
    ],
    transferChoices: ["?", "Miyav", "Hav"],
    transferAnswer: "Hav",
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
    code: [
      "struct Depo { let puan = 3 }",
      "struct Servis { let depo: Depo }",
      "struct EkranModeli { let servis: Servis }",
      "let model = EkranModeli(servis: Servis(depo: Depo()))",
      "print(model.servis.depo.puan)",
    ],
    choices: ["Depo", "Servis", "3"],
    answer: "3",
    memory: ["puan": "3"],
    architecture: architectureChallengeSnapshot(),
    transferCode: [
      "let servis = Servis(depo: Depo())",
      "print(servis.depo.puan)",
    ],
    transferChoices: ["3", "Servis", "Depo"],
    transferAnswer: "3",
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
    code: [
      "let puan =",
      "print(puan)",
    ],
    choices: ["Derlenmez", "0", "nil"],
    answer: "Derlenmez",
    debugKind: .syntax,
    debugLine: 1,
    expected: "bir başlangıç değeri",
    actual: "eksik ifade",
    transferCode: [
      "let ad: String",
      "print(ad)",
    ],
    transferChoices: ["Derlenmez", "Boş metin", "nil"],
    transferAnswer: "Derlenmez"
  ),
  RoadmapBlueprint(
    id: "logic-errors",
    order: 23,
    section: .debugging,
    topic: "LOGIC ERROR",
    title: "Çalışıyor ama yanlış",
    objective: "Derlenen kodda beklenen ve gerçek değer farkından hatalı satırı bul.",
    takeaway: "Logic error programı durdurmaz; yanlış varsayım yanlış sonuç üretir.",
    code: [
      "let fiyat = 100",
      "let indirimli = fiyat + 10",
      "print(indirimli)",
    ],
    choices: ["90", "100", "110"],
    answer: "110",
    memory: ["indirimli": "110"],
    debugKind: .logic,
    debugLine: 2,
    expected: "90",
    actual: "110",
    transferCode: [
      "let puan = 8",
      "let yeniPuan = puan - 2",
      "print(yeniPuan)",
    ],
    transferChoices: ["6", "8", "10"],
    transferAnswer: "6"
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
    code: [
      "func ilk(_ sayilar: [Int]) -> Int {",
      "    return sayilar[0]",
      "}",
      "print(ilk([]))",
    ],
    choices: ["0", "nil", "Hata"],
    answer: "Hata",
    debugKind: .edgeCase,
    debugLine: 2,
    expected: "boş listeyi güvenle ele almak",
    actual: "index hatası",
    transferCode: [
      "let sayilar: [Int] = []",
      "print(sayilar.first ?? 0)",
    ],
    transferChoices: ["0", "nil", "Hata"],
    transferAnswer: "0",
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
    code: [
      "let ad: String? = nil",
      "print(ad!)",
    ],
    choices: ["nil", "Boş", "Hata"],
    answer: "Hata",
    debugKind: .optional,
    debugLine: 2,
    expected: "güvenli varsayılan",
    actual: "nil zorla açma",
    transferCode: [
      "let ad: String? = nil",
      "print(ad ?? \"Misafir\")",
    ],
    transferChoices: ["nil", "Misafir", "Hata"],
    transferAnswer: "Misafir"
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
    code: [
      "func a() { b() }",
      "func b() { c() }",
      "func c() { fatalError(\"Boom\") }",
      "a()",
    ],
    choices: ["a()", "b()", "c()"],
    answer: "c()",
    callStack: [
      CallFrame(functionName: "a", locals: [:]),
      CallFrame(functionName: "b", locals: [:]),
      CallFrame(functionName: "c", locals: [:]),
    ],
    debugKind: .stackTrace,
    debugLine: 3,
    expected: "normal dönüş",
    actual: "fatalError",
    transferCode: [
      "func yukle() { parse() }",
      "func parse() { fatalError(\"Bozuk veri\") }",
      "yukle()",
    ],
    transferChoices: ["yukle()", "parse()", "program"],
    transferAnswer: "parse()",
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
    code: [
      "let sayilar = [1, 2, 3]",
      "print(sayilar[3])",
    ],
    choices: ["3", "nil", "Hata"],
    answer: "Hata",
    debugKind: .runtime,
    debugLine: 2,
    expected: "son eleman",
    actual: "index sınır dışı",
    transferCode: [
      "let sayilar = [1, 2, 3]",
      "print(sayilar[2])",
    ],
    transferChoices: ["2", "3", "Hata"],
    transferAnswer: "3",
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
      "Asenkron iş başlatıldığında mevcut akış beklemek zorunda değildir; sonuç daha sonra gelir.",
    code: [
      "print(\"A\")",
      "Task { print(\"B\") }",
      "print(\"C\")",
    ],
    choices: ["A → B → C", "A → C → B", "B → A → C"],
    answer: "A → C → B",
    memory: ["planlanan": "B"],
    callStack: [CallFrame(functionName: "program", locals: [:])],
    transferCode: [
      "print(\"Başla\")",
      "Task { print(\"Yüklendi\") }",
      "print(\"Arayüz hazır\")",
    ],
    transferChoices: [
      "Başla → Yüklendi → Arayüz hazır",
      "Başla → Arayüz hazır → Yüklendi",
      "Yüklendi → Başla → Arayüz hazır",
    ],
    transferAnswer: "Başla → Arayüz hazır → Yüklendi",
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
    code: [
      "struct Repository { func yukle() -> Int { 4 } }",
      "struct ViewModel {",
      "    let repository: Repository",
      "    func yenile() -> Int { repository.yukle() }",
      "}",
      "let model = ViewModel(repository: Repository())",
      "print(model.yenile())",
    ],
    choices: ["Repository", "ViewModel", "4"],
    answer: "4",
    memory: ["yüklenen değer": "4"],
    callStack: [
      CallFrame(functionName: "View", locals: [:]),
      CallFrame(functionName: "ViewModel.yenile", locals: [:]),
      CallFrame(functionName: "Repository.yukle", locals: [:]),
    ],
    architecture: appFlowSnapshot(),
    transferCode: [
      "let repository = Repository()",
      "print(repository.yukle())",
    ],
    transferChoices: ["4", "Repository", "ViewModel"],
    transferAnswer: "4",
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
    choices: ["Uygun: 4", "Yoğun: 6", "Yoğun: 8"],
    answer: "Yoğun: 6",
    memory: ["görev süreleri": "[2, 4]", "toplam": "6"],
    callStack: [
      CallFrame(functionName: "program", locals: ["plan": "Planlayici instance"]),
      CallFrame(functionName: "Planlayici.toplamSure", locals: ["gorevler": "[2, 4]"]),
      CallFrame(functionName: "durum", locals: ["sure": "6"]),
    ],
    architecture: capstoneSnapshot(),
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
      AssessmentTask(kind: .outputPrediction, prompt: "Programın son çıktısını tahmin et."),
      AssessmentTask(kind: .valueTrace, prompt: "gorevler ve toplam değerlerini izle."),
      AssessmentTask(kind: .callOrder, prompt: "Fonksiyon ve method çağrı sırasını açıkla."),
      AssessmentTask(
        kind: .errorLocation, prompt: "Boş görev edge case'inde riskli varsayımı bul."),
      AssessmentTask(kind: .freeExplanation, prompt: "Kodun amacını kendi cümlenle açıkla."),
    ],
    transferCode: [
      "let sure = 4",
      "print(durum(sure))",
    ],
    transferChoices: ["Uygun", "Yoğun", "4"],
    transferAnswer: "Uygun",
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
