import Foundation

/// Markdown ders dosyalarını uygulama paketinden okuyup kursu kurar.
///
/// İçerik Swift koduna kopyalanmaz; `GrillMe/Core/Learning` ağacı hem SwiftPM
/// kaynağı hem de uygulama paketine kopyalanan bir klasör referansıdır. Tek
/// çözümleme noktası burasıdır.
public enum ReadingLibrary {
  public static let courseID = "software-engineering-fundamentals"
  public static let courseTitle = "Yazılım Mühendisliği Temelleri"
  public static let courseSummary =
    "Kod okuma pratiğinin altındaki kavramsal zemin: yazılımın ne olduğu, problemin nasıl çözülebilir hâle geldiği ve bir çözümün nasıl sınandığı."

  /// İçerik klasörünün paket içindeki kökü.
  ///
  /// `swift test` sırasında kaynaklar `Bundle.module` altında, uygulamada ise
  /// paket kökündeki `Learning` klasör referansında durur.
  public static var contentRootURL: URL? {
    #if SWIFT_PACKAGE
      let bundle = Bundle.module
    #else
      let bundle = Bundle.main
    #endif
    if let url = bundle.url(forResource: "Learning", withExtension: nil) {
      return url
    }
    let fallback = bundle.resourceURL?.appendingPathComponent("Learning")
    guard let fallback,
      FileManager.default.fileExists(atPath: fallback.path)
    else {
      return nil
    }
    return fallback
  }

  /// Kursu yükler; sözleşme ihlalinde hata fırlatır.
  public static func loadCourse(from rootURL: URL? = contentRootURL) throws -> ReadingCourse {
    guard let rootURL else { throw ReadingCurriculumError.contentDirectoryMissing }

    let moduleDirectories = try FileManager.default
      .contentsOfDirectory(at: rootURL, includingPropertiesForKeys: [.isDirectoryKey])
      .filter { isModuleDirectory($0) }
      .sorted { $0.lastPathComponent < $1.lastPathComponent }

    var modules: [ReadingModule] = []
    var pathsByLessonID: [String: [String]] = [:]

    for directory in moduleDirectories {
      let module = try loadModule(at: directory, rootURL: rootURL)
      for lesson in module.lessons {
        pathsByLessonID[lesson.id, default: []].append(lesson.path)
      }
      modules.append(module)
    }

    if let duplicate = pathsByLessonID.first(where: { $0.value.count > 1 }) {
      throw ReadingCurriculumError.duplicateLessonID(
        duplicate.key,
        paths: duplicate.value.sorted()
      )
    }

    let knownIDs = Set(pathsByLessonID.keys)
    for module in modules {
      for lesson in module.lessons {
        for prerequisite in lesson.prerequisites where !knownIDs.contains(prerequisite) {
          throw ReadingCurriculumError.missingPrerequisite(
            lessonID: lesson.id,
            prerequisiteID: prerequisite
          )
        }
      }
    }

    return ReadingCourse(
      id: courseID,
      title: courseTitle,
      summary: courseSummary,
      modules: modules
    )
  }

  /// Yükleme başarısız olursa uygulamayı çökertmeden boş kursla devam eder ve
  /// kullanıcıya gösterilecek bir uyarı döndürür — hata sessizce yutulmaz.
  public static func loadRecovering(
    from rootURL: URL? = contentRootURL
  ) -> (course: ReadingCourse, notice: String?) {
    do {
      return (try loadCourse(from: rootURL), nil)
    } catch {
      let detail = (error as? ReadingCurriculumError)?.description ?? error.localizedDescription
      return (
        ReadingCourse(id: courseID, title: courseTitle, summary: courseSummary, modules: []),
        "Kavram dersleri yüklenemedi, bu bölüm şimdilik boş görünecek. \(detail)"
      )
    }
  }

  // MARK: - Yükleme

