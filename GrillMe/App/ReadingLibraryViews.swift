import SwiftUI

// Kavram kitaplığı: Markdown ders içeriğinin katalog → modül → ders → okuma
// zinciri. Kod okuma dersleriyle aynı katalog sekmesinden açılır; ayrı bir
// kurs sistemi değil, aynı kataloğun ikinci katmanıdır.

/// İçindekiler ekranının başındaki kurs kartı.
struct ReadingCourseCard: View {
  let course: ReadingCourse
  let completedCount: Int

  private var totalCount: Int { course.publishedLessons.count }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Label("KAVRAM KİTAPLIĞI", systemImage: "text.book.closed.fill")
        .adaptiveFont(size: 12, weight: .bold)
        .tracking(1)
        .foregroundStyle(AppPalette.mentor)

      Text(course.title)
        .adaptiveFont(size: 21, weight: .bold)
        .foregroundStyle(.white)
        .fixedSize(horizontal: false, vertical: true)

      Text(course.summary)
        .adaptiveFont(size: 14)
        .foregroundStyle(AppPalette.secondaryText)
        .fixedSize(horizontal: false, vertical: true)

      ProgressBadge(completed: completedCount, total: totalCount)

      Text("Okumaya devam et")
        .adaptiveFont(size: 14, weight: .bold)
        .foregroundStyle(AppPalette.background)
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(AppPalette.mentor, in: RoundedRectangle(cornerRadius: 12))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(18)
    .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 22))
    .overlay(
      RoundedRectangle(cornerRadius: 22)
        .stroke(AppPalette.mentor.opacity(0.4), lineWidth: 1)
    )
    .accessibilityElement(children: .combine)
    .accessibilityLabel(
      "\(course.title). \(totalCount) kavram dersinden \(completedCount) tanesi tamamlandı."
    )
  }
}

/// Modül listesi. Yayında olmayan modüller görünür ama açılamaz.
struct ReadingModuleListView: View {
  let course: ReadingCourse
  let progress: LessonProgress
  let onLessonCompleted: (String) -> Void
  /// Kavram dersinden ilgili kod okuma dersine geçmek için gereken katalog.
  let codeLessons: [XRayLesson]
  let onCodeLessonCompleted: (LessonRunResult) -> Void

  var body: some View {
    ZStack {
      AppPalette.background.ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 18) {
          header

          ForEach(course.visibleModules) { module in
            if module.isOpen {
              NavigationLink {
                ReadingLessonListView(
                  course: course,
                  module: module,
                  progress: progress,
                  onLessonCompleted: onLessonCompleted,
                  codeLessons: codeLessons,
                  onCodeLessonCompleted: onCodeLessonCompleted
                )
              } label: {
                ReadingModuleRow(
                  module: module,
                  completedCount: completedCount(in: module)
                )
              }
              .buttonStyle(.plain)
            } else {
              ReadingModuleRow(module: module, completedCount: 0)
            }
          }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
      }
      .scrollIndicators(.hidden)
    }
    .navigationTitle("Kavram Kitaplığı")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(AppPalette.background, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbarColorScheme(.dark, for: .navigationBar)
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(course.title)
        .adaptiveFont(size: 24, weight: .bold)
        .foregroundStyle(.white)
        .fixedSize(horizontal: false, vertical: true)

      Text(course.summary)
        .adaptiveFont(size: 14)
        .foregroundStyle(AppPalette.secondaryText)
        .fixedSize(horizontal: false, vertical: true)

      ProgressBadge(
        completed: course.completedCount(in: progress),
        total: course.publishedLessons.count
      )
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private func completedCount(in module: ReadingModule) -> Int {
    let completed = progress.completedReadingLessonIDs
    return module.publishedLessons.filter { completed.contains($0.id) }.count
  }
}

private struct ReadingModuleRow: View {
  let module: ReadingModule
  let completedCount: Int

