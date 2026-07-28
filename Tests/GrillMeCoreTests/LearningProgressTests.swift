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
        predictionCorrect: false,
        transferCorrect: false
      )
    )
    progress.recordAttempt(
      LessonAttempt(
        lessonID: "variables",
        completedAt: date(2026, 7, 28),
        durationSeconds: 240,
        predictionCorrect: true,
        transferCorrect: true
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
          predictionCorrect: true,
          transferCorrect: true
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
        predictionCorrect: false,
        transferCorrect: true
      )
    )
    progress.recordAttempt(
      LessonAttempt(
        lessonID: "conditions",
        completedAt: date(2026, 7, 28),
        durationSeconds: 420,
        predictionCorrect: true,
        transferCorrect: true
      )
    )

    let summary = progress.weeklySummary(
      containing: date(2026, 7, 28),
      calendar: utcCalendar
    )

    #expect(summary.completedLessonCount == 2)
    #expect(summary.practiceSeconds == 720)
    #expect(summary.predictionAccuracy == 0.5)
    #expect(summary.transferAccuracy == 1)
  }

  @Test("Eski ilerleme dosyalarını deneme kaydı olmadan açar")
  func decodesLegacyProgress() throws {
    let data = Data(#"{"completedLessonIDs":["variables"]}"#.utf8)

    let progress = try JSONDecoder().decode(LessonProgress.self, from: data)

    #expect(progress.completedLessonIDs == ["variables"])
    #expect(progress.attempts.isEmpty)
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
