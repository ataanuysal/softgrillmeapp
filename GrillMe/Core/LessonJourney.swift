public struct LessonTeachingContent: Equatable, Sendable {
  public let explanation: String
  public let keyIdea: String
  public let exampleCode: [CodeLine]

  public init(
    explanation: String,
    keyIdea: String,
    exampleCode: [CodeLine]
  ) {
    self.explanation = explanation
    self.keyIdea = keyIdea
    self.exampleCode = exampleCode
  }
}

public struct LessonQuiz: Equatable, Sendable {
  public let prompt: String
  public let code: [CodeLine]
  public let choices: [String]
  public let correctAnswer: String
  public let explanation: String

  public init(
    prompt: String,
    code: [CodeLine],
    choices: [String],
    correctAnswer: String,
    explanation: String
  ) {
    self.prompt = prompt
    self.code = code
    self.choices = choices
    self.correctAnswer = correctAnswer
    self.explanation = explanation
  }
}

public enum LessonJourneyPhase: Equatable, Sendable {
  case topic
  case example(step: Int)
  case quiz
  case complete
}

public struct LessonJourney: Equatable, Sendable {
  public let lesson: XRayLesson
  public private(set) var phase: LessonJourneyPhase = .topic
  public private(set) var selectedQuizAnswer: String?
  public private(set) var isQuizAnswerCorrect: Bool?

  public init(lesson: XRayLesson) {
    self.lesson = lesson
  }

  public var teachingContent: LessonTeachingContent {
    let context = lesson.teachingContext
    return LessonTeachingContent(
      explanation: """
        \(lesson.objective)

        \(lesson.takeaway)

        Neden önemli: \(context.whyItMatters)

        Sık hata: \(context.commonMistake)

        Gerçek projede: \(context.realWorldUse)
        """,
      keyIdea: lesson.takeaway,
      exampleCode: lesson.code
    )
  }

  public var quiz: LessonQuiz {
    guard let challenge = lesson.transferChallenge else {
      return LessonQuiz(
        prompt: lesson.question,
        code: lesson.code,
        choices: lesson.choices,
        correctAnswer: lesson.correctAnswer,
        explanation: lesson.takeaway
      )
    }

    return LessonQuiz(
      prompt: challenge.prompt,
      code: challenge.code,
      choices: challenge.choices,
      correctAnswer: challenge.correctAnswer,
      explanation: challenge.explanation
    )
  }

  public var currentExampleStep: TraceStep? {
    guard case .example(let step) = phase, lesson.trace.indices.contains(step) else {
      return nil
    }
    return lesson.trace[step]
  }

  public mutating func startExample() {
    guard phase == .topic else { return }
    phase = lesson.trace.isEmpty ? .quiz : .example(step: 0)
  }

  public mutating func advanceExample() {
    guard case .example(let step) = phase else { return }
    let nextStep = step + 1
    phase =
      lesson.trace.indices.contains(nextStep)
      ? .example(step: nextStep)
      : .quiz
  }

  public mutating func submitQuizAnswer(_ answer: String) {
    guard phase == .quiz else { return }
    selectedQuizAnswer = answer
    isQuizAnswerCorrect = answer == quiz.correctAnswer
    phase = .complete
  }
}

private struct LessonTeachingContext {
  let whyItMatters: String
  let commonMistake: String
  let realWorldUse: String
}