  var body: some View {
    VStack(alignment: .leading, spacing: 9) {
      HStack(alignment: .firstTextBaseline, spacing: 9) {
        Text(String(format: "%02d", module.order))
          .adaptiveFont(size: 13, weight: .bold, design: .monospaced)
          .foregroundStyle(AppPalette.tertiaryText)

        Text(module.title)
          .adaptiveFont(size: 16, weight: .bold)
          .foregroundStyle(module.isOpen ? AppPalette.primaryText : AppPalette.secondaryText)
          .fixedSize(horizontal: false, vertical: true)

        Spacer(minLength: 8)

        if module.isOpen {
          Image(systemName: "chevron.right")
            .adaptiveFont(size: 12, weight: .bold)
            .foregroundStyle(AppPalette.tertiaryText)
        }
      }

      Text(module.summary)
        .adaptiveFont(size: 13)
        .foregroundStyle(AppPalette.secondaryText)
        .fixedSize(horizontal: false, vertical: true)

      if module.isOpen {
        HStack(spacing: 12) {
          Label(
            "\(completedCount)/\(module.publishedLessons.count) ders",
            systemImage: "book.pages"
          )
          Label("\(module.totalEstimatedMinutes) dk", systemImage: "clock")
        }
        .adaptiveFont(size: 11, weight: .semibold)
        .foregroundStyle(AppPalette.highlight)
      } else {
        Label("Yakında — dersleri henüz yazılmadı", systemImage: "hourglass")
          .adaptiveFont(size: 11, weight: .semibold)
          .foregroundStyle(AppPalette.tertiaryText)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(
      module.isOpen ? AppPalette.panel : AppPalette.panel.opacity(0.5),
      in: RoundedRectangle(cornerRadius: 16)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(module.isOpen ? AppPalette.border : AppPalette.border.opacity(0.5), lineWidth: 1)
    )
    .accessibilityElement(children: .combine)
    .accessibilityLabel(
      module.isOpen
        ? "\(module.title) modülü, \(module.publishedLessons.count) ders, \(completedCount) tamamlandı"
        : "\(module.title) modülü, yakında"
    )
  }
}

/// Bir modülün ders listesi.
struct ReadingLessonListView: View {
  let course: ReadingCourse
  let module: ReadingModule
  let progress: LessonProgress
  let onLessonCompleted: (String) -> Void
  let codeLessons: [XRayLesson]
  let onCodeLessonCompleted: (LessonRunResult) -> Void

  var body: some View {
    ZStack {
      AppPalette.background.ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          MarkdownContentView(blocks: overviewIntro)
            .padding(16)
            .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
              RoundedRectangle(cornerRadius: 16)
                .stroke(AppPalette.border, lineWidth: 1)
            )

          FolderHeader(
            name: "\(module.id)/",
            count: module.publishedLessons.count,
            tint: AppPalette.mentor
          )

          ForEach(module.publishedLessons) { lesson in
            NavigationLink {
              ReadingLessonView(
                course: course,
                lesson: lesson,
                progress: progress,
                onLessonCompleted: onLessonCompleted,
                codeLessons: codeLessons,
                onCodeLessonCompleted: onCodeLessonCompleted
              )
            } label: {
              ReadingLessonRow(
                lesson: lesson,
                isCompleted: progress.completedReadingLessonIDs.contains(lesson.id)
              )
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
      }
      .scrollIndicators(.hidden)
    }
    .navigationTitle(module.title)
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(AppPalette.background, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbarColorScheme(.dark, for: .navigationBar)
  }

  /// Modül README'sinin ilk açıklama bölümü; ders listesinin başında özet olarak
  /// gösterilir. Tamamı gösterilseydi ders listesi ekranın çok altına düşerdi.
  private var overviewIntro: [MarkdownBlock] {
    Array(module.overviewBlocks.prefix(6))
  }
}

private struct ReadingLessonRow: View {
  let lesson: ReadingLesson
  let isCompleted: Bool

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
        .adaptiveFont(size: 17, weight: .semibold)
        .foregroundStyle(isCompleted ? AppPalette.successText : AppPalette.tertiaryText)

      VStack(alignment: .leading, spacing: 5) {
        Text(lesson.title)
          .adaptiveFont(size: 15, weight: .bold)
          .foregroundStyle(AppPalette.primaryText)
          .fixedSize(horizontal: false, vertical: true)

        Text(lesson.summary)
          .adaptiveFont(size: 13)
          .foregroundStyle(AppPalette.secondaryText)
          .fixedSize(horizontal: false, vertical: true)

        HStack(spacing: 12) {
          Label("\(lesson.estimatedMinutes) dk", systemImage: "clock")
          Label(lesson.difficulty.displayName, systemImage: "chart.bar")
          if isCompleted {
            Label("Okundu", systemImage: "checkmark")
          }
        }
        .adaptiveFont(size: 11, weight: .semibold)
        .foregroundStyle(isCompleted ? AppPalette.successText : AppPalette.tertiaryText)
      }

      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
    .padding(14)
    .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 14))
    .overlay(
      RoundedRectangle(cornerRadius: 14)
        .stroke(isCompleted ? AppPalette.successText.opacity(0.4) : AppPalette.border, lineWidth: 1)
    )
    .accessibilityElement(children: .combine)
    .accessibilityLabel(
      "\(lesson.title). \(lesson.estimatedMinutes) dakika. \(isCompleted ? "Okundu" : "Okunmadı")"
    )
  }
}

/// Markdown ders ekranı: anlatım → alıştırmalar → tamamla → sonraki ders.
struct ReadingLessonView: View {
  let course: ReadingCourse
  let lesson: ReadingLesson
  let progress: LessonProgress
  let onLessonCompleted: (String) -> Void
  let codeLessons: [XRayLesson]
  let onCodeLessonCompleted: (LessonRunResult) -> Void

