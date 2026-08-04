import Foundation

/// Bir okuma dersinin ya da modülünün yayın durumu.
///
/// Yalnızca `published` olan içerik kullanıcıya gösterilir; taslak ve
/// "yakında" içerik katalogda ders olarak yer almaz.
public enum ReadingStatus: String, Equatable, Sendable, CaseIterable {
  case published
  case draft
  case comingSoon

  public var isVisibleToLearners: Bool { self == .published }
}

public enum ReadingDifficulty: String, Equatable, Sendable, CaseIterable {
  case beginner
  case intermediate
  case advanced

  public var displayName: String {
    switch self {
    case .beginner: return "Başlangıç"
    case .intermediate: return "Orta"
    case .advanced: return "İleri"
    }
  }
}

/// Markdown dosyasından okunan tek bir kavram dersi.
///
/// `id` kalıcıdır: başlık veya dosya yolu değişse bile aynı kalır ve kullanıcı
/// ilerlemesi buna bağlanır. `path` yalnızca teşhis içindir, kimlik değildir.
public struct ReadingLesson: Equatable, Sendable, Identifiable {
  public let id: String
  public let course: String
  public let module: String
  public let moduleOrder: Int
  public let lessonOrder: Int
  public let section: CurriculumSection
  public let title: String
  public let summary: String
  public let difficulty: ReadingDifficulty
  public let estimatedMinutes: Int
  public let prerequisites: [String]
  public let objectives: [String]
  public let status: ReadingStatus
  public let version: Int
  public let path: String
  public let blocks: [MarkdownBlock]

  public init(
    id: String,
    course: String,
    module: String,
    moduleOrder: Int,
    lessonOrder: Int,
    section: CurriculumSection,
    title: String,
    summary: String,
    difficulty: ReadingDifficulty,
    estimatedMinutes: Int,
    prerequisites: [String],
    objectives: [String],
    status: ReadingStatus,
    version: Int,
    path: String,
    blocks: [MarkdownBlock]
  ) {
    self.id = id
    self.course = course
    self.module = module
    self.moduleOrder = moduleOrder
    self.lessonOrder = lessonOrder
    self.section = section
    self.title = title
    self.summary = summary
    self.difficulty = difficulty
    self.estimatedMinutes = estimatedMinutes
    self.prerequisites = prerequisites
    self.objectives = objectives
    self.status = status
    self.version = version
    self.path = path
    self.blocks = blocks
  }

  /// Dersin alıştırma bölümü, ders ekranında ayrı bir adım olarak sunulur.
  ///
  /// Alıştırmalar gövdenin içinde `## Uygulama alıştırmaları` başlığı altında
  /// yaşar; ayrı bir dosya biçimi icat etmemek için oradan çıkarılır.
  public var exerciseBlocks: [MarkdownBlock] {
    guard let range = exerciseSectionRange else { return [] }
    // Başlık bölümün kendisinde tekrar gösterilmez; ekranda zaten "ALIŞTIRMA"
    // başlığı vardır.
    return Array(blocks[blocks.index(after: range.lowerBound)..<range.upperBound])
  }

  /// Alıştırmalar hariç kalan anlatım.
  ///
  /// Çıkarma konuma göre yapılır, değere göre değil: aynı cümle hem anlatımda
  /// hem alıştırmada geçtiğinde değer karşılaştırması anlatımdan da siler.
  public var readingBlocks: [MarkdownBlock] {
    guard let range = exerciseSectionRange else { return blocks }
    return Array(blocks[blocks.startIndex..<range.lowerBound])
      + Array(blocks[range.upperBound...])
  }

  /// `## Uygulama alıştırmaları` başlığından bir sonraki üst düzey başlığa kadar
  /// olan aralık; alt sınır başlığın kendisidir.
  private var exerciseSectionRange: Range<Int>? {
    guard
      let start = blocks.firstIndex(where: { block in
        if case .heading(let level, let text) = block {
          return level == 2 && text == "Uygulama alıştırmaları"
        }
        return false
      })
    else {
      return nil
    }

    let end =
      blocks[blocks.index(after: start)...].firstIndex { block in
        if case .heading(let level, _) = block { return level <= 2 }
        return false
      } ?? blocks.endIndex

    return start..<end
  }
}

/// Bir modül: klasör başına bir `README.md` tarafından tanımlanır.
public struct ReadingModule: Equatable, Sendable, Identifiable {
  public let id: String
  public let course: String
  public let order: Int
  public let title: String
  public let summary: String
  public let status: ReadingStatus
  public let version: Int
  public let overviewBlocks: [MarkdownBlock]
  public let lessons: [ReadingLesson]

  public init(
    id: String,
    course: String,
    order: Int,
    title: String,
    summary: String,
    status: ReadingStatus,
    version: Int,
    overviewBlocks: [MarkdownBlock],
    lessons: [ReadingLesson]
  ) {
    self.id = id
    self.course = course
    self.order = order
    self.title = title
    self.summary = summary
    self.status = status
    self.version = version
    self.overviewBlocks = overviewBlocks
    self.lessons = lessons.sorted { ($0.lessonOrder, $0.id) < ($1.lessonOrder, $1.id) }
  }

