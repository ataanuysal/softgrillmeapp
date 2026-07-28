import Testing

@testable import GrillMeCore

@Suite("Dil köprüsü")
struct LanguageBridgeTests {
  @Test("Aynı değişken örneğini Swift, Python, JavaScript ve Java ile sunar")
  func providesFourLanguageVariants() throws {
    let lesson = XRayLesson.introduction
    let java = try #require(CodeLanguage(rawValue: "java"))

    #expect(lesson.availableLanguages.map(\.rawValue) == ["swift", "python", "javascript", "java"])
    #expect(lesson.code(for: .swift).first?.text == "var puan = 10")
    #expect(lesson.code(for: .python).first?.text == "puan = 10")
    #expect(lesson.code(for: .javascript).first?.text == "let puan = 10;")
    #expect(lesson.code(for: java).first?.text == "int puan = 10;")
    #expect(lesson.availableLenses.contains(.language))
  }

  @Test("Syntax farklarını değişmeyen çalışma mantığından ayırır")
  func explainsSyntaxVersusLogic() {
    let comparison = XRayLesson.introduction.languageComparison

    #expect(comparison?.invariant.contains("10") == true)
    #expect(comparison?.syntaxDifferences.count == 4)
  }
}
