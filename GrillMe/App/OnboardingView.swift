import SwiftUI

/// İlk açılış akışı: altı ekranda ürünün vaadini gösterir ve günlük ritmi sorar.
///
/// Akış yalnızca bir kez görünür; "Atla" her ekranda erişilebilirdir ve ritim
/// seçilmeden çıkılabilir.
struct OnboardingView: View {
  /// Seçilen ritim (atlandıysa nil) ve ilk derse gidilip gidilmeyeceği.
  let onFinish: (DailyGoal?, Bool) -> Void
  let firstLesson: XRayLesson?

  @State private var pageIndex = 0
  @State private var selectedGoal: DailyGoal = .recommended
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  private let pageCount = 6

  var body: some View {
    VStack(spacing: 0) {
      header
        .padding(.horizontal, 26)
        .padding(.top, 8)

      TabView(selection: $pageIndex) {
        welcomePage.tag(0)
        xRayPage.tag(1)
        mentorPage.tag(2)
        languagePage.tag(3)
        goalPage.tag(4)
        readyPage.tag(5)
      }
      .tabViewStyle(.page(indexDisplayMode: .never))

      pageDots
        .padding(.vertical, 16)

      footer
        .padding(.horizontal, 26)
        .padding(.bottom, 24)
    }
    .background(splashBackground.ignoresSafeArea())
    .animation(.easeInOut(duration: 0.25), value: pageIndex)
  }

  // MARK: - Kabuk

  private var header: some View {
    HStack {
      Text(stepLabel)
        .adaptiveFont(size: 11, weight: .bold, design: .monospaced)
        .foregroundStyle(AppPalette.tertiaryText)
      Spacer()
      if pageIndex < pageCount - 1 {
        Button("Atla") { onFinish(nil, false) }
          .adaptiveFont(size: 12, weight: .semibold)
          .foregroundStyle(AppPalette.tertiaryText)
          .frame(minHeight: 44)
          .accessibilityHint("İlk açılış akışını kapatır")
      }
    }
  }

  private var stepLabel: String {
    switch pageIndex {
    case 0: "grillme://welcome"
    case 5: "grillme://ready"
    default: String(format: "%02d / 05 · %@", pageIndex, pageSlug)
    }
  }

  private var pageSlug: String {
    switch pageIndex {
    case 1: "röntgen"
    case 2: "mentor"
    case 3: "köprü"
    default: "hedef"
    }
  }

  private var pageDots: some View {
    HStack(spacing: 6) {
      ForEach(0..<pageCount, id: \.self) { index in
        Capsule()
          .fill(index == pageIndex ? AppPalette.accent : AppPalette.border)
          .frame(width: index == pageIndex ? 20 : 7, height: 7)
      }
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Sayfa \(pageIndex + 1) / \(pageCount)")
  }

  @ViewBuilder
  private var footer: some View {
    if pageIndex == pageCount - 1 {
      VStack(spacing: 10) {
        primaryButton("İlk dersi aç", tone: AppPalette.success) {
          onFinish(selectedGoal, true)
        }
        Button("Önce yol haritasını gezmek istiyorum") {
          onFinish(selectedGoal, false)
        }
        .adaptiveFont(size: 12.5, weight: .semibold)
        .foregroundStyle(AppPalette.tertiaryText)
        .frame(minHeight: 44)
      }
    } else {
      primaryButton(pageIndex == 4 ? "Hedefi belirle" : (pageIndex == 0 ? "Başlayalım" : "Devam")) {
        pageIndex += 1
      }
    }
  }

  private func primaryButton(
    _ title: String,
    tone: Color = Color(red: 0.055, green: 0.388, blue: 0.612),
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      HStack(spacing: 9) {
        Text(title)
          .adaptiveFont(size: 15, weight: .bold)
        Image(systemName: "arrow.right")
          .adaptiveFont(size: 15, weight: .bold)
      }
      .foregroundStyle(.white)
      .frame(maxWidth: .infinity, minHeight: 50)
      .background(tone, in: RoundedRectangle(cornerRadius: 11))
    }
    .buttonStyle(.plain)
  }

  private var splashBackground: some View {
    Color(red: 0.051, green: 0.055, blue: 0.067)
  }

  // MARK: - Sayfalar

