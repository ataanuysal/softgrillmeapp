public enum LessonStatus: Equatable, Sendable {
  case completed
  case available
  case locked
}

public struct LessonCatalogItem: Equatable, Sendable {
  public let lesson: XRayLesson
  public let status: LessonStatus

  public init(lesson: XRayLesson, status: LessonStatus) {
    self.lesson = lesson
    self.status = status
  }
}

public struct LessonCatalog: Equatable, Sendable {
  public let lessons: [XRayLesson]

  public init(lessons: [XRayLesson]) {
    self.lessons = lessons.sorted {
      ($0.order, $0.id) < ($1.order, $1.id)
    }
  }

  public func items(completedLessonIDs: Set<String>) -> [LessonCatalogItem] {
    lessons.enumerated().map { index, lesson in
      let status: LessonStatus

      if completedLessonIDs.contains(lesson.id) {
        status = .completed
      } else if lessons[..<index].allSatisfy({ completedLessonIDs.contains($0.id) }) {
        status = .available
      } else {
        status = .locked
      }

      return LessonCatalogItem(lesson: lesson, status: status)
    }
  }

  public static let standard = LessonCatalog(
    lessons: [.introduction, .conditions, .loops]
  )
}
