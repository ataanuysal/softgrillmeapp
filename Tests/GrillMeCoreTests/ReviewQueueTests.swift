import Foundation
import Testing

@testable import GrillMeCore

@Suite("Aralıklı tekrar kuyruğu")
struct ReviewQueueTests {
  @Test("Yanlış bilinen ders, unutulmaya yüz tutmuş dersin önüne geçer")
  func prioritisesIncorrectAnswers() {
    var progress = LessonProgress()
    progress.recordAttempt(attempt("loops", on: day(1), quizCorrect: true))
    progress.recordAttempt(attempt("conditions", on: day(9), quizCorrect: false))

    let items = ReviewQueue.items(from: progress, asOf: day(10), calendar: utcCalendar)

    #expect(items.map(\.lessonID) == ["conditions", "loops"])
    #expect(items.first?.reason == .incorrectLastTime)
    #expect(items.last?.reason == .fading)
  }

  @Test("Aynı gün çözülen ders tekrara girmez")
  func skipsLessonsPractisedToday() {
    var progress = LessonProgress()
    progress.recordAttempt(attempt("loops", on: day(10), quizCorrect: false))

    let items = ReviewQueue.items(from: progress, asOf: day(10), calendar: utcCalendar)

    #expect(items.isEmpty)
  }

  @Test("Doğru bilinen ders ancak aradan gün geçince tekrara düşer")
  func waitsBeforeRecallingCorrectLessons() {
    var progress = LessonProgress()
    progress.recordAttempt(attempt("loops", on: day(9), quizCorrect: true))

    let tooSoon = ReviewQueue.items(from: progress, asOf: day(10), calendar: utcCalendar)
    let later = ReviewQueue.items(from: progress, asOf: day(12), calendar: utcCalendar)

    #expect(tooSoon.isEmpty)
    #expect(later.map(\.lessonID) == ["loops"])
  }

  @Test("Son deneme doğruysa eski yanlış kayıt kuyruğu tetiklemez")
  func usesLatestAttemptOnly() {
    var progress = LessonProgress()
    progress.recordAttempt(attempt("loops", on: day(1), quizCorrect: false))
    progress.recordAttempt(attempt("loops", on: day(9), quizCorrect: true))

    let items = ReviewQueue.items(from: progress, asOf: day(10), calendar: utcCalendar)

    #expect(items.isEmpty)
  }

  @Test("En uzun süredir görülmeyen ders önce gelir ve kuyruk sınırlanır")
  func ordersByStalenessAndRespectsLimit() {
    var progress = LessonProgress()
    progress.recordAttempt(attempt("variables", on: day(1), quizCorrect: true))
    progress.recordAttempt(attempt("conditions", on: day(3), quizCorrect: true))
    progress.recordAttempt(attempt("loops", on: day(5), quizCorrect: true))

    let items = ReviewQueue.items(from: progress, asOf: day(20), limit: 2, calendar: utcCalendar)

    #expect(items.map(\.lessonID) == ["variables", "conditions"])
  }

  @Test("Tekrar kaydı dersin kaçıncı denemesi olduğunu taşır")
  func reportsAttemptCountForQuestionRotation() {
    var progress = LessonProgress()
    progress.recordAttempt(attempt("loops", on: day(1), quizCorrect: true))
    progress.recordAttempt(attempt("loops", on: day(2), quizCorrect: false))

    let items = ReviewQueue.items(from: progress, asOf: day(10), calendar: utcCalendar)

    #expect(items.first?.completedAttempts == 2)
  }

  private var utcCalendar: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
  }

  private func day(_ index: Int) -> Date {
    Date(timeIntervalSince1970: TimeInterval(index) * 86_400)
  }

  private func attempt(_ lessonID: String, on date: Date, quizCorrect: Bool) -> LessonAttempt {
    LessonAttempt(
      lessonID: lessonID,
      completedAt: date,
      durationSeconds: 300,
      quizCorrect: quizCorrect,
      practiceAccuracy: nil,
      assessmentScore: nil
    )
  }
}
