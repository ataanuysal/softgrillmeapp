/// Kullanıcının ilk açılışta seçtiği günlük okuma ritmi.
///
/// Seçim bir süsleme değil: yol haritasındaki "bugün" göstergesi bu hedefe
/// göre okunur. Hedefsiz kullanıcı için gösterge de gösterilmez.
public enum DailyGoal: String, Codable, CaseIterable, Equatable, Sendable {
  case calm
  case steady
  case intense

  /// Onboarding'de önerilen ritim. Küçük ama düzenli olan, uzun oturumlardan
  /// daha iyi sonuç verir.
  public static let recommended: DailyGoal = .steady

  public var lessonsPerDay: Int {
    switch self {
    case .calm: 1
    case .steady: 2
    case .intense: 4
    }
  }

  public var title: String {
    switch self {
    case .calm: "Sakin"
    case .steady: "Düzenli"
    case .intense: "Yoğun"
    }
  }

  /// "1 ders · ~7 dk" biçiminde özet.
  public var summary: String {
    "\(lessonsPerDay) ders · ~\(estimatedMinutes) dk"
  }

  private var estimatedMinutes: Int {
    switch self {
    case .calm: 7
    case .steady: 15
    case .intense: 30
    }
  }
}
