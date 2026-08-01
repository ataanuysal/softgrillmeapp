import SwiftUI

// Ders deneyimi: konu → rehberli örnek → quiz → kanıt → tamamlama.

struct XRayLessonView: View {
  /// Tekrar akışında havuzdaki sıradaki soruyla açılmak için.
  private let initialQuestionIndex: Int
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
    questionIndex: Int = 0,
    onComplete: @escaping (LessonRunResult) -> Void
  ) {
    self.lesson = lesson
    self.totalLessonCount = totalLessonCount
    initialQuestionIndex = questionIndex
    self.onComplete = onComplete
    _journey = State(initialValue: LessonJourney(lesson: lesson, questionIndex: questionIndex))
    _run = State(
      initialValue: LessonRun(
        lessonID: lesson.id,
        startedAt: Date(),
        attemptNumber: questionIndex + 1
      )
    )
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
        colors: [AppPalette.accent.opacity(0.16), .clear],
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
    .tint(AppPalette.accent)
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
                colors: [AppPalette.accent, AppPalette.link],
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
        .background(AppPalette.accent, in: RoundedRectangle(cornerRadius: 10))

      Text("KOD RÖNTGENİ")
        .adaptiveFont(size: 13, weight: .bold, design: .default)
        .tracking(1.4)
        .foregroundStyle(.white)
    }
  }

  private var lessonPosition: some View {
    Label("\(lesson.order) / \(totalLessonCount)", systemImage: "flame.fill")
      .adaptiveFont(size: 13, weight: .semibold, design: .default)
      .foregroundStyle(AppPalette.highlight)
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(AppPalette.card, in: Capsule())
      .overlay(Capsule().stroke(AppPalette.border, lineWidth: 1))
  }

  private var lessonHeading: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("DERS \(String(format: "%02d", lesson.order))  ·  \(lesson.topic)")
        .adaptiveFont(size: 12, weight: .bold, design: .default)
        .tracking(1.2)
        .foregroundStyle(AppPalette.accent)

      Text(lesson.title)
        .adaptiveFont(size: 34, weight: .bold, design: .default)
        .foregroundStyle(.white)

      Text(stageInstruction)
        .adaptiveFont(size: 16, weight: .regular, design: .default)
        .foregroundStyle(AppPalette.secondaryText)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  @ViewBuilder
  private var lessonStage: some View {
    switch journey.phase {
    case .predict:
      predictionPanel

    case .topic:
      topicPanel

    case .example:
      lensStrip
      languagePicker
      CodeCard(
        lines: lesson.code(for: selectedLanguage),
        activeLineNumber:
          selectedLanguage == .swift ? journey.currentExampleStep?.lineNumber : nil,
        languageLabel: selectedLanguage.displayName.uppercased(),
        language: selectedLanguage
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
    case .predict:
      "Önce tahmin et. Yanlış tahmin de öğrenmenin parçası; anlatım tahminden sonra gelir."
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
            .adaptiveFont(size: 11, weight: .bold, design: .default)
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
          .adaptiveFont(size: 11, weight: .bold, design: .default)
          .tracking(1)
          .foregroundStyle(AppPalette.highlight)

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
          .stroke(AppPalette.border, lineWidth: 1)
      )
    }
  }

  @ViewBuilder
  private var languageComparison: some View {
    if selectedLanguage != .swift, let comparison = lesson.languageComparison {
      VStack(alignment: .leading, spacing: 9) {
        Label("MANTIK AYNI", systemImage: "equal.circle.fill")
          .adaptiveFont(size: 11, weight: .bold, design: .default)
          .foregroundStyle(AppPalette.accent)

        Text(comparison.invariant)
          .adaptiveFont(size: 14, weight: .semibold, design: .default)
          .foregroundStyle(.white)

        if let difference = comparison.syntaxDifferences[selectedLanguage] {
          Text("Syntax farkı: \(difference)")
            .adaptiveFont(size: 13, design: .default)
            .foregroundStyle(AppPalette.secondaryText)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(16)
      .background(AppPalette.accent.opacity(0.07), in: RoundedRectangle(cornerRadius: 18))
    }
  }

  /// Anlatımdan önceki tahmin ekranı.
  ///
  /// Cevap ölçüme girmez; amacı öğrencinin varsayımını görünür kılmak.
  @ViewBuilder
  private var predictionPanel: some View {
    if let hook = lesson.teaching.hook {
      VStack(alignment: .leading, spacing: 18) {
        JourneyStepper(currentStep: 0)

        Label("TAHMİN", systemImage: "questionmark.circle")
          .adaptiveFont(size: 11, weight: .bold, design: .monospaced)
          .foregroundStyle(AppPalette.highlight)

        Text(hook.question)
          .adaptiveFont(size: 20, weight: .bold)
          .foregroundStyle(.white)
          .fixedSize(horizontal: false, vertical: true)

        CodeCard(lines: hook.code, activeLineNumber: nil)

        VStack(spacing: 9) {
          ForEach(hook.choices, id: \.self) { choice in
            Button {
              withAnimation(.snappy) { journey.submitPrediction(choice) }
            } label: {
              Text(choice)
                .adaptiveFont(size: 16, weight: .bold, design: .monospaced)
                .foregroundStyle(AppPalette.primaryText)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 9))
                .overlay(
                  RoundedRectangle(cornerRadius: 9)
                    .stroke(AppPalette.strongBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .accessibilityHint("Tahmininizi seçer ve konu anlatımını açar")
          }
        }

        Button("Tahmin etmeden geç") {
          withAnimation(.snappy) { journey.skipPrediction() }
        }
        .adaptiveFont(size: 13, weight: .semibold)
        .foregroundStyle(AppPalette.secondaryText)
        .frame(maxWidth: .infinity, minHeight: 44)
      }
      .padding(20)
      .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 12))
      .overlay(
        RoundedRectangle(cornerRadius: 12).stroke(AppPalette.border, lineWidth: 1)
      )
    }
  }

  /// Tahmin verildiyse anlatımın başında hatırlatılır.
  @ViewBuilder
  private var predictionRecall: some View {
    if let hook = lesson.teaching.hook, let answer = journey.predictionAnswer {
      IDECallout(
        title: journey.isPredictionCorrect == true ? "// TAHMİNİN DOĞRUYDU" : "// TAHMİNİN",
        message: journey.isPredictionCorrect == true
          ? "\(answer) dedin ve doğruydu. \(hook.reveal)"
          : "\(answer) dedin, doğrusu \(hook.correctAnswer). \(hook.reveal)",
        tint: journey.isPredictionCorrect == true ? AppPalette.successText : AppPalette.highlight,
        systemImage: journey.isPredictionCorrect == true
          ? "checkmark.circle" : "arrow.triangle.branch",
        filled: true
      )
    }
  }

  /// Anlatımın içindeki küçük gösterim.
  @ViewBuilder
  private var microExamplePanel: some View {
    if let micro = lesson.teaching.microExample {
      VStack(alignment: .leading, spacing: 10) {
        Text("// KÜÇÜK ÖRNEK")
          .adaptiveFont(size: 10, weight: .bold, design: .monospaced)
          .foregroundStyle(AppPalette.link)
        CodeCard(lines: micro.code, activeLineNumber: nil)
        Text(micro.note)
          .adaptiveFont(size: 13)
          .foregroundStyle(AppPalette.secondaryText)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }

  /// Önceki derse bağ.
  @ViewBuilder
  private var connectionPanel: some View {
    if let connection = lesson.teaching.connection {
      IDECallout(
        title: "// ÖNCEKİ DERSTEN",
        message: connection,
        tint: AppPalette.link,
        systemImage: "arrow.turn.up.right"
      )
    }
  }

  private var topicPanel: some View {
    VStack(alignment: .leading, spacing: 20) {
      JourneyStepper(currentStep: 0)

      predictionRecall
      connectionPanel

      Label("KONU_ANLATIMI.md", systemImage: "doc.richtext")
        .adaptiveFont(size: 11, weight: .bold, design: .monospaced)
        .foregroundStyle(AppPalette.link)

      Text(journey.teachingContent.explanation)
        .adaptiveFont(size: 17, weight: .semibold, design: .default)
        .foregroundStyle(AppPalette.primaryText)
        .fixedSize(horizontal: false, vertical: true)

      IDECallout(
        title: "// AKLINDA KALSIN",
        message: journey.teachingContent.keyIdea,
        tint: AppPalette.highlight,
        systemImage: "lightbulb.max.fill",
        filled: true
      )

      microExamplePanel

      IDECallout(
        title: "// SIK HATA",
        message: lesson.teaching.commonMistake,
        tint: AppPalette.danger,
        systemImage: "exclamationmark.triangle.fill"
      )

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
        .adaptiveFont(size: 16, weight: .bold, design: .default)
        .foregroundStyle(AppPalette.background)
        .padding(18)
        .background(AppPalette.accent, in: RoundedRectangle(cornerRadius: 18))
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

  private var examplePanel: some View {
    VStack(spacing: 16) {
      JourneyStepper(currentStep: 1)
        .frame(maxWidth: .infinity, alignment: .leading)

      HStack(spacing: 12) {
        Image(systemName: "eye.fill")
          .foregroundStyle(AppPalette.accent)
          .frame(width: 32, height: 32)
          .background(AppPalette.accent.opacity(0.12), in: Circle())

        VStack(alignment: .leading, spacing: 3) {
          Text("KONU İLE İLGİLİ ÖRNEK")
            .adaptiveFont(size: 12, weight: .bold, design: .default)
            .tracking(0.8)
            .foregroundStyle(AppPalette.accent)
          Text("Kodun nasıl çalıştığını adım adım birlikte izliyoruz.")
            .adaptiveFont(size: 13, design: .default)
            .foregroundStyle(AppPalette.secondaryText)
        }

        Spacer()

        Text(exampleProgress)
          .adaptiveFont(size: 12, weight: .semibold, design: .default)
          .foregroundStyle(AppPalette.accent)
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
        .adaptiveFont(size: 16, weight: .bold, design: .default)
        .foregroundStyle(AppPalette.background)
        .padding(18)
        .background(AppPalette.accent, in: RoundedRectangle(cornerRadius: 18))
      }
      .buttonStyle(.plain)
    }
  }

  private var quizPanel: some View {
    let quiz = journey.quiz
    return VStack(alignment: .leading, spacing: 18) {
      JourneyStepper(currentStep: 2)

      Label("SON ADIM · QUIZ", systemImage: "checkmark.diamond.fill")
        .adaptiveFont(size: 12, weight: .bold, design: .default)
        .tracking(1)
        .foregroundStyle(AppPalette.mentor)

      Text("Şimdi sıra sende")
        .adaptiveFont(size: 24, weight: .bold, design: .default)
        .foregroundStyle(.white)

      Text(quiz.prompt)
        .adaptiveFont(size: 18, weight: .semibold, design: .default)
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
        .adaptiveFont(size: 13, design: .default)
        .foregroundStyle(AppPalette.tertiaryText)
    }
    .padding(20)
    .background(AppPalette.panel, in: RoundedRectangle(cornerRadius: 24))
    .overlay(
      RoundedRectangle(cornerRadius: 24)
        .stroke(AppPalette.strongBorder, lineWidth: 1)
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
            .stroke(AppPalette.accent.opacity(0.5), lineWidth: 1)
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
        journey.isQuizAnswerCorrect == true ? AppPalette.accent : AppPalette.highlight
      )

      VStack(alignment: .leading, spacing: 6) {
        Text(
          journey.isQuizAnswerCorrect == true
            ? "Quiz cevabın doğru" : "Doğru cevap: \(journey.quiz.correctAnswer)"
        )
        .adaptiveFont(size: 17, weight: .bold, design: .default)
        .foregroundStyle(.white)

        Text(journey.quiz.explanation)
          .adaptiveFont(size: 14, design: .default)
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
        .adaptiveFont(size: 12, weight: .bold, design: .default)
        .tracking(0.8)
        .foregroundStyle(AppPalette.highlight)

      Text(current.challenge.prompt)
        .adaptiveFont(size: 18, weight: .bold, design: .default)
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
        .adaptiveFont(size: 15, weight: .bold, design: .default)
        .frame(maxWidth: .infinity)
        .padding(16)
        .foregroundStyle(AppPalette.background)
        .background(AppPalette.highlight, in: RoundedRectangle(cornerRadius: 16))
        .disabled(debugHypothesis.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
      } else {
        CodeCard(lines: current.challenge.code, activeLineNumber: nil)

        Text("Sorunu üreten satırı seç")
          .adaptiveFont(size: 14, weight: .semibold, design: .default)
          .foregroundStyle(AppPalette.secondaryText)

        HStack(spacing: 8) {
          ForEach(current.challenge.code, id: \.number) { line in
            Button("Satır \(line.number)") {
              debugSession?.selectLine(line.number)
            }
            .adaptiveFont(size: 12, weight: .bold, design: .default)
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
            .foregroundStyle(.white)
            .background(AppPalette.card, in: RoundedRectangle(cornerRadius: 12))
          }
        }
      }
    }
    .padding(20)
    .background(AppPalette.highlight.opacity(0.08), in: RoundedRectangle(cornerRadius: 24))
    .overlay(
      RoundedRectangle(cornerRadius: 24)
        .stroke(AppPalette.highlight.opacity(0.28), lineWidth: 1)
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
        .foregroundStyle(debugSession.isCorrect == true ? AppPalette.accent : AppPalette.highlight)

        VStack(alignment: .leading, spacing: 5) {
          Text(
            debugSession.isCorrect == true ? "Hipotezin kanıtlandı" : "Kanıt yeni bir ipucu verdi"
          )
          .adaptiveFont(size: 16, weight: .bold, design: .default)
          .foregroundStyle(.white)
          Text(debugSession.evidence ?? "")
            .adaptiveFont(size: 13, design: .default)
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
          .adaptiveFont(size: 12, weight: .bold, design: .default)
          .foregroundStyle(AppPalette.link)

        ForEach(Array(lesson.practiceChallenges.enumerated()), id: \.offset) { index, challenge in
          VStack(alignment: .leading, spacing: 10) {
            Text(challenge.prompt)
              .adaptiveFont(size: 15, weight: .bold, design: .default)
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
                .adaptiveFont(size: 13, weight: .semibold, design: .default)
                .padding(12)
                .foregroundStyle(.white)
                .background(AppPalette.card, in: RoundedRectangle(cornerRadius: 12))
              }
              .buttonStyle(.plain)
            }

            if practiceAnswers[index] != nil {
              Text(challenge.explanation)
                .adaptiveFont(size: 12, design: .default)
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
          .adaptiveFont(size: 12, weight: .bold, design: .default)
          .foregroundStyle(AppPalette.accent)

        ForEach(lesson.assessmentTasks, id: \.kind.rawValue) { task in
          VStack(alignment: .leading, spacing: 10) {
            Label(task.prompt, systemImage: task.kind.icon)
              .adaptiveFont(size: 13, weight: .semibold, design: .default)
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
                  .adaptiveFont(size: 12, weight: .bold, design: .default)
                  .foregroundStyle(
                    evaluation.score == 1 ? AppPalette.accent : AppPalette.highlight
                  )
                Text(evaluation.feedback)
                  .adaptiveFont(size: 12, design: .default)
                  .foregroundStyle(AppPalette.secondaryText)
              }
            }
          }
        }
      }
      .padding(18)
      .background(AppPalette.accent.opacity(0.07), in: RoundedRectangle(cornerRadius: 20))
    }
  }

  private var mentorPanel: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack {
        Label("SOKRATİK MENTOR", systemImage: "sparkles")
          .adaptiveFont(size: 12, weight: .bold, design: .default)
          .foregroundStyle(AppPalette.mentor)
        Spacer()
        Text(OnDeviceMentor.isAvailable ? "Cihaz içi AI" : "Yerel rehber")
          .adaptiveFont(size: 10, weight: .semibold, design: .default)
          .foregroundStyle(
            OnDeviceMentor.isAvailable ? AppPalette.accent : AppPalette.secondaryText)
        Text("\(mentorCoordinator.remainingTurns) tur")
          .adaptiveFont(size: 11, weight: .semibold, design: .default)
          .foregroundStyle(AppPalette.secondaryText)
      }

      Text("Cevabı istemek yerine kodun neden böyle çalıştığını kendi cümlenle anlat.")
        .adaptiveFont(size: 13, design: .default)
        .foregroundStyle(AppPalette.secondaryText)

      ForEach(Array(mentorResponses.enumerated()), id: \.offset) { _, response in
        Text(response.text)
          .adaptiveFont(size: 13, weight: .semibold, design: .default)
          .foregroundStyle(response.kind == .feedback ? AppPalette.accent : .white)
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
      .adaptiveFont(size: 14, weight: .bold, design: .default)
      .padding(14)
      .foregroundStyle(.white)
      .background(AppPalette.mentor, in: RoundedRectangle(cornerRadius: 14))
      .disabled(
        isMentorResponding
          || mentorInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      )
    }
    .padding(18)
    .background(AppPalette.mentor.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
  }

  private var lessonActions: some View {
    VStack(spacing: 14) {
      HStack(spacing: 12) {
        Image(systemName: "lightbulb.max.fill")
          .foregroundStyle(AppPalette.highlight)
        Text("Gerçek ders: \(lesson.takeaway)")
          .adaptiveFont(size: 15, weight: .semibold, design: .default)
          .foregroundStyle(.white)
          .fixedSize(horizontal: false, vertical: true)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(18)
      .background(AppPalette.highlight.opacity(0.1), in: RoundedRectangle(cornerRadius: 18))

      if !evidenceEvaluation.isReadyToComplete {
        Label(
          missingEvidenceMessage,
          systemImage: "lock.open.trianglebadge.exclamationmark"
        )
        .adaptiveFont(size: 13, weight: .semibold, design: .default)
        .foregroundStyle(AppPalette.highlight)
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
        .adaptiveFont(size: 16, weight: .bold, design: .default)
        .foregroundStyle(AppPalette.background)
        .padding(18)
        .background(AppPalette.accent, in: RoundedRectangle(cornerRadius: 18))
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
          .adaptiveFont(size: 15, weight: .bold, design: .default)
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
    // Yeniden çözmede havuzdaki sıradaki soru sorulur; aynı cevabı hatırlamak
    // yerine aynı kavramı yeni bir kodda uygulamak gerekir.
    let nextAttempt = run.attemptNumber + 1
    journey = LessonJourney(
      lesson: lesson,
      questionIndex: initialQuestionIndex + nextAttempt - 1
    )
    run = LessonRun(lessonID: lesson.id, startedAt: Date(), attemptNumber: nextAttempt)
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
