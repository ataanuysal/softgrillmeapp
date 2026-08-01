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
  /// Anlatımdan önceki tahmin. Ders bir `TeachingHook` taşımıyorsa atlanır.
  case predict
  case topic
  case example(step: Int)
  case quiz
  case complete
}

public struct LessonJourney: Equatable, Sendable {
  public let lesson: XRayLesson

  /// Havuzdan hangi quiz sorusunun sorulacağı.
  ///
  /// Tekrar denemede bu değer artar; böylece öğrenci aynı cevabı hatırlamak
  /// yerine aynı kavramı yeni bir kodda uygulamak zorunda kalır.
  public let questionIndex: Int
  public private(set) var phase: LessonJourneyPhase
  public private(set) var selectedQuizAnswer: String?
  public private(set) var isQuizAnswerCorrect: Bool?

  /// Tahmin adımında verilen cevap. Ölçüme girmez; yalnızca öğrencinin kendi
  /// varsayımını anlatım sırasında hatırlatmak için tutulur.
  public private(set) var predictionAnswer: String?
  public private(set) var isPredictionCorrect: Bool?

  public init(lesson: XRayLesson, questionIndex: Int = 0) {
    self.lesson = lesson
    self.questionIndex = questionIndex
    phase = lesson.teaching.hook == nil ? .topic : .predict
  }

  /// Tahmini kaydeder ve anlatıma geçer.
  ///
  /// Yanlış tahmin engel değil, anlatımın başlangıç noktasıdır.
  public mutating func submitPrediction(_ answer: String) {
    guard phase == .predict, let hook = lesson.teaching.hook else { return }
    predictionAnswer = answer
    isPredictionCorrect = answer == hook.correctAnswer
    phase = .topic
  }

  /// Tahmin adımı cevaplanmadan anlatıma geçilebilir.
  public mutating func skipPrediction() {
    guard phase == .predict else { return }
    phase = .topic
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
    guard let challenge = lesson.transferChallenge(at: questionIndex) else {
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
