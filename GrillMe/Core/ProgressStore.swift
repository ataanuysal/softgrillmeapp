import Foundation

public struct LessonAttempt: Codable, Equatable, Sendable {
  public let lessonID: String
  public let completedAt: Date
  public let durationSeconds: Int
  public let quizCorrect: Bool
  public let practiceAccuracy: Double?
  public let assessmentScore: Double?

  public init(
    lessonID: String,
    completedAt: Date,
    durationSeconds: Int,
    quizCorrect: Bool,
    practiceAccuracy: Double?,
    assessmentScore: Double?
  ) {
    self.lessonID = lessonID
    self.completedAt = completedAt
    self.durationSeconds = durationSeconds
    self.quizCorrect = quizCorrect
    self.practiceAccuracy = practiceAccuracy
    self.assessmentScore = assessmentScore
  }

  private enum CodingKeys: String, CodingKey {
    case lessonID
    case completedAt
    case durationSeconds
    case quizCorrect
    case practiceAccuracy
    case assessmentScore
    case predictionCorrect
    case transferCorrect
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    lessonID = try container.decode(String.self, forKey: .lessonID)
    completedAt = try container.decode(Date.self, forKey: .completedAt)
    durationSeconds = try container.decode(Int.self, forKey: .durationSeconds)
    quizCorrect =
      try container.decodeIfPresent(Bool.self, forKey: .quizCorrect)
      ?? container.decode(Bool.self, forKey: .predictionCorrect)
    practiceAccuracy =
      try container.decodeIfPresent(Double.self, forKey: .practiceAccuracy)
      ?? container.decodeIfPresent(Bool.self, forKey: .transferCorrect).map { $0 ? 1 : 0 }
    assessmentScore = try container.decodeIfPresent(Double.self, forKey: .assessmentScore)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(lessonID, forKey: .lessonID)
    try container.encode(completedAt, forKey: .completedAt)
    try container.encode(durationSeconds, forKey: .durationSeconds)
    try container.encode(quizCorrect, forKey: .quizCorrect)
    try container.encodeIfPresent(practiceAccuracy, forKey: .practiceAccuracy)
    try container.encodeIfPresent(assessmentScore, forKey: .assessmentScore)
  }
}

public struct WeeklySummary: Equatable, Sendable {
  public let completedLessonCount: Int
  public let practiceSeconds: Int
  public let quizAccuracy: Double?
  public let practiceAccuracy: Double?
  public let assessmentScore: Double?

  public init(
    completedLessonCount: Int,
    practiceSeconds: Int,
    quizAccuracy: Double?,
    practiceAccuracy: Double?,
    assessmentScore: Double?
  ) {
    self.completedLessonCount = completedLessonCount
    self.practiceSeconds = practiceSeconds
    self.quizAccuracy = quizAccuracy
    self.practiceAccuracy = practiceAccuracy
    self.assessmentScore = assessmentScore
  }
}

public struct LearningGrowthReport: Equatable, Sendable {
  /// Yüzde göstermek için gereken en az quiz sayısı.
  ///
  /// Dört seçenekli tek soruda şans başarısı %25'tir; iki quizlik bir farkı
  /// yüzde olarak sunmak ölçüm değil, gürültüdür.
  public static let minimumSampleSize = 3

  public let baselineQuizAccuracy: Double
  public let exitQuizAccuracy: Double
  public let improvement: Double
  public let baselineSampleSize: Int
  public let exitSampleSize: Int

  public init(
    baselineQuizAccuracy: Double,
    exitQuizAccuracy: Double,
    baselineSampleSize: Int,
    exitSampleSize: Int
  ) {
    self.baselineQuizAccuracy = baselineQuizAccuracy
    self.exitQuizAccuracy = exitQuizAccuracy
    self.baselineSampleSize = baselineSampleSize
    self.exitSampleSize = exitSampleSize
    improvement = exitQuizAccuracy - baselineQuizAccuracy
  }

  /// Örneklem yüzde sunmaya yetiyor mu?
  ///
  /// Yetmiyorsa arayüz sayı yerine "henüz yeterli veri yok" demelidir; rapor
  /// yine de kaç quizden geldiğini taşır.
  public var hasEnoughEvidence: Bool {
    baselineSampleSize >= Self.minimumSampleSize && exitSampleSize >= Self.minimumSampleSize
  }
}

public struct LessonProgress: Codable, Equatable, Sendable {
  public private(set) var completedLessonIDs: Set<String>
  public private(set) var attempts: [LessonAttempt]
  public private(set) var learningEvents: [LearningEvent]
  /// İlk açılış akışı tamamlandı mı? Eski kayıtlarda bu alan yoktur.
  public private(set) var hasFinishedOnboarding: Bool
  /// Seçilen günlük ritim; seçilmediyse nil.
  public private(set) var dailyGoal: DailyGoal?