  private static func isModuleDirectory(_ url: URL) -> Bool {
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory),
      isDirectory.boolValue
    else {
      return false
    }
    // Modül klasörleri "00-", "01-" biçiminde numaralandırılır; `templates`
    // gibi yardımcı klasörler bu desene uymaz ve içerik sayılmaz.
    let name = url.lastPathComponent
    guard name.count > 3 else { return false }
    return name.prefix(2).allSatisfy(\.isNumber) && name.dropFirst(2).hasPrefix("-")
  }

  private static func loadModule(at directory: URL, rootURL: URL) throws -> ReadingModule {
    let overviewURL = directory.appendingPathComponent("README.md")
    let overviewPath = relativePath(of: overviewURL, from: rootURL)
    let overviewText = try String(contentsOf: overviewURL, encoding: .utf8)
    let overview = MarkdownDocument.parse(overviewText)

    let moduleID = try requiredString(overview.frontMatter, "module", overviewPath)
    let moduleOrder = try requiredInt(overview.frontMatter, "moduleOrder", overviewPath)
    let status = try requiredStatus(overview.frontMatter, path: overviewPath)

    let lessonURLs = try FileManager.default
      .contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
      .filter { $0.pathExtension == "md" && $0.lastPathComponent != "README.md" }
      .sorted { $0.lastPathComponent < $1.lastPathComponent }

    let lessons = try lessonURLs.map { try loadLesson(at: $0, rootURL: rootURL) }

    return ReadingModule(
      id: moduleID,
      course: overview.frontMatter["course"]?.stringValue ?? courseID,
      order: moduleOrder,
      title: try requiredString(overview.frontMatter, "title", overviewPath),
      summary: try requiredString(overview.frontMatter, "description", overviewPath),
      status: status,
      version: overview.frontMatter["version"]?.intValue ?? 1,
      overviewBlocks: overview.blocks,
      lessons: lessons
    )
  }

  private static func loadLesson(at url: URL, rootURL: URL) throws -> ReadingLesson {
    let path = relativePath(of: url, from: rootURL)
    let document = MarkdownDocument.parse(try String(contentsOf: url, encoding: .utf8))
    let fields = document.frontMatter

    let sectionRaw = try requiredString(fields, "section", path)
    guard let section = CurriculumSection(rawValue: sectionRaw) else {
      throw ReadingCurriculumError.invalidField(path: path, field: "section", value: sectionRaw)
    }

    let difficultyRaw = fields["difficulty"]?.stringValue ?? ReadingDifficulty.beginner.rawValue
    guard let difficulty = ReadingDifficulty(rawValue: difficultyRaw) else {
      throw ReadingCurriculumError.invalidField(
        path: path,
        field: "difficulty",
        value: difficultyRaw
      )
    }

    return ReadingLesson(
      id: try requiredString(fields, "id", path),
      course: fields["course"]?.stringValue ?? courseID,
      module: try requiredString(fields, "module", path),
      moduleOrder: try requiredInt(fields, "moduleOrder", path),
      lessonOrder: try requiredInt(fields, "lessonOrder", path),
      section: section,
      title: try requiredString(fields, "title", path),
      summary: try requiredString(fields, "description", path),
      difficulty: difficulty,
      estimatedMinutes: try requiredInt(fields, "estimatedMinutes", path),
      prerequisites: fields["prerequisites"]?.listValue ?? [],
      objectives: fields["objectives"]?.listValue ?? [],
      status: try requiredStatus(fields, path: path),
      version: fields["version"]?.intValue ?? 1,
      path: path,
      blocks: document.blocks
    )
  }

  // MARK: - Alan doğrulama

  private static func requiredString(
    _ fields: [String: MarkdownValue],
    _ key: String,
    _ path: String
  ) throws -> String {
    guard let value = fields[key]?.stringValue, !value.isEmpty else {
      throw ReadingCurriculumError.missingField(path: path, field: key)
    }
    return value
  }

  private static func requiredInt(
    _ fields: [String: MarkdownValue],
    _ key: String,
    _ path: String
  ) throws -> Int {
    guard let raw = fields[key]?.stringValue else {
      throw ReadingCurriculumError.missingField(path: path, field: key)
    }
    guard let value = Int(raw) else {
      throw ReadingCurriculumError.invalidField(path: path, field: key, value: raw)
    }
    return value
  }

  private static func requiredStatus(
    _ fields: [String: MarkdownValue],
    path: String
  ) throws -> ReadingStatus {
    let raw = try requiredString(fields, "status", path)
    guard let status = ReadingStatus(rawValue: raw) else {
      throw ReadingCurriculumError.invalidField(path: path, field: "status", value: raw)
    }
    return status
  }

  /// Teşhis mesajlarında kullanılan, içerik köküne göreli yol.
  ///
  /// Karşılaştırma metin öneki yerine yol bileşenleriyle yapılır; geçici klasör
  /// gibi sembolik bağ içeren yollarda önek eşleşmesi sessizce bozuluyordu.
  private static func relativePath(of url: URL, from root: URL) -> String {
    let rootComponents = root.resolvingSymlinksInPath().standardized.pathComponents
    let urlComponents = url.resolvingSymlinksInPath().standardized.pathComponents
    guard urlComponents.count > rootComponents.count,
      Array(urlComponents.prefix(rootComponents.count)) == rootComponents
    else {
      return url.lastPathComponent
    }
    return urlComponents.dropFirst(rootComponents.count).joined(separator: "/")
  }
}