  /// Öğrenciye gösterilecek dersler. Taslak ders hiçbir koşulda görünmez.
  public var publishedLessons: [ReadingLesson] {
    lessons.filter { $0.status.isVisibleToLearners }
  }

  /// Modül yayında ve gösterilecek en az bir dersi var mı?
  public var isOpen: Bool {
    status.isVisibleToLearners && !publishedLessons.isEmpty
  }

  public var totalEstimatedMinutes: Int {
    publishedLessons.reduce(0) { $0 + $1.estimatedMinutes }
  }
}

/// Modüllerden oluşan kurs. Uygulamada tek kurs vardır; katalog yine de
/// kursu adlandırır ki ileride ikincisi eklenirse yapı değişmesin.
public struct ReadingCourse: Equatable, Sendable, Identifiable {
  public let id: String
  public let title: String
  public let summary: String
  public let modules: [ReadingModule]

  public init(id: String, title: String, summary: String, modules: [ReadingModule]) {
    self.id = id
    self.title = title
    self.summary = summary
    self.modules = modules.sorted { ($0.order, $0.id) < ($1.order, $1.id) }
  }

  /// Katalogda görünen modüller: yayındakiler ve "yakında" olanlar.
  /// Taslak modüller hiç görünmez.
  public var visibleModules: [ReadingModule] {
    modules.filter { $0.status != .draft }
  }

  /// Yayın sırasına göre düzleştirilmiş ders listesi; önceki/sonraki gezinme
  /// bunun üzerinden yürür.
  public var publishedLessons: [ReadingLesson] {
    modules.filter(\.isOpen).flatMap(\.publishedLessons)
  }

  public func lesson(id: String) -> ReadingLesson? {
    publishedLessons.first { $0.id == id }
  }

  public func previousLesson(before id: String) -> ReadingLesson? {
    let lessons = publishedLessons
    guard let index = lessons.firstIndex(where: { $0.id == id }), index > 0 else { return nil }
    return lessons[index - 1]
  }

  public func nextLesson(after id: String) -> ReadingLesson? {
    let lessons = publishedLessons
    guard let index = lessons.firstIndex(where: { $0.id == id }),
      index + 1 < lessons.count
    else {
      return nil
    }
    return lessons[index + 1]
  }

  public func completedCount(in progress: LessonProgress) -> Int {
    let completed = progress.completedReadingLessonIDs
    return publishedLessons.filter { completed.contains($0.id) }.count
  }
}

/// Bir kavram dersinin okunma akışı: anlatım → alıştırmalar → tamamlandı.
///
/// Alıştırmalar atlanamaz. Ders "okudum" düğmesiyle değil, alıştırmalar
/// görüldükten sonra kapanır — kod okuma derslerindeki quiz zorunluluğuyla
/// aynı gerekçe: görmeden geçilen adım öğrenme sayılmaz.
public struct ReadingSession: Equatable, Sendable {
  public enum Phase: Equatable, Sendable {
    case reading
    case exercises
    case complete
  }

  public let lesson: ReadingLesson
  public private(set) var phase: Phase

  public init(lesson: ReadingLesson, isAlreadyCompleted: Bool = false) {
    self.lesson = lesson
    phase = isAlreadyCompleted ? .complete : .reading
  }

  /// Dersi tamamlanmış saymak için alıştırmaların görülmüş olması gerekir.
  public var canComplete: Bool { phase == .exercises }

  public mutating func startExercises() {
    guard phase == .reading else { return }
    phase = .exercises
  }

  public mutating func complete() {
    guard canComplete else { return }
    phase = .complete
  }
}

/// İçerik yüklenirken bulunan sözleşme ihlalleri.
///
/// Bunlar testlerin yakaladığı hatalardır; kullanıcıya yarım içerik göstermek
/// yerine yükleme başarısız olur.
public enum ReadingCurriculumError: Error, Equatable, CustomStringConvertible {
  case contentDirectoryMissing
  case missingField(path: String, field: String)
  case invalidField(path: String, field: String, value: String)
  case duplicateLessonID(String, paths: [String])
  case missingPrerequisite(lessonID: String, prerequisiteID: String)

  public var description: String {
    switch self {
    case .contentDirectoryMissing:
      return "Okuma içeriği klasörü uygulama paketinde bulunamadı."
    case .missingField(let path, let field):
      return "\(path): zorunlu '\(field)' alanı yok."
    case .invalidField(let path, let field, let value):
      return "\(path): '\(field)' alanı geçersiz — '\(value)'."
    case .duplicateLessonID(let id, let paths):
      return "Yinelenen ders kimliği '\(id)': \(paths.joined(separator: ", "))"
    case .missingPrerequisite(let lessonID, let prerequisiteID):
      return "\(lessonID) dersi var olmayan bir ön koşula işaret ediyor: \(prerequisiteID)"
    }
  }
}
