import Foundation

/// Bir dersin neden tekrara düştüğü.
public enum ReviewReason: String, Equatable, Sendable {
  /// Son denemede quiz yanlış bilindi.
  case incorrectLastTime
  /// Doğru bilindi ama üzerinden zaman geçti.
  case fading
}

public struct ReviewItem: Equatable, Sendable {
  public let lessonID: String
  public let reason: ReviewReason

  /// Bu ders kaç kez tamamlandı? Tekrar quizinde sıradaki soruyu seçmek için.
  public let completedAttempts: Int

  public init(lessonID: String, reason: ReviewReason, completedAttempts: Int) {
    self.lessonID = lessonID
    self.reason = reason
    self.completedAttempts = completedAttempts
  }
}

/// Tamamlanmış dersleri geri getiren aralıklı tekrar kuyruğu.
///
/// Ders sayısı arttıkça ilk günlerin kavramları geri gelmezse öğrenci onları
/// unutur. Kuyruk önce yanlış bilinen dersi, sonra üzerinden en çok zaman
/// geçmiş dersi önerir.
public enum ReviewQueue {
  /// Doğru bilinen bir dersin tekrara düşmesi için geçmesi gereken gün.
  public static let fadingAfterDays = 3

  public static func items(
    from progress: LessonProgress,
    asOf date: Date,
    limit: Int = 3,
    calendar: Calendar = .current
  ) -> [ReviewItem] {
    let today = calendar.startOfDay(for: date)
    let byLesson = Dictionary(grouping: progress.attempts, by: \.lessonID)

    let candidates: [(item: ReviewItem, lastSeen: Date)] = byLesson.compactMap {
      lessonID, attempts in
      guard let latest = attempts.max(by: { $0.completedAt < $1.completedAt }) else { return nil }
      // Aynı gün içinde çözülen ders tekrara girmez; tekrar aralık ister.
      guard calendar.startOfDay(for: latest.completedAt) < today else { return nil }

      let daysSince =
        calendar.dateComponents(
          [.day],
          from: calendar.startOfDay(for: latest.completedAt),
          to: today
        ).day ?? 0

      if !latest.quizCorrect {
        return (
          ReviewItem(
            lessonID: lessonID,
            reason: .incorrectLastTime,
            completedAttempts: attempts.count
          ),
          latest.completedAt
        )
      }
      guard daysSince >= fadingAfterDays else { return nil }
      return (
        ReviewItem(lessonID: lessonID, reason: .fading, completedAttempts: attempts.count),
        latest.completedAt
      )
    }

    let ordered = candidates.sorted { left, right in
      if (left.item.reason == .incorrectLastTime) != (right.item.reason == .incorrectLastTime) {
        return left.item.reason == .incorrectLastTime
      }
      if left.lastSeen != right.lastSeen {
        return left.lastSeen < right.lastSeen
      }
      return left.item.lessonID < right.item.lessonID
    }

    return Array(ordered.prefix(max(0, limit)).map(\.item))
  }
}
