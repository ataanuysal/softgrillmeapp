import Foundation
import Testing

@testable import GrillMeCore

@Suite("Ders çalışma kaydı")
struct LessonRunTests {
  @Test("Oturum sonucunu süre, doğruluk ve analitik olaylarla tamamlar")
  func finishesRunWithAttemptAndEvents() {
    let startedAt = Date(timeIntervalSince1970: 100)
    let completedAt = Date(timeIntervalSince1970: 412)
    var session = XRaySession(lesson: .introduction)
    session.submitPrediction("10")
    for _ in session.lesson.trace {
      session.advance()
    }
    session.submitTransferAnswer("6")
    let run = LessonRun(lessonID: "variables", startedAt: startedAt)

    let result = run.finish(session: session, completedAt: completedAt)

    #expect(result.attempt.durationSeconds == 312)
    #expect(result.attempt.predictionCorrect == false)
    #expect(result.attempt.transferCorrect == true)
    #expect(
      result.events.map(\.name) == [
        .lessonStarted,
        .predictionSubmitted,
        .transferSubmitted,
        .lessonCompleted,
      ]
    )
  }

  @Test("Dashboard tamamlanma, seri ve haftalık özeti tek görünümde toplar")
  func createsDashboardSnapshot() {
    var progress = LessonProgress()
    progress.recordAttempt(
      LessonAttempt(
        lessonID: "variables",
        completedAt: date(2026, 7, 28),
        durationSeconds: 360,
        predictionCorrect: true,
        transferCorrect: true
      )
    )

    let dashboard = LearningDashboardSnapshot(
      progress: progress,
      totalLessonCount: 30,
      asOf: date(2026, 7, 28),
      calendar: utcCalendar
    )

    #expect(dashboard.completedCount == 1)
    #expect(dashboard.totalCount == 30)
    #expect(dashboard.currentStreak == 1)
    #expect(dashboard.weeklySummary.practiceSeconds == 360)
  }

  @Test("Öğreten yolculuğun son quizini ders denemesi olarak kaydeder")
  func finishesTeachingJourneyWithQuizResult() {
    let startedAt = Date(timeIntervalSince1970: 100)
    let completedAt = Date(timeIntervalSince1970: 220)
    var journey = LessonJourney(lesson: .introduction)
    journey.startExample()
    for _ in journey.lesson.trace {
      journey.advanceExample()
    }
    journey.submitQuizAnswer("6")
    let run = LessonRun(lessonID: "variables", startedAt: startedAt)

    let result = run.finish(journey: journey, completedAt: completedAt)

    #expect(result.attempt.predictionCorrect == true)
    #expect(result.attempt.transferCorrect == true)
    #expect(result.events.map(\.name).last == .lessonCompleted)
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
