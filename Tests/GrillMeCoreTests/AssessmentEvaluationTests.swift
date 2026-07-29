import Testing

@testable import GrillMeCore

@Suite("Açık uçlu değerlendirme")
struct AssessmentEvaluationTests {
  @Test("Rubrik cevapta geçen gerekli kavramlardan puan üretir")
  func scoresRequiredConcepts() {
    let rubric = AssessmentRubric(
      requiredConcepts: ["stok", "hata yolu", "test"],
      modelAnswer: "Stok kontrolünün mutlu ve hata yolları ayrı test edilir."
    )

    let evaluation = rubric.evaluate(
      "Stok yok hata yolu için ayrı bir test yazarım."
    )

    #expect(evaluation.score == 1)
    #expect(evaluation.matchedConcepts == ["stok", "hata yolu", "test"])
    #expect(evaluation.missingConcepts.isEmpty)
  }

  @Test("Eksik kavramlar açıklayıcı geri bildirim üretir")
  func reportsMissingConcepts() {
    let rubric = AssessmentRubric(
      requiredConcepts: ["girdi", "beklenen", "kanıt"],
      modelAnswer: "Girdi ve beklenen sonuç satır kanıtıyla açıklanır."
    )

    let evaluation = rubric.evaluate("Girdiyi takip ederim.")

    #expect(evaluation.score == 1.0 / 3.0)
    #expect(evaluation.missingConcepts == ["beklenen", "kanıt"])
    #expect(evaluation.feedback.contains("beklenen"))
    #expect(evaluation.feedback.contains("kanıt"))
  }

  @Test("Kavramları başka sayı ve kelimelerin içinden yanlış eşleştirmez")
  func matchesWholeConcepts() {
    let rubric = AssessmentRubric(
      requiredConcepts: ["6", "risk", "kabul kriteri"],
      modelAnswer: "Toplam 6; risk kabul kriteriyle doğrulanır."
    )

    let evaluation = rubric.evaluate(
      "Toplam 16. Risksiz akış var ama açık bir kriter yazılmadı."
    )

    #expect(evaluation.score == 0)
    #expect(evaluation.missingConcepts == ["6", "risk", "kabul kriteri"])
  }
}
