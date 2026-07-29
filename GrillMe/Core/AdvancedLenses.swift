import Foundation

public enum CurriculumSection: String, Codable, CaseIterable, Equatable, Hashable, Sendable {
  case fundamentals
  case functions
  case collections
  case objects
  case debugging
  case asynchronous
  case appArchitecture
  case assessment
  case softwareTesting
  case technicalAnalysis
}

public enum CodeLens: String, Codable, Equatable, Sendable {
  case flow
  case memory
  case output
  case call
  case architecture
  case error
  case language
}

public struct CallFrame: Equatable, Sendable {
  public let functionName: String
  public let locals: [String: String]

  public init(functionName: String, locals: [String: String]) {
    self.functionName = functionName
    self.locals = locals
  }
}

public enum ArchitectureEntityKind: String, Codable, Equatable, Sendable {
  case `class`
  case instance
  case value
  case function
}

public struct ArchitectureEntity: Equatable, Sendable {
  public let id: String
  public let label: String
  public let kind: ArchitectureEntityKind

  public init(id: String, label: String, kind: ArchitectureEntityKind) {
    self.id = id
    self.label = label
    self.kind = kind
  }
}

public struct ArchitectureRelationship: Equatable, Sendable {
  public let sourceID: String
  public let targetID: String
  public let label: String

  public init(sourceID: String, targetID: String, label: String) {
    self.sourceID = sourceID
    self.targetID = targetID
    self.label = label
  }
}

public struct ArchitectureSnapshot: Equatable, Sendable {
  public let entities: [ArchitectureEntity]
  public let relationships: [ArchitectureRelationship]

  public init(
    entities: [ArchitectureEntity],
    relationships: [ArchitectureRelationship]
  ) {
    self.entities = entities
    self.relationships = relationships
  }
}

public enum DebugErrorKind: String, Codable, Equatable, Hashable, Sendable {
  case syntax
  case runtime
  case logic
  case edgeCase
  case optional
  case stackTrace
}

public struct DebugChallenge: Equatable, Sendable {
  public let kind: DebugErrorKind
  public let prompt: String
  public let code: [CodeLine]
  public let correctLineNumber: Int
  public let expected: String
  public let actual: String
  public let explanation: String

  public init(
    kind: DebugErrorKind,
    prompt: String,
    code: [CodeLine],
    correctLineNumber: Int,
    expected: String,
    actual: String,
    explanation: String
  ) {
    self.kind = kind
    self.prompt = prompt
    self.code = code
    self.correctLineNumber = correctLineNumber
    self.expected = expected
    self.actual = actual
    self.explanation = explanation
  }
}

public enum DebugSessionPhase: Equatable, Sendable {
  case hypothesizing
  case locating
  case complete
}

public struct DebugSession: Equatable, Sendable {
  public let challenge: DebugChallenge
  public private(set) var phase: DebugSessionPhase = .hypothesizing
  public private(set) var hypothesis: String?
  public private(set) var selectedLineNumber: Int?
  public private(set) var isCorrect: Bool?
  public private(set) var evidence: String?

  public init(challenge: DebugChallenge) {
    self.challenge = challenge
  }

  public mutating func submitHypothesis(_ hypothesis: String) {
    let value = hypothesis.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !value.isEmpty else { return }
    self.hypothesis = value
    phase = .locating
  }

  public mutating func selectLine(_ lineNumber: Int) {
    guard phase == .locating else { return }
    selectedLineNumber = lineNumber
    isCorrect = lineNumber == challenge.correctLineNumber
    evidence = challenge.explanation
    phase = .complete
  }
}

public enum PracticeChallengeKind: String, Codable, Equatable, Sendable {
  case naming
  case concept
  case architecture
}

public struct PracticeChallenge: Equatable, Sendable {
  public let kind: PracticeChallengeKind
  public let prompt: String
  public let choices: [String]
  public let correctAnswer: String
  public let explanation: String

  public init(
    kind: PracticeChallengeKind,
    prompt: String,
    choices: [String],
    correctAnswer: String,
    explanation: String
  ) {
    self.kind = kind
    self.prompt = prompt
    self.choices = choices
    self.correctAnswer = correctAnswer
    self.explanation = explanation
  }
}

public enum AssessmentTaskKind: String, Codable, Equatable, Hashable, Sendable {
  case outputPrediction
  case valueTrace
  case callOrder
  case errorLocation
  case freeExplanation
}

public struct AssessmentEvaluation: Equatable, Sendable {
  public let score: Double
  public let matchedConcepts: [String]
  public let missingConcepts: [String]
  public let feedback: String

  public init(
    score: Double,
    matchedConcepts: [String],
    missingConcepts: [String],
    feedback: String
  ) {
    self.score = score
    self.matchedConcepts = matchedConcepts
    self.missingConcepts = missingConcepts
    self.feedback = feedback
  }
}

public struct AssessmentRubric: Equatable, Sendable {
  public let requiredConcepts: [String]
  public let modelAnswer: String

  public init(requiredConcepts: [String], modelAnswer: String) {
    self.requiredConcepts = requiredConcepts
    self.modelAnswer = modelAnswer
  }

  public func evaluate(_ response: String) -> AssessmentEvaluation {
    let matchedConcepts = requiredConcepts.filter {
      ConceptMatcher.matches($0, in: response)
    }
    let missingConcepts = requiredConcepts.filter { !matchedConcepts.contains($0) }
    let score =
      requiredConcepts.isEmpty
      ? 1
      : Double(matchedConcepts.count) / Double(requiredConcepts.count)
    let feedback =
      missingConcepts.isEmpty
      ? "Gerekli kavramların tamamını kanıtla ilişkilendirdin."
      : "Eksik kavramlar: \(missingConcepts.joined(separator: ", ")). Örnek yaklaşım: \(modelAnswer)"

    return AssessmentEvaluation(
      score: score,
      matchedConcepts: matchedConcepts,
      missingConcepts: missingConcepts,
      feedback: feedback
    )
  }
}

public struct AssessmentTask: Equatable, Sendable {
  public let kind: AssessmentTaskKind
  public let prompt: String
  public let rubric: AssessmentRubric

  public init(
    kind: AssessmentTaskKind,
    prompt: String,
    rubric: AssessmentRubric
  ) {
    self.kind = kind
    self.prompt = prompt
    self.rubric = rubric
  }
}
