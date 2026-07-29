import Foundation
import Testing

@testable import GrillMeCore

@Suite("Öğrenme gelişimi")
struct LearningGrowthTests {
  @Test("Başlangıç dersleri ile çıkış değerlendirmesi arasındaki farkı ölçer")
  func comparesBaselineAndExitAccuracy() {
    var progress = LessonProgress()
    progress.recordAttempt(attempt("variables", quiz: false, practice: 0.5, assessment: 1))
    progress.recordAttempt(attempt("conditions", quiz: false, practice: 0.5, assessment: 1))
    progress.recordAttempt(attempt("loops", quiz: true, practice: 0, assessment: 0.5))
    progress.recordAttempt(attempt("capstone", quiz: true, practice: 1, assessment: 1))

    progress.recordAttempt(attempt("week-one-challenge", quiz: true, practice: 1, assessment: 1))
    progress.recordAttempt(
      attempt("technical-analysis-capstone", quiz: true, practice: 1, assessment: 1)
    )

    let report = progress.growthReport(
      baselineLessonIDs: ["variables", "conditions", "loops"],
      exitLessonIDs: ["capstone", "week-one-challenge", "technical-analysis-capstone"]
    )

    #expect(report?.baselineQuizAccuracy == 1.0 / 3.0)
    #expect(report?.exitQuizAccuracy == 1)
    #expect(report?.baselineSampleSize == 3)
    #expect(report?.exitSampleSize == 3)
    #expect(report?.hasEnoughEvidence == true)
    // Fark iki oranın çıkarımıdır; kayan nokta gösterimi 2/3 ifadesiyle
    // birebir aynı olmak zorunda değildir.
    #expect(abs((report?.improvement ?? 0) - 2.0 / 3.0) < 1e-9)
  }

  @Test("Çıkış değerlendirmesi yoksa erken başarı raporlamaz")
  func requiresExitAssessment() {
    var progress = LessonProgress()
    progress.recordAttempt(attempt("variables", quiz: true, practice: 1, assessment: 1))

    let report = progress.growthReport(
      baselineLessonIDs: ["variables"],
      exitLessonIDs: ["capstone"]
    )

    #expect(report == nil)
  }

  @Test("Tek çıkış quizi yüzde sunmaya yetmez")
  func withholdsPercentageOnThinSample() {
    var progress = LessonProgress()
    progress.recordAttempt(attempt("variables", quiz: false, practice: 0.5, assessment: 1))
    progress.recordAttempt(attempt("conditions", quiz: false, practice: 0.5, assessment: 1))
    progress.recordAttempt(attempt("loops", quiz: true, practice: 0, assessment: 0.5))
    progress.recordAttempt(attempt("capstone", quiz: true, practice: 1, assessment: 1))

    let report = progress.growthReport(
      baselineLessonIDs: ["variables", "conditions", "loops"],
      exitLessonIDs: ["capstone", "technical-analysis-capstone"]
    )

    #expect(report?.exitSampleSize == 1)
    #expect(report?.hasEnoughEvidence == false)
  }

  @Test("Çıkış doğruluğu son denemeyi kullanır, ilk denemeyi değil")
  func exitUsesLatestAttempt() {
    var progress = LessonProgress()
    progress.recordAttempt(attempt("variables", quiz: false, practice: 0, assessment: 0))
    progress.recordAttempt(attempt("capstone", quiz: false, practice: 0, assessment: 0))
    progress.recordAttempt(attempt("capstone", quiz: true, practice: 1, assessment: 1))

    let report = progress.growthReport(
      baselineLessonIDs: ["variables"],
      exitLessonIDs: ["capstone"]
    )

    #expect(report?.exitQuizAccuracy == 1)
    #expect(report?.exitSampleSize == 1)
  }

  private func attempt(
    _ lessonID: String,
    quiz: Bool,
    practice: Double,
    assessment: Double
  ) -> LessonAttempt {
    LessonAttempt(
      lessonID: lessonID,
      completedAt: Date(timeIntervalSince1970: 100),
      durationSeconds: 300,
      quizCorrect: quiz,
      practiceAccuracy: practice,
      assessmentScore: assessment
    )
  }
}
