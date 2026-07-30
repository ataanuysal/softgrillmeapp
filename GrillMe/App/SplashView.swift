import SwiftUI

/// Uygulama ikonundaki `</>` işareti.
///
/// Açılış ekranı ve yol haritası başlığı aynı işareti kullanır; marka tek bir
/// yerde tanımlı kalır.
struct AppIconMark: View {
  var glyphSize: CGFloat = 34
  var showsCursor = true

  private var cursorWidth: CGFloat { glyphSize * 0.12 }
  private var cursorHeight: CGFloat { glyphSize * 0.94 }

  var body: some View {
    HStack(spacing: glyphSize * 0.06) {
      Text("<").foregroundStyle(Color(red: 0.337, green: 0.612, blue: 0.839))
      Text("/").foregroundStyle(AppPalette.successText)
      Text(">").foregroundStyle(Color(red: 0.337, green: 0.612, blue: 0.839))
      if showsCursor {
        RoundedRectangle(cornerRadius: cursorWidth / 2.5)
          .fill(AppPalette.accent)
          .frame(width: cursorWidth, height: cursorHeight)
          .padding(.leading, glyphSize * 0.09)
      }
    }
    .adaptiveFont(size: glyphSize, weight: .heavy, design: .monospaced)
    .accessibilityHidden(true)
  }
}

/// İkonun kendi yüzeyi: koyu editör zemini ve köşeden gelen ışık.
struct AppIconTile: View {
  var size: CGFloat = 104

  var body: some View {
    RoundedRectangle(cornerRadius: size * 0.25, style: .continuous)
      .fill(
        RadialGradient(
          colors: [
            Color(red: 0.106, green: 0.153, blue: 0.200),
            Color(red: 0.051, green: 0.055, blue: 0.067),
          ],
          center: UnitPoint(x: 0.3, y: 0.2),
          startRadius: 0,
          endRadius: size
        )
      )
      .overlay(
        RoundedRectangle(cornerRadius: size * 0.25, style: .continuous)
          .stroke(Color.white.opacity(0.05), lineWidth: 1)
      )
      .overlay(AppIconMark(glyphSize: size * 0.33))
      .frame(width: size, height: size)
  }
}

/// Açılış ekranı: IDE'nin çalışma alanını açması.
///
/// İlerleme çubuğu süsleme değil; arkasında gerçekten cihazdaki ilerleme
/// dosyası okunuyor. Çubuk, okuma bitene kadar görünür kalır.
struct SplashView: View {
  let versionLabel: String

  @State private var barProgress: CGFloat = 0.08
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    VStack(spacing: 0) {
      Spacer()

      AppIconTile(size: 104)
        .shadow(color: AppPalette.accent.opacity(0.5), radius: 26, y: 14)
        .padding(.bottom, 26)

      Text("GrillMe")
        .adaptiveFont(size: 26, weight: .heavy, design: .monospaced)
        .foregroundStyle(.white)

      Text("// kod okuma laboratuvarı")
        .adaptiveFont(size: 12, design: .monospaced)
        .foregroundStyle(CodeTokenKind.comment.color)
        .padding(.top, 6)

      progressBar
        .padding(.top, 40)

      Text("workspace yükleniyor…")
        .adaptiveFont(size: 10, design: .monospaced)
        .foregroundStyle(AppPalette.tertiaryText)
        .padding(.top, 12)

      Spacer()

      IDEStatusBar(leading: "main", trailing: versionLabel)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
      Color(red: 0.051, green: 0.055, blue: 0.067)
        .overlay(
          RadialGradient(
            colors: [AppPalette.accent.opacity(0.16), .clear],
            center: UnitPoint(x: 0.5, y: 0.42),
            startRadius: 0,
            endRadius: 320
          )
        )
        .ignoresSafeArea()
    )
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("GrillMe:Code açılıyor. Kaydedilen ilerleme yükleniyor.")
    .onAppear {
      guard !reduceMotion else {
        barProgress = 0.64
        return
      }
      withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
        barProgress = 0.82
      }
    }
  }

  private var progressBar: some View {
    GeometryReader { geometry in
      Capsule()
        .fill(AppPalette.panel)
        .overlay(alignment: .leading) {
          Capsule()
            .fill(
              LinearGradient(
                colors: [AppPalette.accent, AppPalette.successText],
                startPoint: .leading,
                endPoint: .trailing
              )
            )
            .frame(width: geometry.size.width * barProgress)
        }
    }
    .frame(width: 180, height: 4)
  }
}
