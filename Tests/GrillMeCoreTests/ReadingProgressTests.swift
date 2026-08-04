import Foundation
import Testing

@testable import GrillMeCore

@Suite("Kavram dersi ilerlemesi")
struct ReadingProgressTests {
  @Test("Okunan ders tamamlanmış olarak saklanır")
  func storesCompletion() {
    var progress = LessonProgress()
    progress.completeReading("orientation-01")

    #expect(progress.completedReadingLessonIDs == ["orientation-01"])
    #expect(progress.readingCompletions.count == 1)
  }

  @Test("Aynı ders yeniden okunduğunda kayıt çoğalmaz")
  func doesNotDuplicateCompletion() {
    var progress = LessonProgress()
    let first = Date(timeIntervalSince1970: 1_000)
    let second = Date(timeIntervalSince1970: 2_000)

    progress.completeReading("orientation-01", at: first)
    progress.completeReading("orientation-01", at: second)

    #expect(progress.readingCompletions.count == 1)
    #expect(progress.readingCompletions.first?.completedAt == second)
  }

  @Test("İlerleme diske yazılıp geri okunur")
  func persistsAcrossLaunches() throws {
    let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("grillme-reading-progress-\(UUID().uuidString).json")
    defer { try? FileManager.default.removeItem(at: fileURL) }
    let store = FileProgressStore(fileURL: fileURL)

    var progress = LessonProgress()
    progress.completeReading("orientation-01")
    progress.completeReading("computational-thinking-01")
    try store.save(progress)

    let reloaded = try store.load()
    #expect(
      reloaded.completedReadingLessonIDs == ["orientation-01", "computational-thinking-01"]
    )
  }

  @Test("İlerleme dosya yoluna değil ders kimliğine bağlıdır")
  func keysProgressOnStableIdentifier() throws {
    var progress = LessonProgress()
    progress.completeReading("orientation-01")

    // Dersin başlığı ve dosya yolu değişmiş bir sürümü.
    let renamed = ReadingLesson(
      id: "orientation-01",
      course: "software-engineering-fundamentals",
      module: "orientation",
      moduleOrder: 0,
      lessonOrder: 1,
      section: .fundamentals,
      title: "Yazılım gerçekte nedir?",
      summary: "Yeniden adlandırılmış ders.",
      difficulty: .beginner,
      estimatedMinutes: 15,
      prerequisites: [],
      objectives: [],
      status: .published,
      version: 2,
      path: "00-orientation/01-yazilim-nedir.md",
      blocks: []
    )

    #expect(progress.completedReadingLessonIDs.contains(renamed.id))
  }

  @Test("Okuma sayacı kod okuma ölçümüne karışmaz")
  func keepsMeasurementSeparate() {
    var progress = LessonProgress()
    progress.recordAttempt(
      LessonAttempt(
        lessonID: "intro",
        completedAt: Date(),
        durationSeconds: 300,
        quizCorrect: true,
        practiceAccuracy: 1,
        assessmentScore: 0.8
      )
    )
    let summaryBefore = progress.weeklySummary(containing: Date())
    let streakBefore = progress.currentStreak(asOf: Date())

    progress.completeReading("orientation-01")
    progress.completeReading("orientation-02")

    #expect(progress.attempts.count == 1)
    #expect(progress.completedLessonIDs == ["intro"])
    #expect(progress.weeklySummary(containing: Date()) == summaryBefore)
    #expect(progress.currentStreak(asOf: Date()) == streakBefore)
    #expect(progress.firstAttemptAccuracy == 1)
  }

  @Test("Okuma katmanından önceki kayıtlar sorunsuz açılır")
  func decodesLegacyProgressWithoutReadingField() throws {
    let legacy = """
      {
        "completedLessonIDs": ["intro"],
        "attempts": [
          {
            "lessonID": "intro",
            "completedAt": 0,
            "durationSeconds": 120,
            "quizCorrect": true
          }
        ],
        "learningEvents": [],
        "hasFinishedOnboarding": true
      }
      """

    let progress = try JSONDecoder().decode(
      LessonProgress.self,
      from: Data(legacy.utf8)
    )

    #expect(progress.readingCompletions.isEmpty)
    #expect(progress.completedLessonIDs == ["intro"])
    #expect(progress.attempts.count == 1)
  }

  @Test("Kurs, tamamlanan ders sayısını ilerlemeden okur")
  func reportsCompletedCount() throws {
    let course = try ReadingLibrary.loadCourse()
    var progress = LessonProgress()

    #expect(course.completedCount(in: progress) == 0)

    progress.completeReading("orientation-01")
    progress.completeReading("orientation-02")
    // Kursta olmayan bir kimlik sayacı şişirmez.
    progress.completeReading("boyle-bir-ders-yok")

    #expect(course.completedCount(in: progress) == 2)
  }

  @Test("Kod okuma dersleri okuma katmanından etkilenmez")
  func leavesExistingCatalogUntouched() {
    #expect(LessonCatalog.standard.lessons.count == 40)
    #expect(LessonCatalog.standard.lessons.map(\.order) == Array(1...40))
  }
}
