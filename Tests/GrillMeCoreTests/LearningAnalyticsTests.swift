import Foundation
import Testing

@testable import GrillMeCore

@Suite("Öğrenme analitiği sözleşmesi")
struct LearningAnalyticsTests {
  @Test("Tahmin olayını kişisel veri taşımayan kararlı alanlarla üretir")
  func createsPredictionEvent() {
    let instant = Date(timeIntervalSince1970: 100)

    let event = LearningEvent.predictionSubmitted(
      lessonID: "variables",
      answer: "12",
      isCorrect: true,
      attemptNumber: 1,
      occurredAt: instant
    )

    #expect(event.name == .predictionSubmitted)
    #expect(event.lessonID == "variables")
    #expect(event.occurredAt == instant)
    #expect(event.properties["answer"] == "12")
    #expect(event.properties["correct"] == "true")
    #expect(event.properties["attempt"] == "1")
  }

  @Test("Tamamlama olayı süre ve aktarım sonucunu içerir")
  func createsCompletionEvent() {
    let event = LearningEvent.lessonCompleted(
      lessonID: "conditions",
      durationSeconds: 412,
      transferCorrect: false,
      occurredAt: Date(timeIntervalSince1970: 200)
    )

    #expect(event.name == .lessonCompleted)
    #expect(event.properties["duration_seconds"] == "412")
    #expect(event.properties["transfer_correct"] == "false")
  }
}
