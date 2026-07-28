import SwiftUI

struct ContentView: View {
  @State private var session = XRaySession(lesson: .introduction)

  var body: some View {
    ZStack {
      AppPalette.background
        .ignoresSafeArea()

      RadialGradient(
        colors: [AppPalette.indigo.opacity(0.22), .clear],
        center: .topTrailing,
        startRadius: 20,
        endRadius: 380
      )
      .ignoresSafeArea()

      ScrollView {
        VStack(spacing: 24) {
          header
          lessonHeading
          CodeCard(
            lines: session.lesson.code,
            activeLineNumber: session.currentStep?.lineNumber
          )

          switch session.phase {
          case .predicting:
            predictionPanel
          case .tracing, .complete:
            tracePanel
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 40)
      }
      .scrollIndicators(.hidden)
    }
    .tint(AppPalette.mint)
  }

  private var header: some View {
    VStack(spacing: 14) {
      HStack {
        HStack(spacing: 10) {
          Image(systemName: "chevron.left.forwardslash.chevron.right")
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(AppPalette.background)
            .frame(width: 34, height: 34)
            .background(AppPalette.mint, in: RoundedRectangle(cornerRadius: 10))

          Text("KOD RÖNTGENİ")
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .tracking(1.4)
            .foregroundStyle(.white)
        }

        Spacer()

        Label("1 / 30", systemImage: "flame.fill")
          .font(.system(size: 13, weight: .semibold, design: .rounded))
          .foregroundStyle(AppPalette.amber)
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(AppPalette.card, in: Capsule())
          .overlay(Capsule().stroke(AppPalette.border, lineWidth: 1))
      }

      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          Capsule()
            .fill(AppPalette.card)
          Capsule()
            .fill(
              LinearGradient(
                colors: [AppPalette.mint, AppPalette.indigo],
                startPoint: .leading,
                endPoint: .trailing
              )
            )
            .frame(width: max(18, geometry.size.width / 30))
        }
      }
      .frame(height: 5)
      .accessibilityLabel("30 günlük yolculuğun 1. günü")
    }
  }

  private var lessonHeading: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("DERS 01  ·  DEĞİŞKENLER")
        .font(.system(size: 12, weight: .bold, design: .rounded))
        .tracking(1.2)
        .foregroundStyle(AppPalette.mint)

      Text(session.lesson.title)
        .font(.system(size: 34, weight: .bold, design: .rounded))
        .foregroundStyle(.white)

      Text("Kodu çalıştırmadan önce zihninde izle. Bilgisayarın gördüğünü görmeye çalış.")
        .font(.system(size: 16, weight: .regular, design: .rounded))
        .foregroundStyle(AppPalette.secondaryText)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var predictionPanel: some View {
    VStack(alignment: .leading, spacing: 16) {
      Label(session.lesson.question, systemImage: "sparkles")
        .font(.system(size: 18, weight: .bold, design: .rounded))
        .foregroundStyle(.white)

      HStack(spacing: 12) {
        ForEach(session.lesson.choices, id: \.self) { choice in
          Button {
            withAnimation(.snappy) {
              session.submitPrediction(choice)
            }
          } label: {
            Text(choice)
              .font(.system(size: 22, weight: .bold, design: .monospaced))
              .frame(maxWidth: .infinity)
              .padding(.vertical, 16)
              .foregroundStyle(.white)
              .background(AppPalette.card, in: RoundedRectangle(cornerRadius: 16))
              .overlay(
                RoundedRectangle(cornerRadius: 16)
                  .stroke(AppPalette.border, lineWidth: 1)
              )
          }
          .buttonStyle(.plain)
          .accessibilityHint("Tahminini seçer ve kodun yürütülmesini başlatır")
        }
      }

      Text("Yanlış cevap sorun değil. Önemli olan, değerin neden değiştiğini görebilmek.")
        .font(.system(size: 13, design: .rounded))
        .foregroundStyle(AppPalette.tertiaryText)
    }
    .padding(20)
    .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 24))
    .overlay(
      RoundedRectangle(cornerRadius: 24)
        .stroke(AppPalette.border, lineWidth: 1)
    )
  }

  private var tracePanel: some View {
    VStack(spacing: 16) {
      predictionResult

      if let step = session.currentStep {
        TraceInspector(step: step)
          .transition(.opacity.combined(with: .move(edge: .bottom)))
          .id(step.lineNumber)
      }

      traceAction
    }
    .animation(.snappy, value: session.phase)
  }

  private var predictionResult: some View {
    HStack(spacing: 12) {
      Image(
        systemName: session.isPredictionCorrect == true
          ? "checkmark" : "arrow.trianglehead.2.clockwise.rotate.90"
      )
      .font(.system(size: 14, weight: .bold))
      .foregroundStyle(
        session.isPredictionCorrect == true ? AppPalette.background : AppPalette.amber
      )
      .frame(width: 32, height: 32)
      .background(
        session.isPredictionCorrect == true ? AppPalette.mint : AppPalette.amber.opacity(0.15),
        in: Circle()
      )

      VStack(alignment: .leading, spacing: 3) {
        Text(session.isPredictionCorrect == true ? "Tahminin doğru" : "Şimdi birlikte izleyelim")
          .font(.system(size: 15, weight: .bold, design: .rounded))
          .foregroundStyle(.white)
        Text("Cevabın: \(session.selectedAnswer ?? "—")")
          .font(.system(size: 13, design: .rounded))
          .foregroundStyle(AppPalette.secondaryText)
      }

      Spacer()

      Text(traceProgress)
        .font(.system(size: 12, weight: .semibold, design: .rounded))
        .foregroundStyle(AppPalette.mint)
    }
    .padding(16)
    .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 18))
    .overlay(
      RoundedRectangle(cornerRadius: 18)
        .stroke(AppPalette.border, lineWidth: 1)
    )
  }

  @ViewBuilder
  private var traceAction: some View {
    switch session.phase {
    case .tracing(let step):
      Button {
        withAnimation(.snappy) {
          session.advance()
        }
      } label: {
        HStack {
          Text(step == session.lesson.trace.count - 1 ? "Sonucu gör" : "Sonraki satırı çalıştır")
          Spacer()
          Image(systemName: "arrow.right")
        }
        .font(.system(size: 16, weight: .bold, design: .rounded))
        .foregroundStyle(AppPalette.background)
        .padding(18)
        .background(AppPalette.mint, in: RoundedRectangle(cornerRadius: 18))
      }
      .buttonStyle(.plain)

    case .complete:
      VStack(spacing: 14) {
        HStack(spacing: 12) {
          Image(systemName: "lightbulb.max.fill")
            .foregroundStyle(AppPalette.amber)
          Text("Gerçek ders: Kod, satırlardan çok değişen değerlerin hikâyesidir.")
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppPalette.amber.opacity(0.1), in: RoundedRectangle(cornerRadius: 18))

        Button {
          withAnimation(.snappy) {
            session = XRaySession(lesson: .introduction)
          }
        } label: {
          Label("Dersi yeniden çöz", systemImage: "arrow.counterclockwise")
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(16)
            .foregroundStyle(.white)
            .background(AppPalette.card, in: RoundedRectangle(cornerRadius: 18))
            .overlay(
              RoundedRectangle(cornerRadius: 18)
                .stroke(AppPalette.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
      }

    case .predicting:
      EmptyView()
    }
  }

  private var traceProgress: String {
    switch session.phase {
    case .tracing(let step):
      "ADIM \(step + 1)/\(session.lesson.trace.count)"
    case .complete:
      "TAMAMLANDI"
    case .predicting:
      ""
    }
  }
}

private struct CodeCard: View {
  let lines: [CodeLine]
  let activeLineNumber: Int?

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        HStack(spacing: 7) {
          Circle().fill(Color.red.opacity(0.8)).frame(width: 9, height: 9)
          Circle().fill(AppPalette.amber.opacity(0.8)).frame(width: 9, height: 9)
          Circle().fill(AppPalette.mint.opacity(0.8)).frame(width: 9, height: 9)
        }

        Spacer()

        Text("SWIFT")
          .font(.system(size: 10, weight: .bold, design: .rounded))
          .tracking(1.1)
          .foregroundStyle(AppPalette.secondaryText)
      }
      .padding(.horizontal, 18)
      .padding(.vertical, 14)
      .background(Color.white.opacity(0.025))

      VStack(spacing: 3) {
        ForEach(lines, id: \.number) { line in
          HStack(spacing: 14) {
            Text("\(line.number)")
              .font(.system(size: 13, design: .monospaced))
              .foregroundStyle(
                activeLineNumber == line.number
                  ? AppPalette.mint
                  : AppPalette.tertiaryText
              )
              .frame(width: 18, alignment: .trailing)

            Text(highlightedCode(line.text))
              .font(.system(size: 15, weight: .medium, design: .monospaced))
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 9)
          .background(
            activeLineNumber == line.number
              ? AppPalette.mint.opacity(0.1)
              : Color.clear
          )
          .overlay(alignment: .leading) {
            if activeLineNumber == line.number {
              RoundedRectangle(cornerRadius: 2)
                .fill(AppPalette.mint)
                .frame(width: 3)
            }
          }
        }
      }
      .padding(.vertical, 12)
    }
    .background(AppPalette.codeBackground, in: RoundedRectangle(cornerRadius: 24))
    .clipShape(RoundedRectangle(cornerRadius: 24))
    .overlay(
      RoundedRectangle(cornerRadius: 24)
        .stroke(
          activeLineNumber == nil
            ? AppPalette.border
            : AppPalette.mint.opacity(0.35),
          lineWidth: 1
        )
    )
    .shadow(color: .black.opacity(0.25), radius: 30, y: 18)
  }

  private func highlightedCode(_ code: String) -> AttributedString {
    var result = AttributedString(code)
    result.foregroundColor = .white

    for keyword in ["var", "if", "print"] {
      if let range = result.range(of: keyword) {
        result[range].foregroundColor = AppPalette.indigo
      }
    }

    return result
  }
}

