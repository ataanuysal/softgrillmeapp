import Testing

@testable import GrillMeCore

@Suite("Ders dosya adı")
struct LessonFileNameTests {
  @Test("Türkçe başlık aksansız dosya adına çevrilir")
  func buildsSlugFromTitle() {
    #expect(XRayLesson.introduction.fileStem == "01_degerin_izini_sur")
  }

  @Test("Noktalama ve boşluk tek alt çizgiye iner")
  func collapsesPunctuation() {
    let lesson = LessonCatalog.standard.lessons.first { $0.id == "conditions" }

    #expect(lesson?.fileStem == "02_hangi_yol_calisir")
  }

  @Test("Sıra numarası iki basamağa tamamlanır ve benzersiz kalır")
  func padsOrderAndStaysUnique() {
    let stems = LessonCatalog.standard.lessons.map(\.fileStem)

    #expect(stems.allSatisfy { $0.prefix(2).allSatisfy(\.isNumber) })
    #expect(Set(stems).count == stems.count)
    #expect(stems.allSatisfy { !$0.contains("__") && !$0.hasSuffix("_") })
  }
}
