import XCTest

final class GrillMeUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testLaunchNavigationAndLessonEntry() {
    let app = XCUIApplication()
    app.launch()

    dismissOnboardingIfPresent(in: app)

    XCTAssertTrue(
      app.tabBars.buttons["Yol Haritası"].waitForExistence(timeout: 10),
      "Açılış ekranından sonra Yol Haritası sekmesi görünmeli"
    )
    XCTAssertTrue(app.staticTexts["GRILLME"].exists)

    app.tabBars.buttons["İçindekiler"].tap()
    XCTAssertTrue(
      app.staticTexts["İstediğin konudan başla"].waitForExistence(timeout: 5)
    )

    // Ders satırı bir editör dosyası gibi görünür; başlık yalnızca satırın
    // erişilebilirlik etiketinde geçtiği için sorgu oradan yapılır.
    let firstLesson = app.buttons
      .containing(NSPredicate(format: "label CONTAINS %@", "Değerin izini sür"))
      .firstMatch
    XCTAssertTrue(firstLesson.waitForExistence(timeout: 5), "İlk ders satırı bulunamadı")
    firstLesson.tap()

    // Ders artık anlatımdan önce bir tahmin adımıyla açılıyor.
    let skipPrediction = app.buttons["Tahmin etmeden geç"]
    XCTAssertTrue(skipPrediction.waitForExistence(timeout: 5), "Tahmin adımı görünmedi")
    skipPrediction.tap()

    XCTAssertTrue(app.staticTexts["KONU_ANLATIMI.md"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.buttons["Konu ile ilgili örneğe geç"].exists)
  }

  /// İlk açılış akışı yalnızca temiz kurulumda görünür; testin her iki durumda
  /// da aynı yerden devam edebilmesi için varsa atlanır.
  private func dismissOnboardingIfPresent(in app: XCUIApplication) {
    let skip = app.buttons["Atla"]
    guard skip.waitForExistence(timeout: 10) else { return }
    skip.tap()
  }
}
