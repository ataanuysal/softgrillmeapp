import Foundation
import Testing

@testable import GrillMeCore

@Suite("İlk açılış durumu")
struct OnboardingStateTests {
  @Test("Yeni kurulumda akış gösterilir, tamamlanınca ritim saklanır")
  func storesGoalWhenOnboardingFinishes() {
    var progress = LessonProgress()

    #expect(!progress.hasFinishedOnboarding)
    #expect(progress.dailyGoal == nil)

    progress.finishOnboarding(dailyGoal: .steady)

    #expect(progress.hasFinishedOnboarding)
    #expect(progress.dailyGoal == .steady)
  }

  @Test("Ritim seçmeden atlayan kullanıcı akışı yeniden görmez")
  func skippingStillFinishesOnboarding() {
    var progress = LessonProgress()

    progress.finishOnboarding(dailyGoal: nil)

    #expect(progress.hasFinishedOnboarding)
    #expect(progress.dailyGoal == nil)
  }

  @Test("Onboarding'den önceki kayıtta ilerleme varsa akış tekrar açılmaz")
  func treatsExistingLearnersAsOnboarded() throws {
    // Alanların hiç bulunmadığı eski şema.
    let legacy = """
      {
        "completedLessonIDs": ["variables"],
        "attempts": [
          {
            "lessonID": "variables",
            "completedAt": 750000000,
            "durationSeconds": 300,
            "quizCorrect": true
          }
        ],
        "learningEvents": []
      }
      """

    let progress = try JSONDecoder().decode(
      LessonProgress.self,
      from: Data(legacy.utf8)
    )

    #expect(progress.hasFinishedOnboarding)
    #expect(progress.dailyGoal == nil)
    #expect(progress.attempts.count == 1)
  }

  @Test("Hiç ilerlemesi olmayan eski kayıtta akış açılır")
  func showsOnboardingForEmptyLegacyRecord() throws {
    let legacy = "{\"completedLessonIDs\": [], \"attempts\": [], \"learningEvents\": []}"

    let progress = try JSONDecoder().decode(
      LessonProgress.self,
      from: Data(legacy.utf8)
    )

    #expect(!progress.hasFinishedOnboarding)
  }

  @Test("Seçilen ritim diske yazılıp geri okunur")
  func roundTripsThroughDisk() throws {
    var progress = LessonProgress()
    progress.finishOnboarding(dailyGoal: .intense)

    let restored = try JSONDecoder().decode(
      LessonProgress.self,
      from: JSONEncoder().encode(progress)
    )

    #expect(restored.dailyGoal == .intense)
    #expect(restored.hasFinishedOnboarding)
  }

  @Test("Günlük hedef göstergesi aynı dersin tekrarını iki kez saymaz")
  func countsDistinctLessonsPerDay() {
    var progress = LessonProgress()
    let today = Date(timeIntervalSince1970: 800_000_000)
    progress.recordAttempt(attempt("variables", at: today))
    progress.recordAttempt(attempt("variables", at: today.addingTimeInterval(60)))
    progress.recordAttempt(attempt("loops", at: today.addingTimeInterval(120)))
    progress.recordAttempt(attempt("scope", at: today.addingTimeInterval(-86_400)))

    #expect(progress.completedLessonCount(on: today, calendar: utcCalendar) == 2)
  }

  @Test("Önerilen ritim iki derstir")
  func recommendsSteadyPace() {
    #expect(DailyGoal.recommended == .steady)
    #expect(DailyGoal.recommended.lessonsPerDay == 2)
    #expect(DailyGoal.calm.summary == "1 ders · ~7 dk")
  }

  private var utcCalendar: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
  }

  private func attempt(_ lessonID: String, at date: Date) -> LessonAttempt {
    LessonAttempt(
      lessonID: lessonID,
      completedAt: date,
      durationSeconds: 300,
      quizCorrect: true,
      practiceAccuracy: nil,
      assessmentScore: nil
    )
  }
}
