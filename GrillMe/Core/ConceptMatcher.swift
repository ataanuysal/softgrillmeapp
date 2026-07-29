import Foundation

/// Türkçe yazılmış serbest cevaplarda bir kavramın geçip geçmediğini bulur.
///
/// Türkçe eklemeli bir dildir: öğrenci "girdi" kavramını "girdiyi", "risk"
/// kavramını "riskleri" biçiminde yazar. Tam kelime araması bu cevapları
/// haksız yere sıfırlar, düz `contains` ise "16" içinde "6", "risksiz" içinde
/// "risk" görür. Bu tip ikisinin arasını ayırır:
///
/// - Kavram kelime başında başlamalıdır; "16" içindeki "6" eşleşmez.
/// - Ardından gelen harfler ek sayılır; "riskleri" eşleşir.
/// - Ardından gelen rakam sınır ihlalidir; "60" içindeki "6" eşleşmez.
/// - Olumsuzlayan ek kavramı kanıtlamaz; "risksiz" eşleşmez.
public enum ConceptMatcher {
  /// Kavramın anlamını tersine çevirdiği için ek toleransının dışında tutulan olumsuzluk ekleri.
  private static let negatingSuffixes: Set<String> = Set(
    ["siz", "sız", "suz", "süz"].map(normalized)
  )

  /// Büyük/küçük harf ve Türkçe aksan farklarını kaldırır.
  public static func normalized(_ value: String) -> String {
    value.folding(
      options: [.caseInsensitive, .diacriticInsensitive],
      locale: Locale(identifier: "tr_TR")
    )
  }

  public static func matches(_ concept: String, in text: String) -> Bool {
    let concept = normalized(concept).trimmingCharacters(in: .whitespacesAndNewlines)
    let text = normalized(text)
    guard !concept.isEmpty,
      let expression = try? NSRegularExpression(pattern: pattern(for: concept))
    else {
      return false
    }

    let searchRange = NSRange(text.startIndex..., in: text)
    return expression.matches(in: text, range: searchRange).contains { match in
      guard let suffixRange = Range(match.range(at: 1), in: text) else { return true }
      let suffix = text[suffixRange]
      return !negatingSuffixes.contains { suffix.hasPrefix($0) }
    }
  }

  /// Çok kelimeli kavramları aradaki boşluk miktarından bağımsız arar ve
  /// kelimenin kalan harflerini ek olarak yakalar.
  private static func pattern(for concept: String) -> String {
    let escaped = concept.split(whereSeparator: \.isWhitespace)
      .map { NSRegularExpression.escapedPattern(for: String($0)) }
      .joined(separator: "\\s+")
    return "(?<![\\p{L}\\p{N}_])\(escaped)(\\p{L}*)(?![\\p{L}\\p{N}_])"
  }
}