private struct TraceInspector: View {
  let step: TraceStep

  var body: some View {
    VStack(alignment: .leading, spacing: 18) {
      HStack {
        Label("SATIR \(step.lineNumber)", systemImage: "play.fill")
          .font(.system(size: 12, weight: .bold, design: .rounded))
          .tracking(0.8)
          .foregroundStyle(AppPalette.mint)
        Spacer()
        Text("Şu an çalışıyor")
          .font(.system(size: 12, weight: .medium, design: .rounded))
          .foregroundStyle(AppPalette.secondaryText)
      }

      Text(step.explanation)
        .font(.system(size: 17, weight: .semibold, design: .rounded))
        .foregroundStyle(.white)
        .fixedSize(horizontal: false, vertical: true)

      Divider()
        .overlay(AppPalette.border)

      HStack(alignment: .top, spacing: 12) {
        inspectorBox(
          title: "HAFIZA",
          icon: "memorychip",
          value: memoryDescription,
          accent: AppPalette.indigo
        )

        inspectorBox(
          title: "ÇIKTI",
          icon: "terminal",
          value: step.output ?? "—",
          accent: step.output == nil ? AppPalette.tertiaryText : AppPalette.mint
        )
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
        .font(.system(size: 10, weight: .bold, design: .rounded))
        .tracking(0.8)
        .foregroundStyle(AppPalette.secondaryText)

      Text(value)
        .font(.system(size: 16, weight: .bold, design: .monospaced))
        .foregroundStyle(accent)
        .lineLimit(2)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(14)
    .background(AppPalette.codeBackground, in: RoundedRectangle(cornerRadius: 15))
  }
}

private enum AppPalette {
  static let background = Color(red: 0.035, green: 0.043, blue: 0.07)
  static let panel = Color(red: 0.07, green: 0.082, blue: 0.125)
  static let card = Color(red: 0.095, green: 0.108, blue: 0.155)
  static let codeBackground = Color(red: 0.045, green: 0.052, blue: 0.083)
  static let border = Color.white.opacity(0.09)
  static let mint = Color(red: 0.35, green: 0.93, blue: 0.68)
  static let indigo = Color(red: 0.53, green: 0.55, blue: 1)
  static let amber = Color(red: 1, green: 0.72, blue: 0.29)
  static let secondaryText = Color.white.opacity(0.64)
  static let tertiaryText = Color.white.opacity(0.36)
}

private struct ContentViewPreview: PreviewProvider {
  static var previews: some View {
    ContentView()
      .preferredColorScheme(.dark)
  }
}
