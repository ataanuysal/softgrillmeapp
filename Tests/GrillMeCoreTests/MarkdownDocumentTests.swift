import Testing

@testable import GrillMeCore

@Suite("Markdown ayrıştırma")
struct MarkdownDocumentTests {
  @Test("Front matter gövdeden ayrılır ve alanlar okunur")
  func parsesFrontMatterFields() {
    let document = MarkdownDocument.parse(
      """
      ---
      id: orientation-01
      moduleOrder: 0
      title: Yazılım nedir?
      prerequisites: []
      objectives:
        - Birinci kazanım
        - İkinci kazanım
      status: published
      ---

      # Başlık
      """
    )

    #expect(document.frontMatter["id"]?.stringValue == "orientation-01")
    #expect(document.frontMatter["moduleOrder"]?.intValue == 0)
    #expect(document.frontMatter["title"]?.stringValue == "Yazılım nedir?")
    #expect(document.frontMatter["prerequisites"]?.listValue == [])
    #expect(
      document.frontMatter["objectives"]?.listValue == ["Birinci kazanım", "İkinci kazanım"]
    )
    #expect(document.body.hasPrefix("\n# Başlık"))
  }

  @Test("Front matter yoksa dosyanın tamamı gövde sayılır")
  func treatsFileWithoutFrontMatterAsBody() {
    let document = MarkdownDocument.parse("# Yalnızca gövde")

    #expect(document.frontMatter.isEmpty)
    #expect(document.body == "# Yalnızca gövde")
  }

  @Test("Başlık, paragraf ve ayraç blokları üretilir")
  func producesHeadingsAndParagraphs() {
    let blocks = MarkdownDocument.parse(
      """
      # Birinci düzey

      İlk paragrafın
      iki satırı tek bloğa katlanır.

      ## İkinci düzey

      ---
      """
    ).blocks

    #expect(blocks[0] == .heading(level: 1, text: "Birinci düzey"))
    #expect(blocks[1] == .paragraph("İlk paragrafın iki satırı tek bloğa katlanır."))
    #expect(blocks[2] == .heading(level: 2, text: "İkinci düzey"))
    #expect(blocks[3] == .divider)
  }

  @Test("Madde ve numaralı listeler ayrı blok türleridir")
  func producesLists() {
    let blocks = MarkdownDocument.parse(
      """
      - birinci madde
      - ikinci madde

      1. birinci adım
      2. ikinci adım
      """
    ).blocks

    #expect(blocks[0] == .bulletList(["birinci madde", "ikinci madde"]))
    #expect(blocks[1] == .orderedList(["birinci adım", "ikinci adım"]))
  }

  @Test("Tablo başlık ve satırlarına ayrılır")
  func producesTables() {
    let blocks = MarkdownDocument.parse(
      """
      | Terim | İngilizce |
      | --- | --- |
      | Soyutlama | abstraction |
      | Arayüz | interface |
      """
    ).blocks

    #expect(
      blocks == [
        .table(
          headers: ["Terim", "İngilizce"],
          rows: [["Soyutlama", "abstraction"], ["Arayüz", "interface"]]
        )
      ]
    )
  }

  @Test("Kod bloğu dili ve satırları korunur, girinti bozulmaz")
  func producesCodeBlocks() {
    let blocks = MarkdownDocument.parse(
      """
      ```text
      GİRDİ: sayılar
        toplam ← 0
      ```
      """
    ).blocks

    #expect(blocks == [.codeBlock(language: "text", lines: ["GİRDİ: sayılar", "  toplam ← 0"])])
  }

  @Test("Uyarı kutusu türüyle birlikte tanınır, düz alıntıdan ayrılır")
  func producesCalloutsAndQuotes() {
    let blocks = MarkdownDocument.parse(
      """
      > [!WARNING]
      > Sık yapılan hata.

      > Sıradan bir alıntı.
      """
    ).blocks

    #expect(blocks[0] == .callout(kind: .warning, lines: ["Sık yapılan hata."]))
    #expect(blocks[1] == .quote(["Sıradan bir alıntı."]))
  }

  @Test("Kod bloğu içindeki Markdown işaretleri ayrıştırılmaz")
  func doesNotParseMarkdownInsideCode() {
    let blocks = MarkdownDocument.parse(
      """
      ```
      # bu bir başlık değil
      - bu bir madde değil
      ```
      """
    ).blocks

    #expect(
      blocks == [
        .codeBlock(language: nil, lines: ["# bu bir başlık değil", "- bu bir madde değil"])
      ]
    )
  }
}