extension XRayLesson {
  fileprivate var teachingContext: LessonTeachingContext {
    switch section {
    case .fundamentals:
      LessonTeachingContext(
        whyItMatters:
          "\(topic.lowercased()) bilgisi, kodun hangi değerle hangi yolu seçeceğini önceden açıklayabilmenin temelidir.",
        commonMistake:
          "Satırları yalnızca yukarıdan aşağı okumak ve her satırdan sonra değişen değeri not etmemek.",
        realWorldUse:
          "Form doğrulama, fiyat hesaplama ve kullanıcı eylemlerine verilen kararlar aynı değer-akış mantığıyla çalışır."
      )
    case .functions:
      LessonTeachingContext(
        whyItMatters:
          "\(topic.lowercased()) sayesinde büyük bir akışı küçük, isimlendirilmiş ve tekrar kullanılabilir adımlara ayırabilirsin.",
        commonMistake:
          "Çağrı noktasını, fonksiyonun yerel değerlerini ve dönüş değerini tek bir kapsam sanmak.",
        realWorldUse:
          "Ekran eylemleri servis, doğrulama ve hesaplama fonksiyonlarına gider; sonuç daha sonra çağrı noktasına döner."
      )
    case .collections:
      LessonTeachingContext(
        whyItMatters:
          "\(topic.lowercased()) birden fazla değeri düzenli biçimde okuyup dönüştürmenin temel aracıdır.",
        commonMistake:
          "Index veya key değerinin gerçekten var olduğunu kontrol etmeden koleksiyona erişmek.",
        realWorldUse:
          "Ürün listeleri, kullanıcı kayıtları ve API cevapları uygulamada koleksiyon olarak taşınır."
      )
    case .objects:
      LessonTeachingContext(
        whyItMatters:
          "\(topic.lowercased()) verinin sahibi ile o veri üzerinde çalışan davranışı birlikte anlamanı sağlar.",
        commonMistake:
          "Class tanımı ile bellekte oluşturulmuş instance'ı ya da değer kopyası ile paylaşılan referansı karıştırmak.",
        realWorldUse:
          "Ekran modelleri, servisler ve depolar gerçek uygulamalarda sorumluluk sahibi nesneler olarak birlikte çalışır."
      )
    case .debugging:
      LessonTeachingContext(
        whyItMatters:
          "\(topic.lowercased()) belirtiden kök nedene kanıtla ulaşmayı ve rastgele kod değiştirmemeyi sağlar.",
        commonMistake:
          "Beklenen ve gerçek davranışı yazmadan ilk şüpheli satırı değiştirmek.",
        realWorldUse:
          "Çökme raporları, başarısız testler ve kullanıcı hataları aynı hipotez-gözlem-kanıt döngüsüyle araştırılır."
      )
    case .asynchronous:
      LessonTeachingContext(
        whyItMatters:
          "Asenkron akışta başlatma sırası ile tamamlanma sırasının farklı olabileceğini bilmek yarış koşullarını önler.",
        commonMistake:
          "Bir işi önce başlatmanın onun önce tamamlanacağını garanti ettiğini varsaymak.",
        realWorldUse:
          "Ağ istekleri, dosya okuma ve kullanıcı arayüzü güncellemeleri bekleme noktalarıyla açıkça sıralanır."
      )
    case .appArchitecture:
      LessonTeachingContext(
        whyItMatters:
          "Uygulama akışını katmanlara ayırmak bir hatanın ve değişikliğin hangi sorumluluğa ait olduğunu gösterir.",
        commonMistake:
          "Ekran, iş kuralı ve veri erişimini aynı tipte toplayarak bağımlılık yönünü görünmez yapmak.",
        realWorldUse:
          "View, ViewModel ve Repository arasında istek aşağı iner; sonuç gözlenebilir durum olarak ekrana geri döner."
      )
    case .assessment:
      LessonTeachingContext(
        whyItMatters:
          "Yeni kodu bağımsız çözmek, ezberlenen sözdizimi yerine gerçekten taşınabilen zihinsel modeli ölçer.",
        commonMistake:
          "Çıktıyı tahmin edip değer izi, çağrı sırası ve hata riskine kanıt göstermemek.",
        realWorldUse:
          "Kod inceleme ve teknik mülakatta sonuç kadar sonuca hangi kanıtla ulaştığın da değerlendirilir."
      )
    case .softwareTesting:
      LessonTeachingContext(
        whyItMatters:
          "\(topic.lowercased()) beklenen davranışı çalıştırılabilir bir sözleşmeye dönüştürür.",
        commonMistake:
          "Uygulama ayrıntısını doğrulayıp kullanıcı tarafından gözlenebilen davranışı test etmemek.",
        realWorldUse:
          "Unit, integration ve regression testleri değişikliklerin güvenle yayınlanmasını sağlayan kalite ağıdır."
      )
    case .technicalAnalysis:
      LessonTeachingContext(
        whyItMatters:
          "\(topic.lowercased()) belirsiz bir isteği ekip tarafından uygulanabilir ve doğrulanabilir hale getirir.",
        commonMistake:
          "Mutlu yolu yazıp hata yollarını, veri garantilerini, bağımlılıkları ve geri dönüş planını atlamak.",
        realWorldUse:
          "Ürün talepleri kodlanmadan önce kabul kriteri, sistem akışı, risk ve test planına dönüştürülür."
      )
    }
  }
}
