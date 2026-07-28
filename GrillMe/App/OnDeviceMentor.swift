import Foundation

#if canImport(FoundationModels)
  import FoundationModels
#endif

enum OnDeviceMentorError: Error {
  case unavailable
}

@MainActor
enum OnDeviceMentor {
  static var isAvailable: Bool {
    #if canImport(FoundationModels)
      if #available(iOS 26.0, *) {
        return SystemLanguageModel.default.isAvailable
      }
    #endif
    return false
  }

  static func reply(to prompt: String) async throws -> String {
    #if canImport(FoundationModels)
      if #available(iOS 26.0, *), SystemLanguageModel.default.isAvailable {
        let session = LanguageModelSession(
          instructions: """
            Sen GrillMe uygulamasındaki Türkçe Sokratik kod okuma mentorüsün.
            Kısa, sıcak ve merak uyandıran sorularla öğrencinin kendisinin düşünmesini sağla.
            """
        )
        return try await session.respond(to: prompt).content
      }
    #endif
    throw OnDeviceMentorError.unavailable
  }
}
