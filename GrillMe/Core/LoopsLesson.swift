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
    choices: ["3", "6", "9"],
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
    transferChallenge: TransferChallenge(
      prompt: "Toplama yerine çarpma yapıldığında çıktı ne olur?",
      code: [
        CodeLine(number: 1, text: "var carpim = 1"),
        CodeLine(number: 2, text: "for sayi in 1...4 {"),
        CodeLine(number: 3, text: "    carpim = carpim * sayi"),
        CodeLine(number: 4, text: "}"),
        CodeLine(number: 5, text: "print(carpim)"),
      ],
      choices: ["10", "16", "24"],
      correctAnswer: "24",
      explanation: "carpim sırasıyla 1, 2, 6 ve 24 olur; son değer ekrana yazdırılır."
    )
  )
}
