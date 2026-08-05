import SwiftUI

// Yol Haritası sekmesi: ilerleme kartı, tekrar kuyruğu ve ders satırları.

struct LessonMapView: View {
  let items: [LessonCatalogItem]
  /// Gezinme yığınından gelen ders kimliğini çözebilmek için tüm katalog.
  let allLessons: [XRayLesson]
  let totalLessonCount: Int
  let dashboard: LearningDashboardSnapshot
  let reviewItems: [ReviewItem]
  let onLessonCompleted: (LessonRunResult) -> Void
  /// Kavram kitaplığı; yol haritasında kod okumanın yanında ikinci bir hat
  /// olarak durur, aynı ekrandan açılır.
  let readingCourse: ReadingCourse
  let progress: LessonProgress
  let onReadingLessonCompleted: (String) -> Void
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    ZStack {
      AppPalette.background
        .ignoresSafeArea()

      RadialGradient(
        colors: [AppPalette.accent.opacity(0.18), .clear],
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
          reviewCard
          readingCourseCard

          ForEach(CurriculumSection.allCases, id: \.self) { section in
            let sectionItems = items.filter { $0.lesson.section == section }
            if !sectionItems.isEmpty {
              VStack(alignment: .leading, spacing: 16) {
                FolderHeader(
                  name: section.folderName,
                  count: sectionItems.count,
                  tint: section.accentColor
                )

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
    .navigationDestination(for: String.self) { lessonID in
      if let lesson = allLessons.first(where: { $0.id == lessonID }) {
        XRayLessonView(
          lesson: lesson,
          totalLessonCount: totalLessonCount,
          onComplete: onLessonCompleted
        )
      }
    }
  }

  /// Kavram kitaplığına giriş. İçerik yüklenmediyse hiç görünmez.
  @ViewBuilder
  private var readingCourseCard: some View {
    if !readingCourse.publishedLessons.isEmpty {
      NavigationLink {
        ReadingModuleListView(
          course: readingCourse,
          progress: progress,
          onLessonCompleted: onReadingLessonCompleted,
          codeLessons: allLessons,
          onCodeLessonCompleted: onLessonCompleted
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
        .background(AppPalette.accent, in: RoundedRectangle(cornerRadius: 12))

      VStack(alignment: .leading, spacing: 2) {
        Text("GRILLME")
          .adaptiveFont(size: 15, weight: .bold, design: .default)
          .tracking(1.1)
          .foregroundStyle(.white)
          .lineLimit(1)
        Text("Kod okuma laboratuvarı")
          .adaptiveFont(size: 11, design: .default)
          .foregroundStyle(AppPalette.secondaryText)
      }
    }
  }

  private var headerMetrics: some View {
    HStack(spacing: 8) {
      Label("\(dashboard.currentStreak)", systemImage: "flame.fill")
        .foregroundStyle(AppPalette.highlight)
        .accessibilityLabel("\(dashboard.currentStreak) günlük seri")

      Label("\(dashboard.completedCount)", systemImage: "checkmark.seal.fill")
        .foregroundStyle(AppPalette.accent)
        .accessibilityLabel("\(dashboard.completedCount) ders tamamlandı")
    }
    .adaptiveFont(size: 13, weight: .bold, design: .default)
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
                colors: [AppPalette.accent, AppPalette.link],
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
        .adaptiveFont(size: 32, weight: .bold, design: .default)
        .foregroundStyle(.white)
        .fixedSize(horizontal: false, vertical: true)

      Text("Önce konuyu öğren, örneği adım adım izle ve en son quizde uygula.")
        .adaptiveFont(size: 15, design: .default)
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
            colors: [AppPalette.accent, AppPalette.link],
            center: .center
          ),
          style: StrokeStyle(lineWidth: 7, lineCap: .round)
        )
        .rotationEffect(.degrees(-90))

      VStack(spacing: 1) {
        Text("\(dashboard.completedCount)")
          .font(.system(size: 21, weight: .bold, design: .default))
          .foregroundStyle(.white)
        Text("/ \(dashboard.totalCount)")
          .font(.system(size: 10, weight: .semibold, design: .default))
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
        .foregroundStyle(report.improvement >= 0 ? AppPalette.accent : AppPalette.highlight)

        VStack(alignment: .leading, spacing: 4) {
          Text("Kod okuma gelişimin")
            .adaptiveFont(size: 15, weight: .bold, design: .default)
            .foregroundStyle(.white)
          Text(
            report.hasEnoughEvidence
              ? "Başlangıç quizi \(percentage(report.baselineQuizAccuracy)) · Çıkış quizi \(percentage(report.exitQuizAccuracy))"
              : "\(report.baselineSampleSize) başlangıç, \(report.exitSampleSize) çıkış quizi çözüldü. Yüzde göstermek için en az \(LearningGrowthReport.minimumSampleSize) çıkış quizi gerekiyor."
          )
          .adaptiveFont(size: 12, design: .default)
          .foregroundStyle(AppPalette.secondaryText)
        }

        Spacer()

        if report.hasEnoughEvidence {
          Text(
            "\(report.improvement >= 0 ? "+" : "")\(Int((report.improvement * 100).rounded())) puan"
          )
          .adaptiveFont(size: 13, weight: .bold, design: .default)
          .foregroundStyle(report.improvement >= 0 ? AppPalette.accent : AppPalette.highlight)
        } else {
          Text("Ölçüm sürüyor")
            .adaptiveFont(size: 13, weight: .bold, design: .default)
            .foregroundStyle(AppPalette.secondaryText)
        }
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
        .foregroundStyle(AppPalette.link)
      Text(value)
        .adaptiveFont(size: 16, weight: .bold, design: .default)
        .foregroundStyle(.white)
      Text(label)
        .adaptiveFont(size: 10, weight: .semibold, design: .default)
        .foregroundStyle(AppPalette.secondaryText)
    }
    .frame(maxWidth: .infinity)
  }

  private func percentage(_ value: Double?) -> String {
    guard let value else { return "—" }
    return "\(Int((value * 100).rounded()))%"
  }

  @ViewBuilder
  private var reviewCard: some View {
    let entries = reviewItems.compactMap { review -> (ReviewItem, XRayLesson)? in
      guard let lesson = items.first(where: { $0.lesson.id == review.lessonID })?.lesson else {
        return nil
      }
      return (review, lesson)
    }

    if !entries.isEmpty {
      VStack(alignment: .leading, spacing: 14) {
        HStack(spacing: 10) {
          Image(systemName: "arrow.trianglehead.counterclockwise")
            .foregroundStyle(AppPalette.highlight)
          Text("Tekrar zamanı")
            .adaptiveFont(size: 15, weight: .bold, design: .default)
            .foregroundStyle(.white)
        }

        Text("Önceki derslerden gelen sorular. Aynı kavram, yeni kod.")
          .adaptiveFont(size: 12, design: .default)
          .foregroundStyle(AppPalette.secondaryText)

        ForEach(entries, id: \.0.lessonID) { review, lesson in
          NavigationLink {
            XRayLessonView(
              lesson: lesson,
              totalLessonCount: totalLessonCount,
              questionIndex: review.completedAttempts,
              onComplete: onLessonCompleted
            )
          } label: {
            HStack(spacing: 12) {
              Image(systemName: review.reason == .incorrectLastTime ? "xmark.circle" : "clock")
                .foregroundStyle(
                  review.reason == .incorrectLastTime ? AppPalette.highlight : AppPalette.link
                )
              VStack(alignment: .leading, spacing: 2) {
                Text(lesson.title)
                  .adaptiveFont(size: 14, weight: .semibold, design: .default)
                  .foregroundStyle(.white)
                Text(
                  review.reason == .incorrectLastTime
                    ? "Son denemede quiz yanlıştı"
                    : "Bir süredir tekrar edilmedi"
                )
                .adaptiveFont(size: 11, design: .default)
                .foregroundStyle(AppPalette.secondaryText)
              }
              Spacer()
              Image(systemName: "chevron.right")
                .adaptiveFont(size: 12, weight: .bold)
                .foregroundStyle(AppPalette.secondaryText)
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
          .accessibilityLabel(
            "\(lesson.title) dersini tekrar et. "
              + (review.reason == .incorrectLastTime
                ? "Son denemede quiz yanlıştı." : "Bir süredir tekrar edilmedi.")
          )
        }
      }
      .padding(16)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 20))
      .overlay(
        RoundedRectangle(cornerRadius: 20)
          .stroke(AppPalette.highlight.opacity(0.35), lineWidth: 1)
      )
    }
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
        .foregroundStyle(AppPalette.link)
        .frame(width: 42, height: 42)
        .background(AppPalette.accent.opacity(0.14), in: Circle())

      VStack(alignment: .leading, spacing: 4) {
        Text("Yolculuk devam edecek")
          .adaptiveFont(size: 15, weight: .bold, design: .default)
          .foregroundStyle(.white)
        Text("Temelden teknik analize uzanan \(totalLessonCount) ders hazır.")
          .adaptiveFont(size: 13, design: .default)
          .foregroundStyle(AppPalette.secondaryText)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(18)
    .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 20))
    .overlay(
      RoundedRectangle(cornerRadius: 20)
        .stroke(AppPalette.border, style: StrokeStyle(lineWidth: 1, dash: [5]))
    )
  }
}

struct LessonRow: View {
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
    .padding(13)
    .frame(minHeight: 44)
    .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 9))
    .overlay(
      RoundedRectangle(cornerRadius: 9)
        .stroke(
          item.status == .completed ? AppPalette.border : AppPalette.accent,
          lineWidth: 1
        )
    )
    .overlay(alignment: .leading) {
      // Açık ders, editörde seçili dosya gibi sol kenardan işaretlenir.
      if item.status == .available {
        UnevenRoundedRectangle(topLeadingRadius: 9, bottomLeadingRadius: 9)
          .fill(AppPalette.accent)
          .frame(width: 3)
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(accessibilityDescription)
  }

  private var badge: some View {
    Image(systemName: item.status == .completed ? "checkmark" : "doc.text")
      .adaptiveFont(size: 16, weight: .semibold)
      .foregroundStyle(badgeColor)
      .frame(width: 38, height: 38)
      .background(badgeColor.opacity(0.16), in: RoundedRectangle(cornerRadius: 8))
  }

  /// Dosya adı: `01_degerin_izini_sur.swift`. Uzantı metin renginde yazılır,
  /// tıpkı editörde olduğu gibi.
  private var lessonDetails: some View {
    VStack(alignment: .leading, spacing: 4) {
      (Text(item.lesson.fileStem)
        + Text(".swift").foregroundColor(CodeTokenKind.string.color))
        .adaptiveFont(size: 12.5, weight: .bold, design: .monospaced)
        .foregroundStyle(
          item.status == .completed ? AppPalette.secondaryText : AppPalette.primaryText)

      Text(item.lesson.objective)
        .adaptiveFont(size: 12, design: .default)
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
      .adaptiveFont(size: 10, weight: .semibold, design: .monospaced)
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
    // Tamamlanan dosya sönükleşir, açık dosya editördeki gibi mavi kalır.
    case .completed:
      AppPalette.successText
    case .available:
      AppPalette.link
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
