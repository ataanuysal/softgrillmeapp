import SwiftUI

struct ScaledFontModifier: ViewModifier {
  @ScaledMetric private var scaledSize: CGFloat = 17
  let weight: Font.Weight
  let design: Font.Design

  init(
    size: CGFloat,
    weight: Font.Weight,
    design: Font.Design
  ) {
    let relativeStyle: Font.TextStyle =
      if size >= 28 {
        .largeTitle
      } else if size >= 20 {
        .title2
      } else if size >= 15 {
        .body
      } else {
        .caption
      }
    _scaledSize = ScaledMetric(wrappedValue: size, relativeTo: relativeStyle)
    self.weight = weight
    self.design = design
  }

  func body(content: Content) -> some View {
    content.font(.system(size: scaledSize, weight: weight, design: design))
  }
}

extension View {
  func adaptiveFont(
    size: CGFloat,
    weight: Font.Weight = .regular,
    design: Font.Design = .default
  ) -> some View {
    modifier(ScaledFontModifier(size: size, weight: weight, design: design))
  }
}

/// VS Code Dark+ paletinin uygulamadaki karşılığı.
///
/// Ürün bir kod okuma laboratuvarı; arayüzün bir editöre benzemesi tesadüf
/// değil, öğrencinin ileride karşılaşacağı ortamı tanıtan bilinçli bir seçim.
enum AppPalette {
  /// Editör zemini.
  static let background = Color(hex: 0x1E1E1E)
  /// Kenar çubuğu ve kart zemini.
  static let panel = Color(hex: 0x252526)
  /// Sekme çubuğu ve kart başlığı.
  static let card = Color(hex: 0x2D2D2D)
  /// Aktivite çubuğu.
  static let rail = Color(hex: 0x2B2B2B)
  /// Girdi alanı zemini.
  static let input = Color(hex: 0x3C3C3C)
  static let codeBackground = Color(hex: 0x1E1E1E)
  static let border = Color(hex: 0x333333)
  static let strongBorder = Color(hex: 0x3C3C3C)

  /// Birincil eylem, ilerleme ve aktif satır.
  static let accent = Color(hex: 0x007ACC)
  /// Bağlantı ve vurgulu ikon.
  static let link = Color(hex: 0x4FC1FF)
  /// Mentor ve akış kontrolü.
  static let mentor = Color(hex: 0xC586C0)
  /// Uyarı, ipucu ve "aklında kalsın".
  static let highlight = Color(hex: 0xDCDCAA)
  /// Başarı zemini.
  static let success = Color(hex: 0x237A3A)
  /// Doğru cevap ve bellek göstergesi.
  static let successText = Color(hex: 0x4EC9B0)
  /// Hata ve "sık hata".
  static let danger = Color(hex: 0xF14C4C)
  /// Klasör adı.
  static let folder = Color(hex: 0x9CDCFE)

  static let primaryText = Color(hex: 0xE6E6E6)
  static let secondaryText = Color(hex: 0x858585)
  static let tertiaryText = Color(hex: 0x6A6A6A)
}

extension Color {
  fileprivate init(hex: UInt32) {
    self.init(
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255
    )
  }
}

extension CodeTokenKind {
  /// Dark+ sözdizimi renkleri.
  var color: Color {
    switch self {
    case .keyword: AppPalette.link.opacity(0.92)
    case .controlFlow: AppPalette.mentor
    case .string: Color(hex: 0xCE9178)
    case .number: Color(hex: 0xB5CEA8)
    case .function: AppPalette.highlight
    case .type: AppPalette.successText
    case .variable: AppPalette.folder
    case .comment: Color(hex: 0x6A9955)
    case .plain: AppPalette.primaryText
    }
  }
}

/// Bir kod satırını sözdizimi renkleriyle yazar.
struct HighlightedCodeText: View {
  let line: String
  let language: CodeLanguage

  var body: some View {
    CodeHighlighter.tokens(in: line, language: language)
      .enumerated()
      .reduce(Text("")) { partial, item in
        partial + Text(item.element.text).foregroundColor(item.element.kind.color)
      }
  }
}

/// Editör alt bilgi çubuğu.
///
/// Tamamlanan derste yeşile döner; bu, rengin yanında metin de değiştiği için
/// yalnızca renge dayanan bir işaret değildir.
struct IDEStatusBar: View {
  let leading: String
  let trailing: String
  var tone: Tone = .normal

  enum Tone {
    case normal
    case success
  }

  var body: some View {
    HStack(spacing: 12) {
      Text(leading)
      Spacer(minLength: 8)
      Text(trailing)
    }
    .adaptiveFont(size: 11, weight: .semibold, design: .monospaced)
    .foregroundStyle(.white)
    .lineLimit(1)
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
    .frame(maxWidth: .infinity)
    .background(tone == .success ? AppPalette.success : AppPalette.accent)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Durum: \(leading), \(trailing)")
  }
}

/// Editör sekme çubuğu. Aktif sekme üstten mavi çizgiyle işaretlenir.
struct EditorTabBar: View {
  struct Tab: Identifiable {
    let id = UUID()
    let title: String
    var isActive: Bool = false
    var dotColor: Color?
    var badge: String?
  }

