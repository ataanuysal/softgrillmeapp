extension XRayLesson {
  public static let introduction = XRayLesson(
    id: "variables",
    order: 1,
    topic: "DEĞİŞKENLER",
    objective: "Bir değişkenin değerinin satırlar boyunca nasıl değiştiğini izle.",
    takeaway: "Kod, satırlardan çok değişen değerlerin hikâyesidir.",
    title: "Değerin izini sür",
    question: "Bu kod ekrana hangi değeri yazar?",
    code: [
      CodeLine(number: 1, text: "var puan = 10"),
      CodeLine(number: 2, text: "if puan > 5 {"),
      CodeLine(number: 3, text: "    puan = puan + 2"),
      CodeLine(number: 4, text: "}"),
      CodeLine(number: 5, text: "print(puan)"),
    ],
    choices: ["10", "12", "20", "22"],
    correctAnswer: "12",
    trace: [
      TraceStep(
        lineNumber: 1,
        explanation: "puan adında bir değişken açılır ve başlangıç değeri 10 olur.",
        memory: ["puan": "10"],
        output: nil
      ),
      TraceStep(
        lineNumber: 2,
        explanation: "puan 5'ten büyük mü? 10 > 5 doğru olduğu için koşulun içine girilir.",
        memory: ["puan": "10"],
        output: nil
      ),
      TraceStep(
        lineNumber: 3,
        explanation: "Mevcut puan değerine 2 eklenir ve sonuç tekrar puan'a yazılır.",
        memory: ["puan": "12"],
        output: nil
      ),
      TraceStep(
        lineNumber: 5,
        explanation: "puan'ın o anki değeri ekrana yazdırılır.",
        memory: ["puan": "12"],
        output: "12"
      ),
    ],
    transferChallenge: TransferChallenge(
      prompt: "Aynı fikri yeni koda taşı: çıktı ne olur?",
      code: [
        CodeLine(number: 1, text: "var can = 3"),
        CodeLine(number: 2, text: "can = can * 2"),
        CodeLine(number: 3, text: "print(can)"),
      ],
      choices: ["3", "5", "6", "9"],
      correctAnswer: "6",
      explanation: "can önce 3'tür; ikiyle çarpılıp 6 olur ve bu yeni değer yazdırılır."
    ),
    languageVariants: [
      CodeVariant(
        language: .python,
        lines: [
          "puan = 10",
          "if puan > 5:",
          "    puan = puan + 2",
          "print(puan)",
        ]
      ),
      CodeVariant(
        language: .javascript,
        lines: [
          "let puan = 10;",
          "if (puan > 5) {",
          "    puan = puan + 2;",
          "}",
          "console.log(puan);",
        ]
      ),
      CodeVariant(
        language: .java,
        lines: [
          "int puan = 10;",
          "if (puan > 5) {",
          "    puan = puan + 2;",
          "}",
          "System.out.println(puan);",
        ]
      ),
    ],
    languageComparison: LanguageComparison(
      invariant: "Dört dilde de puan 10 ile başlar, koşul doğru olur ve değer 12'ye değişir.",
      syntaxDifferences: [
        .swift: "Değişken `var`, bloklar süslü parantez ve çıktı `print` ile yazılır.",
        .python: "Tür çıkarımı örtüktür; blok girinti ve iki nokta ile belirtilir.",
        .javascript: "Değişken `let`, satırlar noktalı virgül ve çıktı `console.log` kullanır.",
        .java: "Değişken türü `int` ile belirtilir; çıktı `System.out.println` kullanır.",
      ]
    ),
    teaching: LessonTeaching(
      whyItMatters:
        "Bir değişkenin adı sabit kalır ama içindeki değer değişir. Kodu okumak, o adın hangi satırda hangi değeri taşıdığını takip etmektir.",
      commonMistake:
        "`puan = puan + 2` satırını matematikteki gibi bir eşitlik sanmak. Bu satır bir denklem değil, 'sağdakini hesapla ve sola yaz' komutudur.",
      realWorldUse:
        "Sepet tutarı, kalan hak ve okunmamış bildirim sayısı gibi ekranda gördüğün her sayı böyle güncellenir."
    )
  )

  public static let conditions = XRayLesson(
    id: "conditions",
    order: 2,
    topic: "KOŞULLAR",
    objective: "Bir koşulun hangi kod yolunu seçtiğini adım adım gör.",
    takeaway: "Bir koşul her iki yolu da değil, sonucu doğru olan tek yolu çalıştırır.",
    title: "Hangi yol çalışır?",
    question: "Bu kod ekrana hangi mesajı yazar?",
    code: [
      CodeLine(number: 1, text: "let sicaklik = 18"),
      CodeLine(number: 2, text: "var mesaj = \"\""),
      CodeLine(number: 3, text: "if sicaklik > 20 {"),
      CodeLine(number: 4, text: "    mesaj = \"Tişört yeter\""),
      CodeLine(number: 5, text: "} else {"),
      CodeLine(number: 6, text: "    mesaj = \"Ceket al\""),
      CodeLine(number: 7, text: "}"),
      CodeLine(number: 8, text: "print(mesaj)"),
    ],
    choices: ["Tişört yeter", "Ceket al", "İkisi de yazılır", "Boş mesaj"],
    correctAnswer: "Ceket al",
    trace: [
      TraceStep(
        lineNumber: 1,
        explanation: "sicaklik sabiti 18 değerini tutar.",
        memory: ["sicaklik": "18"],
        output: nil
      ),
      TraceStep(
        lineNumber: 2,
        explanation: "mesaj değişkeni şimdilik boş bir metinle başlar.",
        memory: ["mesaj": "\"\"", "sicaklik": "18"],
        output: nil
      ),
      TraceStep(
        lineNumber: 3,
        explanation: "18 > 20 yanlış olduğu için if kolu atlanır.",
        memory: ["mesaj": "\"\"", "sicaklik": "18"],
        output: nil
      ),
      TraceStep(
        lineNumber: 5,
        explanation: "Koşul yanlış olduğundan çalışma else koluna geçer.",
        memory: ["mesaj": "\"\"", "sicaklik": "18"],
        output: nil
      ),
      TraceStep(
        lineNumber: 6,
        explanation: "mesaj değişkeninin yeni değeri \"Ceket al\" olur.",
        memory: ["mesaj": "\"Ceket al\"", "sicaklik": "18"],
        output: nil
      ),
      TraceStep(
        lineNumber: 8,
        explanation: "mesaj'ın son değeri ekrana yazdırılır.",
        memory: ["mesaj": "\"Ceket al\"", "sicaklik": "18"],
        output: "Ceket al"
      ),
    ],
    transferChallenge: TransferChallenge(
      prompt: "Koşulu yeni bir durumda uygula: çıktı ne olur?",
      code: [
        CodeLine(number: 1, text: "let puan = 75"),
        CodeLine(number: 2, text: "if puan >= 50 {"),
        CodeLine(number: 3, text: "    print(\"Geçti\")"),
        CodeLine(number: 4, text: "} else {"),
        CodeLine(number: 5, text: "    print(\"Kaldı\")"),
        CodeLine(number: 6, text: "}"),
      ],
      choices: ["Geçti", "Kaldı", "İkisi de", "Çıktı yok"],
      correctAnswer: "Geçti",
      explanation: "75, 50'den büyük veya eşit olduğu için doğru olan if kolu çalışır."
    ),
    teaching: LessonTeaching(
      whyItMatters:
        "Koşul, kodun okunduğu sırayı bozan ilk yapıdır. Hangi kolun çalıştığını bilmeden sonucu tahmin etmek imkânsızdır.",
      commonMistake:
        "İki kolu da okuyup ikisinin de çalıştığını düşünmek. Bir çalıştırmada yalnızca tek kol çalışır; diğeri hiç görülmez.",
      realWorldUse:
        "Giriş yapmış kullanıcıya farklı, yapmamışa farklı ekran göstermek aynı çatalın gerçek uygulamadaki hâlidir."
    )
  )
}
