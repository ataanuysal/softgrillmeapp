import Testing

@testable import GrillMeCore

@Suite("40 derslik öğrenme yolu")
struct RoadmapCurriculumTests {
  @Test("Kırk dersi benzersiz kimlik ve kesintisiz sırayla sunar")
  func containsFortyUniqueOrderedLessons() {
    let lessons = LessonCatalog.standard.lessons

    #expect(lessons.count == 40)
    #expect(Set(lessons.map(\.id)).count == 40)
    #expect(lessons.map(\.order) == Array(1...40))
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
        .softwareTesting,
        .technicalAnalysis,
      ]
    )
  }

  @Test("Yazılım testi ünitesi temel test stratejilerini kapsar")
  func softwareTestingUnitCoversCoreStrategies() {
    let lessons = LessonCatalog.standard.lessons.filter {
      $0.section == .softwareTesting
    }

    #expect(lessons.map(\.order) == Array(31...35))
    #expect(
      lessons.map(\.id) == [
        "test-anatomy",
        "unit-testing",
        "boundary-testing",
        "test-doubles",
        "integration-regression",
      ]
    )
  }

  @Test("Teknik analiz ünitesi isteği uygulanabilir plana dönüştürür")
  func technicalAnalysisUnitCoversPlanningSkills() {
    let lessons = LessonCatalog.standard.lessons.filter {
      $0.section == .technicalAnalysis
    }

    #expect(lessons.map(\.order) == Array(36...40))
    #expect(
      lessons.map(\.id) == [
        "acceptance-criteria",
        "system-flow",
        "data-contracts",
        "impact-risk",
        "technical-analysis-capstone",
      ]
    )
  }

  @Test("Uzmanlaşma üniteleri her derste yeni durumla ölçülür")
  func specializationLessonsHaveTransferChallenges() {
    let specializationLessons = LessonCatalog.standard.lessons.filter {
      $0.section == .softwareTesting || $0.section == .technicalAnalysis
    }

    #expect(specializationLessons.count == 10)
    #expect(specializationLessons.allSatisfy { $0.transferChallenge != nil })
  }

  @Test("Bağımlılık odaklı uzmanlaşma dersleri mimari lensini açar")
  func specializationDependencyLessonsExposeArchitectureLens() {
    let lessons = lessonsByID

    for id in ["test-doubles", "impact-risk"] {
      #expect(lessons[id]?.availableLenses.contains(.architecture) == true)
    }
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
