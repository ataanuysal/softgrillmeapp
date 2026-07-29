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
  public let baselineQuizAccuracy: Double
  public let exitQuizAccuracy: Double
  public let improvement: Double

  public init(
    baselineQuizAccuracy: Double,
    exitQuizAccuracy: Double
  ) {
    self.baselineQuizAccuracy = baselineQuizAccuracy
    self.exitQuizAccuracy = exitQuizAccuracy
    improvement = exitQuizAccuracy - baselineQuizAccuracy
  }
}

public struct LessonProgress: Codable, Equatable, Sendable {
  public private(set) var completedLessonIDs: Set<String>
  public private(set) var attempts: [LessonAttempt]
  public private(set) var learningEvents: [LearningEvent]

  public init(
    completedLessonIDs: Set<String> = [],
    attempts: [LessonAttempt] = [],
    learningEvents: [LearningEvent] = []
  ) {
    self.completedLessonIDs = completedLessonIDs
    self.attempts = attempts
    self.learningEvents = learningEvents
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

  public func growthReport(
    baselineLessonIDs: Set<String>,
    exitLessonID: String
  ) -> LearningGrowthReport? {
    let baselineAttempts = baselineLessonIDs.compactMap { lessonID in
      attempts.first(where: { $0.lessonID == lessonID })
    }
    guard baselineAttempts.count == baselineLessonIDs.count,
      let exitAttempt = attempts.last(where: { $0.lessonID == exitLessonID })
    else {
      return nil
    }

    let baseline = accuracy(of: baselineAttempts)
    let exit = accuracy(of: [exitAttempt])
    return LearningGrowthReport(
      baselineQuizAccuracy: baseline,
      exitQuizAccuracy: exit
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
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    completedLessonIDs =
      try container.decodeIfPresent(Set<String>.self, forKey: .completedLessonIDs) ?? []
    attempts = try container.decodeIfPresent([LessonAttempt].self, forKey: .attempts) ?? []
    learningEvents =
      try container.decodeIfPresent([LearningEvent].self, forKey: .learningEvents) ?? []
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(completedLessonIDs, forKey: .completedLessonIDs)
    try container.encode(attempts, forKey: .attempts)
    try container.encode(learningEvents, forKey: .learningEvents)
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
