import SwiftUI

struct ContentView: View {
  private let catalog = LessonCatalog.standard
  private let progressStore: FileProgressStore
  @State private var progress: LessonProgress

  init() {
    let store = FileProgressStore(
      fileURL: URL.applicationSupportDirectory
        .appendingPathComponent("grillme-progress.json")
    )
    progressStore = store
    _progress = State(initialValue: store.load())
  }

  var body: some View {
    NavigationStack {
      LessonMapView(
        items: catalog.items(completedLessonIDs: progress.completedLessonIDs),
        completedCount: progress.completedLessonIDs.count,
        onLessonCompleted: complete
      )
    }
    .tint(AppPalette.mint)
  }

  private func complete(_ lessonID: String) {
    progress.complete(lessonID)
    try? progressStore.save(progress)
  }
}

private struct LessonMapView: View {
  let items: [LessonCatalogItem]
  let completedCount: Int
  let onLessonCompleted: (String) -> Void

  var body: some View {
    ZStack {
      AppPalette.background
        .ignoresSafeArea()

      RadialGradient(
        colors: [AppPalette.indigo.opacity(0.24), .clear],
        center: .topTrailing,
        startRadius: 10,
        endRadius: 430
      )
      .ignoresSafeArea()

      ScrollView {
        VStack(spacing: 28) {
          mapHeader
          progressHero

          VStack(alignment: .leading, spacing: 16) {
            Text("TEMEL MEKANİK")
              .font(.system(size: 12, weight: .bold, design: .rounded))
              .tracking(1.3)
              .foregroundStyle(AppPalette.mint)
              .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(items, id: \.lesson.id) { item in
              lessonDestination(for: item)
            }
          }

          upcomingCard
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 40)
      }
      .scrollIndicators(.hidden)
    }
    .navigationBarHidden(true)
  }

  private var mapHeader: some View {
    HStack {
      HStack(spacing: 10) {
        Image(systemName: "chevron.left.forwardslash.chevron.right")
          .font(.system(size: 15, weight: .bold))
          .foregroundStyle(AppPalette.background)
          .frame(width: 38, height: 38)
          .background(AppPalette.mint, in: RoundedRectangle(cornerRadius: 12))

        VStack(alignment: .leading, spacing: 2) {
          Text("GRILLME")
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .tracking(1.1)
            .foregroundStyle(.white)
          Text("Kod okuma laboratuvarı")
            .font(.system(size: 11, design: .rounded))
            .foregroundStyle(AppPalette.secondaryText)
        }
      }

      Spacer()

      Label("\(completedCount)", systemImage: "checkmark.seal.fill")
        .font(.system(size: 13, weight: .bold, design: .rounded))
        .foregroundStyle(AppPalette.mint)
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(AppPalette.card, in: Capsule())
        .overlay(Capsule().stroke(AppPalette.border, lineWidth: 1))
        .accessibilityLabel("\(completedCount) ders tamamlandı")
    }
  }

