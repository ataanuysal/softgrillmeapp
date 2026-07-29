import Testing

@testable import GrillMeCore

@Suite("Türkçe kavram eşleştirme")
struct ConceptMatcherTests {
  @Test("Çekim eki almış kelimede kavramı tanır")
  func matchesInflectedForms() {
    #expect(ConceptMatcher.matches("girdi", in: "Girdiyi takip ederim."))
    #expect(ConceptMatcher.matches("risk", in: "İki riskleri ayrı yazdım."))
    #expect(ConceptMatcher.matches("test", in: "Ayrı testlerle doğrularım."))
    #expect(ConceptMatcher.matches("toplam", in: "Fonksiyon toplamı sınıflandırır."))
  }

  @Test("Olumsuzlayan ek kavramı kanıtlamaz")
  func rejectsNegatingSuffix() {
    #expect(!ConceptMatcher.matches("risk", in: "Risksiz bir akış var."))
    #expect(!ConceptMatcher.matches("kanıt", in: "Kanıtsız tahmin yürüttüm."))
  }

  @Test("Aynı cevapta olumsuzlanan ve olumlanan kullanım birlikte geçerse eşleşir")
  func matchesLaterValidOccurrence() {
    #expect(ConceptMatcher.matches("risk", in: "Risksiz sandım ama risk stokta."))
  }

  @Test("Kavram kelime ve sayı sınırlarına saygı gösterir")
  func respectsWordAndNumberBoundaries() {
    #expect(!ConceptMatcher.matches("6", in: "Toplam 16 oldu."))
    #expect(!ConceptMatcher.matches("6", in: "Süre 60 saniye."))
    #expect(ConceptMatcher.matches("6", in: "Toplam 6 olur."))
    #expect(!ConceptMatcher.matches("kabul kriteri", in: "Açık bir kriter yazılmadı."))
    #expect(ConceptMatcher.matches("kabul kriteri", in: "Sonucu kabul kriteriyle doğrularım."))
  }

  @Test("Mentor kavram sayımı da aynı sınırları kullanır")
  func mentorUsesSameBoundaries() {
    var mentor = SocraticMentorSession(
      lesson: .introduction,
      requiredConcepts: ["risk"],
      turnLimit: 3
    )

    let response = mentor.reply(to: "Akış risksiz görünüyor.")

    #expect(response.kind == .question)
    #expect(response.matchedConcepts.isEmpty)
  }
}
