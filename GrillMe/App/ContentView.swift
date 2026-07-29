import SwiftUI

struct ContentView: View {
  private let catalog = LessonCatalog.standard
  private let progressStore: FileProgressStore
  @State private var progress: LessonProgress
  @State private var persistenceNotice: String?

  init() {
    let store = FileProgressStore(
      fileURL: URL.applicationSupportDirectory
        .appendingPathComponent("grillme-progress.json")
    )
    let loadResult = store.loadRecovering()
    progressStore = store
    _progress = State(initialValue: loadResult.progress)
    _persistenceNotice = State(initialValue: loadResult.notice)
  }

  var body: some View {
    TabView {
      NavigationStack {
        LessonMapView(
          items: catalog.items(completedLessonIDs: progress.completedLessonIDs),
          totalLessonCount: catalog.lessons.count,
          dashboard: LearningDashboardSnapshot(
            progress: progress,
            totalLessonCount: catalog.lessons.count,
            asOf: Date()
          ),
          onLessonCompleted: complete
        )
      }
      .tabItem {
        Label("Yol Haritası", systemImage: "map.fill")
      }

      NavigationStack {
        LessonContentsView(
          catalog: catalog,
          completedLessonIDs: progress.completedLessonIDs,
          onLessonCompleted: complete
        )
      }
      .tabItem {
        Label("İçindekiler", systemImage: "list.bullet.rectangle.portrait.fill")
      }
    }
    .tint(AppPalette.mint)
    .toolbarBackground(AppPalette.panel, for: .tabBar)
    .toolbarBackground(.visible, for: .tabBar)
    .toolbarColorScheme(.dark, for: .tabBar)
    .alert(
      "İlerleme kaydı",
      isPresented: Binding(
        get: { persistenceNotice != nil },
        set: { isPresented in
          if !isPresented {
            persistenceNotice = nil
          }
        }
      )
    ) {
      Button("Tamam", role: .cancel) {
        persistenceNotice = nil
      }
    } message: {
      Text(persistenceNotice ?? "")
    }
  }

  private func complete(_ result: LessonRunResult) {
    progress.record(result)
    do {
      try progressStore.save(progress)
    } catch {
      persistenceNotice =
        "Ders tamamlandı ancak ilerleme cihaza kaydedilemedi. Uygulamayı kapatmadan önce tekrar dene. Hata: \(error.localizedDescription)"
    }
  }
}

