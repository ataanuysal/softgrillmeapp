import Foundation
import Testing

@testable import GrillMeCore

@Suite("İlerleme deposu")
struct FileProgressStoreTests {
  @Test("Aynı dersi yalnızca bir kez tamamlanmış olarak tutar")
  func completingLessonIsIdempotent() {
    var progress = LessonProgress()

    progress.complete("variables")
    progress.complete("variables")

    #expect(progress.completedLessonIDs == ["variables"])
  }

  @Test("Kaydedilen tamamlanmış dersleri yeniden yükler")
  func savesAndLoadsProgress() throws {
    let fileURL = temporaryFileURL()
    let store = FileProgressStore(fileURL: fileURL)
    let progress = LessonProgress(completedLessonIDs: ["variables", "conditions"])

    try store.save(progress)

    #expect(store.load() == progress)
  }

  @Test("Henüz dosya yoksa boş ilerlemeyle başlar")
  func missingFileReturnsEmptyProgress() {
    let store = FileProgressStore(fileURL: temporaryFileURL())

    #expect(store.load() == LessonProgress())
  }

  private func temporaryFileURL() -> URL {
    FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
      .appendingPathComponent("progress.json")
  }
}
