import Foundation
import Testing

@testable import GrillMeCore

@Suite("Kavram dersleri kütüphanesi")
struct ReadingCurriculumTests {
  // MARK: - Gerçek içerik

  @Test("Yayınlanan Markdown içeriği uygulama paketinden yüklenir")
  func loadsBundledContent() throws {
    let course = try ReadingLibrary.loadCourse()

    #expect(course.id == "software-engineering-fundamentals")
    #expect(!course.modules.isEmpty)
    #expect(course.publishedLessons.count == 8)
  }

  @Test("Front matter alanları derse doğru aktarılır")
  func mapsFrontMatterOntoLesson() throws {
    let course = try ReadingLibrary.loadCourse()
    let lesson = try #require(course.lesson(id: "computational-thinking-01"))

    #expect(lesson.module == "computational-thinking")
    #expect(lesson.moduleOrder == 1)
    #expect(lesson.lessonOrder == 1)
    #expect(lesson.section == .fundamentals)
    #expect(lesson.title == "Problemi parçalara ayırmak")
    #expect(lesson.difficulty == .beginner)
    #expect(lesson.estimatedMinutes == 20)
    #expect(lesson.prerequisites == ["orientation-03"])
    #expect(lesson.objectives.count == 3)
    #expect(lesson.status == .published)
    #expect(!lesson.summary.isEmpty)
  }

