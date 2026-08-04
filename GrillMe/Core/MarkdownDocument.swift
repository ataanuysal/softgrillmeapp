import Foundation

/// Okuma derslerinin gövdesini oluşturan blok türleri.
///
/// Uygulama SwiftUI ile render eder ama ayrıştırma burada yapılır: `Core`
/// SwiftUI'yı import etmez ve bu sayede blok üretimi testlerle doğrulanabilir.
public enum MarkdownBlock: Equatable, Sendable {
  case heading(level: Int, text: String)
  case paragraph(String)
  case bulletList([String])
  case orderedList([String])
  case table(headers: [String], rows: [[String]])
  case codeBlock(language: String?, lines: [String])
  case callout(kind: MarkdownCalloutKind, lines: [String])
  case quote([String])
  case divider
}

/// GitHub uyarı kutuları (`> [!NOTE]`). Ders metinleri bunları kullanır.
public enum MarkdownCalloutKind: String, Equatable, Sendable {
  case note = "NOTE"
  case tip = "TIP"
  case warning = "WARNING"

  /// Kutunun Türkçe başlığı; arayüz metni burada kalır ki tek yerden değişsin.
  public var title: String {
    switch self {
    case .note: return "Not"
    case .tip: return "İpucu"
    case .warning: return "Dikkat"
    }
  }
}

/// Bir Markdown dosyasının front matter'ı ve gövdesi.
public struct MarkdownDocument: Equatable, Sendable {
  public let frontMatter: [String: MarkdownValue]
  public let body: String

  public init(frontMatter: [String: MarkdownValue], body: String) {
    self.frontMatter = frontMatter
    self.body = body
  }

  /// Front matter'ı gövdeden ayırır.
  ///
  /// Front matter isteğe bağlıdır; yoksa sözlük boş döner ve dosyanın tamamı
  /// gövde sayılır.
  public static func parse(_ text: String) -> MarkdownDocument {
    let normalized = text.replacingOccurrences(of: "\r\n", with: "\n")
    guard normalized.hasPrefix("---\n") else {
      return MarkdownDocument(frontMatter: [:], body: normalized)
    }

    let afterOpening = normalized.dropFirst(4)
    guard let closingRange = afterOpening.range(of: "\n---\n") else {
      return MarkdownDocument(frontMatter: [:], body: normalized)
    }

    let header = String(afterOpening[afterOpening.startIndex..<closingRange.lowerBound])
    let body = String(afterOpening[closingRange.upperBound...])
    return MarkdownDocument(frontMatter: parseFrontMatter(header), body: body)
  }

  /// Gövdeyi render edilebilir bloklara böler.
  public var blocks: [MarkdownBlock] {
    Self.blocks(in: body)
  }

  // MARK: - Front matter

  private static func parseFrontMatter(_ header: String) -> [String: MarkdownValue] {
    var values: [String: MarkdownValue] = [:]
    var pendingListKey: String?
    var pendingList: [String] = []

    func flushPendingList() {
      if let key = pendingListKey {
        values[key] = .list(pendingList)
      }
      pendingListKey = nil
      pendingList = []
    }

    for rawLine in header.components(separatedBy: "\n") {
      if rawLine.trimmingCharacters(in: .whitespaces).isEmpty { continue }

      // "  - değer" satırları bir önceki anahtarın listesine aittir.
      if rawLine.hasPrefix(" "), let dashIndex = rawLine.firstIndex(of: "-"),
        pendingListKey != nil
      {
        let item = rawLine[rawLine.index(after: dashIndex)...]
          .trimmingCharacters(in: .whitespaces)
        pendingList.append(unquoted(item))
        continue
      }

      flushPendingList()

      guard let separator = rawLine.firstIndex(of: ":") else { continue }
      let key = String(rawLine[rawLine.startIndex..<separator])
        .trimmingCharacters(in: .whitespaces)
      let rawValue = String(rawLine[rawLine.index(after: separator)...])
        .trimmingCharacters(in: .whitespaces)

      if rawValue.isEmpty {
        pendingListKey = key
        continue
      }
      if rawValue == "[]" {
        values[key] = .list([])
        continue
      }
      values[key] = .scalar(unquoted(rawValue))
    }

    flushPendingList()
    return values
  }

  private static func unquoted(_ text: String) -> String {
    guard text.count >= 2 else { return text }
    let pairs: [(Character, Character)] = [("\"", "\""), ("'", "'")]
    for (open, close) in pairs where text.first == open && text.last == close {
      return String(text.dropFirst().dropLast())
    }
    return text
  }

  // MARK: - Gövde

