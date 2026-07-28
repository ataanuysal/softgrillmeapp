import Testing

@testable import GrillMeCore

@Suite("Kod Röntgeni oturumu")
struct XRaySessionTests {
  @Test("Tahmin gönderildiğinde sonucu değerlendirir ve ilk yürütme adımını açar")
  func submittingPredictionStartsTrace() {
    let lesson = makeLesson()
    var session = XRaySession(lesson: lesson)

    session.submitPrediction("12")

    #expect(session.selectedAnswer == "12")
    #expect(session.isPredictionCorrect == true)
    #expect(session.phase == .tracing(step: 0))
    #expect(session.currentStep == lesson.trace[0])
  }

  @Test("Son adımdan sonra oturumu tamamlar ve son bellek durumunu korur")
  func advancingPastLastStepCompletesSession() {
    let lesson = makeLesson()
    var session = XRaySession(lesson: lesson)
    session.submitPrediction("10")

    for _ in lesson.trace {
      session.advance()
    }

    #expect(session.isPredictionCorrect == false)
    #expect(session.phase == .complete)
    #expect(session.currentStep == lesson.trace.last)
  }

  @Test("Yürütme izinden sonra aktarım görevini açar")
  func finishingTraceStartsTransferChallenge() {
    let lesson = makeLessonWithTransferChallenge()
    var session = XRaySession(lesson: lesson)
    session.submitPrediction("12")

    for _ in lesson.trace {
      session.advance()
    }

    #expect(session.phase == .transfer)
  }

  @Test("Aktarım cevabını değerlendirip oturumu tamamlar")
  func answeringTransferChallengeCompletesSession() {
    let lesson = makeLessonWithTransferChallenge()
    var session = XRaySession(lesson: lesson)
    session.submitPrediction("12")
    for _ in lesson.trace {
      session.advance()
    }

    session.submitTransferAnswer("6")

    #expect(session.selectedTransferAnswer == "6")
    #expect(session.isTransferAnswerCorrect == true)
    #expect(session.phase == .complete)
  }

  private func makeLesson() -> XRayLesson {
    XRayLesson(
      title: "Değerin izini sür",
      question: "Kodun çıktısı ne olur?",
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
          explanation: "puan adında bir değişken oluşturulur.",
          memory: ["puan": "10"],
          output: nil
        ),
        TraceStep(
          lineNumber: 2,
          explanation: "10 > 5 doğru olduğu için koşulun içine girilir.",
          memory: ["puan": "10"],
          output: nil
        ),
        TraceStep(
          lineNumber: 3,
          explanation: "puan değerine 2 eklenir.",
          memory: ["puan": "12"],
          output: nil
        ),
        TraceStep(
          lineNumber: 5,
          explanation: "puan'ın son değeri ekrana yazdırılır.",
          memory: ["puan": "12"],
          output: "12"
        ),
      ]
    )
  }

  private func makeLessonWithTransferChallenge() -> XRayLesson {
    XRayLesson(
      title: "Değerin izini sür",
      question: "Çıktı ne olur?",
      code: [CodeLine(number: 1, text: "print(12)")],
      choices: ["10", "12"],
      correctAnswer: "12",
      trace: [
        TraceStep(
          lineNumber: 1,
          explanation: "12 ekrana yazılır.",
          memory: [:],
          output: "12"
        )
      ],
      transferChallenge: TransferChallenge(
        prompt: "Yeni kodun çıktısı ne olur?",
        code: [
          CodeLine(number: 1, text: "var can = 3"),
          CodeLine(number: 2, text: "can = can * 2"),
          CodeLine(number: 3, text: "print(can)"),
        ],
        choices: ["3", "5", "6"],
        correctAnswer: "6",
        explanation: "3 ikiyle çarpılır ve can'ın yeni değeri 6 olur."
      )
    )
  }
}
