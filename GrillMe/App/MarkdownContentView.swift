import SwiftUI

/// Ders gövdesini oluşturan Markdown bloklarını çizer.
///
/// Ayrıştırma `Core` tarafında yapılır; burada yalnızca blok başına yerleşim
/// vardır. Geniş içerik (tablo, kod) kendi içinde yatay kaydırılır, sayfa
/// gövdesi hiçbir zaman yatay kaymaz.
struct MarkdownContentView: View {
  let blocks: [MarkdownBlock]

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
        MarkdownBlockView(block: block)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct MarkdownBlockView: View {
  let block: MarkdownBlock
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    switch block {
    case .heading(let level, let text):
      Text(text)
        .adaptiveFont(size: headingSize(level), weight: .bold)
        .foregroundStyle(level <= 2 ? AppPalette.primaryText : AppPalette.folder)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, level <= 2 ? 8 : 2)
        .accessibilityAddTraits(.isHeader)

    case .paragraph(let text):
      inlineText(text)
        .adaptiveFont(size: 15)
        .foregroundStyle(AppPalette.primaryText)
        .lineSpacing(4)
        .fixedSize(horizontal: false, vertical: true)

    case .bulletList(let items):
      VStack(alignment: .leading, spacing: 9) {
        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
          listRow(marker: "•", text: item)
        }
      }

    case .orderedList(let items):
      VStack(alignment: .leading, spacing: 9) {
        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
          listRow(marker: "\(index + 1).", text: item)
        }
      }

    case .table(let headers, let rows):
      MarkdownTableView(headers: headers, rows: rows)

    case .codeBlock(let language, let lines):
      MarkdownCodeView(language: language, lines: lines)

    case .callout(let kind, let lines):
      IDECallout(
        title: kind.title.uppercased(with: Locale(identifier: "tr_TR")),
        message: lines.joined(separator: " "),
        tint: tint(for: kind),
        systemImage: icon(for: kind),
        filled: true
      )

    case .quote(let lines):
      inlineText(lines.joined(separator: " "))
        .adaptiveFont(size: 15)
        .foregroundStyle(AppPalette.secondaryText)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.leading, 12)
        .overlay(alignment: .leading) {
          Rectangle().fill(AppPalette.border).frame(width: 2)
        }

    case .divider:
      Rectangle()
        .fill(AppPalette.border)
        .frame(height: 1)
        .accessibilityHidden(true)
    }
  }

  private func listRow(marker: String, text: String) -> some View {
    HStack(alignment: .firstTextBaseline, spacing: 9) {
      Text(marker)
        .adaptiveFont(size: 14, weight: .bold, design: .monospaced)
        .foregroundStyle(AppPalette.accent)
      inlineText(text)
        .adaptiveFont(size: 15)
        .foregroundStyle(AppPalette.primaryText)
        .fixedSize(horizontal: false, vertical: true)
    }
    .accessibilityElement(children: .combine)
  }

  /// Satır içi kalın, kod ve bağlantı işaretlerini çözer.
  private func inlineText(_ text: String) -> Text {
    guard
      let attributed = try? AttributedString(
        markdown: text,
        options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
      )
    else {
      return Text(text)
    }
    return Text(attributed)
  }

  private func headingSize(_ level: Int) -> CGFloat {
    switch level {
    case 1: return 26
    case 2: return 20
    case 3: return 17
    default: return 15
    }
  }

  private func tint(for kind: MarkdownCalloutKind) -> Color {
    switch kind {
    case .note: return AppPalette.link
    case .tip: return AppPalette.successText
    case .warning: return AppPalette.danger
    }
  }

  private func icon(for kind: MarkdownCalloutKind) -> String {
    switch kind {
    case .note: return "info.circle.fill"
    case .tip: return "lightbulb.fill"
    case .warning: return "exclamationmark.triangle.fill"
    }
  }
}

/// Sözde kod ve örnek blokları. Satırlar sarılmaz, blok yatay kaydırılır.
private struct MarkdownCodeView: View {
  let language: String?
  let lines: [String]

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      if let language, !language.isEmpty {
        Text(language)
          .adaptiveFont(size: 10, weight: .bold, design: .monospaced)
          .foregroundStyle(AppPalette.tertiaryText)
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(AppPalette.card)
      }

      ScrollView(.horizontal) {
        VStack(alignment: .leading, spacing: 3) {
          ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
            Text(line.isEmpty ? " " : line)
              .adaptiveFont(size: 13, design: .monospaced)
              .foregroundStyle(AppPalette.primaryText)
              .textSelection(.enabled)
          }
        }
        .padding(12)
      }
      .scrollIndicators(.hidden)
    }
    .background(AppPalette.codeBackground)
    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppPalette.border, lineWidth: 1))
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Kod bloğu: \(lines.joined(separator: ", "))")
  }
}

/// Ders tabloları. Erişilebilir yazı boyutlarında tablo tek sütunlu kartlara
/// dönüşür; yan yana sıkışan hücreler o boyutta okunamıyordu.
private struct MarkdownTableView: View {
  let headers: [String]
  let rows: [[String]]
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    if dynamicTypeSize.isAccessibilitySize {
      VStack(alignment: .leading, spacing: 12) {
        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
          VStack(alignment: .leading, spacing: 5) {
            ForEach(Array(row.enumerated()), id: \.offset) { index, cell in
              HStack(alignment: .firstTextBaseline, spacing: 6) {
                if index < headers.count, !headers[index].isEmpty {
                  Text("\(headers[index]):")
                    .adaptiveFont(size: 13, weight: .bold)
                    .foregroundStyle(AppPalette.folder)
                }
                Text(cell)
                  .adaptiveFont(size: 14)
                  .foregroundStyle(AppPalette.primaryText)
                  .fixedSize(horizontal: false, vertical: true)
              }
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(12)
          .background(AppPalette.card, in: RoundedRectangle(cornerRadius: 10))
        }
      }
    } else {
      ScrollView(.horizontal) {
        VStack(alignment: .leading, spacing: 0) {
          tableRow(headers, isHeader: true)
          ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
            Divider().overlay(AppPalette.border)
            tableRow(row, isHeader: false, isAlternate: index.isMultiple(of: 2))
          }
        }
        .background(AppPalette.card)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppPalette.border, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
      }
      .scrollIndicators(.hidden)
    }
  }

  private func tableRow(
    _ cells: [String],
    isHeader: Bool,
    isAlternate: Bool = false
  ) -> some View {
    HStack(alignment: .top, spacing: 0) {
      ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
        Text(cell)
          .adaptiveFont(size: 13, weight: isHeader ? .bold : .regular)
          .foregroundStyle(isHeader ? AppPalette.folder : AppPalette.primaryText)
          .frame(width: 170, alignment: .leading)
          .fixedSize(horizontal: false, vertical: true)
          .padding(.horizontal, 12)
          .padding(.vertical, 10)
      }
    }
    .background(isHeader ? AppPalette.panel : (isAlternate ? Color.clear : AppPalette.background))
    .accessibilityElement(children: .combine)
  }
}
