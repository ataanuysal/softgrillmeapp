import SwiftUI

struct ContentView: View {
  private let catalog = LessonCatalog.standard
  private let progressStore: FileProgressStore
  @State private var progress: LessonProgress
  @State private var learningEvents: [LearningEvent] = []

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
        dashboard: LearningDashboardSnapshot(
          progress: progress,
          totalLessonCount: catalog.lessons.count,
          asOf: Date()
        ),
        onLessonCompleted: complete
      )
    }
    .tint(AppPalette.mint)
  }

  private func complete(_ result: LessonRunResult) {
    progress.recordAttempt(result.attempt)
    learningEvents.append(contentsOf: result.events)
    try? progressStore.save(progress)
  }
}

private struct LessonMapView: View {
  let items: [LessonCatalogItem]
  let dashboard: LearningDashboardSnapshot
  let onLessonCompleted: (LessonRunResult) -> Void
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
          weeklySummary
          growthSummary

          ForEach(CurriculumSection.allCases, id: \.self) { section in
            let sectionItems = items.filter { $0.lesson.section == section }
            if !sectionItems.isEmpty {
              VStack(alignment: .leading, spacing: 16) {
                Text(section.displayName)
                  .adaptiveFont(size: 12, weight: .bold, design: .rounded)
                  .tracking(1.3)
                  .foregroundStyle(section.accentColor)
                  .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(sectionItems, id: \.lesson.id) { item in
                  lessonDestination(for: item)
                }
              }
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
    Group {
      if dynamicTypeSize.isAccessibilitySize {
        VStack(alignment: .leading, spacing: 14) {
          brand
          headerMetrics
        }
      } else {
        HStack {
          brand
          Spacer()
          headerMetrics
        }
      }
    }
  }

  private var brand: some View {
    HStack(spacing: 10) {
      Image(systemName: "chevron.left.forwardslash.chevron.right")
        .adaptiveFont(size: 15, weight: .bold)
        .foregroundStyle(AppPalette.background)
        .frame(width: 38, height: 38)
        .background(AppPalette.mint, in: RoundedRectangle(cornerRadius: 12))

      VStack(alignment: .leading, spacing: 2) {
        Text("GRILLME")
          .adaptiveFont(size: 15, weight: .bold, design: .rounded)
          .tracking(1.1)
          .foregroundStyle(.white)
          .lineLimit(1)
        Text("Kod okuma laboratuvarı")
          .adaptiveFont(size: 11, design: .rounded)
          .foregroundStyle(AppPalette.secondaryText)
      }
    }
  }

  private var headerMetrics: some View {
    HStack(spacing: 8) {
      Label("\(dashboard.currentStreak)", systemImage: "flame.fill")
        .foregroundStyle(AppPalette.amber)
        .accessibilityLabel("\(dashboard.currentStreak) günlük seri")

      Label("\(dashboard.completedCount)", systemImage: "checkmark.seal.fill")
        .foregroundStyle(AppPalette.mint)
        .accessibilityLabel("\(dashboard.completedCount) ders tamamlandı")
    }
    .adaptiveFont(size: 13, weight: .bold, design: .rounded)
    .padding(.horizontal, 12)
    .padding(.vertical, 9)
    .background(AppPalette.card, in: Capsule())
    .overlay(Capsule().stroke(AppPalette.border, lineWidth: 1))
  }

  private var progressHero: some View {
    VStack(alignment: .leading, spacing: 18) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 8) {
          Text("Kodun içini\nokumaya başla")
            .adaptiveFont(size: 32, weight: .bold, design: .rounded)
            .foregroundStyle(.white)
            .fixedSize(horizontal: false, vertical: true)

          Text("Bugün 10 dakika ayır. Tahmin et, çalıştır ve değerlerin izini sür.")
            .adaptiveFont(size: 15, design: .rounded)
            .foregroundStyle(AppPalette.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
        }

        Spacer(minLength: 16)

        ZStack {
          Circle()
            .stroke(AppPalette.card, lineWidth: 7)
          Circle()
            .trim(
              from: 0,
              to: min(Double(dashboard.completedCount) / Double(dashboard.totalCount), 1)
            )
            .stroke(
              AngularGradient(
                colors: [AppPalette.mint, AppPalette.indigo],
                center: .center
              ),
              style: StrokeStyle(lineWidth: 7, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))

          VStack(spacing: 1) {
            Text("\(dashboard.completedCount)")
              .adaptiveFont(size: 21, weight: .bold, design: .rounded)
              .foregroundStyle(.white)
            Text("/ \(dashboard.totalCount)")
              .adaptiveFont(size: 10, weight: .semibold, design: .rounded)
              .foregroundStyle(AppPalette.secondaryText)
          }
        }
        .frame(width: 82, height: 82)
        .accessibilityLabel(
          "\(dashboard.totalCount) dersten \(dashboard.completedCount) tanesi tamamlandı"
        )
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
                dashboard.completedCount == 0 ? 0 : 12,
                geometry.size.width
                  * min(
                    Double(dashboard.completedCount) / Double(dashboard.totalCount),
                    1
                  )
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

  private var weeklySummary: some View {
    HStack(spacing: 12) {
      summaryMetric(
        value: "\(dashboard.weeklySummary.completedLessonCount)",
        label: "Bu hafta",
        icon: "calendar"
      )
      summaryMetric(
        value: "\(dashboard.weeklySummary.practiceSeconds / 60) dk",
        label: "Pratik",
        icon: "timer"
      )
      summaryMetric(
        value: percentage(dashboard.weeklySummary.predictionAccuracy),
        label: "İlk tahmin",
        icon: "scope"
      )
      summaryMetric(
        value: percentage(dashboard.weeklySummary.transferAccuracy),
        label: "Aktarım",
        icon: "arrow.triangle.branch"
      )
    }
    .padding(16)
    .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 22))
    .overlay(
      RoundedRectangle(cornerRadius: 22)
        .stroke(AppPalette.border, lineWidth: 1)
    )
    .accessibilityElement(children: .contain)
    .accessibilityLabel("Haftalık öğrenme özeti")
  }

