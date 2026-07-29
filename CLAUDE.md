# CLAUDE.md

GrillMe: sözdizimi ezberletmeden kod okumayı öğreten iOS uygulaması. Türkçe
arayüz, İngilizce kod kimlikleri. Bağımlılık yok, ağ yok, backend yok, hesap yok.

Ürün bağlamı için `INTENT.md`, deneyim/mimari için `DESIGN.md`, güncel karar
kaydı için `MEMORY.md`, teslim durumu için `ROADMAP.md`.

## Komutlar

`xcode-select` bu makinede CommandLineTools'a bakıyor; **`DEVELOPER_DIR`
verilmeden `swift test` "no such module 'Testing'" hatası verir ve `xcodebuild`
hiç çalışmaz.** Her komutta öneki koru.

Çekirdek testler:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer CLANG_MODULE_CACHE_PATH=/private/tmp/grillme-module-cache SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/grillme-module-cache swift test
```

Uygulama derlemesi (imzasız):

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer CLANG_MODULE_CACHE_PATH=/private/tmp/grillme-xcode-module-cache xcodebuild -project GrillMe.xcodeproj -scheme GrillMe -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/grillme-derived CODE_SIGNING_ALLOWED=NO build
```

Format ve lint (CI `--strict` kullanır ve `GrillMeUITests`'i de tarar):

```bash
xcrun swift-format format --in-place --recursive GrillMe Tests GrillMeUITests Scripts
```

```bash
xcrun swift-format lint --strict --recursive GrillMe Tests GrillMeUITests Scripts
```

`.swift-format` yapılandırması yoktur; varsayılan stil geçerlidir (2 boşluk
girinti, 100 sütun). CI sırası: lint → `swift test` → app build → XCUITest.

## Yapı

Aynı `GrillMe/Core` klasörü iki yerden derlenir:

- `Package.swift` → `GrillMeCore` kütüphanesi ve `swift test` hedefi
- `GrillMe.xcodeproj` → iOS uygulama hedefi

**`GrillMe/Core` veya `GrillMe/App` altına yeni dosya eklerken
`GrillMe.xcodeproj/project.pbxproj` içine elle `PBXFileReference` +
`PBXBuildFile` + grup + `Sources` girdisi ekle.** Proje
`fileSystemSynchronized` grup kullanmıyor; unutulursa `swift test` geçer ama
uygulama derlemesi "cannot find in scope" ile kırılır. Kimlikler `A1…`/`B1…`
sıralı desenini izler ve **kullanılmamış olmalıdır**: çakışan bir kimlik hata
vermez, dosyayı sessizce derleme dışında bırakır. `AppPackagingTests` hem her
`.swift` dosyasının `Sources` fazında olmasını hem de kimliklerin benzersiz
olmasını doğrular; ekleme sonrası `swift test` bunu yakalar.

Katman kuralı: `Core` SwiftUI'yı import etmez; ders verisi, durum makineleri,
ölçüm ve kalıcılık oradadır. `App` yalnızca bağlama, yerleşim ve sistem model
erişimi yapar. `ContentView.swift` tek dosyada tüm ekranları taşır (`private
struct` alt görünümler); `AppPalette` renkleri, `ScaledFontModifier` Dynamic
Type ölçeklemesini tutar.

## Ders verisi

Ders = `XRayLesson`. Üç üretim yolu var:

- `IntroLesson.swift`, `WeekOneLessons.swift`: 1–7. dersler, elle yazılmış
  `static let` tanımlar
- `RoadmapLessons.swift`: 8–40. dersler, `RoadmapBlueprint` üzerinden türetilir.
  `transferChallenge`, `debugChallenge` ve `programOutcome` blueprint
  alanlarından hesaplanır; **yürütme izi hesaplanmaz, `steps` içinde elle
  yazılır.** Şablondan iz üretimi bilinçli olarak kaldırıldı: ürünün vaadi
  değerin adım adım değişmesini göstermek, iz bunu taşımazsa ders o vaadi
  karşılamıyor demektir.
- `LessonCatalog.standard`: yayınlanan sıra; yeni ders buraya eklenmeden
  görünmez

`LessonValidator` her yayınlanan dersi doğrular ve testler bunu zorunlu kılar:
kod ve seçenekler dolu, doğru cevap seçenekler içinde, en az bir trace adımı,
trace satır numaraları koda ait, `estimatedMinutes` 5–10 arası, transfer cevabı
kendi seçeneklerinde. `programOutcome` `.output` ise son trace adımının çıktısı
ona eşit olmalı; `.compileError`/`.runtimeError`/`.noOutput` ise **hiçbir trace
adımı çıktı üretmemeli** (hata dersleri quiz cevabını çıktı gibi göstermez).

`RoadmapCurriculumTests` katalogun tam olarak 40 benzersiz derse ve kesintisiz
`1...40` sırasına sahip olmasını bekler; ders sayısını değiştiren her iş bu
testi de günceller. Aynı paket üç içerik sözleşmesini de zorunlu kılar:

- Her ders kendi `LessonTeaching` metnini taşır; iki ders aynı "sık hata" veya
  "gerçek projede" cümlesini paylaşamaz.
- Birden fazla değer izleyen her ders en az üç farklı bellek durumundan geçer.
- Gelişim raporunun karşılaştırdığı dersler (`variables`, `conditions`, `loops`,
  `capstone`) en az dört seçenek taşır.

## Davranış sözleşmeleri

Bunlar testlerle korunan ürün kuralları, üslup tercihi değil:

- `LessonJourney`: konu → örnek adımları → quiz. Quiz atlanamaz, quiz kodu
  rehberli örnekten farklıdır (`transferChallenge`).
- `DebugSession`: boş olmayan hipotez yazılmadan satır seçilemez.
- `LessonEvidence.evaluate`: quiz, debug, tüm pratik ve tüm değerlendirme
  yanıtları tamam değilse `isReadyToComplete` false; `LessonRun.finish` bu
  durumda `nil` döner ve ders tamamlanmaz.
- Üç ölçüm birbirine karıştırılmaz: `quizCorrect` (Bool), `practiceAccuracy`
  (oran), `assessmentScore` (rubrik). Ortalamaya katlanmaz.
- `SocraticMentorSession`: ders başına 6 tur; mentor sonucu vermez, tek soru
  sorar. `MentorPromptBuilder` isteme `correctAnswer` koymaz,
  `MentorSafetyFilter` sızan cevabı maskeler.
- `MentorCoordinator`: modele gidilip gidilmeyeceğine karar veren tek yer.
  Boş açıklama tur harcamaz; tur bittiyse, öğrenci kavramları kurduysa veya
  model yoksa istem üretilmez. Arayüz yalnızca asenkron çağrıyı ve iptali
  yönetir — bu kararları `ContentView` içine geri taşıma.
- `LearningEvent`: yalnızca `lesson_started`, `quiz_submitted`,
  `practice_submitted`, `assessment_submitted`, `lesson_completed`. Kişisel veri
  ve serbest metin taşımaz; olaylar cihazda kalır, hiçbir servise gönderilmez.
- `LessonAttempt` eski kayıtları okur (`predictionCorrect`/`transferCorrect` →
  `quizCorrect`/`practiceAccuracy`). Kalıcılık şemasını değiştirirken bu geriye
  dönük çözümlemeyi bozma.
- `FileProgressStore.loadRecovering`: bozuk dosyayı yedekler, boş ilerlemeyle
  devam eder ve kullanıcıya görünen bir uyarı döndürür — hata sessizce yutulmaz.

## Yazım kuralları

- Swift 6, iOS 17 hedefi. `Core` tipleri `public`, `Equatable`, `Sendable`;
  durum makineleri `struct` + `mutating`, dış dünyaya `private(set)`.
- Metin, ders içeriği ve kullanıcıya görünen hata mesajları Türkçe. Türkçe arama
  ve kavram eşlemesi `folding(options: [.caseInsensitive, .diacriticInsensitive],
  locale: Locale(identifier: "tr_TR"))` ile yapılır.
- Testler Swift Testing (`@Suite`/`@Test`/`#expect`), başlıkları Türkçe ve
  davranışı anlatır; dosya `Tests/GrillMeCoreTests/` altına konur (SwiftPM
  otomatik alır, pbxproj'a eklenmez).
- Yeni davranış önce başarısız testle tanımlanır, sonra en küçük uygulamayla
  geçirilir.
- Erişilebilirlik geriletilmez: eylemlerde görünür metin/etiket, Dynamic Type
  erişilebilir boyutlarda tek sütun, kod yatay kaydırılır, seçim durumu yalnızca
  renkle anlatılmaz, birincil butonlarda ≥44pt dokunma alanı.
- Commit mesajı: İngilizce, emir kipi, tek satır (`Add Java language support`).
- Kapsamı değiştiren iş `README.md`, `MEMORY.md`, `DESIGN.md`, `ROADMAP.md`
  içindeki ilgili sayıları ve durumu da günceller.

## Kavram eşleştirme

Serbest cevaplarda kavram araması yalnızca `ConceptMatcher` üzerinden yapılır;
`AssessmentRubric`, `SocraticMentorSession` ve katalog araması onu kullanır.
Yeni bir yerde `contains` ile kavram arama — Türkçede "risksiz" cevabı "risk"
kavramını kanıtlamış sayılır ve puan şişer.

Kural: kavram kelime başında başlar, ardından gelen harfler ek sayılır
("riskleri" eşleşir), ardından gelen rakam sınır ihlalidir ("60" içinde "6"
eşleşmez), olumsuzlayan ek (`-siz/-sız/-suz/-süz`) eşleşmeyi geçersiz kılar.

Rubrik yazarken: `RoadmapCurriculumTests.modelAnswersSatisfyTheirOwnRubric`
her rubriğin kendi `modelAnswer`'ını 1.0 puanlamasını zorunlu kılar. Bu test
kırılıyorsa ya kavram listesi ya örnek cevap yanlış — eşleştiriciyi gevşetme.
