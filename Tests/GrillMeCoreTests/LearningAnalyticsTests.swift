import Foundation
import Testing

@testable import GrillMeCore

@Suite("Öğrenme analitiği sözleşmesi")
struct LearningAnalyticsTests {
  @Test("Quiz olayını kişisel veri taşımayan kararlı alanlarla üretir")
  func createsQuizEvent() {
    let instant = Date(timeIntervalSince1970: 100)

    let event = LearningEvent.quizSubmitted(
      lessonID: "variables",
      answer: "12",
      isCorrect: true,
      attemptNumber: 1,
      occurredAt: instant
    )

    #expect(event.name == .quizSubmitted)
    #expect(event.lessonID == "variables")
    #expect(event.occurredAt == instant)
    #expect(event.properties["answer"] == "12")
    #expect(event.properties["correct"] == "true")
    #expect(event.properties["attempt"] == "1")
  }

  @Test("Tamamlama olayı süre ve bağımsız öğrenme sonuçlarını içerir")
  func createsCompletionEvent() {
    let event = LearningEvent.lessonCompleted(
      lessonID: "conditions",
      durationSeconds: 412,
      quizCorrect: true,
      practiceAccuracy: 0.75,
      assessmentScore: 0.5,
      occurredAt: Date(timeIntervalSince1970: 200)
    )

    #expect(event.name == .lessonCompleted)
    #expect(event.properties["duration_seconds"] == "412")
    #expect(event.properties["quiz_correct"] == "true")
    #expect(event.properties["practice_accuracy"] == "0.75")
    #expect(event.properties["assessment_score"] == "0.5")
  }
}
