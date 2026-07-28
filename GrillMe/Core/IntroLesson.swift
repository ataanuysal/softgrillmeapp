extension XRayLesson {
  public static let introduction = XRayLesson(
    title: "Değerin izini sür",
    question: "Bu kod ekrana hangi değeri yazar?",
    code: [
      CodeLine(number: 1, text: "var puan = 10"),
      CodeLine(number: 2, text: "if puan > 5 {"),
      CodeLine(number: 3, text: "    puan = puan + 2"),
      CodeLine(number: 4, text: "}"),
      CodeLine(number: 5, text: "print(puan)"),
    ],
    choices: ["10", "12", "22"],
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
    ]
  )
}