  private var progressHero: some View {
    VStack(alignment: .leading, spacing: 18) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 8) {
          Text("Kodun içini\nokumaya başla")
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .fixedSize(horizontal: false, vertical: true)

          Text("Bugün 10 dakika ayır. Tahmin et, çalıştır ve değerlerin izini sür.")
            .font(.system(size: 15, design: .rounded))
            .foregroundStyle(AppPalette.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
        }

        Spacer(minLength: 16)

        ZStack {
          Circle()
            .stroke(AppPalette.card, lineWidth: 7)
          Circle()
            .trim(from: 0, to: min(Double(completedCount) / 30, 1))
            .stroke(
              AngularGradient(
                colors: [AppPalette.mint, AppPalette.indigo],
                center: .center
              ),
              style: StrokeStyle(lineWidth: 7, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))

          VStack(spacing: 1) {
            Text("\(completedCount)")
              .font(.system(size: 21, weight: .bold, design: .rounded))
              .foregroundStyle(.white)
            Text("/ 30")
              .font(.system(size: 10, weight: .semibold, design: .rounded))
              .foregroundStyle(AppPalette.secondaryText)
          }
        }
        .frame(width: 82, height: 82)
        .accessibilityLabel("30 dersten \(completedCount) tanesi tamamlandı")
      }

      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          Capsule().fill(AppPalette.card)
          Capsule()
            .fill(
              LinearGradient(
                colors: [AppPalette.mint, AppPalette.indigo],
                startPoint: .leading,
                endPoint: .trailing
              )
            )
            .frame(
              width: max(
                completedCount == 0 ? 0 : 12,
                geometry.size.width * min(Double(completedCount) / 30, 1)
              )
            )
        }
      }
      .frame(height: 6)
    }
    .padding(22)
    .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 26))
    .overlay(
      RoundedRectangle(cornerRadius: 26)
        .stroke(AppPalette.border, lineWidth: 1)
    )
  }

  @ViewBuilder
  private func lessonDestination(for item: LessonCatalogItem) -> some View {
    if item.status == .locked {
      LessonRow(item: item)
    } else {
      NavigationLink {
        XRayLessonView(lesson: item.lesson) {
          onLessonCompleted(item.lesson.id)
        }
      } label: {
        LessonRow(item: item)
      }
      .buttonStyle(.plain)
    }
  }

  private var upcomingCard: some View {
    HStack(spacing: 14) {
      Image(systemName: "ellipsis")
        .font(.system(size: 17, weight: .bold))
        .foregroundStyle(AppPalette.indigo)
        .frame(width: 42, height: 42)
        .background(AppPalette.indigo.opacity(0.12), in: Circle())

      VStack(alignment: .leading, spacing: 4) {
        Text("Yolculuk devam edecek")
          .font(.system(size: 15, weight: .bold, design: .rounded))
          .foregroundStyle(.white)
        Text("Fonksiyonlar, koleksiyonlar ve class'lar sırada.")
          .font(.system(size: 13, design: .rounded))
          .foregroundStyle(AppPalette.secondaryText)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(18)
    .background(AppPalette.indigo.opacity(0.06), in: RoundedRectangle(cornerRadius: 20))
    .overlay(
      RoundedRectangle(cornerRadius: 20)
        .stroke(AppPalette.indigo.opacity(0.18), style: StrokeStyle(lineWidth: 1, dash: [5]))
    )
  }
}

private struct LessonRow: View {
  let item: LessonCatalogItem

  var body: some View {
    HStack(spacing: 15) {
      ZStack {
        Circle()
          .fill(badgeColor.opacity(item.status == .locked ? 0.08 : 0.16))
        Circle()
          .stroke(badgeColor.opacity(item.status == .locked ? 0.16 : 0.45), lineWidth: 1)

        if item.status == .completed {
          Image(systemName: "checkmark")
            .font(.system(size: 15, weight: .bold))
        } else if item.status == .locked {
          Image(systemName: "lock.fill")
            .font(.system(size: 13, weight: .semibold))
        } else {
          Text("\(item.lesson.order)")
            .font(.system(size: 16, weight: .bold, design: .rounded))
        }
      }
      .foregroundStyle(badgeColor)
      .frame(width: 48, height: 48)

      VStack(alignment: .leading, spacing: 5) {
        HStack(spacing: 7) {
          Text("DERS \(String(format: "%02d", item.lesson.order))")
          Text("·")
          Text(item.lesson.topic)
        }
        .font(.system(size: 10, weight: .bold, design: .rounded))
        .tracking(0.8)
        .foregroundStyle(badgeColor)

        Text(item.lesson.title)
          .font(.system(size: 18, weight: .bold, design: .rounded))
          .foregroundStyle(item.status == .locked ? AppPalette.secondaryText : .white)

        Text(item.lesson.objective)
          .font(.system(size: 12, design: .rounded))
          .foregroundStyle(AppPalette.secondaryText)
          .lineLimit(2)
      }

      Spacer(minLength: 6)

      Image(systemName: item.status == .locked ? "lock" : "chevron.right")
        .font(.system(size: 12, weight: .bold))
        .foregroundStyle(item.status == .locked ? AppPalette.tertiaryText : badgeColor)
    }
    .padding(18)
    .background(
      item.status == .available
        ? AppPalette.card
        : AppPalette.panel.opacity(item.status == .locked ? 0.68 : 1),
      in: RoundedRectangle(cornerRadius: 22)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 22)
        .stroke(
          item.status == .available ? AppPalette.mint.opacity(0.34) : AppPalette.border,
          lineWidth: 1
        )
    )
    .opacity(item.status == .locked ? 0.7 : 1)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(accessibilityDescription)
  }

  private var badgeColor: Color {
    switch item.status {
    case .completed:
      AppPalette.mint
    case .available:
      AppPalette.amber
    case .locked:
      AppPalette.tertiaryText
    }
  }

  private var accessibilityDescription: String {
    let status: String
    switch item.status {
    case .completed:
      status = "tamamlandı"
    case .available:
      status = "açık"
    case .locked:
      status = "kilitli"
    }
    return "\(item.lesson.order). ders, \(item.lesson.title), \(status)"
  }
}

private struct XRayLessonView: View {
  let lesson: XRayLesson
  let onComplete: () -> Void
  @Environment(\.dismiss) private var dismiss
  @State private var session: XRaySession

