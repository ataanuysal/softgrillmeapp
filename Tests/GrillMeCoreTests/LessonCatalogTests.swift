import Testing

@testable import GrillMeCore

@Suite("Ders kataloğu")
struct LessonCatalogTests {
  @Test("Dersleri sıra numarasına göre düzenler")
  func sortsLessonsByOrder() {
    let catalog = LessonCatalog(lessons: [.loops, .conditions, .introduction])

    #expect(catalog.lessons.map(\.id) == ["variables", "conditions", "loops"])
  }

  @Test("Yol Haritası bütün dersleri ilerlemeden bağımsız açar")
  func roadmapMakesEveryLessonAvailable() {
    let items = LessonCatalog.standard.items(completedLessonIDs: [])

    #expect(items.count == LessonCatalog.standard.lessons.count)
    #expect(items.allSatisfy { $0.status == .available })
  }

  @Test("Tamamlanan ders işaretlenirken diğer dersler açık kalır")
  func completionDoesNotLockOtherLessons() {
    let items = LessonCatalog.standard.items(completedLessonIDs: ["variables"])

    #expect(items.first?.status == .completed)
    #expect(items.dropFirst().allSatisfy { $0.status == .available })
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
