public struct LessonTeachingContent: Equatable, Sendable {
  public let explanation: String
  public let keyIdea: String
  public let exampleCode: [CodeLine]

  public init(
    explanation: String,
    keyIdea: String,
    exampleCode: [CodeLine]
  ) {
    self.explanation = explanation
    self.keyIdea = keyIdea
    self.exampleCode = exampleCode
  }
}

public struct LessonQuiz: Equatable, Sendable {
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

public enum LessonJourneyPhase: Equatable, Sendable {
  case topic
  case example(step: Int)
  case quiz
  case complete
}

public struct LessonJourney: Equatable, Sendable {
  public let lesson: XRayLesson
  public private(set) var phase: LessonJourneyPhase = .topic
  public private(set) var selectedQuizAnswer: String?
  public private(set) var isQuizAnswerCorrect: Bool?

  public init(lesson: XRayLesson) {
    self.lesson = lesson
  }

  public var teachingContent: LessonTeachingContent {
    let context = lesson.teaching
    return LessonTeachingContent(
      explanation: """
        \(lesson.objective)

        \(lesson.takeaway)

        Neden önemli: \(context.whyItMatters)

        Sık hata: \(context.commonMistake)

        Gerçek projede: \(context.realWorldUse)
        """,
      keyIdea: lesson.takeaway,
      exampleCode: lesson.code
    )
  }

  public var quiz: LessonQuiz {
    guard let challenge = lesson.transferChallenge else {
      return LessonQuiz(
        prompt: lesson.question,
        code: lesson.code,
        choices: lesson.choices,
        correctAnswer: lesson.correctAnswer,
        explanation: lesson.takeaway
      )
    }

    return LessonQuiz(
      prompt: challenge.prompt,
      code: challenge.code,
      choices: challenge.choices,
      correctAnswer: challenge.correctAnswer,
      explanation: challenge.explanation
    )
  }

  public var currentExampleStep: TraceStep? {
    guard case .example(let step) = phase, lesson.trace.indices.contains(step) else {
      return nil
    }
    return lesson.trace[step]
  }

  public mutating func startExample() {
    guard phase == .topic else { return }
    phase = lesson.trace.isEmpty ? .quiz : .example(step: 0)
  }

  public mutating func advanceExample() {
    guard case .example(let step) = phase else { return }
    let nextStep = step + 1
    phase =
      lesson.trace.indices.contains(nextStep)
      ? .example(step: nextStep)
      : .quiz
  }

  public mutating func submitQuizAnswer(_ answer: String) {
    guard phase == .quiz else { return }
    selectedQuizAnswer = answer
    isQuizAnswerCorrect = answer == quiz.correctAnswer
    phase = .complete
  }
}