private struct LessonMapView: View {
  let items: [LessonCatalogItem]
  let totalLessonCount: Int
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
      Group {
        if dynamicTypeSize.isAccessibilitySize {
          VStack(alignment: .leading, spacing: 18) {
            progressCopy
            progressRing
          }
        } else {
          HStack(alignment: .top) {
            progressCopy
            Spacer(minLength: 16)
            progressRing
          }
        }
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

  private var progressCopy: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Kodun içini\nokumaya başla")
        .adaptiveFont(size: 32, weight: .bold, design: .rounded)
        .foregroundStyle(.white)
        .fixedSize(horizontal: false, vertical: true)

      Text("Önce konuyu öğren, örneği adım adım izle ve en son quizde uygula.")
        .adaptiveFont(size: 15, design: .rounded)
        .foregroundStyle(AppPalette.secondaryText)
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  private var progressRing: some View {
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
          .font(.system(size: 21, weight: .bold, design: .rounded))
          .foregroundStyle(.white)
        Text("/ \(dashboard.totalCount)")
          .font(.system(size: 10, weight: .semibold, design: .rounded))
          .foregroundStyle(AppPalette.secondaryText)
      }
    }
    .frame(width: 82, height: 82)
    .accessibilityLabel(
      "\(dashboard.totalCount) dersten \(dashboard.completedCount) tanesi tamamlandı"
    )
  }

  private var weeklySummary: some View {
    LazyVGrid(
      columns: dynamicTypeSize.isAccessibilitySize
        ? [GridItem(.flexible())]
        : [GridItem(.flexible()), GridItem(.flexible())],
      spacing: 16
    ) {
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
        value: percentage(dashboard.weeklySummary.quizAccuracy),
        label: "Quiz",
        icon: "scope"
      )
      summaryMetric(
        value: percentage(dashboard.weeklySummary.practiceAccuracy),
        label: "Pratik doğruluğu",
        icon: "brain.head.profile"
      )
      summaryMetric(
        value: percentage(dashboard.weeklySummary.assessmentScore),
        label: "Rubrik puanı",
        icon: "checklist.checked"
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
            "Başlangıç quizi \(percentage(report.baselineQuizAccuracy)) · Çıkış quizi \(percentage(report.exitQuizAccuracy))"
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

  private func percentage(_ value: Double?) -> String {
    guard let value else { return "—" }
    return "\(Int((value * 100).rounded()))%"
  }

  private func lessonDestination(for item: LessonCatalogItem) -> some View {
    NavigationLink {
      XRayLessonView(
        lesson: item.lesson,
        totalLessonCount: totalLessonCount,
        onComplete: onLessonCompleted
      )
    } label: {
      LessonRow(item: item)
    }
    .buttonStyle(.plain)
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
        Text("Temelden teknik analize uzanan \(totalLessonCount) ders hazır.")
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

private struct LessonContentsView: View {
  let catalog: LessonCatalog
  let completedLessonIDs: Set<String>
  let onLessonCompleted: (LessonRunResult) -> Void
  @State private var searchQuery = ""
  @State private var selectedSection: CurriculumSection?

  private var sections: [LessonContentsSection] {
    let matches = catalog.contents(
      query: searchQuery,
      completedLessonIDs: completedLessonIDs
    )
    guard let selectedSection else { return matches }
    return matches.filter { $0.section == selectedSection }
  }

  private var resultCount: Int {
    sections.reduce(0) { $0 + $1.items.count }
  }

  var body: some View {
    ZStack {
      AppPalette.background
        .ignoresSafeArea()

      RadialGradient(
        colors: [AppPalette.indigo.opacity(0.2), .clear],
        center: .topTrailing,
        startRadius: 10,
        endRadius: 420
      )
      .ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          contentsIntro
          sectionPicker

          if sections.isEmpty {
            emptyResults
          } else {
            ForEach(sections, id: \.section) { group in
              lessonSection(group)
            }
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 40)
      }
      .scrollIndicators(.hidden)
    }
    .navigationTitle("İçindekiler")
    .navigationBarTitleDisplayMode(.large)
    .toolbarBackground(AppPalette.background, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbarColorScheme(.dark, for: .navigationBar)
    .searchable(
      text: $searchQuery,
      placement: .navigationBarDrawer(displayMode: .always),
      prompt: "Ders, konu veya kavram ara"
    )
  }

  private var contentsIntro: some View {
    VStack(alignment: .leading, spacing: 12) {
      Label("SERBEST DERS KATALOĞU", systemImage: "books.vertical.fill")
        .adaptiveFont(size: 12, weight: .bold, design: .rounded)
        .tracking(1)
        .foregroundStyle(AppPalette.mint)

      Text("İstediğin konudan başla")
        .adaptiveFont(size: 27, weight: .bold, design: .rounded)
        .foregroundStyle(.white)

      Text(
        "Tüm \(catalog.lessons.count) ders açık. Konuya göre filtrele, aradığın kavramı bul ve doğrudan derse gir."
      )
      .adaptiveFont(size: 15, design: .rounded)
      .foregroundStyle(AppPalette.secondaryText)
      .fixedSize(horizontal: false, vertical: true)

      ViewThatFits(in: .horizontal) {
        HStack(spacing: 14) {
          contentsMetrics
        }
        VStack(alignment: .leading, spacing: 8) {
          contentsMetrics
        }
      }
      .adaptiveFont(size: 12, weight: .bold, design: .rounded)
      .foregroundStyle(AppPalette.amber)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 24))
    .overlay(
      RoundedRectangle(cornerRadius: 24)
        .stroke(AppPalette.border, lineWidth: 1)
    )
  }

  @ViewBuilder
  private var contentsMetrics: some View {
    Label("\(resultCount) ders", systemImage: "book.pages")
    Label("\(CurriculumSection.allCases.count) bölüm", systemImage: "square.grid.2x2")
  }

  private var sectionPicker: some View {
    ScrollView(.horizontal) {
      HStack(spacing: 9) {
        sectionButton(title: "TÜMÜ", section: nil)

        ForEach(CurriculumSection.allCases, id: \.self) { section in
          sectionButton(title: section.displayName, section: section)
        }
      }
      .padding(.vertical, 1)
    }
    .scrollIndicators(.hidden)
    .accessibilityLabel("İçindekiler bölüm filtresi")
  }

  private func sectionButton(
    title: String,
    section: CurriculumSection?
  ) -> some View {
    let isSelected = selectedSection == section
    return Button {
      withAnimation(.snappy) {
        selectedSection = section
      }
    } label: {
      Text(title)
        .adaptiveFont(size: 11, weight: .bold, design: .rounded)
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .foregroundStyle(isSelected ? AppPalette.background : AppPalette.secondaryText)
        .background(isSelected ? AppPalette.mint : AppPalette.card, in: Capsule())
        .overlay(
          Capsule()
            .stroke(isSelected ? AppPalette.mint : AppPalette.border, lineWidth: 1)
        )
    }
    .buttonStyle(.plain)
  }

  private func lessonSection(_ group: LessonContentsSection) -> some View {
    VStack(alignment: .leading, spacing: 15) {
      HStack {
        Text(group.section.displayName)
          .adaptiveFont(size: 12, weight: .bold, design: .rounded)
          .tracking(1.1)
          .foregroundStyle(group.section.accentColor)

        Spacer()

        Text("\(group.items.count) ders")
          .adaptiveFont(size: 11, weight: .semibold, design: .rounded)
          .foregroundStyle(AppPalette.tertiaryText)
      }

      ForEach(group.items, id: \.lesson.id) { item in
        NavigationLink {
          XRayLessonView(
            lesson: item.lesson,
            totalLessonCount: catalog.lessons.count,
            onComplete: onLessonCompleted
          )
        } label: {
          LessonRow(item: item)
        }
        .buttonStyle(.plain)
      }
    }
  }

  private var emptyResults: some View {
    VStack(spacing: 12) {
      Image(systemName: "magnifyingglass")
        .adaptiveFont(size: 28, weight: .semibold)
        .foregroundStyle(AppPalette.indigo)

      Text("Bu aramayla eşleşen ders yok")
        .adaptiveFont(size: 18, weight: .bold, design: .rounded)
        .foregroundStyle(.white)

      Text("Başka bir konu veya kavram deneyebilirsin.")
        .adaptiveFont(size: 14, design: .rounded)
        .foregroundStyle(AppPalette.secondaryText)

      Button("Filtreleri temizle") {
        searchQuery = ""
        selectedSection = nil
      }
      .adaptiveFont(size: 14, weight: .bold, design: .rounded)
      .foregroundStyle(AppPalette.mint)
    }
    .frame(maxWidth: .infinity)
    .padding(28)
    .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 22))
    .overlay(
      RoundedRectangle(cornerRadius: 22)
        .stroke(AppPalette.border, lineWidth: 1)
    )
  }
}