  @State private var session: ReadingSession
  @Environment(\.dismiss) private var dismiss

  init(
    course: ReadingCourse,
    lesson: ReadingLesson,
    progress: LessonProgress,
    onLessonCompleted: @escaping (String) -> Void,
    codeLessons: [XRayLesson],
    onCodeLessonCompleted: @escaping (LessonRunResult) -> Void
  ) {
    self.course = course
    self.lesson = lesson
    self.progress = progress
    self.onLessonCompleted = onLessonCompleted
    self.codeLessons = codeLessons
    self.onCodeLessonCompleted = onCodeLessonCompleted
    _session = State(
      initialValue: ReadingSession(
        lesson: lesson,
        isAlreadyCompleted: progress.completedReadingLessonIDs.contains(lesson.id)
      )
    )
  }

  var body: some View {
    ZStack {
      AppPalette.background.ignoresSafeArea()

      VStack(spacing: 0) {
        EditorTabBar(tabs: [
          EditorTabBar.Tab(
            title: "\(lesson.id).md",
            isActive: true,
            dotColor: AppPalette.mentor
          )
        ])

        ScrollView {
          VStack(alignment: .leading, spacing: 20) {
            lessonHeader

            switch session.phase {
            case .reading:
              MarkdownContentView(blocks: lesson.readingBlocks)
              primaryButton("Alıştırmalara geç", icon: "pencil.and.list.clipboard") {
                withAnimation(.snappy) { session.startExercises() }
              }

            case .exercises:
              exercisePanel
              primaryButton("Dersi tamamla", icon: "checkmark.circle.fill") {
                withAnimation(.snappy) {
                  session.complete()
                  onLessonCompleted(lesson.id)
                }
              }

            case .complete:
              completionPanel
            }
          }
          .padding(.horizontal, 20)
          .padding(.top, 16)
          .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)

        IDEStatusBar(
          leading: statusLeading,
          trailing: "\(lesson.estimatedMinutes) dk",
          tone: session.phase == .complete ? .success : .normal
        )
      }
    }
    .navigationTitle(lesson.title)
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(AppPalette.panel, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbarColorScheme(.dark, for: .navigationBar)
  }

  private var lessonHeader: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(lesson.title)
        .adaptiveFont(size: 24, weight: .bold)
        .foregroundStyle(.white)
        .fixedSize(horizontal: false, vertical: true)

      Text(lesson.summary)
        .adaptiveFont(size: 14)
        .foregroundStyle(AppPalette.secondaryText)
        .fixedSize(horizontal: false, vertical: true)

      if !lesson.objectives.isEmpty {
        VStack(alignment: .leading, spacing: 6) {
          Text("BU DERSTE KAZANACAKLARIN")
            .adaptiveFont(size: 10, weight: .bold, design: .monospaced)
            .foregroundStyle(AppPalette.highlight)

          ForEach(Array(lesson.objectives.enumerated()), id: \.offset) { _, objective in
            HStack(alignment: .firstTextBaseline, spacing: 8) {
              Image(systemName: "target")
                .adaptiveFont(size: 11)
                .foregroundStyle(AppPalette.highlight)
              Text(objective)
                .adaptiveFont(size: 13)
                .foregroundStyle(AppPalette.primaryText)
                .fixedSize(horizontal: false, vertical: true)
            }
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppPalette.card, in: RoundedRectangle(cornerRadius: 12))
      }
    }
  }

  private var exercisePanel: some View {
    VStack(alignment: .leading, spacing: 16) {
      IDECallout(
        title: "ALIŞTIRMA",
        message:
          "Cevapları yazarak ver. Okumak yeterli değil; üretmeye çalıştığın yer öğrendiğin yerdir.",
        tint: AppPalette.highlight,
        systemImage: "pencil.line",
        filled: true
      )

      MarkdownContentView(blocks: lesson.exerciseBlocks)
    }
  }

