import Foundation

public enum LessonRequirement: String, Equatable, Hashable, Sendable {
  case quiz
  case debugging
  case practice
  case assessment
}

public struct LessonEvidenceEvaluation: Equatable, Sendable {
  public let isReadyToComplete: Bool
  public let missingRequirements: Set<LessonRequirement>
  public let quizCorrect: Bool?
  public let practiceAccuracy: Double?
  public let assessmentScore: Double?

  public init(
    isReadyToComplete: Bool,
    missingRequirements: Set<LessonRequirement>,
    quizCorrect: Bool?,
    practiceAccuracy: Double?,
    assessmentScore: Double?
  ) {
    self.isReadyToComplete = isReadyToComplete
    self.missingRequirements = missingRequirements
    self.quizCorrect = quizCorrect
    self.practiceAccuracy = practiceAccuracy
    self.assessmentScore = assessmentScore
  }
}

public struct LessonEvidence: Equatable, Sendable {
  public let quizAnswer: String?
  public let practiceAnswers: [Int: String]
  public let assessmentResponses: [AssessmentTaskKind: String]
  public let debugCompleted: Bool

  public init(
    quizAnswer: String?,
    practiceAnswers: [Int: String],
    assessmentResponses: [AssessmentTaskKind: String],
    debugCompleted: Bool
  ) {
    self.quizAnswer = quizAnswer
    self.practiceAnswers = practiceAnswers
    self.assessmentResponses = assessmentResponses
    self.debugCompleted = debugCompleted
  }

  public func evaluate(for lesson: XRayLesson) -> LessonEvidenceEvaluation {
    var missingRequirements: Set<LessonRequirement> = []

    let expectedQuizAnswer = lesson.transferChallenge?.correctAnswer ?? lesson.correctAnswer
    let quizCorrect = quizAnswer.map { $0 == expectedQuizAnswer }
    if quizAnswer == nil {
      missingRequirements.insert(.quiz)
    }

    if lesson.debugChallenge != nil, !debugCompleted {
      missingRequirements.insert(.debugging)
    }

    let practiceResults = lesson.practiceChallenges.enumerated().compactMap { index, challenge in
      practiceAnswers[index].map { $0 == challenge.correctAnswer }
    }
    if practiceResults.count != lesson.practiceChallenges.count {
      missingRequirements.insert(.practice)
    }

    let assessmentEvaluations: [AssessmentEvaluation] = lesson.assessmentTasks.compactMap {
      task -> AssessmentEvaluation? in
      guard
        let response = assessmentResponses[task.kind]?
          .trimmingCharacters(in: .whitespacesAndNewlines),
        !response.isEmpty
      else {
        return nil
      }
      return task.rubric.evaluate(response)
    }
    if assessmentEvaluations.count != lesson.assessmentTasks.count {
      missingRequirements.insert(.assessment)
    }

    return LessonEvidenceEvaluation(
      isReadyToComplete: missingRequirements.isEmpty,
      missingRequirements: missingRequirements,
      quizCorrect: quizCorrect,
      practiceAccuracy: ratio(of: practiceResults),
      assessmentScore: average(of: assessmentEvaluations.map(\.score))
    )
  }

  private func ratio(of results: [Bool]) -> Double? {
    guard !results.isEmpty else { return nil }
    return Double(results.filter { $0 }.count) / Double(results.count)
  }

  private func average(of values: [Double]) -> Double? {
    guard !values.isEmpty else { return nil }
    return values.reduce(0, +) / Double(values.count)
  }
}