private struct LessonRow: View {
  let item: LessonCatalogItem
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    Group {
      if dynamicTypeSize.isAccessibilitySize {
        VStack(alignment: .leading, spacing: 14) {
          HStack {
            badge
            Spacer()
            disclosureIndicator
          }
          lessonDetails
        }
      } else {
        HStack(spacing: 15) {
          badge
          lessonDetails
          Spacer(minLength: 6)
          disclosureIndicator
        }
      }
    }
    .padding(18)
    .background(
      item.status == .available
        ? AppPalette.card
        : AppPalette.panel,
      in: RoundedRectangle(cornerRadius: 22)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 22)
        .stroke(
          item.status == .available ? AppPalette.mint.opacity(0.34) : AppPalette.border,
          lineWidth: 1
        )
    )
    .accessibilityElement(children: .combine)
    .accessibilityLabel(accessibilityDescription)
  }

  private var badge: some View {
    ZStack {
      Circle()
        .fill(badgeColor.opacity(0.16))
      Circle()
        .stroke(badgeColor.opacity(0.45), lineWidth: 1)

      if item.status == .completed {
        Image(systemName: "checkmark")
          .font(.system(size: 15, weight: .bold))
      } else {
        Text("\(item.lesson.order)")
          .font(.system(size: 16, weight: .bold, design: .rounded))
      }
    }
    .foregroundStyle(badgeColor)
    .frame(width: 48, height: 48)
  }

  private var lessonDetails: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text("DERS \(String(format: "%02d", item.lesson.order)) · \(item.lesson.topic)")
        .adaptiveFont(size: 10, weight: .bold, design: .rounded)
        .tracking(0.8)
        .foregroundStyle(badgeColor)

      Text(item.lesson.title)
        .adaptiveFont(size: 18, weight: .bold, design: .rounded)
        .foregroundStyle(.white)

      Text(item.lesson.objective)
        .adaptiveFont(size: 12, design: .rounded)
        .foregroundStyle(AppPalette.secondaryText)
        .fixedSize(horizontal: false, vertical: true)

      ViewThatFits(in: .horizontal) {
        HStack(spacing: 10) {
          lessonMetadata
        }
        VStack(alignment: .leading, spacing: 6) {
          lessonMetadata
        }
      }
      .adaptiveFont(size: 10, weight: .semibold, design: .rounded)
      .foregroundStyle(AppPalette.tertiaryText)
    }
  }

  @ViewBuilder
  private var lessonMetadata: some View {
    Label("\(item.lesson.estimatedMinutes) dk", systemImage: "clock")
    Label("\(item.lesson.availableLenses.count) lens", systemImage: "scope")
  }

  private var disclosureIndicator: some View {
    Image(systemName: "chevron.right")
      .adaptiveFont(size: 12, weight: .bold)
      .foregroundStyle(badgeColor)
  }

  private var badgeColor: Color {
    switch item.status {
    case .completed:
      AppPalette.mint
    case .available:
      AppPalette.amber
    }
  }

  private var accessibilityDescription: String {
    let status: String
    switch item.status {
    case .completed:
      status = "tamamlandı"
    case .available:
      status = "açık"
    }
    return "\(item.lesson.order). ders, \(item.lesson.title), \(status)"
  }
}

