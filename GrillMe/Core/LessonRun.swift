import Foundation

public struct LessonRunResult: Equatable, Sendable {
  public let attempt: LessonAttempt
  public let events: [LearningEvent]

  public init(attempt: LessonAttempt, events: [LearningEvent]) {
    self.attempt = attempt
    self.events = events
  }
}

public struct LessonRun: Equatable, Sendable {
  public let lessonID: String
  public let startedAt: Date
  public let attemptNumber: Int

  public init(
    lessonID: String,
    startedAt: Date,
    attemptNumber: Int = 1
  ) {
    self.lessonID = lessonID
    self.startedAt = startedAt
    self.attemptNumber = attemptNumber
  }

  public func finish(
    journey: LessonJourney,
    evidence: LessonEvidenceEvaluation,
    completedAt: Date
  ) -> LessonRunResult? {
    guard evidence.isReadyToComplete, let quizCorrect = evidence.quizCorrect else {
      return nil
    }

    let duration = max(0, Int(completedAt.timeIntervalSince(startedAt)))
    let attempt = LessonAttempt(
      lessonID: lessonID,
      completedAt: completedAt,
      durationSeconds: duration,
      quizCorrect: quizCorrect,
      practiceAccuracy: evidence.practiceAccuracy,
      assessmentScore: evidence.assessmentScore
    )
    var events = [
      LearningEvent(
        name: .lessonStarted,
        lessonID: lessonID,
        occurredAt: startedAt
      ),
      LearningEvent.quizSubmitted(
        lessonID: lessonID,
        answer: journey.selectedQuizAnswer ?? "",
        isCorrect: quizCorrect,
        attemptNumber: attemptNumber,
        occurredAt: completedAt
      ),
    ]
    if let practiceAccuracy = evidence.practiceAccuracy {
      events.append(
        .practiceSubmitted(
          lessonID: lessonID,
          score: practiceAccuracy,
          occurredAt: completedAt
        )
      )
    }
    if let assessmentScore = evidence.assessmentScore {
      events.append(
        .assessmentSubmitted(
          lessonID: lessonID,
          score: assessmentScore,
          occurredAt: completedAt
        )
      )
    }
    events.append(
      .lessonCompleted(
        lessonID: lessonID,
        durationSeconds: duration,
        quizCorrect: quizCorrect,
        practiceAccuracy: evidence.practiceAccuracy,
        assessmentScore: evidence.assessmentScore,
        occurredAt: completedAt
      )
    )
    return LessonRunResult(attempt: attempt, events: events)
  }
}

public struct LearningDashboardSnapshot: Equatable, Sendable {
  public let completedCount: Int
  public let totalCount: Int
  public let currentStreak: Int
  public let weeklySummary: WeeklySummary
  public let growthReport: LearningGrowthReport?

  public init(
    progress: LessonProgress,
    totalLessonCount: Int,
    asOf date: Date,
    calendar: Calendar = .current
  ) {
    completedCount = progress.completedLessonIDs.count
    totalCount = totalLessonCount
    currentStreak = progress.currentStreak(asOf: date, calendar: calendar)
    weeklySummary = progress.weeklySummary(containing: date, calendar: calendar)
    growthReport = progress.growthReport(
      baselineLessonIDs: ["variables", "conditions", "loops"],
      exitLessonID: "capstone"
    )
  }
}
