import Testing

@testable import GrillMeCore

@Suite("Koşullar dersi")
struct ConditionsLessonTests {
  @Test("Yanlış koşuldan else koluna geçişi doğru sırada gösterir")
  func followsElseBranch() {
    let lesson = XRayLesson.conditions
    let sourceLineNumbers = Set(lesson.code.map(\.number))

    #expect(lesson.id == "conditions")
    #expect(lesson.correctAnswer == "Ceket al")
    #expect(lesson.trace.allSatisfy { sourceLineNumbers.contains($0.lineNumber) })
    #expect(lesson.trace.last?.output == lesson.correctAnswer)
  }
}
