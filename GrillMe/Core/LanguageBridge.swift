public enum CodeLanguage: String, Codable, CaseIterable, Equatable, Sendable {
  case swift
  case python
  case javascript
  case java
}

public struct CodeVariant: Equatable, Sendable {
  public let language: CodeLanguage
  public let code: [CodeLine]

  public init(language: CodeLanguage, lines: [String]) {
    self.language = language
    code = lines.enumerated().map {
      CodeLine(number: $0.offset + 1, text: $0.element)
    }
  }
}

public struct LanguageComparison: Equatable, Sendable {
  public let invariant: String
  public let syntaxDifferences: [CodeLanguage: String]

  public init(
    invariant: String,
    syntaxDifferences: [CodeLanguage: String]
  ) {
    self.invariant = invariant
    self.syntaxDifferences = syntaxDifferences
  }
}