  private var completionPanel: some View {
    VStack(alignment: .leading, spacing: 16) {
      IDECallout(
        title: "TAMAMLANDI",
        message: "Bu ders okundu ve ilerlemene kaydedildi.",
        tint: AppPalette.successText,
        systemImage: "checkmark.seal.fill",
        filled: true
      )

      relatedCodeLessonsPanel

      if let next = course.nextLesson(after: lesson.id) {
        NavigationLink {
          ReadingLessonView(
            course: course,
            lesson: next,
            progress: progress,
            onLessonCompleted: onLessonCompleted,
            codeLessons: codeLessons,
            onCodeLessonCompleted: onCodeLessonCompleted
          )
        } label: {
          nextLessonLabel(next)
        }
        .buttonStyle(.plain)
      } else {
        IDECallout(
          title: "MODÜL SONU",
          message: "Bu kursun yayınlanan son dersiydi. Diğer modüller yakında eklenecek.",
          tint: AppPalette.link,
          systemImage: "flag.checkered",
          filled: true
        )
      }

      Button("Ders listesine dön") { dismiss() }
        .adaptiveFont(size: 14, weight: .bold)
        .foregroundStyle(AppPalette.link)
        .frame(maxWidth: .infinity, minHeight: 44)
    }
  }

  /// Kavramı satır satır çalışabileceğin kod okuma dersleri.
  ///
  /// Okuma katmanı tek başına "neden böyle"yi anlatır; öğrenci aynı kavramı
  /// çalışan kodda görmeden bağ kurulmuş sayılmaz.
  @ViewBuilder
  private var relatedCodeLessonsPanel: some View {
    let related = codeLessons.filter { lesson.relatedCodeLessonIDs.contains($0.id) }

    if !related.isEmpty {
      VStack(alignment: .leading, spacing: 9) {
        Text("BU KAVRAMI KODDA GÖR")
          .adaptiveFont(size: 10, weight: .bold, design: .monospaced)
          .foregroundStyle(AppPalette.link)

        ForEach(related, id: \.id) { codeLesson in
          NavigationLink {
            XRayLessonView(
              lesson: codeLesson,
              totalLessonCount: codeLessons.count,
              onComplete: onCodeLessonCompleted
            )
          } label: {
            HStack(spacing: 10) {
              Image(systemName: "chevron.left.forwardslash.chevron.right")
                .adaptiveFont(size: 13, weight: .semibold)
                .foregroundStyle(AppPalette.link)
              VStack(alignment: .leading, spacing: 2) {
                Text("\(codeLesson.order). ders")
                  .adaptiveFont(size: 10, weight: .bold, design: .monospaced)
                  .foregroundStyle(AppPalette.tertiaryText)
                Text(codeLesson.title)
                  .adaptiveFont(size: 14, weight: .semibold)
                  .foregroundStyle(AppPalette.primaryText)
                  .fixedSize(horizontal: false, vertical: true)
              }
              Spacer(minLength: 0)
              Image(systemName: "arrow.right")
                .adaptiveFont(size: 12, weight: .bold)
                .foregroundStyle(AppPalette.tertiaryText)
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .padding(12)
            .background(AppPalette.card, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .stroke(AppPalette.link.opacity(0.35), lineWidth: 1)
            )
          }
          .buttonStyle(.plain)
          .accessibilityLabel("Kod okuma dersine geç: \(codeLesson.title)")
        }
      }
    }
  }

  private func nextLessonLabel(_ next: ReadingLesson) -> some View {
    VStack(alignment: .leading, spacing: 5) {
      Text("SONRAKİ DERS")
        .adaptiveFont(size: 10, weight: .bold, design: .monospaced)
        .foregroundStyle(AppPalette.background.opacity(0.75))
      Text(next.title)
        .adaptiveFont(size: 15, weight: .bold)
        .foregroundStyle(AppPalette.background)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
    .padding(14)
    .background(AppPalette.mentor, in: RoundedRectangle(cornerRadius: 12))
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Sonraki ders: \(next.title)")
  }

  private func primaryButton(
    _ title: String,
    icon: String,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      Label(title, systemImage: icon)
        .adaptiveFont(size: 15, weight: .bold)
        .foregroundStyle(AppPalette.background)
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(AppPalette.accent, in: RoundedRectangle(cornerRadius: 12))
    }
    .buttonStyle(.plain)
  }

  private var statusLeading: String {
    switch session.phase {
    case .reading: return "OKUMA"
    case .exercises: return "ALIŞTIRMA"
    case .complete: return "TAMAMLANDI"
    }
  }
}

/// "3/8 ders okundu" rozeti. Durum yalnızca renkle değil, sayıyla da anlatılır.
private struct ProgressBadge: View {
  let completed: Int
  let total: Int

  var body: some View {
    HStack(spacing: 8) {
      Image(systemName: completed >= total && total > 0 ? "checkmark.seal.fill" : "book.pages")
        .adaptiveFont(size: 12, weight: .semibold)
      Text("\(completed)/\(total) ders okundu")
        .adaptiveFont(size: 12, weight: .bold)
    }
    .foregroundStyle(completed >= total && total > 0 ? AppPalette.successText : AppPalette.link)
    .accessibilityElement(children: .combine)
  }
}
