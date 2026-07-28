import Foundation

public struct LessonProgress: Codable, Equatable, Sendable {
  public private(set) var completedLessonIDs: Set<String>

  public init(completedLessonIDs: Set<String> = []) {
    self.completedLessonIDs = completedLessonIDs
  }

  public mutating func complete(_ lessonID: String) {
    completedLessonIDs.insert(lessonID)
  }
}

public struct FileProgressStore: Sendable {
  private let fileURL: URL

  public init(fileURL: URL) {
    self.fileURL = fileURL
  }

  public func load() -> LessonProgress {
    guard
      let data = try? Data(contentsOf: fileURL),
      let progress = try? JSONDecoder().decode(LessonProgress.self, from: data)
    else {
      return LessonProgress()
    }

    return progress
  }

  public func save(_ progress: LessonProgress) throws {
    try FileManager.default.createDirectory(
      at: fileURL.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )
    let data = try JSONEncoder().encode(progress)
    try data.write(to: fileURL, options: .atomic)
  }
}
