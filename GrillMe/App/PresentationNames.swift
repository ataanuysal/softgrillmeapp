import SwiftUI

// Çekirdek tiplerin arayüzde görünen adları ve renkleri.

extension CurriculumSection {
  /// Dosya gezgininde görünen klasör adı.
  var folderName: String {
    displayName.lowercased(with: Locale(identifier: "tr_TR"))
      .replacingOccurrences(of: " ", with: "_")
      .replacingOccurrences(of: "ı", with: "i")
      .replacingOccurrences(of: "ğ", with: "g")
      .replacingOccurrences(of: "ş", with: "s")
      .replacingOccurrences(of: "ç", with: "c")
      .replacingOccurrences(of: "ö", with: "o")
      .replacingOccurrences(of: "ü", with: "u")
  }

  var displayName: String {
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

  var accentColor: Color {
    switch self {
    case .fundamentals, .collections, .asynchronous:
      AppPalette.accent
    case .functions, .objects, .appArchitecture:
      AppPalette.mentor
    case .debugging, .assessment:
      AppPalette.highlight
    case .softwareTesting:
      AppPalette.accent
    case .technicalAnalysis:
      AppPalette.mentor
    }
  }
}

extension CodeLanguage {
  var displayName: String {
    switch self {
    case .swift: "Swift"
    case .python: "Python"
    case .javascript: "JavaScript"
    case .java: "Java"
    }
  }
}

extension CodeLens {
  var displayName: String {
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

  var icon: String {
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

  var accentColor: Color {
    switch self {
    case .error:
      AppPalette.highlight
    case .call, .architecture, .language:
      AppPalette.mentor
    case .flow, .memory, .output:
      AppPalette.accent
    }
  }
}

extension AssessmentTaskKind {
  var icon: String {
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
  var mentorConcepts: [String] {
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
