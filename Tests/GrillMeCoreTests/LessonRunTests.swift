import Foundation
import Testing

@testable import GrillMeCore

@Suite("Ders çalışma kaydı")
struct LessonRunTests {
  @Test("Yanlış quiz sonucunu süre ve analitik olaylarla kaydeder")
  func finishesRunWithIncorrectQuizResult() {
    let startedAt = Date(timeIntervalSince1970: 100)
    let completedAt = Date(timeIntervalSince1970: 412)
    var journey = LessonJourney(lesson: .introduction)
    journey.startExample()
    for _ in journey.lesson.trace {
      journey.advanceExample()
    }
    journey.submitQuizAnswer("5")
    let run = LessonRun(lessonID: "variables", startedAt: startedAt)

    let result = run.finish(
      journey: journey,
      evidence: evidence(for: journey),
      completedAt: completedAt
    )!

    #expect(result.attempt.durationSeconds == 312)
    #expect(result.attempt.quizCorrect == false)
    #expect(result.attempt.practiceAccuracy == 1)
    #expect(result.attempt.assessmentScore == nil)
    #expect(
      result.events.map(\.name) == [
        .lessonStarted,
        .quizSubmitted,
        .practiceSubmitted,
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
        quizCorrect: true,
        practiceAccuracy: 0.75,
        assessmentScore: 0.5
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

    let result = run.finish(
      journey: journey,
      evidence: evidence(for: journey),
      completedAt: completedAt
    )!

    #expect(result.attempt.durationSeconds == 120)
    #expect(result.attempt.quizCorrect == true)
    #expect(result.attempt.practiceAccuracy == 1)
    #expect(result.attempt.assessmentScore == nil)
    #expect(
      result.events.map(\.name) == [
        .lessonStarted,
        .quizSubmitted,
        .practiceSubmitted,
        .lessonCompleted,
      ]
    )
  }

  @Test("Tek quiz sonucu ikinci bir transfer ölçümü üretmez")
  func recordsQuizResultOnlyOnce() {
    let startedAt = Date(timeIntervalSince1970: 100)
    let completedAt = Date(timeIntervalSince1970: 220)
    var journey = LessonJourney(lesson: .introduction)
    journey.startExample()
    for _ in journey.lesson.trace {
      journey.advanceExample()
    }
    journey.submitQuizAnswer("6")

    let result = LessonRun(lessonID: "variables", startedAt: startedAt)
      .finish(
        journey: journey,
        evidence: evidence(for: journey),
        completedAt: completedAt
      )!

    #expect(result.attempt.practiceAccuracy == 1)
    #expect(result.attempt.assessmentScore == nil)
    #expect(
      result.events.map(\.name.rawValue) == [
        "lesson_started",
        "quiz_submitted",
        "practice_submitted",
        "lesson_completed",
      ]
    )
  }

  @Test("Quiz, pratik ve değerlendirme kanıtlarını bağımsız kaydeder")
  func recordsIndependentEvidence() {
    let lesson = LessonCatalog.standard.lessons.first { $0.id == "capstone" }!
    var journey = LessonJourney(lesson: lesson)
    journey.startExample()
    for _ in lesson.trace {
      journey.advanceExample()
    }
    journey.submitQuizAnswer(lesson.transferChallenge?.correctAnswer ?? lesson.correctAnswer)

    let evidence = LessonEvidence(
      quizAnswer: journey.selectedQuizAnswer,
      practiceAnswers: Dictionary(
        uniqueKeysWithValues: lesson.practiceChallenges.enumerated().map {
          ($0.offset, $0.element.correctAnswer)
        }
      ),
      assessmentResponses: Dictionary(
        uniqueKeysWithValues: lesson.assessmentTasks.map {
          ($0.kind, $0.rubric.modelAnswer)
        }
      ),
      debugCompleted: true
    ).evaluate(for: lesson)

    let result = LessonRun(
      lessonID: lesson.id,
      startedAt: Date(timeIntervalSince1970: 100)
    ).finish(
      journey: journey,
      evidence: evidence,
      completedAt: Date(timeIntervalSince1970: 220)
    )

    #expect(result?.attempt.quizCorrect == true)
    #expect(result?.attempt.practiceAccuracy == 1)
    #expect(result?.attempt.assessmentScore == 1)
    #expect(
      result?.events.map(\.name) == [
        .lessonStarted,
        .quizSubmitted,
        .practiceSubmitted,
        .assessmentSubmitted,
        .lessonCompleted,
      ]
    )
  }

  @Test("Eksik öğrenme kanıtıyla ders tamamlanmaz")
  func rejectsIncompleteEvidence() {
    let lesson = LessonCatalog.standard.lessons.first { $0.id == "capstone" }!
    let journey = LessonJourney(lesson: lesson)
    let evidence = LessonEvidence(
      quizAnswer: nil,
      practiceAnswers: [:],
      assessmentResponses: [:],
      debugCompleted: false
    ).evaluate(for: lesson)

    let result = LessonRun(lessonID: lesson.id, startedAt: Date())
      .finish(journey: journey, evidence: evidence, completedAt: Date())

    #expect(result == nil)
  }

  private var utcCalendar: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return calendar
  }

  private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
    utcCalendar.date(from: DateComponents(year: year, month: month, day: day))!
  }

  /// Dersin bütün pratik sorularını doğru cevaplamış bir kanıt üretir.
  ///
  /// Kanıt kapısı eksik pratik yanıtında tamamlamayı kapatır; bu yardımcı
  /// testin ölçmek istediği şeye (quiz sonucu ve süre) odaklanmasını sağlar.
  private func evidence(for journey: LessonJourney) -> LessonEvidenceEvaluation {
    let practiceAnswers = Dictionary(
      uniqueKeysWithValues: journey.lesson.practiceChallenges.enumerated().map {
        ($0.offset, $0.element.correctAnswer)
      }
    )
    return LessonEvidence(
      quizAnswer: journey.selectedQuizAnswer,
      practiceAnswers: practiceAnswers,
      assessmentResponses: [:],
      debugCompleted: journey.lesson.debugChallenge == nil
    ).evaluate(for: journey.lesson)
  }
}
