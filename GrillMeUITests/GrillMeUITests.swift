import XCTest

final class GrillMeUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testLaunchNavigationAndLessonEntry() {
    let app = XCUIApplication()
    app.launch()

    XCTAssertTrue(
      app.tabBars.buttons["Yol Haritası"].waitForExistence(timeout: 5)
    )
    XCTAssertTrue(app.staticTexts["GRILLME"].exists)

    app.tabBars.buttons["İçindekiler"].tap()
    XCTAssertTrue(
      app.staticTexts["İstediğin konudan başla"].waitForExistence(timeout: 3)
    )

    app.staticTexts["Değerin izini sür"].firstMatch.tap()
    XCTAssertTrue(app.staticTexts["KONU ANLATIMI"].waitForExistence(timeout: 3))
    XCTAssertTrue(app.buttons["Konu ile ilgili örneğe geç"].exists)
  }
}