  public init(
    completedLessonIDs: Set<String> = [],
    attempts: [LessonAttempt] = [],
    learningEvents: [LearningEvent] = [],
    hasFinishedOnboarding: Bool = false,
    dailyGoal: DailyGoal? = nil
  ) {
    self.completedLessonIDs = completedLessonIDs
    self.attempts = attempts
    self.learningEvents = learningEvents
    self.hasFinishedOnboarding = hasFinishedOnboarding
    self.dailyGoal = dailyGoal
  }

  /// İlk açılış akışını kapatır ve seçilen ritmi saklar.
  public mutating func finishOnboarding(dailyGoal: DailyGoal?) {
    hasFinishedOnboarding = true
    self.dailyGoal = dailyGoal
  }

  /// Verilen gün içinde tamamlanan benzersiz ders sayısı.
  public func completedLessonCount(
    on date: Date,
    calendar: Calendar = .current
  ) -> Int {
    let day = calendar.startOfDay(for: date)
    let sameDay = attempts.filter { calendar.startOfDay(for: $0.completedAt) == day }
    return Set(sameDay.map(\.lessonID)).count
  }

  public mutating func complete(_ lessonID: String) {
    completedLessonIDs.insert(lessonID)
  }

  public mutating func recordAttempt(_ attempt: LessonAttempt) {
    attempts.append(attempt)
    complete(attempt.lessonID)
  }

  public mutating func record(_ result: LessonRunResult) {
    recordAttempt(result.attempt)
    learningEvents.append(contentsOf: result.events)
  }

  public var firstAttemptAccuracy: Double {
    accuracy(of: firstAttempts)
  }

  public var retryAccuracy: Double {
    let firstIndices = Set(
      Dictionary(grouping: attempts.indices, by: { attempts[$0].lessonID })
        .values
        .compactMap(\.first)
    )
    return accuracy(of: attempts.indices.filter { !firstIndices.contains($0) }.map { attempts[$0] })
  }

  public func currentStreak(
    asOf date: Date,
    calendar: Calendar = .current
  ) -> Int {
    let practiceDays = Set(attempts.map { calendar.startOfDay(for: $0.completedAt) })
    var cursor = calendar.startOfDay(for: date)

    if !practiceDays.contains(cursor),
      let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor),
      practiceDays.contains(yesterday)
    {
      cursor = yesterday
    }