  private static func blocks(in body: String) -> [MarkdownBlock] {
    var blocks: [MarkdownBlock] = []
    var paragraph: [String] = []
    let lines = body.components(separatedBy: "\n")
    var index = 0

    func flushParagraph() {
      guard !paragraph.isEmpty else { return }
      blocks.append(.paragraph(paragraph.joined(separator: " ")))
      paragraph = []
    }

    while index < lines.count {
      let line = lines[index]
      let trimmed = line.trimmingCharacters(in: .whitespaces)

      if trimmed.isEmpty {
        flushParagraph()
        index += 1
        continue
      }

      if trimmed.hasPrefix("```") {
        flushParagraph()
        let language = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
        var code: [String] = []
        index += 1
        while index < lines.count,
          !lines[index].trimmingCharacters(in: .whitespaces).hasPrefix("```")
        {
          code.append(lines[index])
          index += 1
        }
        index += 1  // kapanış çitini atla
        blocks.append(.codeBlock(language: language.isEmpty ? nil : language, lines: code))
        continue
      }

      if trimmed.hasPrefix("#") {
        flushParagraph()
        let level = trimmed.prefix(while: { $0 == "#" }).count
        let text = String(trimmed.dropFirst(level)).trimmingCharacters(in: .whitespaces)
        blocks.append(.heading(level: min(level, 6), text: text))
        index += 1
        continue
      }

      if trimmed == "---" || trimmed == "***" {
        flushParagraph()
        blocks.append(.divider)
        index += 1
        continue
      }

      if trimmed.hasPrefix(">") {
        flushParagraph()
        var quoteLines: [String] = []
        while index < lines.count,
          lines[index].trimmingCharacters(in: .whitespaces).hasPrefix(">")
        {
          let content = lines[index].trimmingCharacters(in: .whitespaces)
          quoteLines.append(String(content.dropFirst()).trimmingCharacters(in: .whitespaces))
          index += 1
        }
        blocks.append(quoteBlock(from: quoteLines))
        continue
      }

      if isTableRow(trimmed), index + 1 < lines.count,
        isTableSeparator(lines[index + 1].trimmingCharacters(in: .whitespaces))
      {
        flushParagraph()
        let headers = tableCells(trimmed)
        index += 2
        var rows: [[String]] = []
        while index < lines.count,
          isTableRow(lines[index].trimmingCharacters(in: .whitespaces))
        {
          rows.append(tableCells(lines[index].trimmingCharacters(in: .whitespaces)))
          index += 1
        }
        blocks.append(.table(headers: headers, rows: rows))
        continue
      }

      if let marker = bulletMarker(trimmed) {
        flushParagraph()
        var items: [String] = []
        while index < lines.count {
          let candidate = lines[index].trimmingCharacters(in: .whitespaces)
          guard bulletMarker(candidate) != nil else { break }
          items.append(
            String(candidate.dropFirst(marker.count)).trimmingCharacters(in: .whitespaces))
          index += 1
        }
        blocks.append(.bulletList(items))
        continue
      }

      if let numberLength = orderedMarkerLength(trimmed) {
        flushParagraph()
        var items: [String] = []
        var length = numberLength
        while index < lines.count {
          let candidate = lines[index].trimmingCharacters(in: .whitespaces)
          guard let currentLength = orderedMarkerLength(candidate) else { break }
          length = currentLength
          items.append(String(candidate.dropFirst(length)).trimmingCharacters(in: .whitespaces))
          index += 1
        }
        blocks.append(.orderedList(items))
        continue
      }

      paragraph.append(trimmed)
      index += 1
    }

    flushParagraph()
    return blocks
  }

  private static func quoteBlock(from lines: [String]) -> MarkdownBlock {
    guard let first = lines.first,
      first.hasPrefix("[!"),
      let closing = first.firstIndex(of: "]"),
      let kind = MarkdownCalloutKind(
        rawValue: String(first[first.index(first.startIndex, offsetBy: 2)..<closing])
      )
    else {
      return .quote(lines.filter { !$0.isEmpty })
    }
    return .callout(kind: kind, lines: Array(lines.dropFirst()).filter { !$0.isEmpty })
  }

  /// `- ` veya `* ` madde işareti. `-` ile başlayan ama boşluk içermeyen
  /// satırlar (örneğin `--foo`) madde sayılmaz.
  private static func bulletMarker(_ line: String) -> String? {
    for marker in ["- ", "* "] where line.hasPrefix(marker) {
      return marker
    }
    return nil
  }

  /// `12. ` biçimindeki işaretin uzunluğu.
  private static func orderedMarkerLength(_ line: String) -> Int? {
    let digits = line.prefix(while: \.isNumber)
    guard !digits.isEmpty else { return nil }
    let rest = line.dropFirst(digits.count)
    guard rest.hasPrefix(". ") else { return nil }
    return digits.count + 2
  }

  private static func isTableRow(_ line: String) -> Bool {
    line.hasPrefix("|") && line.hasSuffix("|") && line.count > 1
  }

  private static func isTableSeparator(_ line: String) -> Bool {
    guard isTableRow(line) else { return false }
    return tableCells(line).allSatisfy { cell in
      !cell.isEmpty && cell.allSatisfy { $0 == "-" || $0 == ":" || $0 == " " }
    }
  }

  private static func tableCells(_ line: String) -> [String] {
    line.dropFirst().dropLast()
      .components(separatedBy: "|")
      .map { $0.trimmingCharacters(in: .whitespaces) }
  }
}

/// Front matter değeri: tek değer ya da liste.
public enum MarkdownValue: Equatable, Sendable {
  case scalar(String)
  case list([String])

  public var stringValue: String? {
    if case .scalar(let value) = self { return value }
    return nil
  }

  public var intValue: Int? {
    stringValue.flatMap(Int.init)
  }

  public var listValue: [String] {
    switch self {
    case .list(let items): return items
    case .scalar(let value): return [value]
    }
  }
}
