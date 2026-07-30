import Foundation

public enum LessonStatus: Equatable, Sendable {
  case completed
  case available
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

extension XRayLesson {
  /// Dersin dosya gezgininde görünen adı: `01_degerin_izini_sur`.
  ///
  /// Arayüz dersleri bir editör dosyası gibi listeler; ad Türkçe başlıktan
  /// türetilir ve aksanlar sadeleşir çünkü dosya adları öyle yazılır.
  public var fileStem: String {
    // Aksan katlama Türkçede "ı" ve "İ" harflerini olduğu gibi bırakır; dosya
    // adı ASCII kalsın diye bunlar açıkça karşılanır.
    let transliterated = title.lowercased(with: Locale(identifier: "tr_TR"))
      .replacingOccurrences(of: "ı", with: "i")
      .replacingOccurrences(of: "ğ", with: "g")
      .replacingOccurrences(of: "ş", with: "s")
      .replacingOccurrences(of: "ç", with: "c")
      .replacingOccurrences(of: "ö", with: "o")
      .replacingOccurrences(of: "ü", with: "u")
    let slug = transliterated.map { character -> Character in
      character.isASCII && (character.isLetter || character.isNumber) ? character : "_"
    }
    let collapsed = String(slug)
      .split(separator: "_", omittingEmptySubsequences: true)
      .joined(separator: "_")
    return String(format: "%02d_%@", order, collapsed)
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
    lessons.map { lesson in
      LessonCatalogItem(
        lesson: lesson,
        status: completedLessonIDs.contains(lesson.id) ? .completed : .available
      )
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
    ConceptMatcher.normalized(text)
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
