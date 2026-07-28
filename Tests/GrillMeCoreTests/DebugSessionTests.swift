import Testing

@testable import GrillMeCore

@Suite("Hata avcılığı oturumu")
struct DebugSessionTests {
  @Test("Kullanıcı hipotez kurmadan satır seçemez")
  func requiresHypothesisBeforeLocatingError() {
    var session = DebugSession(challenge: challenge)

    session.selectLine(2)

    #expect(session.phase == .hypothesizing)
    #expect(session.selectedLineNumber == nil)
  }

  @Test("Hipotezden sonra seçilen satırı kanıtla değerlendirir")
  func evaluatesLineAfterHypothesis() {
    var session = DebugSession(challenge: challenge)

    session.submitHypothesis("Toplama yerine çıkarma yapılmış olabilir.")
    #expect(session.phase == .locating)

    session.selectLine(2)

    #expect(session.phase == .complete)
    #expect(session.isCorrect == true)
    #expect(session.evidence == "Beklenen 3, gerçek -3. Satır 2 değeri azaltıyor.")
  }

  private var challenge: DebugChallenge {
    DebugChallenge(
      kind: .logic,
      prompt: "Yanlış sonucu üreten satırı bul.",
      code: [
        CodeLine(number: 1, text: "var toplam = 0"),
        CodeLine(number: 2, text: "toplam = toplam - 3"),
        CodeLine(number: 3, text: "print(toplam)"),
      ],
      correctLineNumber: 2,
      expected: "3",
      actual: "-3",
      explanation: "Beklenen 3, gerçek -3. Satır 2 değeri azaltıyor."
    )
  }
}
