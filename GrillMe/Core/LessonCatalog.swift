import Foundation

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

public struct LessonContentsSection: Equatable, Sendable {
  public let section: CurriculumSection
  public let items: [LessonCatalogItem]

  public init(section: CurriculumSection, items: [LessonCatalogItem]) {
    self.section = section
    self.items = items
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

  public func contents(
    query: String,
    completedLessonIDs: Set<String>
  ) -> [LessonContentsSection] {
    let normalizedQuery = normalizedSearchText(query)
    let matchingLessons = lessons.filter { lesson in
      guard !normalizedQuery.isEmpty else { return true }
      return [
        lesson.topic,
        lesson.title,
        lesson.objective,
        lesson.takeaway,
      ].contains { normalizedSearchText($0).contains(normalizedQuery) }
    }

    return CurriculumSection.allCases.compactMap { section in
      let items =
        matchingLessons
        .filter { $0.section == section }
        .map { lesson in
          LessonCatalogItem(
            lesson: lesson,
            status: completedLessonIDs.contains(lesson.id) ? .completed : .available
          )
        }

      return items.isEmpty ? nil : LessonContentsSection(section: section, items: items)
    }
  }

  public static let standard = LessonCatalog(
    lessons: [
      .introduction,
      .conditions,
      .loops,
      .compoundConditions,
      .functionCall,
      .parametersAndReturn,
      .weekOneChallenge,
    ] + XRayLesson.roadmapContinuation
  )

  private func normalizedSearchText(_ text: String) -> String {
    text
      .folding(
        options: [.caseInsensitive, .diacriticInsensitive],
        locale: Locale(identifier: "tr_TR")
      )
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
