public struct CodeLine: Equatable, Sendable {
  public let number: Int
  public let text: String

  public init(number: Int, text: String) {
    self.number = number
    self.text = text
  }
}

public struct TraceStep: Equatable, Sendable {
  public let lineNumber: Int
  public let explanation: String
  public let memory: [String: String]
  public let output: String?

  public init(
    lineNumber: Int,
    explanation: String,
    memory: [String: String],
    output: String?
  ) {
    self.lineNumber = lineNumber
    self.explanation = explanation
    self.memory = memory
    self.output = output
  }
}

public struct TransferChallenge: Equatable, Sendable {
  public let prompt: String
  public let code: [CodeLine]
  public let choices: [String]
  public let correctAnswer: String
  public let explanation: String

  public init(
    prompt: String,
    code: [CodeLine],
    choices: [String],
    correctAnswer: String,
    explanation: String
  ) {
    self.prompt = prompt
    self.code = code
    self.choices = choices
    self.correctAnswer = correctAnswer
    self.explanation = explanation
  }
}

public struct XRayLesson: Equatable, Sendable {
  public let id: String
  public let order: Int
  public let topic: String
  public let objective: String
  public let takeaway: String
  public let title: String
  public let question: String
  public let code: [CodeLine]
  public let choices: [String]
  public let correctAnswer: String
  public let trace: [TraceStep]
  public let transferChallenge: TransferChallenge?

  public init(
    id: String = "lesson",
    order: Int = 0,
    topic: String = "",
    objective: String = "",
    takeaway: String = "",
    title: String,
    question: String,
    code: [CodeLine],
    choices: [String],
    correctAnswer: String,
    trace: [TraceStep],
    transferChallenge: TransferChallenge? = nil
  ) {
    self.id = id
    self.order = order
    self.topic = topic
    self.objective = objective
    self.takeaway = takeaway
    self.title = title
    self.question = question
    self.code = code
    self.choices = choices
    self.correctAnswer = correctAnswer
    self.trace = trace
    self.transferChallenge = transferChallenge
  }
}

public enum XRaySessionPhase: Equatable, Sendable {
  case predicting
  case tracing(step: Int)
  case transfer
  case complete
}

public struct XRaySession: Equatable, Sendable {
  public let lesson: XRayLesson
  public private(set) var selectedAnswer: String?
  public private(set) var isPredictionCorrect: Bool?
  public private(set) var selectedTransferAnswer: String?
  public private(set) var isTransferAnswerCorrect: Bool?
  public private(set) var phase: XRaySessionPhase = .predicting

  public init(lesson: XRayLesson) {
    self.lesson = lesson
  }

  public var currentStep: TraceStep? {
    switch phase {
    case .predicting:
      nil
    case .tracing(let step):
      lesson.trace.indices.contains(step) ? lesson.trace[step] : nil
    case .transfer, .complete:
      lesson.trace.last
    }
  }

  public mutating func submitPrediction(_ answer: String) {
    selectedAnswer = answer
    isPredictionCorrect = answer == lesson.correctAnswer
    phase = lesson.trace.isEmpty ? .complete : .tracing(step: 0)
  }

  public mutating func advance() {
    guard case .tracing(let step) = phase else {
      return
    }

    let nextStep = step + 1
    phase =
      lesson.trace.indices.contains(nextStep)
      ? .tracing(step: nextStep)
      : lesson.transferChallenge == nil ? .complete : .transfer
  }

  public mutating func submitTransferAnswer(_ answer: String) {
    guard case .transfer = phase, let challenge = lesson.transferChallenge else {
      return
    }

    selectedTransferAnswer = answer
    isTransferAnswerCorrect = answer == challenge.correctAnswer
    phase = .complete
  }
}
