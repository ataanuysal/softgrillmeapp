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

    #expect(try store.load() == progress)
  }

  @Test("Henüz dosya yoksa boş ilerlemeyle başlar")
  func missingFileReturnsEmptyProgress() throws {
    let store = FileProgressStore(fileURL: temporaryFileURL())

    #expect(try store.load() == LessonProgress())
  }

  @Test("Bozuk ilerleme dosyasını yedekler ve kullanıcıya kurtarma bilgisi verir")
  func recoversCorruptProgress() throws {
    let fileURL = temporaryFileURL()
    try FileManager.default.createDirectory(
      at: fileURL.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )
    try Data("{not-json}".utf8).write(to: fileURL)
    let store = FileProgressStore(fileURL: fileURL)

    let result = store.loadRecovering()

    #expect(result.progress == LessonProgress())
    #expect(result.notice != nil)
    #expect(result.backupURL != nil)
    #expect(result.backupURL.map { FileManager.default.fileExists(atPath: $0.path) } == true)
    #expect(!FileManager.default.fileExists(atPath: fileURL.path))
  }

  private func temporaryFileURL() -> URL {
    FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
      .appendingPathComponent("progress.json")
  }
}
