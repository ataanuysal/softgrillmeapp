public enum LessonValidationIssue: Equatable, Sendable {
  case missingCode
  case missingChoices
  case correctAnswerNotInChoices
  case missingTrace
  case traceReferencesUnknownLine(Int)
  case finalOutputDoesNotMatchAnswer
  case unexpectedOutputForProgramFailure
  case missingTransferChallenge
  case transferAnswerNotInChoices
  case invalidEstimatedMinutes
}

public struct LessonValidator: Sendable {
  public init() {}

  public func issues(in lesson: XRayLesson) -> [LessonValidationIssue] {
    var issues: [LessonValidationIssue] = []
    let lineNumbers = Set(lesson.code.map(\.number))

    if lesson.code.isEmpty {
      issues.append(.missingCode)
    }
    if lesson.choices.isEmpty {
      issues.append(.missingChoices)
    }
    if !lesson.choices.contains(lesson.correctAnswer) {
      issues.append(.correctAnswerNotInChoices)
    }
    if lesson.trace.isEmpty {
      issues.append(.missingTrace)
    }
    for step in lesson.trace where !lineNumbers.contains(step.lineNumber) {
      issues.append(.traceReferencesUnknownLine(step.lineNumber))
    }
    switch lesson.programOutcome {
    case .output(let expected):
      if lesson.trace.last?.output != expected {
        issues.append(.finalOutputDoesNotMatchAnswer)
      }
    case .compileError, .runtimeError, .noOutput:
      if lesson.trace.contains(where: { $0.output != nil }) {
        issues.append(.unexpectedOutputForProgramFailure)
      }
    }
    if lesson.transferChallenges.isEmpty {
      issues.append(.missingTransferChallenge)
    }
    for transfer in lesson.transferChallenges
    where !transfer.choices.contains(transfer.correctAnswer) {
      issues.append(.transferAnswerNotInChoices)
    }
    if !(5...10).contains(lesson.estimatedMinutes) {
      issues.append(.invalidEstimatedMinutes)
    }
    return issues
  }
}
