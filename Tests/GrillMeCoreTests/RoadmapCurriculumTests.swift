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

  @Test("Devam dersleri iki adımlık özet yerine çok adımlı yürütme izi sunar")
  func continuationLessonsProvideMeaningfulExecutionTraces() {
    let continuation = LessonCatalog.standard.lessons.filter { $0.order >= 8 }

    #expect(continuation.allSatisfy { $0.trace.count >= 3 })
    #expect(
      continuation.allSatisfy { lesson in
        Set(lesson.trace.map(\.explanation)).count == lesson.trace.count
      }
    )
  }

  @Test("Derlenmeyen veya çöken örnekler quiz cevabını program çıktısı gibi göstermez")
  func failingProgramsDoNotFabricateOutput() {
    let lessons = lessonsByID
    let failingLessonIDs = [
      "error-types",
      "edge-cases",
      "optionals",
      "stack-traces",
      "debug-hypothesis",
    ]

    for id in failingLessonIDs {
      #expect(lessons[id]?.trace.compactMap(\.output).isEmpty == true)
      #expect(lessons[id].map { LessonValidator().issues(in: $0).isEmpty } == true)
    }
  }

  @Test("Hata derslerinin izi tetikleyici çağrıdan gerçek hata satırına gider")
  func failingProgramsEndTraceAtFailure() {
    let catalog = LessonCatalog.standard
    let runtimeFailureIDs = ["edge-cases", "optionals", "stack-traces", "debug-hypothesis"]

    for id in runtimeFailureIDs {
      let lesson = catalog.lessons.first { $0.id == id }!
      let failureLine = lesson.debugChallenge!.correctLineNumber

      #expect(lesson.trace.last?.lineNumber == failureLine, Comment(rawValue: id))
      #expect(
        lesson.trace.dropLast().contains { $0.lineNumber == lesson.code.last?.number },
        Comment(rawValue: id)
      )
    }

    let syntaxLesson = catalog.lessons.first { $0.id == "error-types" }!
    #expect(
      syntaxLesson.trace.allSatisfy {
        $0.lineNumber == syntaxLesson.debugChallenge?.correctLineNumber
      }
    )
  }

  @Test("Asenkron sıra açık bekleme noktasıyla deterministik hale getirilir")
  func asynchronousLessonUsesExplicitAwait() throws {
    let lesson = try #require(lessonsByID["async-order"])
    let source = lesson.code.map(\.text).joined(separator: "\n")
    let transfer = try #require(lesson.transferChallenge).code.map(\.text).joined(separator: "\n")

    #expect(source.contains("await task.value"))
    #expect(transfer.contains("await task.value"))
    #expect(!source.contains("Task { print"))
    #expect(!transfer.contains("Task { print"))
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

  @Test("Çıkış görevleri puanlanabilir rubrikler taşır")
  func capstoneTasksHaveScoringRubrics() throws {
    let capstone = try #require(lessonsByID["capstone"])
    let analysisCapstone = try #require(lessonsByID["technical-analysis-capstone"])

    for task in capstone.assessmentTasks + analysisCapstone.assessmentTasks {
      #expect(!task.rubric.requiredConcepts.isEmpty)
      #expect(!task.rubric.modelAnswer.isEmpty)
    }
  }

  @Test("Her rubrik kendi örnek cevabını tam puanla değerlendirir")
  func modelAnswersSatisfyTheirOwnRubric() {
    for lesson in LessonCatalog.standard.lessons {
      for task in lesson.assessmentTasks {
        let evaluation = task.rubric.evaluate(task.rubric.modelAnswer)

        #expect(
          evaluation.score == 1,
          Comment(rawValue: "\(lesson.id)/\(task.kind): eksik \(evaluation.missingConcepts)")
        )
      }
    }
  }

  private var lessonsByID: [String: XRayLesson] {
    Dictionary(
      uniqueKeysWithValues: LessonCatalog.standard.lessons.map { ($0.id, $0) }
    )
  }
}