private struct XRayLessonView: View {
  let lesson: XRayLesson
  let totalLessonCount: Int
  let onComplete: (LessonRunResult) -> Void
  @Environment(\.dismiss) private var dismiss
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @State private var journey: LessonJourney
  @State private var run: LessonRun
  @State private var selectedLanguage: CodeLanguage = .swift
  @State private var debugSession: DebugSession?
  @State private var debugHypothesis = ""
  @State private var practiceAnswers: [Int: String] = [:]
  @State private var mentorCoordinator: MentorCoordinator
  @State private var mentorInput = ""
  @State private var mentorResponses: [MentorResponse] = []
  @State private var isMentorResponding = false
  @State private var assessmentResponses: [AssessmentTaskKind: String] = [:]
  @State private var mentorTask: Task<Void, Never>?

  init(
    lesson: XRayLesson,
    totalLessonCount: Int,
    onComplete: @escaping (LessonRunResult) -> Void
  ) {
    self.lesson = lesson
    self.totalLessonCount = totalLessonCount
    self.onComplete = onComplete
    _journey = State(initialValue: LessonJourney(lesson: lesson))
    _run = State(initialValue: LessonRun(lessonID: lesson.id, startedAt: Date()))
    _debugSession = State(
      initialValue: lesson.debugChallenge.map { DebugSession(challenge: $0) }
    )
    _mentorCoordinator = State(
      initialValue: MentorCoordinator(
        session: SocraticMentorSession(
          lesson: lesson,
          requiredConcepts: lesson.mentorConcepts,
          turnLimit: 6
        ),
        correctAnswer: lesson.correctAnswer
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
          lessonStage
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
    .onDisappear {
      mentorTask?.cancel()
    }
  }

  private var header: some View {
    VStack(spacing: 14) {
      Group {
        if dynamicTypeSize.isAccessibilitySize {
          VStack(alignment: .leading, spacing: 12) {
            lessonHeaderBrand
            lessonPosition
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        } else {
          HStack {
            lessonHeaderBrand
            Spacer()
            lessonPosition
          }
        }
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
            .frame(
              width: max(
                18,
                geometry.size.width * Double(lesson.order) / Double(totalLessonCount)
              )
            )
        }
      }
      .frame(height: 5)
      .accessibilityLabel("\(totalLessonCount) derslik yolculuğun \(lesson.order). dersi")
    }
  }

  private var lessonHeaderBrand: some View {
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
  }

  private var lessonPosition: some View {
    Label("\(lesson.order) / \(totalLessonCount)", systemImage: "flame.fill")
      .adaptiveFont(size: 13, weight: .semibold, design: .rounded)
      .foregroundStyle(AppPalette.amber)
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(AppPalette.card, in: Capsule())
      .overlay(Capsule().stroke(AppPalette.border, lineWidth: 1))
  }

  private var lessonHeading: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("DERS \(String(format: "%02d", lesson.order))  ·  \(lesson.topic)")
        .adaptiveFont(size: 12, weight: .bold, design: .rounded)
        .tracking(1.2)
        .foregroundStyle(AppPalette.mint)

      Text(lesson.title)
        .adaptiveFont(size: 34, weight: .bold, design: .rounded)
        .foregroundStyle(.white)

      Text(stageInstruction)
        .adaptiveFont(size: 16, weight: .regular, design: .rounded)
        .foregroundStyle(AppPalette.secondaryText)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  @ViewBuilder
  private var lessonStage: some View {
    switch journey.phase {
    case .topic:
      topicPanel

    case .example:
      lensStrip
      languagePicker
      CodeCard(
        lines: lesson.code(for: selectedLanguage),
        activeLineNumber:
          selectedLanguage == .swift ? journey.currentExampleStep?.lineNumber : nil,
        languageLabel: selectedLanguage.displayName.uppercased()
      )
      languageComparison
      examplePanel

    case .quiz:
      quizPanel

    case .complete:
      completionPanel
    }
  }

  private var stageInstruction: String {
    switch journey.phase {
    case .topic:
      "Önce konuyu anlayalım. Soru çözmeden önce sağlam bir zihinsel model kur."
    case .example:
      "Şimdi konu ile ilgili örneği bilgisayarın çalışma sırasıyla incele."
    case .quiz:
      "Son adım: öğrendiğini yeni bir kod üzerinde kendi başına uygula."
    case .complete:
      "Quiz tamamlandı. Sonucu incele ve öğrendiğin fikri kendi cümlenle özetle."
    }
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

        if dynamicTypeSize.isAccessibilitySize {
          Picker("Kod dili", selection: $selectedLanguage) {
            ForEach(lesson.availableLanguages, id: \.rawValue) { language in
              Text(language.displayName).tag(language)
            }
          }
          .pickerStyle(.menu)
        } else {
          Picker("Kod dili", selection: $selectedLanguage) {
            ForEach(lesson.availableLanguages, id: \.rawValue) { language in
              Text(language.displayName).tag(language)
            }
          }
          .pickerStyle(.segmented)
        }
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

  private var topicPanel: some View {
    VStack(alignment: .leading, spacing: 20) {
      stageMap

      Label("KONU ANLATIMI", systemImage: "book.pages.fill")
        .adaptiveFont(size: 12, weight: .bold, design: .rounded)
        .tracking(1)
        .foregroundStyle(AppPalette.mint)

      Text(journey.teachingContent.explanation)
        .adaptiveFont(size: 20, weight: .semibold, design: .rounded)
        .foregroundStyle(.white)
        .fixedSize(horizontal: false, vertical: true)

      HStack(alignment: .top, spacing: 12) {
        Image(systemName: "lightbulb.max.fill")
          .foregroundStyle(AppPalette.amber)

        VStack(alignment: .leading, spacing: 5) {
          Text("AKLINDA KALSIN")
            .adaptiveFont(size: 11, weight: .bold, design: .rounded)
            .tracking(0.8)
            .foregroundStyle(AppPalette.amber)
          Text(journey.teachingContent.keyIdea)
            .adaptiveFont(size: 15, weight: .semibold, design: .rounded)
            .foregroundStyle(.white)
        }
      }
      .padding(16)
      .background(AppPalette.amber.opacity(0.09), in: RoundedRectangle(cornerRadius: 16))

      Button {
        withAnimation(.snappy) {
          journey.startExample()
        }
      } label: {
        HStack {
          Text("Konu ile ilgili örneğe geç")
          Spacer()
          Image(systemName: "arrow.right")
        }
        .adaptiveFont(size: 16, weight: .bold, design: .rounded)
        .foregroundStyle(AppPalette.background)
        .padding(18)
        .background(AppPalette.mint, in: RoundedRectangle(cornerRadius: 18))
      }
      .buttonStyle(.plain)
      .accessibilityHint("Rehberli kod örneğini açar")
    }
    .padding(20)
    .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 24))
    .overlay(
      RoundedRectangle(cornerRadius: 24)
        .stroke(AppPalette.border, lineWidth: 1)
    )
  }

  private var stageMap: some View {
    Group {
      if dynamicTypeSize.isAccessibilitySize {
        VStack(alignment: .leading, spacing: 8) {
          stageBadge(number: 1, title: "Konu", isActive: journey.phase == .topic)
          Image(systemName: "chevron.down")
            .foregroundStyle(AppPalette.tertiaryText)
          exampleStageBadge
          Image(systemName: "chevron.down")
            .foregroundStyle(AppPalette.tertiaryText)
          stageBadge(number: 3, title: "Quiz", isActive: journey.phase == .quiz)
        }
      } else {
        HStack(spacing: 8) {
          stageBadge(number: 1, title: "Konu", isActive: journey.phase == .topic)
          Image(systemName: "chevron.right")
            .foregroundStyle(AppPalette.tertiaryText)
          exampleStageBadge
          Image(systemName: "chevron.right")
            .foregroundStyle(AppPalette.tertiaryText)
          stageBadge(number: 3, title: "Quiz", isActive: journey.phase == .quiz)
        }
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Ders sırası: konu anlatımı, örnek, quiz")
  }

  private var exampleStageBadge: some View {
    stageBadge(
      number: 2,
      title: "Örnek",
      isActive: {
        if case .example = journey.phase { return true }
        return false
      }()
    )
  }

  private func stageBadge(
    number: Int,
    title: String,
    isActive: Bool
  ) -> some View {
    HStack(spacing: 6) {
      Text("\(number)")
        .frame(width: 22, height: 22)
        .background(isActive ? AppPalette.mint : AppPalette.card, in: Circle())
        .foregroundStyle(isActive ? AppPalette.background : AppPalette.secondaryText)
      Text(title)
    }
    .adaptiveFont(size: 11, weight: .bold, design: .rounded)
    .foregroundStyle(isActive ? .white : AppPalette.secondaryText)
  }

  private var examplePanel: some View {
    VStack(spacing: 16) {
      HStack(spacing: 12) {
        Image(systemName: "eye.fill")
          .foregroundStyle(AppPalette.mint)
          .frame(width: 32, height: 32)
          .background(AppPalette.mint.opacity(0.12), in: Circle())

        VStack(alignment: .leading, spacing: 3) {
          Text("KONU İLE İLGİLİ ÖRNEK")
            .adaptiveFont(size: 12, weight: .bold, design: .rounded)
            .tracking(0.8)
            .foregroundStyle(AppPalette.mint)
          Text("Kodun nasıl çalıştığını adım adım birlikte izliyoruz.")
            .adaptiveFont(size: 13, design: .rounded)
            .foregroundStyle(AppPalette.secondaryText)
        }

        Spacer()

        Text(exampleProgress)
          .adaptiveFont(size: 12, weight: .semibold, design: .rounded)
          .foregroundStyle(AppPalette.mint)
      }
      .padding(16)
      .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 18))

      if let step = journey.currentExampleStep {
        TraceInspector(step: step)
          .transition(.opacity.combined(with: .move(edge: .bottom)))
          .id(step.lineNumber)
      }

      exampleAction
    }
    .animation(.snappy, value: journey.phase)
  }

  @ViewBuilder
  private var exampleAction: some View {
    if case .example(let step) = journey.phase {
      Button {
        withAnimation(.snappy) {
          journey.advanceExample()
        }
      } label: {
        HStack {
          Text(
            step == lesson.trace.count - 1
              ? "Örneği anladım, quiz'e geç" : "Sonraki adımı göster"
          )
          Spacer()
          Image(systemName: "arrow.right")
        }
        .adaptiveFont(size: 16, weight: .bold, design: .rounded)
        .foregroundStyle(AppPalette.background)
        .padding(18)
        .background(AppPalette.mint, in: RoundedRectangle(cornerRadius: 18))
      }
      .buttonStyle(.plain)
    }
  }

  private var quizPanel: some View {
    let quiz = journey.quiz
    return VStack(alignment: .leading, spacing: 18) {
      stageMap

      Label("SON ADIM · QUIZ", systemImage: "checkmark.diamond.fill")
        .adaptiveFont(size: 12, weight: .bold, design: .rounded)
        .tracking(1)
        .foregroundStyle(AppPalette.indigo)

      Text("Şimdi sıra sende")
        .adaptiveFont(size: 24, weight: .bold, design: .rounded)
        .foregroundStyle(.white)

      Text(quiz.prompt)
        .adaptiveFont(size: 18, weight: .semibold, design: .rounded)
        .foregroundStyle(AppPalette.secondaryText)
        .fixedSize(horizontal: false, vertical: true)

      CodeCard(lines: quiz.code, activeLineNumber: nil)

      if quiz.choices.allSatisfy({ $0.count <= 3 }) {
        HStack(spacing: 12) {
          ForEach(quiz.choices, id: \.self) { choice in
            quizButton(choice)
          }
        }
      } else {
        VStack(spacing: 10) {
          ForEach(quiz.choices, id: \.self) { choice in
            quizButton(choice)
          }
        }
      }

      Text("Önce konu, sonra örnek, şimdi bağımsız uygulama. Yanlış cevap da öğrenmenin parçası.")
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

  private func quizButton(_ choice: String) -> some View {
    Button {
      withAnimation(.snappy) {
        journey.submitQuizAnswer(choice)
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
    .accessibilityHint("Quiz cevabını seçer")
  }

  private var completionPanel: some View {
    VStack(spacing: 14) {
      quizResult

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

  private var quizResult: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(
        systemName: journey.isQuizAnswerCorrect == true
          ? "checkmark.seal.fill" : "arrow.trianglehead.2.clockwise.rotate.90"
      )
      .adaptiveFont(size: 20, weight: .bold)
      .foregroundStyle(
        journey.isQuizAnswerCorrect == true ? AppPalette.mint : AppPalette.amber
      )

      VStack(alignment: .leading, spacing: 6) {
        Text(
          journey.isQuizAnswerCorrect == true
            ? "Quiz cevabın doğru" : "Doğru cevap: \(journey.quiz.correctAnswer)"
        )
        .adaptiveFont(size: 17, weight: .bold, design: .rounded)
        .foregroundStyle(.white)

        Text(journey.quiz.explanation)
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
          VStack(alignment: .leading, spacing: 10) {
            Label(task.prompt, systemImage: task.kind.icon)
              .adaptiveFont(size: 13, weight: .semibold, design: .rounded)
              .foregroundStyle(.white)

            TextField(
              "Kanıtını kendi cümlenle yaz",
              text: assessmentBinding(for: task.kind),
              axis: .vertical
            )
            .lineLimit(2...6)
            .padding(14)
            .foregroundStyle(.white)
            .background(AppPalette.codeBackground, in: RoundedRectangle(cornerRadius: 14))

            if let response = assessmentResponses[task.kind],
              !response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            {
              let evaluation = task.rubric.evaluate(response)
              VStack(alignment: .leading, spacing: 5) {
                Text("Rubrik puanı: \(Int((evaluation.score * 100).rounded()))%")
                  .adaptiveFont(size: 12, weight: .bold, design: .rounded)
                  .foregroundStyle(
                    evaluation.score == 1 ? AppPalette.mint : AppPalette.amber
                  )
                Text(evaluation.feedback)
                  .adaptiveFont(size: 12, design: .rounded)
                  .foregroundStyle(AppPalette.secondaryText)
              }
            }
          }
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
        Text("\(mentorCoordinator.remainingTurns) tur")
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

      if !evidenceEvaluation.isReadyToComplete {
        Label(
          missingEvidenceMessage,
          systemImage: "lock.open.trianglebadge.exclamationmark"
        )
        .adaptiveFont(size: 13, weight: .semibold, design: .rounded)
        .foregroundStyle(AppPalette.amber)
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      Button {
        guard
          let result = run.finish(
            journey: journey,
            evidence: evidenceEvaluation,
            completedAt: Date()
          )
        else {
          return
        }
        onComplete(result)
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
      .disabled(!evidenceEvaluation.isReadyToComplete)
      .opacity(evidenceEvaluation.isReadyToComplete ? 1 : 0.45)

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
    mentorTask?.cancel()
    mentorTask = nil
    journey = LessonJourney(lesson: lesson)
    run = LessonRun(lessonID: lesson.id, startedAt: Date())
    selectedLanguage = .swift
    debugSession = lesson.debugChallenge.map { DebugSession(challenge: $0) }
    debugHypothesis = ""
    practiceAnswers = [:]
    mentorCoordinator = MentorCoordinator(
      session: SocraticMentorSession(
        lesson: lesson,
        requiredConcepts: lesson.mentorConcepts,
        turnLimit: 6
      ),
      correctAnswer: lesson.correctAnswer
    )
    mentorInput = ""
    mentorResponses = []
    isMentorResponding = false
    assessmentResponses = [:]
  }

  private func askMentor() {
    let explanation = mentorInput
    guard
      let turn = mentorCoordinator.beginTurn(
        explanation: explanation,
        isModelAvailable: OnDeviceMentor.isAvailable
      )
    else {
      return
    }

    mentorInput = ""
    guard let prompt = turn.promptForModel else {
      mentorResponses.append(turn.localResponse)
      return
    }

    isMentorResponding = true
    mentorTask?.cancel()
    mentorTask = Task {
      defer { isMentorResponding = false }
      do {
        let generated = try await OnDeviceMentor.reply(to: prompt)
        guard !Task.isCancelled else { return }
        mentorResponses.append(mentorCoordinator.response(forGenerated: generated, in: turn))
      } catch is CancellationError {
        return
      } catch {
        guard !Task.isCancelled else { return }
        mentorResponses.append(turn.localResponse)
      }
    }
  }

  private var evidenceEvaluation: LessonEvidenceEvaluation {
    LessonEvidence(
      quizAnswer: journey.selectedQuizAnswer,
      practiceAnswers: practiceAnswers,
      assessmentResponses: assessmentResponses,
      debugCompleted: lesson.debugChallenge == nil || debugSession?.phase == .complete
    ).evaluate(for: lesson)
  }

  private var missingEvidenceMessage: String {
    let labels = evidenceEvaluation.missingRequirements
      .sorted { $0.rawValue < $1.rawValue }
      .map {
        switch $0 {
        case .quiz: "quiz"
        case .debugging: "hata ayıklama"
        case .practice: "ek pratik"
        case .assessment: "çıkış değerlendirmesi"
        }
      }
    return "Tamamlamak için eksik: \(labels.joined(separator: ", "))."
  }

  private func assessmentBinding(for kind: AssessmentTaskKind) -> Binding<String> {
    Binding(
      get: { assessmentResponses[kind, default: ""] },
      set: { assessmentResponses[kind] = $0 }
    )
  }

  private var exampleProgress: String {
    guard case .example(let step) = journey.phase else { return "" }
    return "ADIM \(step + 1)/\(lesson.trace.count)"
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

      ScrollView(.horizontal) {
        VStack(alignment: .leading, spacing: 3) {
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
                .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
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
        .frame(minWidth: 320, alignment: .leading)
        .padding(.vertical, 12)
      }
      .scrollIndicators(.visible)
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
    case .softwareTesting: "YAZILIM TESTİ"
    case .technicalAnalysis: "TEKNİK ANALİZ"
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
    case .softwareTesting:
      AppPalette.mint
    case .technicalAnalysis:
      AppPalette.indigo
    }
  }
}

extension CodeLanguage {
  fileprivate var displayName: String {
    switch self {
    case .swift: "Swift"
    case .python: "Python"
    case .javascript: "JavaScript"
    case .java: "Java"
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
