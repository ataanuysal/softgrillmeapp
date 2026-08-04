import SwiftUI

// İçindekiler sekmesi: bölüm filtresi ve Türkçe karakterden bağımsız arama.

struct LessonContentsView: View {
  let catalog: LessonCatalog
  let completedLessonIDs: Set<String>
  let onLessonCompleted: (LessonRunResult) -> Void
  /// Markdown kavram dersleri; kod okuma kataloğunun ikinci katmanı.
  let readingCourse: ReadingCourse
  let progress: LessonProgress
  let onReadingLessonCompleted: (String) -> Void
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
        colors: [AppPalette.mentor.opacity(0.2), .clear],
        center: .topTrailing,
        startRadius: 10,
        endRadius: 420
      )
      .ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          contentsIntro
          readingCourseEntry
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
        .adaptiveFont(size: 12, weight: .bold, design: .default)
        .tracking(1)
        .foregroundStyle(AppPalette.accent)

      Text("İstediğin konudan başla")
        .adaptiveFont(size: 27, weight: .bold, design: .default)
        .foregroundStyle(.white)

      Text(
        "Tüm \(catalog.lessons.count) ders açık. Konuya göre filtrele, aradığın kavramı bul ve doğrudan derse gir."
      )
      .adaptiveFont(size: 15, design: .default)
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
      .adaptiveFont(size: 12, weight: .bold, design: .default)
      .foregroundStyle(AppPalette.highlight)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 24))
    .overlay(
      RoundedRectangle(cornerRadius: 24)
        .stroke(AppPalette.border, lineWidth: 1)
    )
  }

  /// Kavram kitaplığının girişi.
  ///
  /// İçerik yüklenemediyse ya da hiç yayınlanmış ders yoksa kart hiç
  /// görünmez; kullanıcıya boş bir kurs açtırılmaz.
  @ViewBuilder
  private var readingCourseEntry: some View {
    if !readingCourse.publishedLessons.isEmpty {
      NavigationLink {
        ReadingModuleListView(
          course: readingCourse,
          progress: progress,
          onLessonCompleted: onReadingLessonCompleted
        )
      } label: {
        ReadingCourseCard(
          course: readingCourse,
          completedCount: readingCourse.completedCount(in: progress)
        )
      }
      .buttonStyle(.plain)
    }
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
        .adaptiveFont(size: 11, weight: .bold, design: .default)
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .foregroundStyle(isSelected ? AppPalette.background : AppPalette.secondaryText)
        .background(isSelected ? AppPalette.accent : AppPalette.card, in: Capsule())
        .overlay(
          Capsule()
            .stroke(isSelected ? AppPalette.accent : AppPalette.border, lineWidth: 1)
        )
    }
    .buttonStyle(.plain)
  }

  private func lessonSection(_ group: LessonContentsSection) -> some View {
    VStack(alignment: .leading, spacing: 15) {
      HStack {
        FolderHeader(
          name: group.section.folderName,
          count: group.items.count,
          tint: group.section.accentColor
        )

        Spacer()

        Text("\(group.items.count) ders")
          .adaptiveFont(size: 11, weight: .semibold, design: .default)
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
        .foregroundStyle(AppPalette.mentor)

      Text("Bu aramayla eşleşen ders yok")
        .adaptiveFont(size: 18, weight: .bold, design: .default)
        .foregroundStyle(.white)

      Text("Başka bir konu veya kavram deneyebilirsin.")
        .adaptiveFont(size: 14, design: .default)
        .foregroundStyle(AppPalette.secondaryText)

      Button("Filtreleri temizle") {
        searchQuery = ""
        selectedSection = nil
      }
      .adaptiveFont(size: 14, weight: .bold, design: .default)
      .foregroundStyle(AppPalette.accent)
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