  @ViewBuilder
  private var growthSummary: some View {
    if let report = dashboard.growthReport {
      HStack(spacing: 14) {
        Image(
          systemName: report.improvement >= 0
            ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis"
        )
        .foregroundStyle(report.improvement >= 0 ? AppPalette.mint : AppPalette.amber)

        VStack(alignment: .leading, spacing: 4) {
          Text("Kod okuma gelişimin")
            .adaptiveFont(size: 15, weight: .bold, design: .rounded)
            .foregroundStyle(.white)
          Text(
            "Başlangıç \(percentage(report.baselineAccuracy)) · Çıkış \(percentage(report.exitAccuracy))"
          )
          .adaptiveFont(size: 12, design: .rounded)
          .foregroundStyle(AppPalette.secondaryText)
        }

        Spacer()

        Text(
          "\(report.improvement >= 0 ? "+" : "")\(Int((report.improvement * 100).rounded())) puan"
        )
        .adaptiveFont(size: 13, weight: .bold, design: .rounded)
        .foregroundStyle(report.improvement >= 0 ? AppPalette.mint : AppPalette.amber)
      }
      .padding(16)
      .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 20))
      .overlay(
        RoundedRectangle(cornerRadius: 20)
          .stroke(AppPalette.border, lineWidth: 1)
      )
      .accessibilityElement(children: .combine)
    }
  }

  private func summaryMetric(
    value: String,
    label: String,
    icon: String
  ) -> some View {
    VStack(spacing: 6) {
      Image(systemName: icon)
        .foregroundStyle(AppPalette.indigo)
      Text(value)
        .adaptiveFont(size: 16, weight: .bold, design: .rounded)
        .foregroundStyle(.white)
      Text(label)
        .adaptiveFont(size: 10, weight: .semibold, design: .rounded)
        .foregroundStyle(AppPalette.secondaryText)
    }
    .frame(maxWidth: .infinity)
  }

  private func percentage(_ value: Double) -> String {
    "\(Int((value * 100).rounded()))%"
  }

  @ViewBuilder
  private func lessonDestination(for item: LessonCatalogItem) -> some View {
    if item.status == .locked {
      LessonRow(item: item)
    } else {
      NavigationLink {
        XRayLessonView(lesson: item.lesson, onComplete: onLessonCompleted)
      } label: {
        LessonRow(item: item)
      }
      .buttonStyle(.plain)
    }
  }

  private var upcomingCard: some View {
    HStack(spacing: 14) {
      Image(systemName: "ellipsis")
        .adaptiveFont(size: 17, weight: .bold)
        .foregroundStyle(AppPalette.indigo)
        .frame(width: 42, height: 42)
        .background(AppPalette.indigo.opacity(0.12), in: Circle())

      VStack(alignment: .leading, spacing: 4) {
        Text("Yolculuk devam edecek")
          .adaptiveFont(size: 15, weight: .bold, design: .rounded)
          .foregroundStyle(.white)
        Text("Temelden uygulama mimarisine uzanan 30 ders hazır.")
          .adaptiveFont(size: 13, design: .rounded)
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
            .adaptiveFont(size: 15, weight: .bold)
        } else if item.status == .locked {
          Image(systemName: "lock.fill")
            .adaptiveFont(size: 13, weight: .semibold)
        } else {
          Text("\(item.lesson.order)")
            .adaptiveFont(size: 16, weight: .bold, design: .rounded)
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
        .adaptiveFont(size: 10, weight: .bold, design: .rounded)
        .tracking(0.8)
        .foregroundStyle(badgeColor)

        Text(item.lesson.title)
          .adaptiveFont(size: 18, weight: .bold, design: .rounded)
          .foregroundStyle(item.status == .locked ? AppPalette.secondaryText : .white)

        Text(item.lesson.objective)
          .adaptiveFont(size: 12, design: .rounded)
          .foregroundStyle(AppPalette.secondaryText)
          .lineLimit(2)

        HStack(spacing: 10) {
          Label("\(item.lesson.estimatedMinutes) dk", systemImage: "clock")
          Label("\(item.lesson.availableLenses.count) lens", systemImage: "scope")
        }
        .adaptiveFont(size: 10, weight: .semibold, design: .rounded)
        .foregroundStyle(AppPalette.tertiaryText)
      }

      Spacer(minLength: 6)

      Image(systemName: item.status == .locked ? "lock" : "chevron.right")
        .adaptiveFont(size: 12, weight: .bold)
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
  let onComplete: (LessonRunResult) -> Void
  @Environment(\.dismiss) private var dismiss
  @State private var session: XRaySession
  @State private var run: LessonRun
  @State private var selectedLanguage: CodeLanguage = .swift
  @State private var debugSession: DebugSession?
  @State private var debugHypothesis = ""
  @State private var practiceAnswers: [Int: String] = [:]
  @State private var mentorSession: SocraticMentorSession
  @State private var mentorInput = ""
  @State private var mentorResponses: [MentorResponse] = []
  @State private var isMentorResponding = false
  @State private var assessmentExplanation = ""

  init(lesson: XRayLesson, onComplete: @escaping (LessonRunResult) -> Void) {
    self.lesson = lesson
    self.onComplete = onComplete
    _session = State(initialValue: XRaySession(lesson: lesson))
    _run = State(initialValue: LessonRun(lessonID: lesson.id, startedAt: Date()))
    _debugSession = State(
      initialValue: lesson.debugChallenge.map { DebugSession(challenge: $0) }
    )
    _mentorSession = State(
      initialValue: SocraticMentorSession(
        lesson: lesson,
        requiredConcepts: lesson.mentorConcepts,
        turnLimit: 6
      )
    )
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
          lensStrip
          languagePicker
          CodeCard(
            lines: session.lesson.code(for: selectedLanguage),
            activeLineNumber: selectedLanguage == .swift ? session.currentStep?.lineNumber : nil,
            languageLabel: selectedLanguage.displayName.uppercased()
          )
          languageComparison

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
            .adaptiveFont(size: 15, weight: .bold)
            .foregroundStyle(AppPalette.background)
            .frame(width: 34, height: 34)
            .background(AppPalette.mint, in: RoundedRectangle(cornerRadius: 10))

          Text("KOD RÖNTGENİ")
            .adaptiveFont(size: 13, weight: .bold, design: .rounded)
            .tracking(1.4)
            .foregroundStyle(.white)
        }

        Spacer()

        Label("\(lesson.order) / 30", systemImage: "flame.fill")
          .adaptiveFont(size: 13, weight: .semibold, design: .rounded)
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
        .adaptiveFont(size: 12, weight: .bold, design: .rounded)
        .tracking(1.2)
        .foregroundStyle(AppPalette.mint)

      Text(session.lesson.title)
        .adaptiveFont(size: 34, weight: .bold, design: .rounded)
        .foregroundStyle(.white)

      Text("Kodu çalıştırmadan önce zihninde izle. Bilgisayarın gördüğünü görmeye çalış.")
        .adaptiveFont(size: 16, weight: .regular, design: .rounded)
        .foregroundStyle(AppPalette.secondaryText)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var lensStrip: some View {
    ScrollView(.horizontal) {
      HStack(spacing: 8) {
        ForEach(lesson.availableLenses, id: \.rawValue) { lens in
          Label(lens.displayName, systemImage: lens.icon)
            .adaptiveFont(size: 11, weight: .bold, design: .rounded)
            .foregroundStyle(lens.accentColor)
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .background(lens.accentColor.opacity(0.1), in: Capsule())
            .overlay(Capsule().stroke(lens.accentColor.opacity(0.25), lineWidth: 1))
        }
      }
    }
    .scrollIndicators(.hidden)
    .accessibilityLabel("Bu derste kullanılabilen Kod Röntgeni lensleri")
  }

  @ViewBuilder
  private var languagePicker: some View {
    if lesson.availableLanguages.count > 1 {
      VStack(alignment: .leading, spacing: 10) {
        Text("DİL KÖPRÜSÜ")
          .adaptiveFont(size: 11, weight: .bold, design: .rounded)
          .tracking(1)
          .foregroundStyle(AppPalette.indigo)

        Picker("Kod dili", selection: $selectedLanguage) {
          ForEach(lesson.availableLanguages, id: \.rawValue) { language in
            Text(language.displayName).tag(language)
          }
        }
        .pickerStyle(.segmented)
      }
      .padding(14)
      .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 18))
      .overlay(
        RoundedRectangle(cornerRadius: 18)
          .stroke(AppPalette.indigo.opacity(0.22), lineWidth: 1)
      )
    }
  }

  @ViewBuilder
  private var languageComparison: some View {
    if selectedLanguage != .swift, let comparison = lesson.languageComparison {
      VStack(alignment: .leading, spacing: 9) {
        Label("MANTIK AYNI", systemImage: "equal.circle.fill")
          .adaptiveFont(size: 11, weight: .bold, design: .rounded)
          .foregroundStyle(AppPalette.mint)

        Text(comparison.invariant)
          .adaptiveFont(size: 14, weight: .semibold, design: .rounded)
          .foregroundStyle(.white)

        if let difference = comparison.syntaxDifferences[selectedLanguage] {
          Text("Syntax farkı: \(difference)")
            .adaptiveFont(size: 13, design: .rounded)
            .foregroundStyle(AppPalette.secondaryText)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(16)
      .background(AppPalette.mint.opacity(0.07), in: RoundedRectangle(cornerRadius: 18))
    }
  }

  private var predictionPanel: some View {
    VStack(alignment: .leading, spacing: 16) {
      Label(session.lesson.question, systemImage: "sparkles")
        .adaptiveFont(size: 18, weight: .bold, design: .rounded)
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
        .adaptiveFont(size: 13, design: .rounded)
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
        .adaptiveFont(size: 19, weight: .bold, design: .monospaced)
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
      .adaptiveFont(size: 14, weight: .bold)
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
          .adaptiveFont(size: 15, weight: .bold, design: .rounded)
          .foregroundStyle(.white)
        Text("Cevabın: \(session.selectedAnswer ?? "—")")
          .adaptiveFont(size: 13, design: .rounded)
          .foregroundStyle(AppPalette.secondaryText)
      }

      Spacer()

      Text(traceProgress)
        .adaptiveFont(size: 12, weight: .semibold, design: .rounded)
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
        .adaptiveFont(size: 16, weight: .bold, design: .rounded)
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
            .adaptiveFont(size: 12, weight: .bold, design: .rounded)
            .tracking(0.8)
            .foregroundStyle(AppPalette.indigo)

          Text(challenge.prompt)
            .adaptiveFont(size: 20, weight: .bold, design: .rounded)
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
            .adaptiveFont(size: 13, design: .rounded)
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
        .adaptiveFont(size: 17, weight: .bold, design: .monospaced)
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
      transferResult

      if let debugSession, debugSession.phase != .complete {
        debugChallengePanel(debugSession)
      } else {
        debugResult
        practiceChallengesPanel
        assessmentPanel
        mentorPanel
        lessonActions
      }
    }
  }

  @ViewBuilder
  private var transferResult: some View {
    if let challenge = lesson.transferChallenge {
      HStack(alignment: .top, spacing: 12) {
        Image(
          systemName: session.isTransferAnswerCorrect == true
            ? "checkmark.seal.fill" : "arrow.trianglehead.2.clockwise.rotate.90"
        )
        .adaptiveFont(size: 20, weight: .bold)
        .foregroundStyle(
          session.isTransferAnswerCorrect == true ? AppPalette.mint : AppPalette.amber
        )

        VStack(alignment: .leading, spacing: 6) {
          Text(
            session.isTransferAnswerCorrect == true
              ? "Aktarımın doğru" : "Doğru cevap: \(challenge.correctAnswer)"
          )
          .adaptiveFont(size: 17, weight: .bold, design: .rounded)
          .foregroundStyle(.white)

          Text(challenge.explanation)
            .adaptiveFont(size: 14, design: .rounded)
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
  }

  private func debugChallengePanel(_ current: DebugSession) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      Label("HATA LENSİ", systemImage: "ladybug.fill")
        .adaptiveFont(size: 12, weight: .bold, design: .rounded)
        .tracking(0.8)
        .foregroundStyle(AppPalette.amber)

      Text(current.challenge.prompt)
        .adaptiveFont(size: 18, weight: .bold, design: .rounded)
        .foregroundStyle(.white)

      if current.phase == .hypothesizing {
        TextField(
          "Hipotezin: hangi varsayım yanlış olabilir?",
          text: $debugHypothesis,
          axis: .vertical
        )
        .lineLimit(2...4)
        .padding(14)
        .foregroundStyle(.white)
        .background(AppPalette.codeBackground, in: RoundedRectangle(cornerRadius: 14))
        .accessibilityLabel("Hata hipotezin")

        Button("Hipotezi kaydet ve satırı seç") {
          debugSession?.submitHypothesis(debugHypothesis)
        }
        .adaptiveFont(size: 15, weight: .bold, design: .rounded)
        .frame(maxWidth: .infinity)
        .padding(16)
        .foregroundStyle(AppPalette.background)
        .background(AppPalette.amber, in: RoundedRectangle(cornerRadius: 16))
        .disabled(debugHypothesis.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
      } else {
        CodeCard(lines: current.challenge.code, activeLineNumber: nil)

        Text("Sorunu üreten satırı seç")
          .adaptiveFont(size: 14, weight: .semibold, design: .rounded)
          .foregroundStyle(AppPalette.secondaryText)

        HStack(spacing: 8) {
          ForEach(current.challenge.code, id: \.number) { line in
            Button("Satır \(line.number)") {
              debugSession?.selectLine(line.number)
            }
            .adaptiveFont(size: 12, weight: .bold, design: .rounded)
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
            .foregroundStyle(.white)
            .background(AppPalette.card, in: RoundedRectangle(cornerRadius: 12))
          }
        }
      }
    }
    .padding(20)
    .background(AppPalette.amber.opacity(0.08), in: RoundedRectangle(cornerRadius: 24))
    .overlay(
      RoundedRectangle(cornerRadius: 24)
        .stroke(AppPalette.amber.opacity(0.28), lineWidth: 1)
    )
  }

  @ViewBuilder
  private var debugResult: some View {
    if let debugSession, debugSession.phase == .complete {
      HStack(alignment: .top, spacing: 12) {
        Image(
          systemName: debugSession.isCorrect == true
            ? "checkmark.seal.fill" : "magnifyingglass.circle.fill"
        )
        .foregroundStyle(debugSession.isCorrect == true ? AppPalette.mint : AppPalette.amber)

        VStack(alignment: .leading, spacing: 5) {
          Text(
            debugSession.isCorrect == true ? "Hipotezin kanıtlandı" : "Kanıt yeni bir ipucu verdi"
          )
          .adaptiveFont(size: 16, weight: .bold, design: .rounded)
          .foregroundStyle(.white)
          Text(debugSession.evidence ?? "")
            .adaptiveFont(size: 13, design: .rounded)
            .foregroundStyle(AppPalette.secondaryText)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(18)
      .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 18))
    }
  }

  @ViewBuilder
  private var practiceChallengesPanel: some View {
    if !lesson.practiceChallenges.isEmpty {
      VStack(alignment: .leading, spacing: 16) {
        Label("EK PRATİK", systemImage: "brain.head.profile")
          .adaptiveFont(size: 12, weight: .bold, design: .rounded)
          .foregroundStyle(AppPalette.indigo)

        ForEach(Array(lesson.practiceChallenges.enumerated()), id: \.offset) { index, challenge in
          VStack(alignment: .leading, spacing: 10) {
            Text(challenge.prompt)
              .adaptiveFont(size: 15, weight: .bold, design: .rounded)
              .foregroundStyle(.white)

            ForEach(challenge.choices, id: \.self) { choice in
              Button {
                practiceAnswers[index] = choice
              } label: {
                HStack {
                  Text(choice)
                  Spacer()
                  if practiceAnswers[index] == choice {
                    Image(
                      systemName: choice == challenge.correctAnswer
                        ? "checkmark.circle.fill" : "xmark.circle.fill"
                    )
                  }
                }
                .adaptiveFont(size: 13, weight: .semibold, design: .rounded)
                .padding(12)
                .foregroundStyle(.white)
                .background(AppPalette.card, in: RoundedRectangle(cornerRadius: 12))
              }
              .buttonStyle(.plain)
            }

            if practiceAnswers[index] != nil {
              Text(challenge.explanation)
                .adaptiveFont(size: 12, design: .rounded)
                .foregroundStyle(AppPalette.secondaryText)
            }
          }
        }
      }
      .padding(18)
      .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 20))
    }
  }

  @ViewBuilder
  private var assessmentPanel: some View {
    if !lesson.assessmentTasks.isEmpty {
      VStack(alignment: .leading, spacing: 14) {
        Label("ÇIKIŞ DEĞERLENDİRMESİ", systemImage: "checklist.checked")
          .adaptiveFont(size: 12, weight: .bold, design: .rounded)
          .foregroundStyle(AppPalette.mint)

        ForEach(lesson.assessmentTasks, id: \.kind.rawValue) { task in
          Label(task.prompt, systemImage: task.kind.icon)
            .adaptiveFont(size: 13, design: .rounded)
            .foregroundStyle(.white)
        }

        if lesson.assessmentTasks.contains(where: { $0.kind == .freeExplanation }) {
          TextField(
            "Kodu kendi cümlenle açıkla",
            text: $assessmentExplanation,
            axis: .vertical
          )
          .lineLimit(3...6)
          .padding(14)
          .foregroundStyle(.white)
          .background(AppPalette.codeBackground, in: RoundedRectangle(cornerRadius: 14))
        }
      }
      .padding(18)
      .background(AppPalette.mint.opacity(0.07), in: RoundedRectangle(cornerRadius: 20))
    }
  }

  private var mentorPanel: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack {
        Label("SOKRATİK MENTOR", systemImage: "sparkles")
          .adaptiveFont(size: 12, weight: .bold, design: .rounded)
          .foregroundStyle(AppPalette.indigo)
        Spacer()
        Text(OnDeviceMentor.isAvailable ? "Cihaz içi AI" : "Yerel rehber")
          .adaptiveFont(size: 10, weight: .semibold, design: .rounded)
          .foregroundStyle(OnDeviceMentor.isAvailable ? AppPalette.mint : AppPalette.secondaryText)
        Text("\(mentorSession.remainingTurns) tur")
          .adaptiveFont(size: 11, weight: .semibold, design: .rounded)
          .foregroundStyle(AppPalette.secondaryText)
      }

      Text("Cevabı istemek yerine kodun neden böyle çalıştığını kendi cümlenle anlat.")
        .adaptiveFont(size: 13, design: .rounded)
        .foregroundStyle(AppPalette.secondaryText)

      ForEach(Array(mentorResponses.enumerated()), id: \.offset) { _, response in
        Text(response.text)
          .adaptiveFont(size: 13, weight: .semibold, design: .rounded)
          .foregroundStyle(response.kind == .feedback ? AppPalette.mint : .white)
          .padding(12)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(AppPalette.codeBackground, in: RoundedRectangle(cornerRadius: 12))
      }

      TextField("Açıklamanı yaz", text: $mentorInput, axis: .vertical)
        .lineLimit(2...4)
        .padding(14)
        .foregroundStyle(.white)
        .background(AppPalette.codeBackground, in: RoundedRectangle(cornerRadius: 14))

      Button {
        askMentor()
      } label: {
        HStack(spacing: 8) {
          if isMentorResponding {
            ProgressView()
              .tint(.white)
          }
          Text(isMentorResponding ? "Mentor düşünüyor" : "Mentora sor")
        }
        .frame(maxWidth: .infinity)
      }
      .adaptiveFont(size: 14, weight: .bold, design: .rounded)
      .padding(14)
      .foregroundStyle(.white)
      .background(AppPalette.indigo, in: RoundedRectangle(cornerRadius: 14))
      .disabled(
        isMentorResponding
          || mentorInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      )
    }
    .padding(18)
    .background(AppPalette.indigo.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
  }

  private var lessonActions: some View {
    VStack(spacing: 14) {
      HStack(spacing: 12) {
        Image(systemName: "lightbulb.max.fill")
          .foregroundStyle(AppPalette.amber)
        Text("Gerçek ders: \(lesson.takeaway)")
          .adaptiveFont(size: 15, weight: .semibold, design: .rounded)
          .foregroundStyle(.white)
          .fixedSize(horizontal: false, vertical: true)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(18)
      .background(AppPalette.amber.opacity(0.1), in: RoundedRectangle(cornerRadius: 18))

      Button {
        onComplete(run.finish(session: session, completedAt: Date()))
        dismiss()
      } label: {
        HStack {
          Text("Dersi tamamla")
          Spacer()
          Image(systemName: "checkmark")
        }
        .adaptiveFont(size: 16, weight: .bold, design: .rounded)
        .foregroundStyle(AppPalette.background)
        .padding(18)
        .background(AppPalette.mint, in: RoundedRectangle(cornerRadius: 18))
      }
      .buttonStyle(.plain)

      Button {
        withAnimation(.snappy) {
          resetLesson()
        }
      } label: {
        Label("Dersi yeniden çöz", systemImage: "arrow.counterclockwise")
          .adaptiveFont(size: 15, weight: .bold, design: .rounded)
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

  private func resetLesson() {
    session = XRaySession(lesson: lesson)
    run = LessonRun(lessonID: lesson.id, startedAt: Date())
    selectedLanguage = .swift
    debugSession = lesson.debugChallenge.map { DebugSession(challenge: $0) }
    debugHypothesis = ""
    practiceAnswers = [:]
    mentorSession = SocraticMentorSession(
      lesson: lesson,
      requiredConcepts: lesson.mentorConcepts,
      turnLimit: 6
    )
    mentorInput = ""
    mentorResponses = []
    isMentorResponding = false
    assessmentExplanation = ""
  }

  private func askMentor() {
    let explanation = mentorInput.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !explanation.isEmpty else { return }

    mentorInput = ""
    let localResponse = mentorSession.reply(to: explanation)
    guard localResponse.kind == .question, OnDeviceMentor.isAvailable else {
      mentorResponses.append(localResponse)
      return
    }

    isMentorResponding = true
    let prompt = MentorPromptBuilder.build(
      lesson: lesson,
      userExplanation: explanation,
      matchedConcepts: localResponse.matchedConcepts
    )

    Task {
      defer { isMentorResponding = false }
      do {
        let generated = try await OnDeviceMentor.reply(to: prompt)
        let safeText = MentorSafetyFilter(correctAnswer: lesson.correctAnswer)
          .sanitize(generated)
        mentorResponses.append(
          MentorResponse(
            kind: .question,
            text: safeText,
            matchedConcepts: localResponse.matchedConcepts
          )
        )
      } catch {
        mentorResponses.append(localResponse)
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
  let languageLabel: String

  init(
    lines: [CodeLine],
    activeLineNumber: Int?,
    languageLabel: String = "SWIFT"
  ) {
    self.lines = lines
    self.activeLineNumber = activeLineNumber
    self.languageLabel = languageLabel
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        HStack(spacing: 7) {
          Circle().fill(Color.red.opacity(0.8)).frame(width: 9, height: 9)
          Circle().fill(AppPalette.amber.opacity(0.8)).frame(width: 9, height: 9)
          Circle().fill(AppPalette.mint.opacity(0.8)).frame(width: 9, height: 9)
        }

        Spacer()

        Text(languageLabel)
          .adaptiveFont(size: 10, weight: .bold, design: .rounded)
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
              .adaptiveFont(size: 13, design: .monospaced)
              .foregroundStyle(
                activeLineNumber == line.number
                  ? AppPalette.mint
                  : AppPalette.tertiaryText
              )
              .frame(width: 18, alignment: .trailing)

            Text(highlightedCode(line.text))
              .adaptiveFont(size: 15, weight: .medium, design: .monospaced)
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

    for keyword in [
      "var", "let", "if", "else", "for", "in", "print", "func", "return", "class", "struct",
      "def", "function",
    ] {
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
          .adaptiveFont(size: 12, weight: .bold, design: .rounded)
          .tracking(0.8)
          .foregroundStyle(AppPalette.mint)
        Spacer()
        Text("Şu an çalışıyor")
          .adaptiveFont(size: 12, weight: .medium, design: .rounded)
          .foregroundStyle(AppPalette.secondaryText)
      }

      Text(step.explanation)
        .adaptiveFont(size: 17, weight: .semibold, design: .rounded)
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

      if !step.callStack.isEmpty {
        VStack(alignment: .leading, spacing: 10) {
          Label("ÇAĞRI YIĞINI", systemImage: "square.3.layers.3d")
            .adaptiveFont(size: 10, weight: .bold, design: .rounded)
            .tracking(0.8)
            .foregroundStyle(AppPalette.secondaryText)

          ForEach(Array(step.callStack.enumerated()), id: \.offset) { index, frame in
            HStack(alignment: .top, spacing: 10) {
              Text("\(index + 1)")
                .adaptiveFont(size: 11, weight: .bold, design: .monospaced)
                .foregroundStyle(AppPalette.indigo)
                .frame(width: 22, height: 22)
                .background(AppPalette.indigo.opacity(0.12), in: Circle())

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
            .adaptiveFont(size: 10, weight: .bold, design: .rounded)
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
                .foregroundStyle(AppPalette.indigo)
              Image(systemName: "arrow.right")
                .foregroundStyle(AppPalette.tertiaryText)
              Text(relation.label)
                .foregroundStyle(AppPalette.secondaryText)
              Image(systemName: "arrow.right")
                .foregroundStyle(AppPalette.tertiaryText)
              Text(target)
                .foregroundStyle(AppPalette.mint)
            }
            .adaptiveFont(size: 11, weight: .semibold, design: .rounded)
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
        .adaptiveFont(size: 10, weight: .bold, design: .rounded)
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

extension CurriculumSection {
  fileprivate var displayName: String {
    switch self {
    case .fundamentals: "TEMEL MEKANİK"
    case .functions: "FONKSİYONLAR VE VERİ AKIŞI"
    case .collections: "KOLEKSİYONLAR"
    case .objects: "NESNELER VE MİMARİ"
    case .debugging: "HATA AVCILIĞI"
    case .asynchronous: "ASENKRON DÜŞÜNME"
    case .appArchitecture: "GERÇEK UYGULAMA AKIŞI"
    case .assessment: "ÇIKIŞ DEĞERLENDİRMESİ"
    }
  }

  fileprivate var accentColor: Color {
    switch self {
    case .fundamentals, .collections, .asynchronous:
      AppPalette.mint
    case .functions, .objects, .appArchitecture:
      AppPalette.indigo
    case .debugging, .assessment:
      AppPalette.amber
    }
  }
}

extension CodeLanguage {
  fileprivate var displayName: String {
    switch self {
    case .swift: "Swift"
    case .python: "Python"
    case .javascript: "JavaScript"
    }
  }
}

extension CodeLens {
  fileprivate var displayName: String {
    switch self {
    case .flow: "Akış"
    case .memory: "Hafıza"
    case .output: "Çıktı"
    case .call: "Çağrı"
    case .architecture: "Mimari"
    case .error: "Hata"
    case .language: "Dil"
    }
  }

  fileprivate var icon: String {
    switch self {
    case .flow: "arrow.triangle.branch"
    case .memory: "memorychip"
    case .output: "terminal"
    case .call: "square.3.layers.3d"
    case .architecture: "point.3.connected.trianglepath.dotted"
    case .error: "ladybug"
    case .language: "character.bubble"
    }
  }

  fileprivate var accentColor: Color {
    switch self {
    case .error:
      AppPalette.amber
    case .call, .architecture, .language:
      AppPalette.indigo
    case .flow, .memory, .output:
      AppPalette.mint
    }
  }
}

extension AssessmentTaskKind {
  fileprivate var icon: String {
    switch self {
    case .outputPrediction: "terminal"
    case .valueTrace: "memorychip"
    case .callOrder: "square.3.layers.3d"
    case .errorLocation: "ladybug"
    case .freeExplanation: "text.bubble"
    }
  }
}

extension XRayLesson {
  fileprivate var mentorConcepts: [String] {
    switch id {
    case "variables":
      ["puan", "koşul", "değişir"]
    case "conditions", "compound-conditions":
      ["koşul", "doğru", "yol"]
    case "loops":
      ["döngü", "tur", "toplam"]
    case "function-call", "parameters-return", "scope", "pure-side-effects":
      ["fonksiyon", "çağrı", "değer"]
    case "class-instance", "property-method", "initializer":
      ["instance", "property", "değer"]
    case "logic-errors", "edge-cases", "optionals", "stack-traces", "debug-hypothesis":
      ["beklenen", "gerçek", "satır"]
    default:
      ["değer", "akış", "satır"]
    }
  }
}

private struct ScaledFontModifier: ViewModifier {
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
  fileprivate func adaptiveFont(
    size: CGFloat,
    weight: Font.Weight = .regular,
    design: Font.Design = .default
  ) -> some View {
    modifier(ScaledFontModifier(size: size, weight: weight, design: design))
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