  private func page<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        content()
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 26)
      .padding(.vertical, 12)
    }
    .scrollBounceBehavior(.basedOnSize)
  }

  private func eyebrow(_ text: String, _ tint: Color) -> some View {
    Text(text)
      .adaptiveFont(size: 11, weight: .bold, design: .monospaced)
      .tracking(1)
      .foregroundStyle(tint)
      .padding(.bottom, 12)
  }

  private func headline(_ text: String) -> some View {
    Text(text)
      .adaptiveFont(size: 30, weight: .heavy)
      .foregroundStyle(.white)
      .fixedSize(horizontal: false, vertical: true)
      .padding(.bottom, 14)
  }

  private func lead(_ text: String) -> some View {
    Text(text)
      .adaptiveFont(size: 15)
      .foregroundStyle(Color(red: 0.604, green: 0.604, blue: 0.604))
      .fixedSize(horizontal: false, vertical: true)
  }

  private var welcomePage: some View {
    page {
      VStack(spacing: 0) {
        Spacer(minLength: 20)
        AppIconTile(size: 110)
          .shadow(color: AppPalette.accent.opacity(0.5), radius: 24, y: 12)
          .padding(.bottom, 28)
        Text("// kod okuma laboratuvarı")
          .adaptiveFont(size: 12, design: .monospaced)
          .foregroundStyle(CodeTokenKind.comment.color)
          .padding(.bottom, 10)
        (Text("Kodu ")
          + Text("okumayı").foregroundColor(CodeTokenKind.keyword.color)
          + Text("\növren"))
          .adaptiveFont(size: 34, weight: .heavy)
          .foregroundStyle(.white)
          .multilineTextAlignment(.center)
          .padding(.bottom, 14)
        lead(
          "Sözdizimi ezberletmeyiz. Çalışan kodu satır satır anlamayı ve programcı gibi düşünmeyi öğretiriz."
        )
        .multilineTextAlignment(.center)
        .frame(maxWidth: 280)
        Spacer(minLength: 20)
      }
      .frame(maxWidth: .infinity)
    }
  }

  private var xRayPage: some View {
    page {
      eyebrow("// NASIL ÇALIŞIR", AppPalette.link)
      headline("Kodun içini\nröntgenle")
      lead("Her satırı bilgisayarın çalışma sırasıyla izle. Üç lens ne olduğunu gösterir:")
        .padding(.bottom, 20)

      CodeCard(
        lines: [
          CodeLine(number: 1, text: "var puan = 10"),
          CodeLine(number: 2, text: "puan = puan + 2"),
          CodeLine(number: 3, text: "print(puan)"),
        ],
        activeLineNumber: 2
      )
      .padding(.bottom, 14)

      VStack(alignment: .leading, spacing: 9) {
        lensRow("play.fill", "Akış", "hangi satır, hangi sırada", CodeTokenKind.keyword.color)
        lensRow(
          "square.grid.2x2", "Hafıza", "değişkende o an ne var", AppPalette.successText)
        lensRow(
          "terminal", "Çıktı", "ekrana ne yazılır", CodeTokenKind.number.color)
      }
    }
  }

  private func lensRow(
    _ systemImage: String,
    _ title: String,
    _ detail: String,
    _ tint: Color
  ) -> some View {
    HStack(spacing: 11) {
      Image(systemName: systemImage)
        .adaptiveFont(size: 14, weight: .semibold)
        .foregroundStyle(tint)
        .frame(width: 30, height: 30)
        .background(tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
      Text(title)
        .adaptiveFont(size: 13, weight: .bold)
        .foregroundStyle(AppPalette.primaryText)
      Text("— \(detail)")
        .adaptiveFont(size: 12)
        .foregroundStyle(AppPalette.secondaryText)
        .fixedSize(horizontal: false, vertical: true)
      Spacer(minLength: 0)
    }
    .accessibilityElement(children: .combine)
  }

  private var mentorPage: some View {
    page {
      eyebrow("// SOKRATİK MENTOR", AppPalette.mentor)
      headline("Cevabı vermez,\ndüşündürür")
      lead(
        "Takıldığında mentor sana hazır cevap değil, doğru soruyu sorar. Kendi çıkarımını sen yaparsın."
      )
      .padding(.bottom, 22)

      VStack(alignment: .leading, spacing: 10) {
        chatBubble("Bu satırdan sonra puan kaç oldu, emin değilim.", isLearner: true)
        chatBubble(
          "“=” işaretini bir eşitlik mi, yoksa bir komut olarak mı okudun?",
          isLearner: false
        )
        chatBubble("Komut… sağı hesaplayıp sola yazıyor. Yani 12!", isLearner: true)
        chatBubble(
          "Tam da öyle. İşte bu, kod okumak.", isLearner: false, tint: AppPalette.successText)
      }
    }
  }

  private func chatBubble(
    _ text: String,
    isLearner: Bool,
    tint: Color = AppPalette.mentor
  ) -> some View {
    HStack {
      if isLearner { Spacer(minLength: 40) }
      VStack(alignment: .leading, spacing: 4) {
        if !isLearner {
          Text("mentor ›")
            .adaptiveFont(size: 10, weight: .bold, design: .monospaced)
            .foregroundStyle(tint)
        }
        Text(text)
          .adaptiveFont(size: 13.5, weight: isLearner ? .regular : .semibold)
          .foregroundStyle(isLearner ? .white : Color(red: 0.839, green: 0.839, blue: 0.839))
          .fixedSize(horizontal: false, vertical: true)
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 12)
      .background(
        isLearner
          ? Color(red: 0.055, green: 0.388, blue: 0.612)
          : Color(red: 0.078, green: 0.082, blue: 0.098),
        in: RoundedRectangle(cornerRadius: 13)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 13)
          .stroke(isLearner ? Color.clear : AppPalette.border, lineWidth: 1)
      )
      if !isLearner { Spacer(minLength: 30) }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(isLearner ? "Öğrenci: \(text)" : "Mentor: \(text)")
  }

  private var languagePage: some View {
    page {
      eyebrow("// DİL KÖPRÜSÜ", AppPalette.highlight)
      headline("Tek dil değil,\ndüşünme biçimi")
      lead("Aynı fikri dört dilde gör. Syntax değişir, mantık aynı kalır — asıl öğrendiğin bu.")
        .padding(.bottom, 20)

      HStack(spacing: 8) {
        ForEach(CodeLanguage.allCases, id: \.self) { language in
          Text(language.displayName)
            .adaptiveFont(size: 12, weight: .bold, design: .monospaced)
            .foregroundStyle(
              language == .swift ? .white : AppPalette.secondaryText
            )
            .frame(maxWidth: .infinity, minHeight: 34)
            .background(
              language == .swift
                ? AppPalette.background : Color(red: 0.078, green: 0.082, blue: 0.098),
              in: RoundedRectangle(cornerRadius: 8)
            )
            .overlay(alignment: .bottom) {
              if language == .swift {
                Rectangle().fill(AppPalette.accent).frame(height: 2)
              }
            }
        }
      }
      .padding(.bottom, 14)
      .accessibilityHidden(true)

      CodeCard(
        lines: [
          CodeLine(number: 1, text: "if puan > 5 {"),
          CodeLine(number: 2, text: "    puan = puan + 2"),
          CodeLine(number: 3, text: "}"),
        ],
        activeLineNumber: nil
      )
      .padding(.bottom, 12)

      IDECallout(
        title: "// AYNI MANTIK",
        message: "Dört dilde de mantık aynı: koşul doğruysa değeri 2 artır.",
        tint: AppPalette.successText,
        systemImage: "arrow.left.and.right.square",
        filled: true
      )
    }
  }

  private var goalPage: some View {
    page {
      eyebrow("// GÜNLÜK RİTİM", AppPalette.successText)
      headline("Günde ne kadar\nokuyalım?")
      lead("Küçük ama düzenli. Seriyi korumak, uzun oturumlardan daha çok işe yarar.")
        .padding(.bottom, 22)

      VStack(spacing: 11) {
        ForEach(DailyGoal.allCases, id: \.self) { goal in
          goalRow(goal)
        }
      }
    }
  }

  private func goalRow(_ goal: DailyGoal) -> some View {
    let isSelected = goal == selectedGoal
    return Button {
      selectedGoal = goal
    } label: {
      HStack(spacing: 13) {
        Image(systemName: icon(for: goal))
          .adaptiveFont(size: 16, weight: .semibold)
          .foregroundStyle(isSelected ? AppPalette.link : AppPalette.secondaryText)
          .frame(width: 38, height: 38)
          .background(
            isSelected
              ? AppPalette.accent.opacity(0.18) : Color(red: 0.106, green: 0.110, blue: 0.129),
            in: RoundedRectangle(cornerRadius: 9)
          )

        VStack(alignment: .leading, spacing: 2) {
          HStack(spacing: 6) {
            Text(goal.title)
              .adaptiveFont(size: 15, weight: .bold)
              .foregroundStyle(isSelected ? .white : AppPalette.primaryText)
            if goal == .recommended {
              Text("önerilen")
                .adaptiveFont(size: 10, weight: .semibold, design: .monospaced)
                .foregroundStyle(AppPalette.link)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(AppPalette.accent.opacity(0.2), in: Capsule())
            }
          }
          Text(goal.summary)
            .adaptiveFont(size: 12)
            .foregroundStyle(
              isSelected ? Color(red: 0.612, green: 0.788, blue: 0.910) : AppPalette.secondaryText)
        }

        Spacer(minLength: 0)

        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
          .adaptiveFont(size: 19, weight: .semibold)
          .foregroundStyle(isSelected ? AppPalette.accent : AppPalette.strongBorder)
      }
      .padding(15)
      .frame(minHeight: 44)
      .background(
        isSelected ? AppPalette.accent.opacity(0.1) : Color(red: 0.078, green: 0.082, blue: 0.098),
        in: RoundedRectangle(cornerRadius: 13)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 13)
          .stroke(
            isSelected ? AppPalette.accent : AppPalette.border, lineWidth: isSelected ? 1.5 : 1)
      )
    }
    .buttonStyle(.plain)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("\(goal.title), \(goal.summary)")
    .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
  }

  private func icon(for goal: DailyGoal) -> String {
    switch goal {
    case .calm: "clock"
    case .steady: "bolt.fill"
    case .intense: "flame.fill"
    }
  }

  private var readyPage: some View {
    page {
      VStack(spacing: 0) {
        Spacer(minLength: 16)
        Image(systemName: "checkmark")
          .adaptiveFont(size: 38, weight: .bold)
          .foregroundStyle(AppPalette.successText)
          .frame(width: 88, height: 88)
          .background(AppPalette.success.opacity(0.16), in: Circle())
          .overlay(Circle().stroke(AppPalette.successText.opacity(0.4), lineWidth: 1))
          .padding(.bottom, 24)

        Text("// workspace hazır")
          .adaptiveFont(size: 12, design: .monospaced)
          .foregroundStyle(AppPalette.successText)
          .padding(.bottom, 10)

        Text("İlk dersin\nseni bekliyor")
          .adaptiveFont(size: 32, weight: .heavy)
          .foregroundStyle(.white)
          .multilineTextAlignment(.center)
          .padding(.bottom, 14)

        lead("40 ders · temelden teknik analize. Bugün ilk satırı okuyarak başla.")
          .multilineTextAlignment(.center)
          .frame(maxWidth: 270)
          .padding(.bottom, 22)

        if let lesson = firstLesson {
          HStack(spacing: 12) {
            Image(systemName: "doc.text")
              .adaptiveFont(size: 16, weight: .semibold)
              .foregroundStyle(AppPalette.link)
              .frame(width: 38, height: 38)
              .background(AppPalette.accent.opacity(0.16), in: RoundedRectangle(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 2) {
              lessonFileName(for: lesson)
              Text("\(lesson.topic.capitalized) · \(lesson.estimatedMinutes) dk")
                .adaptiveFont(size: 11.5)
                .foregroundStyle(AppPalette.secondaryText)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
              .adaptiveFont(size: 13, weight: .bold)
              .foregroundStyle(AppPalette.link)
          }
          .padding(14)
          .background(
            Color(red: 0.078, green: 0.082, blue: 0.098),
            in: RoundedRectangle(cornerRadius: 14)
          )
          .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(AppPalette.border, lineWidth: 1)
          )
          .accessibilityElement(children: .combine)
        }
        Spacer(minLength: 16)
      }
      .frame(maxWidth: .infinity)
    }
  }

  private func lessonFileName(for lesson: XRayLesson) -> some View {
    (Text(lesson.fileStem) + Text(".swift").foregroundColor(CodeTokenKind.string.color))
      .adaptiveFont(size: 12, weight: .bold, design: .monospaced)
      .foregroundStyle(AppPalette.primaryText)
  }
}
