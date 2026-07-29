import Testing

@testable import GrillMeCore

@Suite("Mentor akış kararı")
struct MentorCoordinatorTests {
  @Test("Boş açıklama tur harcamaz")
  func ignoresEmptyExplanation() {
    var coordinator = makeCoordinator(turnLimit: 3)

    let turn = coordinator.beginTurn(explanation: "   \n ", isModelAvailable: true)

    #expect(turn == nil)
    #expect(coordinator.remainingTurns == 3)
  }

  @Test("Model kullanılamadığında istek üretmez, yerel soruyu döner")
  func fallsBackToLocalWhenModelUnavailable() {
    var coordinator = makeCoordinator(turnLimit: 3)

    let turn = coordinator.beginTurn(explanation: "Bilmiyorum", isModelAvailable: false)

    #expect(turn?.promptForModel == nil)
    #expect(turn?.localResponse.kind == .question)
    #expect(coordinator.remainingTurns == 2)
  }

  @Test("Öğrenci bütün kavramları kurduğunda modele hiç gidilmez")
  func skipsModelWhenLearnerAlreadyExplained() {
    var coordinator = makeCoordinator(turnLimit: 3)

    let turn = coordinator.beginTurn(
      explanation: "puan değişkeni koşul doğru olunca değişir.",
      isModelAvailable: true
    )

    #expect(turn?.localResponse.kind == .feedback)
    #expect(turn?.promptForModel == nil)
  }

  @Test("Tur bütçesi dolduğunda model isteği üretilmez")
  func stopsAtTurnBudget() {
    var coordinator = makeCoordinator(turnLimit: 1)
    _ = coordinator.beginTurn(explanation: "İlk deneme", isModelAvailable: true)

    let turn = coordinator.beginTurn(explanation: "İkinci deneme", isModelAvailable: true)

    #expect(turn?.localResponse.kind == .limitReached)
    #expect(turn?.promptForModel == nil)
    #expect(coordinator.remainingTurns == 0)
  }

  @Test("Model istemi ders bağlamını taşır ama doğru cevabı taşımaz")
  func buildsPromptWithoutAnswer() {
    var coordinator = makeCoordinator(turnLimit: 3)

    let prompt = coordinator.beginTurn(
      explanation: "Satırları izliyorum",
      isModelAvailable: true
    )?.promptForModel

    #expect(prompt?.contains(XRayLesson.introduction.objective) == true)
    #expect(prompt?.contains("Satırları izliyorum") == true)
    #expect(prompt?.contains("Doğru cevap:") == false)
  }

  @Test("Modelin sızdırdığı cevap kullanıcıya ulaşmadan maskelenir")
  func sanitizesGeneratedAnswer() {
    var coordinator = makeCoordinator(turnLimit: 3)
    let turn = coordinator.beginTurn(explanation: "Emin değilim", isModelAvailable: true)!

    let response = coordinator.response(
      forGenerated: "Sonuç 12 olacak, gördün mü?",
      in: turn
    )

    #expect(!response.text.contains("12"))
    #expect(response.kind == .question)
  }

  private func makeCoordinator(turnLimit: Int) -> MentorCoordinator {
    MentorCoordinator(
      session: SocraticMentorSession(
        lesson: .introduction,
        requiredConcepts: ["puan", "koşul", "değişir"],
        turnLimit: turnLimit
      ),
      correctAnswer: XRayLesson.introduction.correctAnswer
    )
  }
}