  let tabs: [Tab]

  var body: some View {
    HStack(spacing: 0) {
      ForEach(tabs) { tab in
        HStack(spacing: 7) {
          if let dotColor = tab.dotColor {
            Circle().fill(dotColor).frame(width: 7, height: 7)
          }
          Text(tab.title)
            .adaptiveFont(size: 12, weight: .medium, design: .monospaced)
            .lineLimit(1)
            .truncationMode(.middle)
          if let badge = tab.badge {
            Text(badge)
              .adaptiveFont(size: 11, weight: .bold, design: .monospaced)
              .foregroundStyle(AppPalette.highlight)
          }
        }
        .foregroundStyle(tab.isActive ? AppPalette.primaryText : AppPalette.secondaryText)
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .frame(maxHeight: .infinity)
        .background(tab.isActive ? AppPalette.background : Color.clear)
        .overlay(alignment: .top) {
          Rectangle()
            .fill(tab.isActive ? AppPalette.accent : Color.clear)
            .frame(height: 1.5)
        }
        .overlay(alignment: .trailing) {
          Rectangle().fill(AppPalette.background).frame(width: 1)
        }
      }
      Spacer(minLength: 0)
    }
    .frame(height: 38)
    .background(AppPalette.panel)
    .accessibilityHidden(true)
  }
}

/// Dosya gezginindeki klasör satırı.
struct FolderHeader: View {
  let name: String
  let count: Int
  var isOpen = true
  var tint: Color = AppPalette.folder

  var body: some View {
    HStack(spacing: 8) {
      Image(systemName: isOpen ? "chevron.down" : "chevron.right")
        .adaptiveFont(size: 11, weight: .bold)
      Text(name)
        .adaptiveFont(size: 12, weight: .bold, design: .monospaced)
      Text("\(count)")
        .adaptiveFont(size: 12, weight: .medium, design: .monospaced)
        .foregroundStyle(AppPalette.tertiaryText)
      Spacer(minLength: 0)
    }
    .foregroundStyle(tint)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(name) bölümü, \(count) ders")
  }
}

/// Editör uyarı çubuğu: sol kenarı renkli, başlığı yorum satırı biçiminde.
struct IDECallout: View {
  let title: String
  let message: String
  let tint: Color
  let systemImage: String
  var filled = false

  var body: some View {
    HStack(alignment: .top, spacing: 10) {
      Image(systemName: systemImage)
        .adaptiveFont(size: 15, weight: .semibold)
        .foregroundStyle(tint)
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .adaptiveFont(size: 10, weight: .bold, design: .monospaced)
          .foregroundStyle(tint)
        Text(message)
          .adaptiveFont(size: 14, weight: .medium)
          .foregroundStyle(AppPalette.primaryText)
          .fixedSize(horizontal: false, vertical: true)
      }
      Spacer(minLength: 0)
    }
    .padding(13)
    .background(filled ? tint.opacity(0.08) : AppPalette.background)
    .overlay(alignment: .leading) {
      Rectangle().fill(tint).frame(width: 2)
    }
    .clipShape(UnevenRoundedRectangle(bottomTrailingRadius: 8, topTrailingRadius: 8))
    .accessibilityElement(children: .combine)
  }
}

/// Konu → Örnek → Quiz ilerleme göstergesi.
struct JourneyStepper: View {
  let currentStep: Int
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  private let titles = ["Konu", "Örnek", "Quiz"]

  var body: some View {
    HStack(spacing: 7) {
      ForEach(Array(titles.enumerated()), id: \.offset) { index, title in
        if index > 0 {
          Image(systemName: "chevron.right")
            .adaptiveFont(size: 10, weight: .black)
            .foregroundStyle(AppPalette.border)
        }
        HStack(spacing: 6) {
          badge(for: index)
          if !dynamicTypeSize.isAccessibilitySize || index == currentStep {
            Text(title)
              .adaptiveFont(size: 11, weight: .bold)
              .foregroundStyle(
                index == currentStep ? AppPalette.primaryText : AppPalette.secondaryText
              )
          }
        }
      }
      Spacer(minLength: 0)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Adım \(currentStep + 1) / 3: \(titles[min(currentStep, 2)])")
  }

  @ViewBuilder
  private func badge(for index: Int) -> some View {
    let isDone = index < currentStep
    let isCurrent = index == currentStep
    ZStack {
      Circle()
        .fill(
          isDone
            ? AppPalette.success
            : (isCurrent ? stepColor(index) : AppPalette.border)
        )
      if isDone {
        Image(systemName: "checkmark")
          .adaptiveFont(size: 9, weight: .black)
          .foregroundStyle(.white)
      } else {
        Text("\(index + 1)")
          .adaptiveFont(size: 10, weight: .black, design: .monospaced)
          .foregroundStyle(isCurrent ? .white : AppPalette.secondaryText)
      }
    }
    .frame(width: 20, height: 20)
  }

  private func stepColor(_ index: Int) -> Color {
    index == 2 ? AppPalette.mentor : AppPalette.accent
  }
}
