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
    session: XRaySession,
    completedAt: Date
  ) -> LessonRunResult {
    let duration = max(0, Int(completedAt.timeIntervalSince(startedAt)))
    let predictionCorrect = session.isPredictionCorrect ?? false
    let transferCorrect = session.isTransferAnswerCorrect
    let attempt = LessonAttempt(
      lessonID: lessonID,
      completedAt: completedAt,
      durationSeconds: duration,
      predictionCorrect: predictionCorrect,
      transferCorrect: transferCorrect
    )

    var events = [
      LearningEvent(
        name: .lessonStarted,
        lessonID: lessonID,
        occurredAt: startedAt
      ),
      LearningEvent.predictionSubmitted(
        lessonID: lessonID,
        answer: session.selectedAnswer ?? "",
        isCorrect: predictionCorrect,
        attemptNumber: attemptNumber,
        occurredAt: completedAt
      ),
    ]

    if let transferCorrect {
      events.append(
        LearningEvent(
          name: .transferSubmitted,
          lessonID: lessonID,
          occurredAt: completedAt,
          properties: [
            "answer": session.selectedTransferAnswer ?? "",
            "correct": String(transferCorrect),
          ]
        )
      )
    }

    events.append(
      LearningEvent.lessonCompleted(
        lessonID: lessonID,
        durationSeconds: duration,
        transferCorrect: transferCorrect ?? false,
        occurredAt: completedAt
      )
    )
    return LessonRunResult(attempt: attempt, events: events)
  }

  public func finish(
    journey: LessonJourney,
    completedAt: Date
  ) -> LessonRunResult {
    let duration = max(0, Int(completedAt.timeIntervalSince(startedAt)))
    let quizCorrect = journey.isQuizAnswerCorrect ?? false
    let answer = journey.selectedQuizAnswer ?? ""
    let attempt = LessonAttempt(
      lessonID: lessonID,
      completedAt: completedAt,
      durationSeconds: duration,
      predictionCorrect: quizCorrect,
      transferCorrect: quizCorrect
    )
    let events = [
      LearningEvent(
        name: .lessonStarted,
        lessonID: lessonID,
        occurredAt: startedAt
      ),
      LearningEvent.predictionSubmitted(
        lessonID: lessonID,
        answer: answer,
        isCorrect: quizCorrect,
        attemptNumber: attemptNumber,
        occurredAt: completedAt
      ),
      LearningEvent(
        name: .transferSubmitted,
        lessonID: lessonID,
        occurredAt: completedAt,
        properties: [
          "answer": answer,
          "correct": String(quizCorrect),
        ]
      ),
      LearningEvent.lessonCompleted(
        lessonID: lessonID,
        durationSeconds: duration,
        transferCorrect: quizCorrect,
        occurredAt: completedAt
      ),
    ]
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
