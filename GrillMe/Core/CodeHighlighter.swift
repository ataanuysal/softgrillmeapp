/// Bir kod parçasının sözdizimindeki rolü.
///
/// Renkler `App` katmanında seçilir; `Core` yalnızca hangi parçanın ne olduğunu
/// söyler. Böylece kural değişikliği testlenebilir kalır.
public enum CodeTokenKind: String, Equatable, Sendable, CaseIterable {
  case plain
  case keyword
  case controlFlow
  case string
  case number
  case function
  case type
  case variable
  case comment
}

public struct CodeToken: Equatable, Sendable {
  public let text: String
  public let kind: CodeTokenKind

  public init(_ text: String, _ kind: CodeTokenKind) {
    self.text = text
    self.kind = kind
  }
}

/// Ders kodunu satır satır anlamlı parçalara ayırır.
///
/// Kelime sınırına bakmayan bir arama "print" içindeki "in"i anahtar kelime
/// sayar. Bu tip önce kelimeyi bütün olarak toplar, sonra rolünü belirler.
public enum CodeHighlighter {
  private static let declarationKeywords: Set<String> = [
    "var", "let", "func", "return", "class", "struct", "protocol", "extension", "init",
    "self", "static", "override", "guard", "import", "true", "false", "nil",
    "def", "None", "True", "False", "lambda",
    "const", "function", "new", "null", "undefined",
    "int", "boolean", "void", "public", "private", "String",
  ]

  private static let controlKeywords: Set<String> = [
    "if", "else", "elif", "for", "in", "while", "switch", "case", "default",
    "break", "continue", "do", "try", "catch", "throw", "throws",
    "async", "await", "defer",
  ]

  public static func tokens(
    in line: String,
    language: CodeLanguage = .swift
  ) -> [CodeToken] {
    var tokens: [CodeToken] = []
    var index = line.startIndex

    func append(_ text: String, _ kind: CodeTokenKind) {
      guard !text.isEmpty else { return }
      // Bitişik düz parçalar tek token'da birleşir; render tarafı daha az
      // parça çizer ve satır aynen geri birleştirilebilir kalır.
      if kind == .plain, let last = tokens.last, last.kind == .plain {
        tokens[tokens.count - 1] = CodeToken(last.text + text, .plain)
      } else {
        tokens.append(CodeToken(text, kind))
      }
    }

    while index < line.endIndex {
      let character = line[index]

      if startsComment(at: index, in: line, language: language) {
        append(String(line[index...]), .comment)
        break
      }

      if character == "\"" {
        let closing = line[line.index(after: index)...].firstIndex(of: "\"")
        let stop = closing.map(line.index(after:)) ?? line.endIndex
        append(String(line[index..<stop]), .string)
        index = stop
        continue
      }

      if character.isNumber {
        var cursor = index
        while cursor < line.endIndex, line[cursor].isNumber || line[cursor] == "." {
          cursor = line.index(after: cursor)
        }
        append(String(line[index..<cursor]), .number)
        index = cursor
        continue
      }

      if character.isLetter || character == "_" {
        var cursor = index
        while cursor < line.endIndex, isIdentifier(line[cursor]) {
          cursor = line.index(after: cursor)
        }
        let word = String(line[index..<cursor])
        append(word, kind(of: word, callsSomething: line[cursor...].first == "("))
        index = cursor
        continue
      }

      append(String(character), .plain)
      index = line.index(after: index)
    }

    return tokens
  }

  private static func isIdentifier(_ character: Character) -> Bool {
    character.isLetter || character.isNumber || character == "_"
  }

  private static func startsComment(
    at index: String.Index,
    in line: String,
    language: CodeLanguage
  ) -> Bool {
    if language == .python {
      return line[index] == "#"
    }
    guard line[index] == "/" else { return false }
    let next = line.index(after: index)
    return next < line.endIndex && line[next] == "/"
  }

  private static func kind(of word: String, callsSomething: Bool) -> CodeTokenKind {
    if controlKeywords.contains(word) { return .controlFlow }
    if declarationKeywords.contains(word) { return .keyword }
    // Tür adı çağrılsa bile tür kalır: `Kutu()` bir initializer'dır.
    if word.first?.isUppercase == true { return .type }
    return callsSomething ? .function : .variable
  }
}
