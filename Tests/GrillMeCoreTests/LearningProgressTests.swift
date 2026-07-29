import Foundation
import Testing

@testable import GrillMeCore

@Suite("Öğrenme ölçümleri")
struct LearningProgressTests {
  @Test("İlk ve ikinci deneme doğruluğunu ayrı hesaplar")
  func separatesFirstAndRetryAccuracy() {
    var progress = LessonProgress()

    progress.recordAttempt(
      LessonAttempt(
        lessonID: "variables",
        completedAt: date(2026, 7, 27),
        durationSeconds: 300,
        quizCorrect: false,
        practiceAccuracy: 0.25,
        assessmentScore: 0.5
      )
    )
    progress.recordAttempt(
      LessonAttempt(
        lessonID: "variables",
        completedAt: date(2026, 7, 28),
        durationSeconds: 240,
        quizCorrect: true,
        practiceAccuracy: 1,
        assessmentScore: 1
      )
    )

    #expect(progress.completedLessonIDs == ["variables"])
    #expect(progress.firstAttemptAccuracy == 0)
    #expect(progress.retryAccuracy == 1)
  }

  @Test("Ardışık çalışma günlerinden güncel seriyi üretir")
  func calculatesCurrentStreak() {
    var progress = LessonProgress()
    for day in 26...28 {
      progress.recordAttempt(
        LessonAttempt(
          lessonID: "lesson-\(day)",
          completedAt: date(2026, 7, day),
          durationSeconds: 300,
          quizCorrect: true,
          practiceAccuracy: nil,
          assessmentScore: nil
        )
      )
    }

    #expect(
      progress.currentStreak(
        asOf: date(2026, 7, 28),
        calendar: utcCalendar
      ) == 3
    )
  }

  @Test("Haftalık özette süreyi, ders sayısını ve doğruluğu toplar")
  func buildsWeeklySummary() {
    var progress = LessonProgress()
    progress.recordAttempt(
      LessonAttempt(
        lessonID: "variables",
        completedAt: date(2026, 7, 27),
        durationSeconds: 300,
        quizCorrect: false,
        practiceAccuracy: 0.5,
        assessmentScore: 0.25
      )
    )
    progress.recordAttempt(
      LessonAttempt(
        lessonID: "conditions",
        completedAt: date(2026, 7, 28),
        durationSeconds: 420,
        quizCorrect: true,
        practiceAccuracy: 1,
        assessmentScore: 0.75
      )
    )

    let summary = progress.weeklySummary(
      containing: date(2026, 7, 28),
      calendar: utcCalendar
    )

    #expect(summary.completedLessonCount == 2)
    #expect(summary.practiceSeconds == 720)
    #expect(summary.quizAccuracy == 0.5)
    #expect(summary.practiceAccuracy == 0.75)
    #expect(summary.assessmentScore == 0.5)
  }

  @Test("Kanıt yokken başarısızlık uydurmak yerine ölçümü boş bırakır")
  func leavesUnavailableMetricsEmpty() {
    let summary = LessonProgress().weeklySummary(
      containing: date(2026, 7, 28),
      calendar: utcCalendar
    )

    #expect(summary.quizAccuracy == nil)
    #expect(summary.practiceAccuracy == nil)
    #expect(summary.assessmentScore == nil)
  }

  @Test("Eski ilerleme dosyalarını deneme kaydı olmadan açar")
  func decodesLegacyProgress() throws {
    let data = Data(#"{"completedLessonIDs":["variables"]}"#.utf8)

    let progress = try JSONDecoder().decode(LessonProgress.self, from: data)

    #expect(progress.completedLessonIDs == ["variables"])
    #expect(progress.attempts.isEmpty)
    #expect(progress.learningEvents.isEmpty)
  }

  @Test("Eski deneme alanlarını yeni ölçümlere kayıpsız taşır")
  func decodesLegacyAttemptMetrics() throws {
    let data = Data(
      #"""
      {
        "completedLessonIDs": ["variables"],
        "attempts": [{
          "lessonID": "variables",
          "completedAt": 0,
          "durationSeconds": 120,
          "predictionCorrect": true,
          "transferCorrect": false
        }]
      }
      """#.utf8
    )

    let progress = try JSONDecoder().decode(LessonProgress.self, from: data)

    #expect(progress.attempts.first?.quizCorrect == true)
    #expect(progress.attempts.first?.practiceAccuracy == 0)
    #expect(progress.attempts.first?.assessmentScore == nil)
  }

  private var utcCalendar: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return calendar
  }

  private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
    utcCalendar.date(from: DateComponents(year: year, month: month, day: day))!
  }
}
