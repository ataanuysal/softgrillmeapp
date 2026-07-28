import Foundation

public enum MentorResponseKind: Equatable, Sendable {
  case question
  case feedback
  case limitReached
}

public struct MentorResponse: Equatable, Sendable {
  public let kind: MentorResponseKind
  public let text: String
  public let matchedConcepts: [String]

  public init(
    kind: MentorResponseKind,
    text: String,
    matchedConcepts: [String]
  ) {
    self.kind = kind
    self.text = text
    self.matchedConcepts = matchedConcepts
  }
}

public enum MentorPromptBuilder {
  public static func build(
    lesson: XRayLesson,
    userExplanation: String,
    matchedConcepts: [String]
  ) -> String {
    let source = lesson.code
      .map { "\($0.number): \($0.text)" }
      .joined(separator: "\n")
    let concepts =
      matchedConcepts.isEmpty
      ? "Henüz eşleşen kavram yok."
      : matchedConcepts.joined(separator: ", ")

    return """
      Türkçe konuşan Sokratik bir kod okuma mentorüsün.
      Doğrudan cevabı verme, doğru çıktıyı yazma ve çözümü kullanıcı adına tamamlama.
      En fazla iki kısa cümle kullan. Önce kullanıcının düşüncesindeki bir noktayı fark et,
      sonra onu kodun bir sonraki adımını kendi başına bulmaya yönelten tek bir soru sor.

      Ders hedefi: \(lesson.objective)
      Kod:
      \(source)
      Kullanıcının açıklaması: \(userExplanation)
      Açıklamada eşleşen kavramlar: \(concepts)
      """
  }
}

public struct MentorSafetyFilter: Equatable, Sendable {
  public let correctAnswer: String

  public init(correctAnswer: String) {
    self.correctAnswer = correctAnswer
  }

  public func sanitize(_ response: String) -> String {
    guard !correctAnswer.isEmpty else { return response }
    return response.replacingOccurrences(
      of: correctAnswer,
      with: "sonucu kendin hesapla",
      options: [.caseInsensitive, .diacriticInsensitive]
    )
  }
}

public struct SocraticMentorSession: Equatable, Sendable {
  public let lesson: XRayLesson
  public let requiredConcepts: [String]
  public let turnLimit: Int
  public private(set) var usedTurns = 0

  public init(
    lesson: XRayLesson,
    requiredConcepts: [String],
    turnLimit: Int = 6
  ) {
    self.lesson = lesson
    self.requiredConcepts = requiredConcepts
    self.turnLimit = max(0, turnLimit)
  }

  public var remainingTurns: Int {
    max(0, turnLimit - usedTurns)
  }

  public mutating func reply(to explanation: String) -> MentorResponse {
    guard remainingTurns > 0 else {
      return MentorResponse(
        kind: .limitReached,
        text: "Bu ders için mentor turu doldu. Kodu yeniden izleyip kendi özetini yaz.",
        matchedConcepts: []
      )
    }

    usedTurns += 1
    let normalized = explanation.folding(
      options: [.caseInsensitive, .diacriticInsensitive],
      locale: Locale(identifier: "tr_TR")
    )
    let matches = requiredConcepts.filter {
      normalized.contains(
        $0.folding(
          options: [.caseInsensitive, .diacriticInsensitive],
          locale: Locale(identifier: "tr_TR")
        )
      )
    }

    if matches.count == requiredConcepts.count, !matches.isEmpty {
      return MentorResponse(
        kind: .feedback,
        text:
          "Açıklamanda \(countWord(matches.count)) temel kavramı ilişkilendirdin. "
          + "Şimdi aynı akışı farklı başlangıç değeriyle yeniden düşün.",
        matchedConcepts: matches
      )
    }

    let missing = requiredConcepts.first { !matches.contains($0) }
    let question =
      missing.map {
        "Önce \($0) için şu soruyu yanıtla: bu değer hangi satırda ve neden değişiyor?"
      }
      ?? "İlk çalışan satır hangisi ve bellekte ne değişiyor?"

    return MentorResponse(
      kind: .question,
      text: question,
      matchedConcepts: matches
    )
  }

  private func countWord(_ count: Int) -> String {
    switch count {
    case 1: "bir"
    case 2: "iki"
    case 3: "üç"
    case 4: "dört"
    case 5: "beş"
    default: String(count)
    }
  }
}
