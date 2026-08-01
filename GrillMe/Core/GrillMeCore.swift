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
  public let callStack: [CallFrame]
  public let architecture: ArchitectureSnapshot?

  public init(
    lineNumber: Int,
    explanation: String,
    memory: [String: String],
    output: String?,
    callStack: [CallFrame] = [],
    architecture: ArchitectureSnapshot? = nil
  ) {
    self.lineNumber = lineNumber
    self.explanation = explanation
    self.memory = memory
    self.output = output
    self.callStack = callStack
    self.architecture = architecture
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

/// Anlatımdan önce sorulan tahmin.
///
/// Öğrenci önce küçük bir kodu tahmin eder, sonra açıklamayı okur. Sıra
/// bilerek böyle: tahmin etmeden okumak pasif okumadır ve ürünün vaadi
/// öğrenciyi pasif izleyicilikten çıkarmaktır.
///
/// Tahmin bir ölçüm değildir. Doğru ya da yanlış olması derse kaydedilmez;
/// amacı öğrencinin kendi varsayımını görünür kılmaktır.
public struct TeachingHook: Equatable, Sendable {
  public let question: String
  public let code: [CodeLine]
  public let choices: [String]
  public let correctAnswer: String
  /// Cevaptan sonra gösterilen tek cümlelik açılış.
  public let reveal: String

  public init(
    question: String = "Sence bu kod ne yazar?",
    code: [CodeLine],
    choices: [String],
    correctAnswer: String,
    reveal: String
  ) {
    self.question = question
    self.code = code
    self.choices = choices
    self.correctAnswer = correctAnswer
    self.reveal = reveal
  }
}

/// Anlatımın içine işlenmiş küçük örnek.
///
/// Anlatım yalnızca iddia etmesin diye: iki üç satır kod ve o kodda neyin
/// değiştiğini söyleyen tek cümle.
public struct MicroExample: Equatable, Sendable {
  public let code: [CodeLine]
  public let note: String

  public init(code: [CodeLine], note: String) {
    self.code = code
    self.note = note
  }
}

/// Dersin kendi konu anlatımı.
///
/// Bölüm başına yazılmış ortak metin, aynı bölümdeki yedi dersi birbirinin
/// aynısı yapar. Bu tip her dersin kendi gerekçesini, kendi tipik hatasını ve
/// kendi gerçek proje bağlamını taşımasını sağlar.
public struct LessonTeaching: Equatable, Sendable {
  public let whyItMatters: String
  public let commonMistake: String
  public let realWorldUse: String
  /// Anlatımdan önceki tahmin adımı.
  public let hook: TeachingHook?
  /// Anlatımın içindeki küçük gösterim.
  public let microExample: MicroExample?
  /// Önceki bir derse tek cümlelik bağ.
  ///
  /// Kırk ders birbirine değmezse öğrencinin kafasında ağ değil, ayrı kartlar
  /// oluşur.
  public let connection: String?

  public init(
    whyItMatters: String,
    commonMistake: String,
    realWorldUse: String,
    hook: TeachingHook? = nil,
    microExample: MicroExample? = nil,
    connection: String? = nil
  ) {
    self.whyItMatters = whyItMatters
    self.commonMistake = commonMistake
    self.realWorldUse = realWorldUse
    self.hook = hook
    self.microExample = microExample
    self.connection = connection
  }
}

public enum ProgramOutcome: Equatable, Sendable {
  case output(String)
  case compileError(String)
  case runtimeError(String)
  case noOutput

  public var output: String? {
    guard case .output(let value) = self else { return nil }
    return value
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

  /// Dersin quiz havuzu.
  ///
  /// Tek soru, kavramı tek atışta ölçer ve tekrar denemede aynı cevabın
  /// hatırlanmasından ibaret kalır. Havuz sayesinde her deneme farklı bir
  /// soruya düşer; `LessonJourney` sırayı `questionIndex` ile seçer.
  public let transferChallenges: [TransferChallenge]
  public let estimatedMinutes: Int
  public let debugChallenge: DebugChallenge?
  public let section: CurriculumSection
  public let practiceChallenges: [PracticeChallenge]
  public let assessmentTasks: [AssessmentTask]
  public let languageVariants: [CodeVariant]
  public let languageComparison: LanguageComparison?
  public let programOutcome: ProgramOutcome
  public let teaching: LessonTeaching

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
    transferChallenges: [TransferChallenge] = [],
    estimatedMinutes: Int = 7,
    debugChallenge: DebugChallenge? = nil,
    section: CurriculumSection = .fundamentals,
    practiceChallenges: [PracticeChallenge] = [],
    assessmentTasks: [AssessmentTask] = [],
    languageVariants: [CodeVariant] = [],
    languageComparison: LanguageComparison? = nil,
    programOutcome: ProgramOutcome? = nil,
    teaching: LessonTeaching
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
    self.transferChallenges = transferChallenges
    self.estimatedMinutes = estimatedMinutes
    self.debugChallenge = debugChallenge
    self.section = section
    self.practiceChallenges = practiceChallenges
    self.assessmentTasks = assessmentTasks
    self.languageVariants = languageVariants
    self.languageComparison = languageComparison
    self.programOutcome = programOutcome ?? .output(correctAnswer)
    self.teaching = teaching
  }

  /// Havuzdaki ilk soru. Tek soru bekleyen çağrı noktaları için.
  public var transferChallenge: TransferChallenge? {
    transferChallenges.first
  }

  /// Verilen denemeye düşen quiz sorusu; havuz tükendiğinde başa sarar.
  public func transferChallenge(at index: Int) -> TransferChallenge? {
    guard !transferChallenges.isEmpty else { return nil }
    let wrapped =
      ((index % transferChallenges.count) + transferChallenges.count)
      % transferChallenges.count
    return transferChallenges[wrapped]
  }

  public var availableLenses: [CodeLens] {
    var lenses: [CodeLens] = [.flow, .memory, .output]
    if trace.contains(where: { !$0.callStack.isEmpty }) {
      lenses.append(.call)
    }
    if trace.contains(where: { $0.architecture != nil }) {
      lenses.append(.architecture)
    }
    if debugChallenge != nil {
      lenses.append(.error)
    }
    if availableLanguages.count > 1 {
      lenses.append(.language)
    }
    return lenses
  }

  public var availableLanguages: [CodeLanguage] {
    CodeLanguage.allCases.filter { language in
      language == .swift || languageVariants.contains(where: { $0.language == language })
    }
  }

  public func code(for language: CodeLanguage) -> [CodeLine] {
    guard language != .swift else { return code }
    return languageVariants.first(where: { $0.language == language })?.code ?? code
  }
}
