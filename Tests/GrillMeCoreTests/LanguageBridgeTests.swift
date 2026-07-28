import Testing

@testable import GrillMeCore

@Suite("Dil köprüsü")
struct LanguageBridgeTests {
  @Test("Aynı değişken örneğini Swift, Python ve JavaScript ile sunar")
  func providesThreeLanguageVariants() {
    let lesson = XRayLesson.introduction

    #expect(lesson.availableLanguages == [.swift, .python, .javascript])
    #expect(lesson.code(for: .swift).first?.text == "var puan = 10")
    #expect(lesson.code(for: .python).first?.text == "puan = 10")
    #expect(lesson.code(for: .javascript).first?.text == "let puan = 10;")
    #expect(lesson.availableLenses.contains(.language))
  }

  @Test("Syntax farklarını değişmeyen çalışma mantığından ayırır")
  func explainsSyntaxVersusLogic() {
    let comparison = XRayLesson.introduction.languageComparison

    #expect(comparison?.invariant.contains("10") == true)
    #expect(comparison?.syntaxDifferences.count == 3)
  }
}