    var streak = 0
    while practiceDays.contains(cursor) {
      streak += 1
      guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else {
        break
      }
      cursor = previous
    }
    return streak
  }

  public func weeklySummary(
    containing date: Date,
    calendar: Calendar = .current
  ) -> WeeklySummary {
    guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else {
      return WeeklySummary(
        completedLessonCount: 0,
        practiceSeconds: 0,
        quizAccuracy: nil,
        practiceAccuracy: nil,
        assessmentScore: nil
      )
    }

    let weekAttempts = attempts.filter { interval.contains($0.completedAt) }

    return WeeklySummary(
      completedLessonCount: Set(weekAttempts.map(\.lessonID)).count,
      practiceSeconds: weekAttempts.reduce(0) { $0 + $1.durationSeconds },
      quizAccuracy: weekAttempts.isEmpty ? nil : accuracy(of: weekAttempts),
      practiceAccuracy: optionalAverage(of: weekAttempts.compactMap(\.practiceAccuracy)),
      assessmentScore: optionalAverage(of: weekAttempts.compactMap(\.assessmentScore))
    )
  }

  /// Başlangıç ve çıkış quiz doğruluğunu karşılaştırır.
  ///
  /// Başlangıç her dersin **ilk** denemesinden, çıkış ise **son** denemesinden
  /// gelir: ilki henüz öğrenilmemiş hali, ikincisi ulaşılan hali temsil eder.
  /// Çıkış ölçümü tek derse bağlı değildir; verilen bütün çıkış derslerinden
  /// toplanır ve rapor kaç quizden geldiğini taşır.
  public func growthReport(
    baselineLessonIDs: Set<String>,
    exitLessonIDs: Set<String>
  ) -> LearningGrowthReport? {
    let baselineAttempts = baselineLessonIDs.compactMap { lessonID in
      attempts.first(where: { $0.lessonID == lessonID })
    }
    let exitAttempts = exitLessonIDs.compactMap { lessonID in
      attempts.last(where: { $0.lessonID == lessonID })
    }
    guard baselineAttempts.count == baselineLessonIDs.count, !exitAttempts.isEmpty else {
      return nil
    }

    return LearningGrowthReport(
      baselineQuizAccuracy: accuracy(of: baselineAttempts),
      exitQuizAccuracy: accuracy(of: exitAttempts),
      baselineSampleSize: baselineAttempts.count,
      exitSampleSize: exitAttempts.count
    )
  }

  private var firstAttempts: [LessonAttempt] {
    var seen: Set<String> = []
    return attempts.filter { seen.insert($0.lessonID).inserted }
  }

  private func accuracy(of attempts: [LessonAttempt]) -> Double {
    ratio(of: attempts.map(\.quizCorrect))
  }

  private func ratio(of results: [Bool]) -> Double {
    guard !results.isEmpty else { return 0 }
    return Double(results.filter { $0 }.count) / Double(results.count)
  }

  private func average(of values: [Double]) -> Double {
    guard !values.isEmpty else { return 0 }
    return values.reduce(0, +) / Double(values.count)
  }

  private func optionalAverage(of values: [Double]) -> Double? {
    guard !values.isEmpty else { return nil }
    return average(of: values)
  }

  private enum CodingKeys: String, CodingKey {
    case completedLessonIDs
    case attempts
    case learningEvents
    case hasFinishedOnboarding
    case dailyGoal
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    completedLessonIDs =
      try container.decodeIfPresent(Set<String>.self, forKey: .completedLessonIDs) ?? []
    attempts = try container.decodeIfPresent([LessonAttempt].self, forKey: .attempts) ?? []
    learningEvents =
      try container.decodeIfPresent([LearningEvent].self, forKey: .learningEvents) ?? []
    // Onboarding'den önceki kayıtlarda bu alanlar yoktur; eski kullanıcı akışı
    // yeniden görmesin diye ilerlemesi olan kayıt tamamlanmış sayılır.
    hasFinishedOnboarding =
      try container.decodeIfPresent(Bool.self, forKey: .hasFinishedOnboarding)
      ?? !attempts.isEmpty
    dailyGoal = try container.decodeIfPresent(DailyGoal.self, forKey: .dailyGoal)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(completedLessonIDs, forKey: .completedLessonIDs)
    try container.encode(attempts, forKey: .attempts)
    try container.encode(learningEvents, forKey: .learningEvents)
    try container.encode(hasFinishedOnboarding, forKey: .hasFinishedOnboarding)
    try container.encodeIfPresent(dailyGoal, forKey: .dailyGoal)
  }
}

public struct ProgressLoadResult: Equatable, Sendable {
  public let progress: LessonProgress
  public let notice: String?
  public let backupURL: URL?

  public init(progress: LessonProgress, notice: String?, backupURL: URL?) {
    self.progress = progress
    self.notice = notice
    self.backupURL = backupURL
  }
}

public struct FileProgressStore: Sendable {
  private let fileURL: URL

  public init(fileURL: URL) {
    self.fileURL = fileURL
  }

  public func load() throws -> LessonProgress {
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      return LessonProgress()
    }
    let data = try Data(contentsOf: fileURL)
    return try JSONDecoder().decode(LessonProgress.self, from: data)
  }

  public func loadRecovering() -> ProgressLoadResult {
    do {
      return ProgressLoadResult(progress: try load(), notice: nil, backupURL: nil)
    } catch {
      let backupURL = corruptBackupURL()
      let recoveredURL: URL?
      do {
        try FileManager.default.moveItem(at: fileURL, to: backupURL)
        recoveredURL = backupURL
      } catch {
        recoveredURL = nil
      }
      let backupMessage =
        recoveredURL == nil
        ? "Bozuk ilerleme dosyası yedeklenemedi."
        : "Bozuk ilerleme dosyası güvenli bir yedeğe taşındı."
      return ProgressLoadResult(
        progress: LessonProgress(),
        notice: "\(backupMessage) Yeni ve boş bir ilerleme kaydıyla devam ediliyor.",
        backupURL: recoveredURL
      )
    }
  }

  public func save(_ progress: LessonProgress) throws {
    try FileManager.default.createDirectory(
      at: fileURL.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )
    let data = try JSONEncoder().encode(progress)
    try data.write(to: fileURL, options: .atomic)
  }

  private func corruptBackupURL() -> URL {
    let baseName = fileURL.deletingPathExtension().lastPathComponent
    return fileURL.deletingLastPathComponent()
      .appendingPathComponent("\(baseName)-corrupt-\(UUID().uuidString).json")
  }
}