  @Test("Modüller ve dersler yayın sırasını korur")
  func ordersModulesAndLessons() throws {
    let course = try ReadingLibrary.loadCourse()

    #expect(course.modules.map(\.order) == Array(0...14))
    #expect(course.modules.first?.id == "orientation")

    let openModuleIDs = course.modules.filter(\.isOpen).map(\.id)
    #expect(openModuleIDs == ["orientation", "computational-thinking"])

    let computational = try #require(course.modules.first { $0.id == "computational-thinking" })
    #expect(computational.publishedLessons.map(\.lessonOrder) == [1, 2, 3, 4, 5])

    #expect(
      course.publishedLessons.map(\.id) == [
        "orientation-01", "orientation-02", "orientation-03",
        "computational-thinking-01", "computational-thinking-02",
        "computational-thinking-03", "computational-thinking-04",
        "computational-thinking-05",
      ]
    )
  }

  @Test("Ders gövdesi başlık, liste, tablo ve kod bloğu taşır")
  func exposesRenderableBlocks() throws {
    let course = try ReadingLibrary.loadCourse()
    let lesson = try #require(course.lesson(id: "computational-thinking-04"))

    func contains(_ predicate: (MarkdownBlock) -> Bool) -> Bool {
      lesson.blocks.contains(where: predicate)
    }

    #expect(contains { if case .heading = $0 { return true } else { return false } })
    #expect(contains { if case .bulletList = $0 { return true } else { return false } })
    #expect(contains { if case .table = $0 { return true } else { return false } })
    #expect(contains { if case .codeBlock = $0 { return true } else { return false } })
    #expect(contains { if case .callout = $0 { return true } else { return false } })
  }

  @Test("Alıştırmalar anlatımdan ayrı bir adım olarak sunulur")
  func separatesExercisesFromReading() throws {
    let course = try ReadingLibrary.loadCourse()

    for lesson in course.publishedLessons {
      #expect(!lesson.exerciseBlocks.isEmpty, Comment(rawValue: "\(lesson.id) alıştırma taşımıyor"))
      #expect(lesson.readingBlocks.count < lesson.blocks.count)
      #expect(
        !lesson.readingBlocks.contains { block in
          if case .heading(let level, let text) = block {
            return level == 3 && text == "Kavrama"
          }
          return false
        }
      )
    }
  }

  @Test("Önceki ve sonraki ders gezinmesi kurs boyunca zincir kurar")
  func navigatesBetweenLessons() throws {
    let course = try ReadingLibrary.loadCourse()

    #expect(course.previousLesson(before: "orientation-01") == nil)
    #expect(course.nextLesson(after: "orientation-01")?.id == "orientation-02")
    // Modül sınırını da geçer.
    #expect(course.nextLesson(after: "orientation-03")?.id == "computational-thinking-01")
    #expect(course.previousLesson(before: "computational-thinking-01")?.id == "orientation-03")
    #expect(course.nextLesson(after: "computational-thinking-05") == nil)
  }

  @Test("Yayında olmayan modüllerin dersi kullanıcıya gösterilmez")
  func hidesUnpublishedContent() throws {
    let course = try ReadingLibrary.loadCourse()

    #expect(course.publishedLessons.allSatisfy { $0.status == .published })
    #expect(course.visibleModules.allSatisfy { $0.status != .draft })

    let comingSoon = course.modules.filter { $0.status == .comingSoon }
    #expect(comingSoon.count == 13)
    #expect(comingSoon.allSatisfy { !$0.isOpen })
    #expect(comingSoon.allSatisfy { $0.publishedLessons.isEmpty })
  }

  @Test("Her ön koşul yayınlanmış bir derse işaret eder")
  func resolvesEveryPrerequisite() throws {
    let course = try ReadingLibrary.loadCourse()
    let known = Set(course.publishedLessons.map(\.id))

    for lesson in course.publishedLessons {
      for prerequisite in lesson.prerequisites {
        #expect(
          known.contains(prerequisite),
          Comment(rawValue: "\(lesson.id) → \(prerequisite) çözümlenemedi")
        )
      }
    }
  }

  @Test("Kavram dersleri kod okuma derslerine çözümlenen bağlar kurar")
  func linksToRealCodeLessons() throws {
    let course = try ReadingLibrary.loadCourse()
    let codeLessonIDs = Set(LessonCatalog.standard.lessons.map(\.id))

    let linked = course.publishedLessons.filter { !$0.relatedCodeLessonIDs.isEmpty }
    #expect(linked.count >= 5, "Kavram dersleri kod okuma katmanına bağlanmalı")

    for lesson in course.publishedLessons {
      for codeLessonID in lesson.relatedCodeLessonIDs {
        #expect(
          codeLessonIDs.contains(codeLessonID),
          Comment(rawValue: "\(lesson.id) → \(codeLessonID) çözümlenemedi")
        )
      }
    }
  }

  @Test("Var olmayan kod okuma dersine bağ yükleme sırasında hata verir")
  func rejectsUnknownCodeLessonLinks() throws {
    let root = try makeFixture([
      "00-first": [
        "README.md": moduleFrontMatter(id: "first", order: 0),
        "01-a.md": lessonFrontMatter(
          id: "first-01",
          module: "first",
          order: 0,
          lesson: 1,
          relatedCodeLessons: ["boyle-bir-kod-dersi-yok"]
        ),
      ]
    ])
    defer { try? FileManager.default.removeItem(at: root) }

    #expect(
      throws: ReadingCurriculumError.unknownCodeLesson(
        lessonID: "first-01",
        codeLessonID: "boyle-bir-kod-dersi-yok"
      )
    ) {
      _ = try ReadingLibrary.loadCourse(from: root)
    }
  }

  // MARK: - Okuma oturumu

  @Test("Ders alıştırmalar görülmeden tamamlanamaz")
  func requiresExercisesBeforeCompletion() throws {
    let course = try ReadingLibrary.loadCourse()
    let lesson = try #require(course.lesson(id: "orientation-01"))
    var session = ReadingSession(lesson: lesson)

    #expect(session.phase == .reading)
    #expect(session.canComplete == false)

    session.complete()
    #expect(session.phase == .reading)

    session.startExercises()
    #expect(session.phase == .exercises)
    #expect(session.canComplete)

    session.complete()
    #expect(session.phase == .complete)
  }

  @Test("Daha önce okunmuş ders tamamlanmış olarak açılır")
  func opensCompletedLessonInFinishedState() throws {
    let course = try ReadingLibrary.loadCourse()
    let lesson = try #require(course.lesson(id: "orientation-01"))

    let session = ReadingSession(lesson: lesson, isAlreadyCompleted: true)

    #expect(session.phase == .complete)
  }

  // MARK: - Doğrulama

  @Test("Yinelenen ders kimliği yükleme sırasında hata verir")
  func rejectsDuplicateLessonIDs() throws {
    let root = try makeFixture([
      "00-first": [
        "README.md": moduleFrontMatter(id: "first", order: 0),
        "01-a.md": lessonFrontMatter(id: "shared-id", module: "first", order: 0, lesson: 1),
      ],
      "01-second": [
        "README.md": moduleFrontMatter(id: "second", order: 1),
        "01-b.md": lessonFrontMatter(id: "shared-id", module: "second", order: 1, lesson: 1),
      ],
    ])
    defer { try? FileManager.default.removeItem(at: root) }

    #expect(throws: ReadingCurriculumError.self) {
      _ = try ReadingLibrary.loadCourse(from: root)
    }
  }

  @Test("Var olmayan ön koşul yükleme sırasında hata verir")
  func rejectsMissingPrerequisites() throws {
    let root = try makeFixture([
      "00-first": [
        "README.md": moduleFrontMatter(id: "first", order: 0),
        "01-a.md": lessonFrontMatter(
          id: "first-01",
          module: "first",
          order: 0,
          lesson: 1,
          prerequisites: ["hic-yok"]
        ),
      ]
    ])
    defer { try? FileManager.default.removeItem(at: root) }

    #expect(
      throws: ReadingCurriculumError.missingPrerequisite(
        lessonID: "first-01",
        prerequisiteID: "hic-yok"
      )
    ) {
      _ = try ReadingLibrary.loadCourse(from: root)
    }
  }

  @Test("Zorunlu alanı eksik ders yükleme sırasında hata verir")
  func rejectsMissingRequiredField() throws {
    let root = try makeFixture([
      "00-first": [
        "README.md": moduleFrontMatter(id: "first", order: 0),
        "01-a.md": """
        ---
        id: first-01
        module: first
        moduleOrder: 0
        section: fundamentals
        title: Başlık
        description: Özet.
        estimatedMinutes: 10
        status: published
        ---

        # Başlık
        """,
      ]
    ])
    defer { try? FileManager.default.removeItem(at: root) }

    #expect(
      throws: ReadingCurriculumError.missingField(path: "00-first/01-a.md", field: "lessonOrder")
    ) {
      _ = try ReadingLibrary.loadCourse(from: root)
    }
  }

  @Test("İçerik bulunamazsa uygulama boş kurs ve uyarıyla devam eder")
  func recoversWhenContentIsMissing() {
    let result = ReadingLibrary.loadRecovering(from: nil)

    #expect(result.course.modules.isEmpty)
    #expect(result.notice != nil)
  }

  @Test("Taslak ders katalogda yer almaz")
  func hidesDraftLessons() throws {
    let root = try makeFixture([
      "00-first": [
        "README.md": moduleFrontMatter(id: "first", order: 0),
        "01-a.md": lessonFrontMatter(id: "first-01", module: "first", order: 0, lesson: 1),
        "02-b.md": lessonFrontMatter(
          id: "first-02",
          module: "first",
          order: 0,
          lesson: 2,
          status: "draft"
        ),
      ]
    ])
    defer { try? FileManager.default.removeItem(at: root) }

    let course = try ReadingLibrary.loadCourse(from: root)

    #expect(course.publishedLessons.map(\.id) == ["first-01"])
    #expect(course.lesson(id: "first-02") == nil)
    #expect(course.nextLesson(after: "first-01") == nil)
  }

  @Test("Şablon klasörü içerik sayılmaz")
  func ignoresNonModuleDirectories() throws {
    let root = try makeFixture([
      "00-first": [
        "README.md": moduleFrontMatter(id: "first", order: 0),
        "01-a.md": lessonFrontMatter(id: "first-01", module: "first", order: 0, lesson: 1),
      ],
      "templates": [
        "lesson-template.md": lessonFrontMatter(
          id: "module-slug-01",
          module: "slug",
          order: 9,
          lesson: 1,
          status: "draft"
        )
      ],
    ])
    defer { try? FileManager.default.removeItem(at: root) }

    let course = try ReadingLibrary.loadCourse(from: root)

    #expect(course.modules.map(\.id) == ["first"])
  }

  // MARK: - Fixture

  private func makeFixture(_ tree: [String: [String: String]]) throws -> URL {
    let root = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("grillme-reading-\(UUID().uuidString)")
    for (directory, files) in tree {
      let directoryURL = root.appendingPathComponent(directory)
      try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
      for (name, contents) in files {
        try contents.write(
          to: directoryURL.appendingPathComponent(name),
          atomically: true,
          encoding: .utf8
        )
      }
    }
    return root
  }

  private func moduleFrontMatter(id: String, order: Int) -> String {
    """
    ---
    course: software-engineering-fundamentals
    module: \(id)
    moduleOrder: \(order)
    title: \(id) modülü
    description: Test modülü.
    status: published
    version: 1
    ---

    # \(id)
    """
  }

  private func lessonFrontMatter(
    id: String,
    module: String,
    order: Int,
    lesson: Int,
    prerequisites: [String] = [],
    relatedCodeLessons: [String] = [],
    status: String = "published"
  ) -> String {
    let prerequisiteBlock =
      prerequisites.isEmpty
      ? "prerequisites: []"
      : (["prerequisites:"] + prerequisites.map { "  - \($0)" }).joined(separator: "\n")
    let relatedBlock =
      relatedCodeLessons.isEmpty
      ? ""
      : (["relatedCodeLessons:"] + relatedCodeLessons.map { "  - \($0)" })
        .joined(separator: "\n") + "\n"

    return """
      ---
      id: \(id)
      course: software-engineering-fundamentals
      module: \(module)
      moduleOrder: \(order)
      lessonOrder: \(lesson)
      section: fundamentals
      title: \(id) dersi
      description: Test dersi.
      difficulty: beginner
      estimatedMinutes: 10
      \(prerequisiteBlock)
      \(relatedBlock)objectives:
        - Test kazanımı
      status: \(status)
      version: 1
      ---

      # \(id)

      Gövde.
      """
  }
}
