import Testing

@testable import GrillMeCore

@Suite("Başlangıç dersi")
struct IntroLessonTests {
  @Test("Tahmin seçenekleri ve yürütme izi kaynak kodla tutarlıdır")
  func lessonContentIsInternallyConsistent() {
    let lesson = XRayLesson.introduction
    let sourceLineNumbers = Set(lesson.code.map(\.number))

    #expect(lesson.choices.contains(lesson.correctAnswer))
    #expect(lesson.trace.allSatisfy { sourceLineNumbers.contains($0.lineNumber) })
    #expect(lesson.trace.last?.output == lesson.correctAnswer)
  }
}
