import Testing

@testable import GrillMeCore

@Suite("Öğreten ders yolculuğu")
struct LessonJourneyTests {
  @Test("Ders konu anlatımı, rehberli örnek ve quiz sırasını zorunlu tutar")
  func enforcesTeachingBeforeQuiz() {
    var journey = LessonJourney(lesson: .introduction)

    // Ders bir tahmin adımı taşıdığı için akış oradan başlar.
    #expect(journey.phase == .predict)

    journey.submitQuizAnswer("6")
    #expect(journey.selectedQuizAnswer == nil)

    journey.skipPrediction()
    #expect(journey.phase == .topic)

    journey.submitQuizAnswer("6")
    #expect(journey.selectedQuizAnswer == nil)

    journey.startExample()
    #expect(journey.phase == .example(step: 0))
    #expect(journey.currentExampleStep == XRayLesson.introduction.trace[0])

    for _ in XRayLesson.introduction.trace {
      journey.advanceExample()
    }

    #expect(journey.phase == .quiz)

    journey.submitQuizAnswer("6")
    #expect(journey.isQuizAnswerCorrect == true)
    #expect(journey.phase == .complete)
  }

  @Test("Konu anlatımı hedefi açıklar, örnek ve quiz farklı kodlar kullanır")
  func providesTeachingContentBeforeIndependentQuiz() {
    let lesson = XRayLesson.introduction
    let journey = LessonJourney(lesson: lesson)

    #expect(journey.teachingContent.explanation.contains(lesson.objective))
    #expect(journey.teachingContent.keyIdea == lesson.takeaway)
    #expect(journey.teachingContent.exampleCode == lesson.code)
    #expect(journey.quiz.code == lesson.transferChallenge?.code)
    #expect(journey.quiz.code != journey.teachingContent.exampleCode)
  }

  @Test("Her ders neden, sık hata ve gerçek proje bağlamıyla öğretilir")
  func everyLessonProvidesDeepTeachingContext() {
    for lesson in LessonCatalog.standard.lessons {
      let explanation = LessonJourney(lesson: lesson).teachingContent.explanation

      #expect(explanation.contains("Neden önemli:"))
      #expect(explanation.contains("Sık hata:"))
      #expect(explanation.contains("Gerçek projede:"))
    }
  }
}
