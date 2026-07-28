import Testing

@testable import GrillMeCore

@Suite("İlk hafta müfredatı")
struct WeekOneCurriculumTests {
  @Test("İlk yedi dersi öğrenme sırasına göre sunar")
  func containsSevenOrderedLessons() {
    let week = Array(LessonCatalog.standard.lessons.prefix(7))

    #expect(
      week.map(\.id) == [
        "variables",
        "conditions",
        "loops",
        "compound-conditions",
        "function-call",
        "parameters-return",
        "week-one-challenge",
      ]
    )
    #expect(week.map(\.order) == Array(1...7))
  }

  @Test("İlk hafta derslerinin içerik sözleşmesi geçerlidir")
  func validatesWeekOneContent() {
    let week = Array(LessonCatalog.standard.lessons.prefix(7))
    let validator = LessonValidator()

    #expect(week.allSatisfy { validator.issues(in: $0).isEmpty })
    #expect(week.allSatisfy { (5...10).contains($0.estimatedMinutes) })
  }
}
