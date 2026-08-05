import SwiftUI

struct ContentView: View {
  /// Açılış ekranının en az görünür kalacağı süre.
  ///
  /// İlerleme dosyasını okumak çoğu cihazda birkaç milisaniye sürer; bu süre
  /// olmadan açılış ekranı göz kırpması gibi görünürdü. Marka için eklenmiş
  /// yapay bir bekleme değil, titremeyi önleyen alt sınırdır.
  private static let minimumSplashDuration = Duration.milliseconds(650)

  private let catalog = LessonCatalog.standard
  private let progressStore = FileProgressStore(
    fileURL: URL.applicationSupportDirectory
      .appendingPathComponent("grillme-progress.json")
  )
  @State private var progress = LessonProgress()
  /// Markdown kavram dersleri; paketten okunur, Swift koduna kopyalanmaz.
  @State private var readingCourse = ReadingCourse(
    id: ReadingLibrary.courseID,
    title: ReadingLibrary.courseTitle,
    summary: ReadingLibrary.courseSummary,
    modules: []
  )
  @State private var persistenceNotice: String?
  @State private var isWorkspaceReady = false
  /// Yol Haritası sekmesinin gezinme yığını; onboarding buraya ilk dersi iterek
  /// "İlk dersi aç" düğmesini gerçekten çalıştırır.
  @State private var roadmapPath: [String] = []

  var body: some View {
    ZStack {
      workspace
        .opacity(isWorkspaceReady && progress.hasFinishedOnboarding ? 1 : 0)

      if isWorkspaceReady, !progress.hasFinishedOnboarding {
        OnboardingView(
          onFinish: finishOnboarding,
          firstLesson: catalog.lessons.first
        )
        .transition(.opacity)
      }

      if !isWorkspaceReady {
        SplashView(versionLabel: Self.versionLabel)
          .transition(.opacity)
      }
    }
    .task(loadWorkspace)
  }

  /// İlk açılış akışı bittiğinde ritmi saklar ve istenirse ilk dersi açar.
  private func finishOnboarding(dailyGoal: DailyGoal?, opensFirstLesson: Bool) {
    withAnimation(.easeInOut(duration: 0.3)) {
      progress.finishOnboarding(dailyGoal: dailyGoal)
      if opensFirstLesson, let firstLessonID = catalog.lessons.first?.id {
        roadmapPath = [firstLessonID]
      }
    }
    save()
  }

  private static var versionLabel: String {
    let version =
      Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    return "v\(version ?? "1.0")"
  }

  /// İlerlemeyi ana iş parçacığını bloklamadan okur.
  @Sendable
  private func loadWorkspace() async {
    let store = progressStore
    async let loaded = Task.detached(priority: .userInitiated) {
      store.loadRecovering()
    }.value
    async let reading = Task.detached(priority: .userInitiated) {
      ReadingLibrary.loadRecovering()
    }.value
    async let floor: Void? = try? await Task.sleep(for: Self.minimumSplashDuration)

    let result = await loaded
    let readingResult = await reading
    _ = await floor

    progress = result.progress
    readingCourse = readingResult.course
    persistenceNotice = result.notice ?? readingResult.notice
    withAnimation(.easeOut(duration: 0.3)) {
      isWorkspaceReady = true
    }
  }

  private var workspace: some View {
    TabView {
      NavigationStack(path: $roadmapPath) {
        LessonMapView(
          items: catalog.items(completedLessonIDs: progress.completedLessonIDs),
          allLessons: catalog.lessons,
          totalLessonCount: catalog.lessons.count,
          dashboard: LearningDashboardSnapshot(
            progress: progress,
            totalLessonCount: catalog.lessons.count,
            asOf: Date()
          ),
          reviewItems: ReviewQueue.items(from: progress, asOf: Date()),
          onLessonCompleted: complete,
          readingCourse: readingCourse,
          progress: progress,
          onReadingLessonCompleted: completeReading
        )
      }
      .tabItem {
        Label("Yol Haritası", systemImage: "map.fill")
      }

      NavigationStack {
        LessonContentsView(
          catalog: catalog,
          completedLessonIDs: progress.completedLessonIDs,
          onLessonCompleted: complete,
          readingCourse: readingCourse,
          progress: progress,
          onReadingLessonCompleted: completeReading
        )
      }
      .tabItem {
        Label("İçindekiler", systemImage: "list.bullet.rectangle.portrait.fill")
      }
    }
    .tint(AppPalette.accent)
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
    save()
  }

  /// Kavram dersi tamamlandığında ayrı sayaca yazar; kod okuma ölçümlerine
  /// dokunmaz.
  private func completeReading(_ lessonID: String) {
    progress.completeReading(lessonID)
    save()
  }

  private func save() {
    do {
      try progressStore.save(progress)
    } catch {
      persistenceNotice =
        "İlerleme cihaza kaydedilemedi. Uygulamayı kapatmadan önce tekrar dene. Hata: \(error.localizedDescription)"
    }
  }
}

private struct ContentViewPreview: PreviewProvider {
  static var previews: some View {
    ContentView()
      .preferredColorScheme(.dark)
  }
}
