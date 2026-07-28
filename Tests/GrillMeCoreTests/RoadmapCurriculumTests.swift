import Testing

@testable import GrillMeCore

@Suite("30 günlük çekirdek yol")
struct RoadmapCurriculumTests {
  @Test("Otuz dersi benzersiz kimlik ve kesintisiz sırayla sunar")
  func containsThirtyUniqueOrderedLessons() {
    let lessons = LessonCatalog.standard.lessons

    #expect(lessons.count == 30)
    #expect(Set(lessons.map(\.id)).count == 30)
    #expect(lessons.map(\.order) == Array(1...30))
  }

  @Test("Yayınlanan bütün dersler veri sözleşmesini karşılar")
  func validatesEveryPublishedLesson() {
    let validator = LessonValidator()

    #expect(
      LessonCatalog.standard.lessons.allSatisfy {
        validator.issues(in: $0).isEmpty
      }
    )
  }

  @Test("Roadmapteki bütün içerik bölümlerini kapsar")
  func coversEveryCurriculumSection() {
    let sections = Set(LessonCatalog.standard.lessons.map(\.section))

    #expect(
      sections == [
        .fundamentals,
        .functions,
        .collections,
        .objects,
        .debugging,
        .asynchronous,
        .appArchitecture,
        .assessment,
      ]
    )
  }

  @Test("Fonksiyon ve veri akışı dersleri çağrı lensiyle izlenebilir")
  func functionLessonsExposeCallLens() {
    let lessons = lessonsByID

    for id in ["function-call", "parameters-return", "scope", "pure-side-effects"] {
      #expect(lessons[id]?.availableLenses.contains(.call) == true)
    }
    #expect(lessons["map-intro"]?.title == "Her elemanı dönüştür")
    #expect(lessons["filter-intro"]?.title == "Yalnızca uyanları seç")
    #expect(
      lessons["function-call"]?.practiceChallenges.contains {
        $0.kind == .naming
      } == true
    )
  }

  @Test("Nesne dersleri mimari lensiyle sahiplik ve ilişki gösterir")
  func objectLessonsExposeArchitectureLens() {
    let lessons = lessonsByID
    let objectIDs = [
      "class-instance",
      "property-method",
      "initializer",
      "value-reference",
      "composition",
      "inheritance",
      "architecture-challenge",
    ]

    #expect(
      objectIDs.allSatisfy {
        lessons[$0]?.availableLenses.contains(.architecture) == true
      }
    )
  }

  @Test("Hata avcılığı dersleri bütün temel hata türlerini kapsar")
  func debuggingLessonsCoverErrorKinds() {
    let kinds = Set(
      LessonCatalog.standard.lessons
        .compactMap(\.debugChallenge)
        .map(\.kind)
    )

    #expect(kinds == [.syntax, .runtime, .logic, .edgeCase, .optional, .stackTrace])
  }

  @Test("Çıkış değerlendirmesi yeni ve yeterince uzun kodla tüm becerileri ölçer")
  func capstoneCoversExitSkills() {
    let capstone = lessonsByID["capstone"]
    let taskKinds = Set(capstone?.assessmentTasks.map(\.kind) ?? [])

    #expect((20...30).contains(capstone?.code.count ?? 0))
    #expect(
      taskKinds == [
        .outputPrediction,
        .valueTrace,
        .callOrder,
        .errorLocation,
        .freeExplanation,
      ]
    )
  }

  private var lessonsByID: [String: XRayLesson] {
    Dictionary(
      uniqueKeysWithValues: LessonCatalog.standard.lessons.map { ($0.id, $0) }
    )
  }
}
