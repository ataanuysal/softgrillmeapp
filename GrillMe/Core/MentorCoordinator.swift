/// Cihaz içi dil modelini üreten kaynak.
///
/// `Core` katmanı Foundation Models'ı doğrudan tanımaz; uygulama katmanı bu
/// sözleşmeyi uygular, testler ise sahte bir uygulama verir.
public protocol MentorTextGenerating: Sendable {
  var isAvailable: Bool { get }
  func reply(to prompt: String) async throws -> String
}

/// Bir mentor turunun kararı.
///
/// `promptForModel` nil ise model hiç çağrılmaz: ya tur bütçesi dolmuştur, ya
/// öğrenci bütün kavramları zaten kurmuştur, ya da model kullanılamaz durumdadır.
public struct MentorTurn: Equatable, Sendable {
  public let localResponse: MentorResponse
  public let promptForModel: String?

  public init(localResponse: MentorResponse, promptForModel: String?) {
    self.localResponse = localResponse
    self.promptForModel = promptForModel
  }
}

/// Mentor akışının kararlarını arayüzden ayıran katman.
///
/// Model çağrısının kendisi asenkron olduğu için burada tutulmaz; bu tip
/// yalnızca "model çağrılmalı mı", "istem ne olmalı" ve "gelen metin nasıl
/// güvenli hale gelir" sorularını cevaplar.
public struct MentorCoordinator: Equatable, Sendable {
  public private(set) var session: SocraticMentorSession
  private let correctAnswer: String

  public init(session: SocraticMentorSession, correctAnswer: String) {
    self.session = session
    self.correctAnswer = correctAnswer
  }

  public var remainingTurns: Int {
    session.remainingTurns
  }

  /// Boş açıklama tur harcamaz ve nil döner.
  public mutating func beginTurn(
    explanation: String,
    isModelAvailable: Bool
  ) -> MentorTurn? {
    let explanation = explanation.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !explanation.isEmpty else { return nil }

    let localResponse = session.reply(to: explanation)
    guard localResponse.kind == .question, isModelAvailable else {
      return MentorTurn(localResponse: localResponse, promptForModel: nil)
    }

    return MentorTurn(
      localResponse: localResponse,
      promptForModel: MentorPromptBuilder.build(
        lesson: session.lesson,
        userExplanation: explanation,
        matchedConcepts: localResponse.matchedConcepts
      )
    )
  }

  /// Modelden gelen metni doğru cevabı sızdırmayacak biçimde paketler.
  public func response(forGenerated text: String, in turn: MentorTurn) -> MentorResponse {
    MentorResponse(
      kind: .question,
      text: MentorSafetyFilter(correctAnswer: correctAnswer).sanitize(text),
      matchedConcepts: turn.localResponse.matchedConcepts
    )
  }
}
