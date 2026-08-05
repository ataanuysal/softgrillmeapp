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
    // Sekme geçişi yüklü bir makinede birkaç saniye sürebiliyor; bekleme
    // dosyadaki diğer açılış beklemeleriyle aynı seviyede tutulur.
    XCTAssertTrue(
      app.staticTexts["İstediğin konudan başla"].waitForExistence(timeout: 10)
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

  func testReadingLibraryFlowFromCatalogToLessonCompletion() {
    let app = XCUIApplication()
    app.launch()

    dismissOnboardingIfPresent(in: app)

    app.tabBars.buttons["İçindekiler"].tap()

    let courseCard = app.buttons
      .containing(NSPredicate(format: "label CONTAINS %@", "Yazılım Mühendisliği Temelleri"))
      .firstMatch
    XCTAssertTrue(courseCard.waitForExistence(timeout: 10), "Kavram kitaplığı kartı bulunamadı")
    courseCard.tap()

    // Modül listesi: yayındaki modül açılır, yazılmamış modül "Yakında" der.
    let module = app.buttons
      .containing(NSPredicate(format: "label CONTAINS %@", "Yönelim ve Çalışma Yöntemi"))
      .firstMatch
    XCTAssertTrue(module.waitForExistence(timeout: 5), "Modül satırı bulunamadı")
    XCTAssertTrue(
      app.staticTexts
        .containing(NSPredicate(format: "label CONTAINS %@", "Yakında"))
        .firstMatch.exists,
      "Yazılmamış modüller yakında olarak işaretlenmeli"
    )
    module.tap()

    let lesson = app.buttons
      .containing(NSPredicate(format: "label CONTAINS %@", "Yazılım nedir?"))
      .firstMatch
    XCTAssertTrue(lesson.waitForExistence(timeout: 5), "Ders satırı bulunamadı")
    lesson.tap()

    // Markdown ekranı: anlatım → alıştırmalar → tamamla → sonraki ders.
    XCTAssertTrue(app.staticTexts["orientation-01.md"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.staticTexts["BU DERSTE KAZANACAKLARIN"].exists)

    // Okuma ilerlemesi diskte kalıcıdır: ilk koşu dersi tamamlar, sonraki
    // koşularda aynı ders doğrudan "tamamlandı" durumunda açılır. Test iki
    // durumu da aynı son duruma getirir.
    let toExercises = app.buttons["Alıştırmalara geç"]
    if toExercises.waitForExistence(timeout: 5) {
      toExercises.tap()

      let complete = app.buttons["Dersi tamamla"]
      XCTAssertTrue(complete.waitForExistence(timeout: 5), "Alıştırmalardan sonra tamamlama yok")
      complete.tap()
    }

    XCTAssertTrue(
      app.buttons
        .containing(NSPredicate(format: "label CONTAINS %@", "Sonraki ders"))
        .firstMatch.waitForExistence(timeout: 5),
      "Tamamlanan dersten sonraki derse geçiş görünmeli"
    )
  }

  /// İlk açılış akışı yalnızca temiz kurulumda görünür; testin her iki durumda
  /// da aynı yerden devam edebilmesi için varsa atlanır.
  private func dismissOnboardingIfPresent(in app: XCUIApplication) {
    let skip = app.buttons["Atla"]
    guard skip.waitForExistence(timeout: 10) else { return }
    skip.tap()
  }
}
