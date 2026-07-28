import Foundation
import Testing

@testable import GrillMeCore

@Suite("Öğrenme gelişimi")
struct LearningGrowthTests {
  @Test("Başlangıç dersleri ile çıkış değerlendirmesi arasındaki farkı ölçer")
  func comparesBaselineAndExitAccuracy() {
    var progress = LessonProgress()
    progress.recordAttempt(attempt("variables", prediction: false, transfer: true))
    progress.recordAttempt(attempt("conditions", prediction: false, transfer: true))
    progress.recordAttempt(attempt("loops", prediction: true, transfer: false))
    progress.recordAttempt(attempt("capstone", prediction: true, transfer: true))

    let report = progress.growthReport(
      baselineLessonIDs: ["variables", "conditions", "loops"],
      exitLessonID: "capstone"
    )

    #expect(report?.baselineAccuracy == 0.5)
    #expect(report?.exitAccuracy == 1)
    #expect(report?.improvement == 0.5)
  }

  @Test("Çıkış değerlendirmesi yoksa erken başarı raporlamaz")
  func requiresExitAssessment() {
    var progress = LessonProgress()
    progress.recordAttempt(attempt("variables", prediction: true, transfer: true))

    let report = progress.growthReport(
      baselineLessonIDs: ["variables"],
      exitLessonID: "capstone"
    )

    #expect(report == nil)
  }

  private func attempt(
    _ lessonID: String,
    prediction: Bool,
    transfer: Bool
  ) -> LessonAttempt {
    LessonAttempt(
      lessonID: lessonID,
      completedAt: Date(timeIntervalSince1970: 100),
      durationSeconds: 300,
      predictionCorrect: prediction,
      transferCorrect: transfer
    )
  }
}
