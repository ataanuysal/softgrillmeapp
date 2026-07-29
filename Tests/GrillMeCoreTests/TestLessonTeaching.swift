@testable import GrillMeCore

extension LessonTeaching {
  /// Konu anlatımını ölçmeyen testler için yer tutucu.
  ///
  /// Yayınlanan derslerin kendi metinlerini taşıması
  /// `RoadmapCurriculumTests.everyLessonTeachesItsOwnContent` ile zorunlu kılınır.
  static let test = LessonTeaching(
    whyItMatters: "test",
    commonMistake: "test",
    realWorldUse: "test"
  )
}