  init(lesson: XRayLesson, onComplete: @escaping () -> Void) {
    self.lesson = lesson
    self.onComplete = onComplete
    _session = State(initialValue: XRaySession(lesson: lesson))
  }

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
          case .tracing:
            tracePanel
          case .transfer:
            transferPanel
          case .complete:
            completionPanel
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 40)
      }
      .scrollIndicators(.hidden)
    }
    .tint(AppPalette.mint)
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.hidden, for: .navigationBar)
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

        Label("\(lesson.order) / 30", systemImage: "flame.fill")
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
            .frame(width: max(18, geometry.size.width * Double(lesson.order) / 30))
        }
      }
      .frame(height: 5)
      .accessibilityLabel("30 günlük yolculuğun \(lesson.order). günü")
    }
  }

  private var lessonHeading: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("DERS \(String(format: "%02d", lesson.order))  ·  \(lesson.topic)")
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

      if session.lesson.choices.allSatisfy({ $0.count <= 3 }) {
        HStack(spacing: 12) {
          ForEach(session.lesson.choices, id: \.self) { choice in
            predictionButton(choice)
          }
        }
      } else {
        VStack(spacing: 10) {
          ForEach(session.lesson.choices, id: \.self) { choice in
            predictionButton(choice)
          }
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

  private func predictionButton(_ choice: String) -> some View {
    Button {
      withAnimation(.snappy) {
        session.submitPrediction(choice)
      }
    } label: {
      Text(choice)
        .font(.system(size: 19, weight: .bold, design: .monospaced))
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

    case .predicting, .transfer, .complete:
      EmptyView()
    }
  }

  @ViewBuilder
  private var transferPanel: some View {
    if let challenge = lesson.transferChallenge {
      VStack(spacing: 14) {
        predictionResult

        VStack(alignment: .leading, spacing: 16) {
          Label("AYNI MANTIK · YENİ DURUM", systemImage: "arrow.triangle.branch")
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .tracking(0.8)
            .foregroundStyle(AppPalette.indigo)

          Text(challenge.prompt)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .fixedSize(horizontal: false, vertical: true)

          CodeCard(lines: challenge.code, activeLineNumber: nil)

          if challenge.choices.allSatisfy({ $0.count <= 3 }) {
            HStack(spacing: 12) {
              ForEach(challenge.choices, id: \.self) { choice in
                transferButton(choice)
              }
            }
          } else {
            VStack(spacing: 10) {
              ForEach(challenge.choices, id: \.self) { choice in
                transferButton(choice)
              }
            }
          }

          Text("Ezber değil aktarım: aynı düşünme biçimini yeni koda uygula.")
            .font(.system(size: 13, design: .rounded))
            .foregroundStyle(AppPalette.tertiaryText)
        }
        .padding(20)
        .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
          RoundedRectangle(cornerRadius: 24)
            .stroke(AppPalette.indigo.opacity(0.28), lineWidth: 1)
        )
      }
      .animation(.snappy, value: session.phase)
    }
  }

  private func transferButton(_ choice: String) -> some View {
    Button {
      withAnimation(.snappy) {
        session.submitTransferAnswer(choice)
      }
    } label: {
      Text(choice)
        .font(.system(size: 17, weight: .bold, design: .monospaced))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .foregroundStyle(.white)
        .background(AppPalette.card, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
          RoundedRectangle(cornerRadius: 16)
            .stroke(AppPalette.indigo.opacity(0.35), lineWidth: 1)
        )
    }
    .buttonStyle(.plain)
    .accessibilityHint("Aktarım cevabını seçer")
  }

  private var completionPanel: some View {
    VStack(spacing: 14) {
      if let challenge = lesson.transferChallenge {
        HStack(alignment: .top, spacing: 12) {
          Image(
            systemName: session.isTransferAnswerCorrect == true
              ? "checkmark.seal.fill" : "arrow.trianglehead.2.clockwise.rotate.90"
          )
          .font(.system(size: 20, weight: .bold))
          .foregroundStyle(
            session.isTransferAnswerCorrect == true ? AppPalette.mint : AppPalette.amber
          )

          VStack(alignment: .leading, spacing: 6) {
            Text(
              session.isTransferAnswerCorrect == true
                ? "Aktarımın doğru" : "Doğru cevap: \(challenge.correctAnswer)"
            )
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundStyle(.white)

            Text(challenge.explanation)
              .font(.system(size: 14, design: .rounded))
              .foregroundStyle(AppPalette.secondaryText)
              .fixedSize(horizontal: false, vertical: true)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 18))
        .overlay(
          RoundedRectangle(cornerRadius: 18)
            .stroke(AppPalette.border, lineWidth: 1)
        )
      }

      VStack(spacing: 14) {
        HStack(spacing: 12) {
          Image(systemName: "lightbulb.max.fill")
            .foregroundStyle(AppPalette.amber)
          Text("Gerçek ders: \(lesson.takeaway)")
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppPalette.amber.opacity(0.1), in: RoundedRectangle(cornerRadius: 18))

        Button {
          onComplete()
          dismiss()
        } label: {
          HStack {
            Text("Dersi tamamla")
            Spacer()
            Image(systemName: "checkmark")
          }
          .font(.system(size: 16, weight: .bold, design: .rounded))
          .foregroundStyle(AppPalette.background)
          .padding(18)
          .background(AppPalette.mint, in: RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)

        Button {
          withAnimation(.snappy) {
            session = XRaySession(lesson: lesson)
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
    }
  }

  private var traceProgress: String {
    switch session.phase {
    case .tracing(let step):
      "ADIM \(step + 1)/\(session.lesson.trace.count)"
    case .transfer:
      "AKTARIM"
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

    for keyword in ["var", "let", "if", "else", "for", "in", "print"] {
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
