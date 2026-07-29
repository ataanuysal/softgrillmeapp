extension XRayLesson {
  public static let compoundConditions = XRayLesson(
    id: "compound-conditions",
    order: 4,
    topic: "BİRLEŞİK KOŞULLAR",
    objective: "Birden fazla koşulun birlikte nasıl karar verdiğini izle.",
    takeaway: "`&&` kullanıldığında bütün koşullar doğru olmadan kod o yola girmez.",
    title: "İki şart da doğru mu?",
    question: "Bu kod ekrana hangi mesajı yazar?",
    code: [
      CodeLine(number: 1, text: "let yas = 22"),
      CodeLine(number: 2, text: "let uye = true"),
      CodeLine(number: 3, text: "if yas >= 18 && uye {"),
      CodeLine(number: 4, text: "    print(\"Girebilir\")"),
      CodeLine(number: 5, text: "} else {"),
      CodeLine(number: 6, text: "    print(\"Bekle\")"),
      CodeLine(number: 7, text: "}"),
    ],
    choices: ["Girebilir", "Bekle", "Çıktı yok", "Girebilir ve Bekle"],
    correctAnswer: "Girebilir",
    trace: [
      TraceStep(
        lineNumber: 1,
        explanation: "yas sabiti 22 değerini tutar.",
        memory: ["yas": "22"],
        output: nil
      ),
      TraceStep(
        lineNumber: 2,
        explanation: "uye değeri true olduğu için üyelik koşulu sağlanır.",
        memory: ["uye": "true", "yas": "22"],
        output: nil
      ),
      TraceStep(
        lineNumber: 3,
        explanation:
          "Sol koşul değerlendirilir: 22 >= 18 doğru. `&&` bu yüzden sağ tarafa da bakar.",
        memory: ["uye": "true", "yas": "22", "yas >= 18": "doğru"],
        output: nil
      ),
      TraceStep(
        lineNumber: 3,
        explanation:
          "Sağ koşul da doğru olduğu için birleşik ifade doğru olur ve if koluna girilir.",
        memory: [
          "uye": "true", "yas": "22", "yas >= 18": "doğru", "birleşik koşul": "doğru",
        ],
        output: nil
      ),
      TraceStep(
        lineNumber: 4,
        explanation: "Doğru olan if kolu Girebilir mesajını yazdırır.",
        memory: ["uye": "true", "yas": "22", "birleşik koşul": "doğru"],
        output: "Girebilir"
      ),
    ],
    transferChallenge: TransferChallenge(
      prompt: "Bu kez koşullardan biri yanlış. Çıktı ne olur?",
      code: [
        CodeLine(number: 1, text: "let stok = 3"),
        CodeLine(number: 2, text: "let aktif = false"),
        CodeLine(number: 3, text: "if stok > 0 && aktif {"),
        CodeLine(number: 4, text: "    print(\"Satışta\")"),
        CodeLine(number: 5, text: "} else {"),
        CodeLine(number: 6, text: "    print(\"Bekle\")"),
        CodeLine(number: 7, text: "}"),
      ],
      choices: ["Satışta", "Bekle", "3", "Satışta ve Bekle"],
      correctAnswer: "Bekle",
      explanation: "Stok koşulu doğru olsa da aktif false olduğu için birleşik koşul yanlıştır."
    ),
    teaching: LessonTeaching(
      whyItMatters:
        "`&&` ile bağlanan koşullarda tek bir yanlış bütün ifadeyi yanlış yapar. Hangi parçanın yanlış olduğunu bulmak, kolları tek tek değerlendirmeyi gerektirir.",
      commonMistake:
        "Koşullardan birinin doğru olmasını yeterli saymak. `&&` hepsini, `||` ise en az birini ister.",
      realWorldUse:
        "Bir düğmenin aktif olması genelde birden çok şarta bağlıdır: form dolu, kullanıcı giriş yapmış ve istek sürmüyor."
    )
  )

  public static let functionCall = XRayLesson(
    id: "function-call",
    order: 5,
    topic: "FONKSİYONLAR",
    objective: "Fonksiyon çağrısında akışın gövdeye gidip geri döndüğünü gör.",
    takeaway: "Fonksiyon çağrısı akışı gövdeye taşır; gövde bitince çağrının sonrasına dönülür.",
    title: "Akış nereye gider?",
    question: "Mesajlar hangi sırayla yazılır?",
    code: [
      CodeLine(number: 1, text: "func selamla() {"),
      CodeLine(number: 2, text: "    print(\"Merhaba\")"),
      CodeLine(number: 3, text: "}"),
      CodeLine(number: 4, text: "print(\"Başla\")"),
      CodeLine(number: 5, text: "selamla()"),
      CodeLine(number: 6, text: "print(\"Bitti\")"),
    ],
    choices: [
      "Başla → Merhaba → Bitti",
      "Merhaba → Başla → Bitti",
      "Başla → Bitti → Merhaba",
      "Merhaba → Bitti → Başla",
    ],
    correctAnswer: "Başla → Merhaba → Bitti",
    trace: [
      TraceStep(
        lineNumber: 4,
        explanation: "Program önce Başla mesajını yazdırır.",
        memory: [:],
        output: "Başla",
        callStack: [CallFrame(functionName: "program", locals: [:])]
      ),
      TraceStep(
        lineNumber: 5,
        explanation: "selamla çağrısı akışı fonksiyon gövdesine götürür.",
        memory: [:],
        output: "Başla",
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "selamla", locals: [:]),
        ]
      ),
      TraceStep(
        lineNumber: 2,
        explanation: "Fonksiyon gövdesi Merhaba mesajını yazdırır.",
        memory: [:],
        output: "Başla → Merhaba",
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "selamla", locals: [:]),
        ]
      ),
      TraceStep(
        lineNumber: 6,
        explanation: "Fonksiyon bitince akış çağrının sonrasına döner ve Bitti yazılır.",
        memory: [:],
        output: "Başla → Merhaba → Bitti",
        callStack: [CallFrame(functionName: "program", locals: [:])]
      ),
    ],
    transferChallenge: TransferChallenge(
      prompt: "İki çağrı yapıldığında mesaj kaç kez görünür?",
      code: [
        CodeLine(number: 1, text: "func bip() {"),
        CodeLine(number: 2, text: "    print(\"Bip\")"),
        CodeLine(number: 3, text: "}"),
        CodeLine(number: 4, text: "bip()"),
        CodeLine(number: 5, text: "bip()"),
      ],
      choices: ["Bir kez", "İki kez", "Hiç", "Üç kez"],
      correctAnswer: "İki kez",
      explanation: "Fonksiyonun gövdesi her çağrıda yeniden çalışır."
    ),
    estimatedMinutes: 8,
    section: .functions,
    practiceChallenges: [
      PracticeChallenge(
        kind: .naming,
        prompt: "Kullanıcıya hoş geldin mesajı yazan fonksiyon için en açıklayıcı ad hangisi?",
        choices: ["islem()", "x()", "hosGeldinMesajiYaz()"],
        correctAnswer: "hosGeldinMesajiYaz()",
        explanation: "İyi bir ad fonksiyonun niyetini çağrı noktasında açıklar."
      )
    ],
    teaching: LessonTeaching(
      whyItMatters:
        "Fonksiyon çağrısı okuma sırasını böler: akış gövdeye gider, işini bitirir ve tam kaldığı yere döner.",
      commonMistake:
        "Fonksiyon tanımını gördüğü yerde çalıştığını sanmak. Tanım beklemede durur; yalnızca çağrıldığında çalışır.",
      realWorldUse:
        "Bir düğmeye basıldığında çalışan her işlem, ekranın çağırdığı ve sonucu ekrana dönen bir fonksiyondur."
    )
  )

  public static let parametersAndReturn = XRayLesson(
    id: "parameters-return",
    order: 6,
    topic: "PARAMETRE VE RETURN",
    objective: "Bir argümanın parametreye, sonucun da çağrı noktasına taşınmasını izle.",
    takeaway: "Parametre veriyi fonksiyona götürür; return sonucu çağrının yerine getirir.",
    title: "Değer gidip nasıl döner?",
    question: "sonuc değişkeninin değeri nedir?",
    code: [
      CodeLine(number: 1, text: "func ikiKat(_ sayi: Int) -> Int {"),
      CodeLine(number: 2, text: "    return sayi * 2"),
      CodeLine(number: 3, text: "}"),
      CodeLine(number: 4, text: "let sonuc = ikiKat(4)"),
      CodeLine(number: 5, text: "print(sonuc)"),
    ],
    choices: ["2", "4", "8", "6"],
    correctAnswer: "8",
    trace: [
      TraceStep(
        lineNumber: 4,
        explanation: "ikiKat fonksiyonu 4 argümanıyla çağrılır.",
        memory: ["argüman": "4"],
        output: nil,
        callStack: [CallFrame(functionName: "program", locals: [:])]
      ),
      TraceStep(
        lineNumber: 1,
        explanation: "4 değeri fonksiyon içindeki sayi parametresine bağlanır.",
        memory: ["sayi": "4"],
        output: nil,
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "ikiKat", locals: ["sayi": "4"]),
        ]
      ),
      TraceStep(
        lineNumber: 2,
        explanation: "sayi ikiyle çarpılır ve 8 değeri çağrı noktasına döner.",
        memory: ["sayi": "4", "dönen": "8"],
        output: nil,
        callStack: [
          CallFrame(functionName: "program", locals: [:]),
          CallFrame(functionName: "ikiKat", locals: ["sayi": "4"]),
        ]
      ),
      TraceStep(
        lineNumber: 5,
        explanation: "Dönen 8 değeri sonuc içinde tutulur ve yazdırılır.",
        memory: ["sonuc": "8"],
        output: "8",
        callStack: [CallFrame(functionName: "program", locals: ["sonuc": "8"])]
      ),
    ],
    transferChallenge: TransferChallenge(
      prompt: "Fonksiyon bu kez 5 ile çağrılırsa çıktı ne olur?",
      code: [
        CodeLine(number: 1, text: "func ucEkle(_ sayi: Int) -> Int {"),
        CodeLine(number: 2, text: "    return sayi + 3"),
        CodeLine(number: 3, text: "}"),
        CodeLine(number: 4, text: "print(ucEkle(5))"),
      ],
      choices: ["3", "5", "8", "15"],
      correctAnswer: "8",
      explanation: "5 parametreye gider, 3 eklenir ve dönen 8 doğrudan yazdırılır."
    ),
    estimatedMinutes: 8,
    section: .functions,
    teaching: LessonTeaching(
      whyItMatters:
        "Parametre ve return, fonksiyonun dış dünyayla kurduğu iki yönlü köprüdür: veri içeri girer, sonuç dışarı çıkar.",
      commonMistake:
        "return satırından sonra gövdedeki kodun çalışmaya devam ettiğini sanmak. return fonksiyonu o anda bitirir.",
      realWorldUse:
        "Fiyat hesaplama, doğrulama ve biçimlendirme fonksiyonları hep girdi alıp sonuç döndürerek çalışır."
    )
  )

  public static let weekOneChallenge = XRayLesson(
    id: "week-one-challenge",
    order: 7,
    topic: "HAFTALIK MEYDAN OKUMA",
    objective: "Değişken, döngü, fonksiyon ve koşulu tek bir akışta birleştir.",
    takeaway: "Uzun görünen kodu küçük yürütme adımlarına bölersen akış takip edilebilir olur.",
    title: "Bütün parçaları birleştir",
    question: "Bu programın son çıktısı nedir?",
    code: [
      CodeLine(number: 1, text: "func topla(_ son: Int) -> Int {"),
      CodeLine(number: 2, text: "    var toplam = 0"),
      CodeLine(number: 3, text: "    for sayi in 1...son {"),
      CodeLine(number: 4, text: "        toplam = toplam + sayi"),
      CodeLine(number: 5, text: "    }"),
      CodeLine(number: 6, text: "    return toplam"),
      CodeLine(number: 7, text: "}"),
      CodeLine(number: 8, text: "let sonuc = topla(3)"),
      CodeLine(number: 9, text: "if sonuc > 5 {"),
      CodeLine(number: 10, text: "    print(\"Tamam: \\(sonuc)\")"),
      CodeLine(number: 11, text: "}"),
    ],
    choices: ["Tamam: 3", "Tamam: 6", "Çıktı yok", "6"],
    correctAnswer: "Tamam: 6",
    trace: [
      TraceStep(
        lineNumber: 8,
        explanation: "topla fonksiyonu 3 argümanıyla çağrılır.",
        memory: ["son": "3"],
        output: nil
      ),
      TraceStep(
        lineNumber: 2,
        explanation: "Fonksiyon içindeki toplam 0 ile başlar.",
        memory: ["son": "3", "toplam": "0"],
        output: nil
      ),
      TraceStep(
        lineNumber: 4,
        explanation: "Üç döngü turu sonunda 1 + 2 + 3 işlemi toplamı 6 yapar.",
        memory: ["sayi": "3", "son": "3", "toplam": "6"],
        output: nil
      ),
      TraceStep(
        lineNumber: 6,
        explanation: "Fonksiyon 6 değerini çağrı noktasına döndürür.",
        memory: ["dönen": "6", "toplam": "6"],
        output: nil
      ),
      TraceStep(
        lineNumber: 9,
        explanation: "6 > 5 doğru olduğu için koşulun içine girilir.",
        memory: ["sonuc": "6"],
        output: nil
      ),
      TraceStep(
        lineNumber: 10,
        explanation: "Metnin içine sonuc değeri yerleştirilip ekrana yazılır.",
        memory: ["sonuc": "6"],
        output: "Tamam: 6"
      ),
    ],
    transferChallenge: TransferChallenge(
      prompt: "Aynı program topla(2) ile çalışırsa ne yazdırır?",
      code: [
        CodeLine(number: 1, text: "let sonuc = topla(2)"),
        CodeLine(number: 2, text: "if sonuc > 5 {"),
        CodeLine(number: 3, text: "    print(\"Tamam: \\(sonuc)\")"),
        CodeLine(number: 4, text: "} else {"),
        CodeLine(number: 5, text: "    print(\"Devam\")"),
        CodeLine(number: 6, text: "}"),
      ],
      choices: ["Tamam: 3", "Devam", "Tamam: 6", "Çıktı yok"],
      correctAnswer: "Devam",
      explanation: "topla(2) değeri 3'tür; 3 > 5 yanlış olduğu için else kolu çalışır."
    ),
    estimatedMinutes: 10,
    section: .fundamentals,
    teaching: LessonTeaching(
      whyItMatters:
        "Gerçek kod tek bir kavramdan oluşmaz. Fonksiyon, döngü ve koşul iç içe geçtiğinde okuma sırası da iç içe geçer.",
      commonMistake:
        "Fonksiyonun içindeki döngüyü bitirmeden dışarıdaki koşula atlamak. Dıştaki karar, içteki hesap bitmeden verilemez.",
      realWorldUse:
        "Bir raporu hesaplayıp sonucuna göre farklı ekran göstermek tam olarak bu iç içe yapıdır."
    )
  )
}
