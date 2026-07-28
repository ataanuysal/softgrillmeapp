import Testing

@testable import GrillMeCore

@Suite("Sokratik mentor")
struct SocraticMentorTests {
  @Test("Doğrudan cevap isteğinde sonucu açıklamadan yönlendirici soru sorar")
  func refusesToRevealAnswerImmediately() {
    var mentor = SocraticMentorSession(
      lesson: .introduction,
      requiredConcepts: ["puan", "koşul", "değişir"],
      turnLimit: 3
    )

    let response = mentor.reply(to: "Cevabı söyle.")

    #expect(response.kind == .question)
    #expect(!response.text.contains(XRayLesson.introduction.correctAnswer))
    #expect(response.matchedConcepts.isEmpty)
  }

  @Test("Kullanıcının açıklamasında gördüğü kavramlara kişisel geri bildirim verir")
  func respondsToMatchedConcepts() {
    var mentor = SocraticMentorSession(
      lesson: .introduction,
      requiredConcepts: ["puan", "koşul", "değişir"],
      turnLimit: 3
    )

    let response = mentor.reply(
      to: "puan değişkeni koşul doğru olunca değişir."
    )

    #expect(response.kind == .feedback)
    #expect(response.matchedConcepts == ["puan", "koşul", "değişir"])
    #expect(response.text.contains("üç temel kavram"))
  }

  @Test("Tur bütçesi dolduğunda yeni model isteği üretmez")
  func enforcesTurnBudget() {
    var mentor = SocraticMentorSession(
      lesson: .introduction,
      requiredConcepts: ["puan"],
      turnLimit: 2
    )

    _ = mentor.reply(to: "Bilmiyorum")
    _ = mentor.reply(to: "Satırları izliyorum")
    let response = mentor.reply(to: "Bir ipucu daha")

    #expect(response.kind == .limitReached)
    #expect(mentor.remainingTurns == 0)
  }

  @Test("Cihaz içi model istemi ders bağlamını taşır ama cevabı taşımaz")
  func buildsSafeOnDevicePrompt() {
    let prompt = MentorPromptBuilder.build(
      lesson: .introduction,
      userExplanation: "Puan koşuldan sonra değişiyor.",
      matchedConcepts: ["puan", "koşul"]
    )

    #expect(prompt.contains(XRayLesson.introduction.objective))
    #expect(prompt.contains("var puan = 10"))
    #expect(prompt.contains("Puan koşuldan sonra değişiyor."))
    #expect(prompt.contains("Doğrudan cevabı verme"))
    #expect(!prompt.contains("Doğru cevap:"))
  }

  @Test("Model cevabı doğru sonucu açıklarsa güvenlik filtresi sonucu gizler")
  func removesLeakedAnswer() {
    let filtered = MentorSafetyFilter(correctAnswer: "12")
      .sanitize("Doğru cevap 12. Çünkü değer iki arttı.")

    #expect(!filtered.contains("12"))
    #expect(filtered.contains("sonucu kendin hesapla"))
  }
}
