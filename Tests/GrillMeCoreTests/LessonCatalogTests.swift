import Testing

@testable import GrillMeCore

@Suite("Ders kataloğu")
struct LessonCatalogTests {
  @Test("Dersleri sıra numarasına göre düzenler")
  func sortsLessonsByOrder() {
    let catalog = LessonCatalog(lessons: [.loops, .conditions, .introduction])

    #expect(catalog.lessons.map(\.id) == ["variables", "conditions", "loops"])
  }

  @Test("İlerleme yokken yalnızca ilk dersi açar")
  func unlocksOnlyFirstLessonWithoutProgress() {
    let items = LessonCatalog.standard.items(completedLessonIDs: [])

    #expect(
      Array(items.prefix(7).map(\.status)) == [
        .available, .locked, .locked, .locked, .locked, .locked, .locked,
      ]
    )
    #expect(items.dropFirst(7).allSatisfy { $0.status == .locked })
  }

  @Test("İlk ders tamamlandığında ikinci dersi açar")
  func completingFirstLessonUnlocksSecond() {
    let items = LessonCatalog.standard.items(completedLessonIDs: ["variables"])

    #expect(
      Array(items.prefix(7).map(\.status)) == [
        .completed, .available, .locked, .locked, .locked, .locked, .locked,
      ]
    )
    #expect(items.dropFirst(7).allSatisfy { $0.status == .locked })
  }

  @Test("İlk iki ders tamamlandığında döngüler dersini açar")
  func completingFirstTwoLessonsUnlocksLoops() {
    let items = LessonCatalog.standard.items(
      completedLessonIDs: ["variables", "conditions"]
    )

    #expect(
      Array(items.prefix(7).map(\.status)) == [
        .completed, .completed, .available, .locked, .locked, .locked, .locked,
      ]
    )
    #expect(items.dropFirst(7).allSatisfy { $0.status == .locked })
  }

  @Test("İlk üç ders tamamlandığında birleşik koşullar dersini açar")
  func completingFirstThreeLessonsUnlocksCompoundConditions() {
    let items = LessonCatalog.standard.items(
      completedLessonIDs: ["variables", "conditions", "loops"]
    )

    #expect(
      Array(items.prefix(7).map(\.status)) == [
        .completed, .completed, .completed, .available, .locked, .locked, .locked,
      ]
    )
    #expect(items.dropFirst(7).allSatisfy { $0.status == .locked })
  }

  @Test("İçindekiler bütün derslere ilerlemeden bağımsız erişim verir")
  func contentsMakesEveryLessonAvailable() {
    let sections = LessonCatalog.standard.contents(
      query: "",
      completedLessonIDs: []
    )
    let items = sections.flatMap(\.items)

    #expect(items.count == LessonCatalog.standard.lessons.count)
    #expect(items.allSatisfy { $0.status == .available })
  }

  @Test("İçindekiler dersleri müfredat bölümlerinde sırayla gruplar")
  func contentsGroupsLessonsByCurriculumSection() {
    let sections = LessonCatalog.standard.contents(
      query: "",
      completedLessonIDs: []
    )

    #expect(sections.map(\.section) == CurriculumSection.allCases)
    #expect(
      sections.allSatisfy { group in
        group.items.allSatisfy { $0.lesson.section == group.section }
      })
  }

  @Test("İçindekiler araması Türkçe karakterlerden bağımsız çalışır")
  func contentsSearchIgnoresTurkishDiacritics() {
    let sections = LessonCatalog.standard.contents(
      query: "bos liste",
      completedLessonIDs: []
    )

    #expect(sections.flatMap(\.items).map(\.lesson.id) == ["edge-cases"])
  }

  @Test("Standart derslerin aktarım görevleri geçerli cevap içerir")
  func standardLessonsHaveValidTransferChallenges() {
    let lessons = LessonCatalog.standard.lessons

    #expect(
      lessons.allSatisfy {
        guard let challenge = $0.transferChallenge else { return false }
        return challenge.choices.contains(challenge.correctAnswer)
      }
    )
  }
}
