import Foundation

public struct LessonAttempt: Codable, Equatable, Sendable {
  public let lessonID: String
  public let completedAt: Date
  public let durationSeconds: Int
  public let predictionCorrect: Bool
  public let transferCorrect: Bool?

  public init(
    lessonID: String,
    completedAt: Date,
    durationSeconds: Int,
    predictionCorrect: Bool,
    transferCorrect: Bool?
  ) {
    self.lessonID = lessonID
    self.completedAt = completedAt
    self.durationSeconds = durationSeconds
    self.predictionCorrect = predictionCorrect
    self.transferCorrect = transferCorrect
  }
}

public struct WeeklySummary: Equatable, Sendable {
  public let completedLessonCount: Int
  public let practiceSeconds: Int
  public let predictionAccuracy: Double
  public let transferAccuracy: Double

  public init(
    completedLessonCount: Int,
    practiceSeconds: Int,
    predictionAccuracy: Double,
    transferAccuracy: Double
  ) {
    self.completedLessonCount = completedLessonCount
    self.practiceSeconds = practiceSeconds
    self.predictionAccuracy = predictionAccuracy
    self.transferAccuracy = transferAccuracy
  }
}

public struct LearningGrowthReport: Equatable, Sendable {
  public let baselineAccuracy: Double
  public let exitAccuracy: Double
  public let improvement: Double

  public init(
    baselineAccuracy: Double,
    exitAccuracy: Double
  ) {
    self.baselineAccuracy = baselineAccuracy
    self.exitAccuracy = exitAccuracy
    improvement = exitAccuracy - baselineAccuracy
  }
}

public struct LessonProgress: Codable, Equatable, Sendable {
  public private(set) var completedLessonIDs: Set<String>
  public private(set) var attempts: [LessonAttempt]

  public init(
    completedLessonIDs: Set<String> = [],
    attempts: [LessonAttempt] = []
  ) {
    self.completedLessonIDs = completedLessonIDs
    self.attempts = attempts
  }

  public mutating func complete(_ lessonID: String) {
    completedLessonIDs.insert(lessonID)
  }

  public mutating func recordAttempt(_ attempt: LessonAttempt) {
    attempts.append(attempt)
    complete(attempt.lessonID)
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
        predictionAccuracy: 0,
        transferAccuracy: 0
      )
    }

    let weekAttempts = attempts.filter { interval.contains($0.completedAt) }
    let transferResults = weekAttempts.compactMap(\.transferCorrect)

    return WeeklySummary(
      completedLessonCount: Set(weekAttempts.map(\.lessonID)).count,
      practiceSeconds: weekAttempts.reduce(0) { $0 + $1.durationSeconds },
      predictionAccuracy: accuracy(of: weekAttempts),
      transferAccuracy: ratio(of: transferResults)
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

    let baseline = averageCombinedAccuracy(of: baselineAttempts)
    let exit = averageCombinedAccuracy(of: [exitAttempt])
    return LearningGrowthReport(
      baselineAccuracy: baseline,
      exitAccuracy: exit
    )
  }

  private var firstAttempts: [LessonAttempt] {
    var seen: Set<String> = []
    return attempts.filter { seen.insert($0.lessonID).inserted }
  }

  private func accuracy(of attempts: [LessonAttempt]) -> Double {
    ratio(of: attempts.map(\.predictionCorrect))
  }

  private func ratio(of results: [Bool]) -> Double {
    guard !results.isEmpty else { return 0 }
    return Double(results.filter { $0 }.count) / Double(results.count)
  }

  private func averageCombinedAccuracy(of attempts: [LessonAttempt]) -> Double {
    let results = attempts.flatMap { attempt in
      var results = [attempt.predictionCorrect]
      if let transferCorrect = attempt.transferCorrect {
        results.append(transferCorrect)
      }
      return results
    }
    return ratio(of: results)
  }

  private enum CodingKeys: String, CodingKey {
    case completedLessonIDs
    case attempts
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    completedLessonIDs =
      try container.decodeIfPresent(Set<String>.self, forKey: .completedLessonIDs) ?? []
    attempts = try container.decodeIfPresent([LessonAttempt].self, forKey: .attempts) ?? []
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(completedLessonIDs, forKey: .completedLessonIDs)
    try container.encode(attempts, forKey: .attempts)
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
