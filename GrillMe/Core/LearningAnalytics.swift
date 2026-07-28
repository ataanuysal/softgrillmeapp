import Foundation

public enum LearningEventName: String, Codable, Equatable, Sendable {
  case lessonStarted = "lesson_started"
  case predictionSubmitted = "prediction_submitted"
  case transferSubmitted = "transfer_submitted"
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

  public static func predictionSubmitted(
    lessonID: String,
    answer: String,
    isCorrect: Bool,
    attemptNumber: Int,
    occurredAt: Date
  ) -> LearningEvent {
    LearningEvent(
      name: .predictionSubmitted,
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
    transferCorrect: Bool,
    occurredAt: Date
  ) -> LearningEvent {
    LearningEvent(
      name: .lessonCompleted,
      lessonID: lessonID,
      occurredAt: occurredAt,
      properties: [
        "duration_seconds": String(durationSeconds),
        "transfer_correct": String(transferCorrect),
      ]
    )
  }
}
