import SwiftUI

// Editör görünümleri: satır numaralı kod kartı ve yürütme adımı paneli.

struct CodeCard: View {
  let lines: [CodeLine]
  let activeLineNumber: Int?
  let languageLabel: String
  let language: CodeLanguage

  init(
    lines: [CodeLine],
    activeLineNumber: Int?,
    languageLabel: String = "SWIFT",
    language: CodeLanguage = .swift
  ) {
    self.lines = lines
    self.activeLineNumber = activeLineNumber
    self.languageLabel = languageLabel
    self.language = language
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 7) {
        Circle().fill(AppPalette.danger).frame(width: 8, height: 8)
        Circle().fill(AppPalette.highlight).frame(width: 8, height: 8)
        Circle().fill(AppPalette.successText).frame(width: 8, height: 8)

        Spacer()

        Text(languageLabel)
          .adaptiveFont(size: 10, weight: .bold, design: .monospaced)
          .tracking(0.8)
          .foregroundStyle(AppPalette.secondaryText)
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 10)
      .background(AppPalette.card)

      ScrollView(.horizontal) {
        VStack(alignment: .leading, spacing: 0) {
          ForEach(lines, id: \.number) { line in
            codeRow(line)
          }
        }
        .frame(minWidth: 300, alignment: .leading)
        .padding(.vertical, 8)
      }
      .scrollIndicators(.visible)
    }
    .background(AppPalette.codeBackground)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(AppPalette.border, lineWidth: 1)
    )
  }

  /// Satır numarası editördeki gutter'ı taklit eder; aktif satır hem zemin
  /// rengiyle hem sol kenar çizgisiyle işaretlenir, yani yalnızca renge
  /// dayanmaz.
  private func codeRow(_ line: CodeLine) -> some View {
    let isActive = activeLineNumber == line.number
    return HStack(alignment: .top, spacing: 14) {
      Text("\(line.number)")
        .adaptiveFont(size: 13, design: .monospaced)
        .foregroundStyle(isActive ? AppPalette.link : AppPalette.border)
        .frame(width: 20, alignment: .trailing)

      HighlightedCodeText(line: line.text, language: language)
        .adaptiveFont(size: 14, weight: .medium, design: .monospaced)
        .fixedSize(horizontal: true, vertical: false)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(isActive ? AppPalette.accent.opacity(0.14) : Color.clear)
    .overlay(alignment: .leading) {
      if isActive {
        Rectangle().fill(AppPalette.accent).frame(width: 3)
      }
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(
      isActive
        ? "Çalışan satır \(line.number): \(line.text)"
        : "Satır \(line.number): \(line.text)"
    )
  }
}

struct TraceInspector: View {
  let step: TraceStep

  var body: some View {
    VStack(alignment: .leading, spacing: 18) {
      HStack {
        Label("SATIR \(step.lineNumber)", systemImage: "play.fill")
          .adaptiveFont(size: 12, weight: .bold, design: .default)
          .tracking(0.8)
          .foregroundStyle(AppPalette.accent)
        Spacer()
        Text("Şu an çalışıyor")
          .adaptiveFont(size: 12, weight: .medium, design: .default)
          .foregroundStyle(AppPalette.secondaryText)
      }

      Text(step.explanation)
        .adaptiveFont(size: 17, weight: .semibold, design: .default)
        .foregroundStyle(.white)
        .fixedSize(horizontal: false, vertical: true)

      Divider()
        .overlay(AppPalette.border)

      HStack(alignment: .top, spacing: 12) {
        inspectorBox(
          title: "HAFIZA",
          icon: "memorychip",
          value: memoryDescription,
          accent: AppPalette.mentor
        )

        inspectorBox(
          title: "ÇIKTI",
          icon: "terminal",
          value: step.output ?? "—",
          accent: step.output == nil ? AppPalette.tertiaryText : AppPalette.accent
        )
      }

      if !step.callStack.isEmpty {
        VStack(alignment: .leading, spacing: 10) {
          Label("ÇAĞRI YIĞINI", systemImage: "square.3.layers.3d")
            .adaptiveFont(size: 10, weight: .bold, design: .default)
            .tracking(0.8)
            .foregroundStyle(AppPalette.secondaryText)

          ForEach(Array(step.callStack.enumerated()), id: \.offset) { index, frame in
            HStack(alignment: .top, spacing: 10) {
              Text("\(index + 1)")
                .adaptiveFont(size: 11, weight: .bold, design: .monospaced)
                .foregroundStyle(AppPalette.mentor)
                .frame(width: 22, height: 22)
                .background(AppPalette.mentor.opacity(0.12), in: Circle())

              VStack(alignment: .leading, spacing: 3) {
                Text(frame.functionName)
                  .adaptiveFont(size: 14, weight: .bold, design: .monospaced)
                  .foregroundStyle(.white)
                if !frame.locals.isEmpty {
                  Text(
                    frame.locals
                      .sorted { $0.key < $1.key }
                      .map { "\($0.key) = \($0.value)" }
                      .joined(separator: " · ")
                  )
                  .adaptiveFont(size: 11, design: .monospaced)
                  .foregroundStyle(AppPalette.secondaryText)
                }
              }
            }
          }
        }
        .padding(14)
        .background(AppPalette.codeBackground, in: RoundedRectangle(cornerRadius: 15))
      }

      if let architecture = step.architecture {
        VStack(alignment: .leading, spacing: 10) {
          Label("MİMARİ", systemImage: "point.3.connected.trianglepath.dotted")
            .adaptiveFont(size: 10, weight: .bold, design: .default)
            .tracking(0.8)
            .foregroundStyle(AppPalette.secondaryText)

          ForEach(Array(architecture.relationships.enumerated()), id: \.offset) { _, relation in
            let source =
              architecture.entities.first(where: { $0.id == relation.sourceID })?.label
              ?? relation.sourceID
            let target =
              architecture.entities.first(where: { $0.id == relation.targetID })?.label
              ?? relation.targetID

            HStack(spacing: 8) {
              Text(source)
                .foregroundStyle(AppPalette.mentor)
              Image(systemName: "arrow.right")
                .foregroundStyle(AppPalette.tertiaryText)
              Text(relation.label)
                .foregroundStyle(AppPalette.secondaryText)
              Image(systemName: "arrow.right")
                .foregroundStyle(AppPalette.tertiaryText)
              Text(target)
                .foregroundStyle(AppPalette.accent)
            }
            .adaptiveFont(size: 11, weight: .semibold, design: .default)
          }
        }
        .padding(14)
        .background(AppPalette.codeBackground, in: RoundedRectangle(cornerRadius: 15))
      }
    }
    .padding(20)
    .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 24))
    .overlay(
      RoundedRectangle(cornerRadius: 24)
        .stroke(AppPalette.border, lineWidth: 1)
    )
  }

  private var memoryDescription: String {
    step.memory
      .sorted { $0.key < $1.key }
      .map { "\($0.key) = \($0.value)" }
      .joined(separator: "\n")
  }

  private func inspectorBox(
    title: String,
    icon: String,
    value: String,
    accent: Color
  ) -> some View {
    VStack(alignment: .leading, spacing: 9) {
      Label(title, systemImage: icon)
        .adaptiveFont(size: 10, weight: .bold, design: .default)
        .tracking(0.8)
        .foregroundStyle(AppPalette.secondaryText)

      Text(value)
        .adaptiveFont(size: 16, weight: .bold, design: .monospaced)
        .foregroundStyle(accent)
        .lineLimit(2)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(14)
    .background(AppPalette.codeBackground, in: RoundedRectangle(cornerRadius: 15))
  }
}
