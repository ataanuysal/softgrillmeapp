extension XRayLesson {
  public static let loops = XRayLesson(
    id: "loops",
    order: 3,
    topic: "DÖNGÜLER",
    objective: "Bir döngünün her turunda değişen toplamı izle.",
    takeaway: "Döngü aynı kodu tekrarlar; bellek her turdaki yeni değeri taşır.",
    title: "Her turda ne değişir?",
    question: "Bu kod ekrana hangi değeri yazar?",
    code: [
      CodeLine(number: 1, text: "var toplam = 0"),
      CodeLine(number: 2, text: "for sayi in 1...3 {"),
      CodeLine(number: 3, text: "    toplam = toplam + sayi"),
      CodeLine(number: 4, text: "}"),
      CodeLine(number: 5, text: "print(toplam)"),
    ],
    choices: ["3", "6", "9", "12"],
    correctAnswer: "6",
    trace: [
      TraceStep(
        lineNumber: 1,
        explanation: "toplam değişkeni 0 değeriyle başlar.",
        memory: ["toplam": "0"],
        output: nil
      ),
      TraceStep(
        lineNumber: 2,
        explanation: "İlk tur başlar ve sayi değeri 1 olur.",
        memory: ["sayi": "1", "toplam": "0"],
        output: nil
      ),
      TraceStep(
        lineNumber: 3,
        explanation: "1 mevcut toplama eklenir; toplam artık 1'dir.",
        memory: ["sayi": "1", "toplam": "1"],
        output: nil
      ),
      TraceStep(
        lineNumber: 2,
        explanation: "İkinci turda sayi değeri 2 olur.",
        memory: ["sayi": "2", "toplam": "1"],
        output: nil
      ),
      TraceStep(
        lineNumber: 3,
        explanation: "2 mevcut toplama eklenir; toplam artık 3'tür.",
        memory: ["sayi": "2", "toplam": "3"],
        output: nil
      ),
      TraceStep(
        lineNumber: 2,
        explanation: "Son turda sayi değeri 3 olur.",
        memory: ["sayi": "3", "toplam": "3"],
        output: nil
      ),
      TraceStep(
        lineNumber: 3,
        explanation: "3 mevcut toplama eklenir; toplam artık 6'dır.",
        memory: ["sayi": "3", "toplam": "6"],
        output: nil
      ),
      TraceStep(
        lineNumber: 5,
        explanation: "Döngü biter ve toplam'ın son değeri ekrana yazdırılır.",
        memory: ["toplam": "6"],
        output: "6"
      ),
    ],
    transferChallenges: [
      TransferChallenge(
        prompt: "Toplama yerine çarpma yapıldığında çıktı ne olur?",
        code: [
          CodeLine(number: 1, text: "var carpim = 1"),
          CodeLine(number: 2, text: "for sayi in 1...4 {"),
          CodeLine(number: 3, text: "    carpim = carpim * sayi"),
          CodeLine(number: 4, text: "}"),
          CodeLine(number: 5, text: "print(carpim)"),
        ],
        choices: ["10", "16", "24", "12"],
        correctAnswer: "24",
        explanation: "carpim sırasıyla 1, 2, 6 ve 24 olur; son değer ekrana yazdırılır."
      ),
      TransferChallenge(
        prompt: "Aynı zihinsel modeli yeni durumda uygula. Sonuç nedir?",
        code: [
          CodeLine(number: 1, text: "var sayac = 0"),
          CodeLine(number: 2, text: "for _ in 1...4 {"),
          CodeLine(number: 3, text: "    sayac = sayac + 2"),
          CodeLine(number: 4, text: "}"),
          CodeLine(number: 5, text: "print(sayac)"),
        ],
        choices: ["8", "4", "6", "2"],
        correctAnswer: "8",
        explanation: "Dört tur, her turda 2 eklenir: 2, 4, 6, 8."
      ),
      TransferChallenge(
        prompt: "Aynı zihinsel modeli yeni durumda uygula. Sonuç nedir?",
        code: [
          CodeLine(number: 1, text: "var sonuc = 10"),
          CodeLine(number: 2, text: "for sayi in 1...2 {"),
          CodeLine(number: 3, text: "    sonuc = sonuc - sayi"),
          CodeLine(number: 4, text: "}"),
          CodeLine(number: 5, text: "print(sonuc)"),
        ],
        choices: ["7", "8", "9", "10"],
        correctAnswer: "7",
        explanation: "İlk tur 10 - 1 = 9, ikinci tur 9 - 2 = 7."
      ),
    ],
    practiceChallenges: [
      PracticeChallenge(
        kind: .concept,
        prompt: "`1...3` aralığı kaç tur çalışır?",
        choices: ["3", "2", "4", "1"],
        correctAnswer: "3",
        explanation: "Swift'te `...` üst sınırı da kapsar; 1, 2 ve 3 için birer tur döner."
      ),
      PracticeChallenge(
        kind: .concept,
        prompt: "Döngüdeki hata en çok nerede saklanır?",
        choices: ["İlk ve son turda", "Ortadaki turlarda", "Döngüden sonra", "Değişken adında"],
        correctAnswer: "İlk ve son turda",
        explanation: "Sınır turları, sayaç ve birikim hatalarının en sık ortaya çıktığı yerdir."
      ),
    ],
    languageVariants: [
      CodeVariant(
        language: .python,
        lines: [
          "toplam = 0",
          "for sayi in range(1, 4):",
          "    toplam = toplam + sayi",
          "print(toplam)",
        ]
      ),
      CodeVariant(
        language: .javascript,
        lines: [
          "let toplam = 0;",
          "for (let sayi = 1; sayi <= 3; sayi++) {",
          "    toplam = toplam + sayi;",
          "}",
          "console.log(toplam);",
        ]
      ),
      CodeVariant(
        language: .java,
        lines: [
          "int toplam = 0;",
          "for (int sayi = 1; sayi <= 3; sayi++) {",
          "    toplam = toplam + sayi;",
          "}",
          "System.out.println(toplam);",
        ]
      ),
    ],
    languageComparison: LanguageComparison(
      invariant: "Dört dilde de döngü 1, 2 ve 3 turlarını çalıştırır ve toplam 6 olur.",
      syntaxDifferences: [
        .swift: "`1...3` aralığı üç turu kapsar; son değer dahildir.",
        .python: "`range(1, 4)` üst sınırı dışarıda bırakır, bu yüzden 4 yazılır.",
        .javascript: "Tur sayacı, koşulu ve artışı elle yazılır.",
        .java: "Sayaç türü `int` olarak belirtilir; yapı JavaScript ile aynıdır.",
      ]
    ),
    teaching: LessonTeaching(
      whyItMatters:
        "Döngüde aynı satır birden çok kez çalışır ama her turda farklı bir değerle. Kodu okumak, turları tek tek yazabilmektir.",
      commonMistake:
        "Döngü değişkeninin son değerine bakıp ara turları atlamak. Hata genellikle ilk veya son turda saklanır.",
      realWorldUse:
        "Listedeki her satırı çizmek, her siparişi toplamak ve her dosyayı işlemek aynı tur mantığıyla çalışır.",
      hook: TeachingHook(
        question: "Sence bu kod ne yazar?",
        code: [
          CodeLine(number: 1, text: "var t = 0"),
          CodeLine(number: 2, text: "for s in 1...2 { t = t + s }"),
          CodeLine(number: 3, text: "print(t)"),
        ],
        choices: ["3", "2", "1", "0"],
        correctAnswer: "3",
        reveal:
          "İki tur döndü: önce 1, sonra 2 eklendi."
      ),
      microExample: MicroExample(
        code: [
          CodeLine(number: 1, text: "for s in 1...3 {"),
          CodeLine(number: 2, text: "    print(s)"),
          CodeLine(number: 3, text: "}"),
        ],
        note:
          "Aynı satır üç kez çalışır ve her turda s farklı bir değer taşır."
      ),
      connection:
        "2. derste koşul tek bir yolu seçiyordu; döngü aynı yolu birden çok kez çalıştırır."
    )
  )
}
