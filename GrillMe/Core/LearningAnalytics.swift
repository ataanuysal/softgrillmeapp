import Foundation

public enum LearningEventName: String, Codable, Equatable, Sendable {
  case lessonStarted = "lesson_started"
  case quizSubmitted = "quiz_submitted"
  case practiceSubmitted = "practice_submitted"
  case assessmentSubmitted = "assessment_submitted"
  case lessonCompleted = "lesson_completed"
}

public struct LearningEvent: Codable, Equatable, Sendable {
  public let name: LearningEventName
  public let lessonID: String
  public let occurredAt: Date
  public let properties: [String: String]

  public init(
    name: LearningEventName,
    lessonID: String,
    occurredAt: Date,
    properties: [String: String] = [:]
  ) {
    self.name = name
    self.lessonID = lessonID
    self.occurredAt = occurredAt
    self.properties = properties
  }

  public static func quizSubmitted(
    lessonID: String,
    answer: String,
    isCorrect: Bool,
    attemptNumber: Int,
    occurredAt: Date
  ) -> LearningEvent {
    LearningEvent(
      name: .quizSubmitted,
      lessonID: lessonID,
      occurredAt: occurredAt,
      properties: [
        "answer": answer,
        "attempt": String(attemptNumber),
        "correct": String(isCorrect),
      ]
    )
  }

  public static func lessonCompleted(
    lessonID: String,
    durationSeconds: Int,
    quizCorrect: Bool,
    practiceAccuracy: Double?,
    assessmentScore: Double?,
    occurredAt: Date
  ) -> LearningEvent {
    var properties = [
      "duration_seconds": String(durationSeconds),
      "quiz_correct": String(quizCorrect),
    ]
    if let practiceAccuracy {
      properties["practice_accuracy"] = String(practiceAccuracy)
    }
    if let assessmentScore {
      properties["assessment_score"] = String(assessmentScore)
    }

    return LearningEvent(
      name: .lessonCompleted,
      lessonID: lessonID,
      occurredAt: occurredAt,
      properties: properties
    )
  }

  public static func practiceSubmitted(
    lessonID: String,
    score: Double,
    occurredAt: Date
  ) -> LearningEvent {
    return LearningEvent(
      name: .practiceSubmitted,
      lessonID: lessonID,
      occurredAt: occurredAt,
      properties: ["score": String(score)]
    )
  }

  public static func assessmentSubmitted(
    lessonID: String,
    score: Double,
    occurredAt: Date
  ) -> LearningEvent {
    return LearningEvent(
      name: .assessmentSubmitted,
      lessonID: lessonID,
      occurredAt: occurredAt,
      properties: ["score": String(score)]
    )
  }
}
