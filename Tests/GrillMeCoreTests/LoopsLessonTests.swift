import Testing

@testable import GrillMeCore

@Suite("Döngüler dersi")
struct LoopsLessonTests {
  @Test("Her turda toplamın yeni değerini doğru sırada gösterir")
  func accumulatesValuesAcrossIterations() {
    let lesson = XRayLesson.loops
    let sourceLineNumbers = Set(lesson.code.map(\.number))

    #expect(lesson.id == "loops")
    #expect(lesson.correctAnswer == "6")
    #expect(lesson.trace.allSatisfy { sourceLineNumbers.contains($0.lineNumber) })
    #expect(lesson.trace.last?.memory["toplam"] == "6")
    #expect(lesson.trace.last?.output == lesson.correctAnswer)
  }
}
