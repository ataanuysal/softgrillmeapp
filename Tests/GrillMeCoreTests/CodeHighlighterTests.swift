import Testing

@testable import GrillMeCore

@Suite("Sözdizimi renklendirme")
struct CodeHighlighterTests {
  @Test("Anahtar kelime, değişken ve sayı ayrı ayrı işaretlenir")
  func marksDeclarationLine() {
    let tokens = CodeHighlighter.tokens(in: "var puan = 10")

    #expect(kinds(of: tokens, matching: "var") == [.keyword])
    #expect(kinds(of: tokens, matching: "puan") == [.variable])
    #expect(kinds(of: tokens, matching: "10") == [.number])
  }

  @Test("Kelime içinde geçen anahtar kelime boyanmaz")
  func doesNotMatchKeywordsInsideIdentifiers() {
    // Eski uygulama `range(of: "in")` kullandığı için "print" içindeki "in"i
    // anahtar kelime sayıyordu.
    let tokens = CodeHighlighter.tokens(in: "print(puan)")

    #expect(kinds(of: tokens, matching: "print") == [.function])
    #expect(!tokens.contains { $0.text == "in" })
  }

  @Test("Kontrol akışı anahtar kelimeleri tanımlardan ayrılır")
  func separatesControlFlowFromDeclarations() {
    let tokens = CodeHighlighter.tokens(in: "if puan > 5 {")

    #expect(kinds(of: tokens, matching: "if") == [.controlFlow])
  }

  @Test("Metin ve yorum satır sonuna kadar tek parça kalır")
  func keepsStringsAndCommentsWhole() {
    let string = CodeHighlighter.tokens(in: "let ad = \"Ada Lovelace\"")
    let comment = CodeHighlighter.tokens(in: "let x = 1 // burası yorum")

    #expect(string.contains(CodeToken("\"Ada Lovelace\"", .string)))
    #expect(comment.contains(CodeToken("// burası yorum", .comment)))
  }

  @Test("Büyük harfle başlayan ad tür, çağrılan ad fonksiyon sayılır")
  func distinguishesTypesFromCalls() {
    let tokens = CodeHighlighter.tokens(in: "let kutu = Kutu()")
    let call = CodeHighlighter.tokens(in: "topla(3)")

    #expect(kinds(of: tokens, matching: "Kutu") == [.type])
    #expect(kinds(of: call, matching: "topla") == [.function])
  }

  @Test("Python yorumu ve tanımı kendi sözdizimine göre okunur")
  func readsPythonSyntax() {
    let comment = CodeHighlighter.tokens(in: "# python yorumu", language: .python)
    let definition = CodeHighlighter.tokens(in: "def topla(son):", language: .python)

    #expect(comment == [CodeToken("# python yorumu", .comment)])
    #expect(kinds(of: definition, matching: "def") == [.keyword])
    #expect(kinds(of: definition, matching: "topla") == [.function])
  }

  @Test("Diziye çevrilen satır aynen geri birleştirilebilir")
  func preservesTheOriginalLine() {
    let line = "    puan = puan + 2  // iki artar"

    let rebuilt = CodeHighlighter.tokens(in: line).map(\.text).joined()

    #expect(rebuilt == line)
  }

  private func kinds(of tokens: [CodeToken], matching text: String) -> [CodeTokenKind] {
    tokens.filter { $0.text == text }.map(\.kind)
  }
}
