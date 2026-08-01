import Testing

@testable import GrillMeCore

@Suite("Anlatım öncesi tahmin")
struct TeachingHookTests {
  @Test("Tahmin taşıyan ders anlatımdan önce tahminle açılır")
  func startsWithPredictionWhenHookExists() {
    let journey = LessonJourney(lesson: hooked)

    #expect(journey.phase == .predict)
    #expect(journey.predictionAnswer == nil)
  }

  @Test("Tahmin taşımayan ders doğrudan anlatımla açılır")
  func startsWithTopicWithoutHook() {
    let journey = LessonJourney(lesson: unhooked)

    #expect(journey.phase == .topic)
  }

  @Test("Verilen tahmin kaydedilir ve anlatıma geçilir")
  func recordsPredictionAndMovesOn() {
    var journey = LessonJourney(lesson: hooked)

    journey.submitPrediction("12")

    #expect(journey.phase == .topic)
    #expect(journey.predictionAnswer == "12")
    #expect(journey.isPredictionCorrect == true)
  }

  @Test("Yanlış tahmin anlatımı engellemez")
  func wrongPredictionStillOpensTheTopic() {
    var journey = LessonJourney(lesson: hooked)

    journey.submitPrediction("10")

    #expect(journey.phase == .topic)
    #expect(journey.isPredictionCorrect == false)
  }

  @Test("Tahmin atlanabilir ve cevapsız kalır")
  func predictionCanBeSkipped() {
    var journey = LessonJourney(lesson: hooked)

    journey.skipPrediction()

    #expect(journey.phase == .topic)
    #expect(journey.predictionAnswer == nil)
    #expect(journey.isPredictionCorrect == nil)
  }

  @Test("Tahmin ölçüme karışmaz")
  func predictionIsNotAMeasurement() {
    var journey = LessonJourney(lesson: hooked)
    journey.submitPrediction("10")
    journey.startExample()
    for _ in journey.lesson.trace { journey.advanceExample() }
    journey.submitQuizAnswer(journey.quiz.correctAnswer)

    let evaluation = LessonEvidence(
      quizAnswer: journey.selectedQuizAnswer,
      practiceAnswers: [:],
      assessmentResponses: [:],
      debugCompleted: true
    ).evaluate(for: journey.lesson)

    // Tahmin yanlış olmasına rağmen ders tamamlanabilir ve hiçbir ölçüme
    // yansımaz: tahmin öğretme aracıdır, sınav değil.
    #expect(evaluation.isReadyToComplete)
    #expect(evaluation.quizCorrect == true)
    #expect(evaluation.practiceAccuracy == nil)
  }

  private var hooked: XRayLesson {
    lesson(
      hook: TeachingHook(
        code: [CodeLine(number: 1, text: "var puan = 10")],
        choices: ["10", "12"],
        correctAnswer: "12",
        reveal: "Değer değişti."
      )
    )
  }

  private var unhooked: XRayLesson { lesson(hook: nil) }

  private func lesson(hook: TeachingHook?) -> XRayLesson {
    XRayLesson(
      title: "Deneme",
      question: "Ne olur?",
      code: [CodeLine(number: 1, text: "print(1)")],
      choices: ["1"],
      correctAnswer: "1",
      trace: [
        TraceStep(lineNumber: 1, explanation: "Yazılır.", memory: [:], output: "1")
      ],
      transferChallenges: [
        TransferChallenge(
          prompt: "Yeni kod",
          code: [CodeLine(number: 1, text: "print(2)")],
          choices: ["2"],
          correctAnswer: "2",
          explanation: "İkisi yazılır."
        )
      ],
      teaching: LessonTeaching(
        whyItMatters: "test",
        commonMistake: "test",
        realWorldUse: "test",
        hook: hook
      )
    )
  }
}
