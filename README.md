# GrillMe

GrillMe, sözdizimi ezberletmek yerine çalışan kodu okumayı ve programcı gibi
düşünmeyi öğreten bir iOS uygulamasıdır.

> Önce konuyu öğren, çalışan bir örneği bilgisayarın adımlarıyla izle ve en son
> öğrendiğini farklı kodlu quizde uygula.

Uygulama 30 derslik temel yolu ve ardından gelen 10 derslik uzmanlaşma yolunu;
konu anlatımı, rehberli Kod Röntgeni örneği, ders sonu quiz, hata avcılığı ve
Sokratik mentor döngüsüyle sunar. Yol Haritası ve İçindekiler bütün dersleri
baştan erişilebilir tutar; Yol Haritası yeni başlayanlara önerilen sırayı,
İçindekiler ise bölüm ve arama üzerinden serbest gezinmeyi sunar.

![GrillMe 30 günlük öğrenme yolu](grillme-final-preview.png)

## Belgeler

- [INTENT.md](INTENT.md): Ürün vizyonu, hedef kullanıcı ve kapsam sınırları
- [MEMORY.md](MEMORY.md): Kalıcı kararlar ve güncel teknik durum
- [DESIGN.md](DESIGN.md): Öğrenme deneyimi, arayüz sistemi ve mimari
- [ROADMAP.md](ROADMAP.md): Tamamlanan teslim aşamaları ve kabul ölçütleri

## Tamamlanan ürün kapsamı

- Temelden çıkış değerlendirmesine uzanan 30 ders ve iki uzmanlaşma ünitesindeki
  10 ders
- Yol Haritası ve İçindekiler üzerinden 40 dersin tamamına serbest erişim;
  önerilen sıra, bölüm filtresi ve Türkçe karakterlerden bağımsız arama
- Değişken, koşul, döngü, fonksiyon, scope, `map`, `filter`, koleksiyon,
  nesne, mimari, debugging, asenkron sıra ve uygulama akışı içerikleri
- Konu anlatımı → rehberli örnek → farklı kodlu quiz sırasını zorunlu tutan
  ders yolculuğu
- Satır satır yürütme, bellek ve çıktı görünümü
- Fonksiyon çağrı yığını, mimari, hata ve dil lensleri
- Her derste yeni bir örneğe aktarım görevi
- Hipotez kurmadan hata satırı seçmeye izin vermeyen hata avcılığı
- Swift, Python, JavaScript ve Java karşılaştırması
- 20 satırlık çıkış değerlendirmesi: çıktı, değer izi, çağrı sırası, hata
  noktası ve serbest açıklama görevleri
- Yazılım testi: Arrange–Act–Assert, unit test, sınır değer, test double,
  integration ve regression
- Teknik analiz: kabul kriteri, sistem akışı, veri sözleşmesi, etki/risk analizi
  ve uygulanabilir teknik plan
- Ders süresi, ilk/tekrar tahmin doğruluğu, aktarım doğruluğu, günlük seri,
  haftalık özet ve başlangıç/çıkış gelişim raporu
- Cihaz üzerinde JSON tabanlı, eski kayıtlarla uyumlu ilerleme
- Kişisel verisiz temel öğrenme olayı sözleşmesi
- Tur bütçeli Sokratik mentor; iOS 26 ve desteklenen cihazlarda Apple
  Foundation Models, diğer durumlarda çevrimdışı yerel rehber
- Üretilen mentor cevabının doğru sonucu açıklamasını engelleyen güvenlik
  filtresi
- Dynamic Type erişilebilirlik boyutlarına uyarlanan SwiftUI arayüzü ve
  metinli erişilebilir eylemler

## Gereksinimler

- macOS
- Xcode 26 veya uyumlu güncel bir Xcode sürümü
- iOS 17 veya üzeri
- Swift 6

Cihaz içi üretken mentor iOS 26, Apple Intelligence ve uygun bir cihaz modeli
gerektirir. Bu şartlar sağlanmadığında uygulamanın bütün ders akışı yerel,
deterministik Sokratik rehberle çalışmaya devam eder.

## Projeyi çalıştırma

1. `GrillMe.xcodeproj` dosyasını Xcode ile açın.
2. `GrillMe` şemasını seçin.
3. Bir iPhone simülatörü veya cihaz seçip Run düğmesine basın.

Kod imzalama olmadan komut satırı derlemesi:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
CLANG_MODULE_CACHE_PATH=/private/tmp/grillme-xcode-module-cache \
xcodebuild \
  -project GrillMe.xcodeproj \
  -scheme GrillMe \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /private/tmp/grillme-derived \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Testler

Çekirdek öğrenme akışı bağımsız bir Swift Package hedefidir:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
CLANG_MODULE_CACHE_PATH=/private/tmp/grillme-module-cache \
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/grillme-module-cache \
swift test --disable-sandbox
```

Biçim ve lint:

```sh
swift-format format --in-place --recursive GrillMe Tests Scripts
swift-format lint --recursive GrillMe Tests Scripts
```

## Proje yapısı

```text
GrillMe/
├── App/
│   ├── Assets.xcassets/
│   ├── GrillMeApp.swift
│   ├── ContentView.swift
│   └── OnDeviceMentor.swift
└── Core/
    ├── GrillMeCore.swift
    ├── IntroLesson.swift
    ├── LoopsLesson.swift
    ├── WeekOneLessons.swift
    ├── RoadmapLessons.swift
    ├── LessonCatalog.swift
    ├── LessonValidator.swift
    ├── AdvancedLenses.swift
    ├── LanguageBridge.swift
    ├── SocraticMentor.swift
    ├── LessonJourney.swift
    ├── LessonRun.swift
    ├── LearningAnalytics.swift
    └── ProgressStore.swift
Tests/
└── GrillMeCoreTests/
Scripts/
└── generate-app-icon.swift
```

`Core`, SwiftUI'dan bağımsız ders, ölçüm ve oturum davranışını taşır. `App`,
çekirdek durumu ekrana bağlar ve yalnızca kullanılabildiğinde sistem dil
modeline erişir. `Assets.xcassets`, App Store dağıtımı için `AppIcon` setini;
üretim betiği ise markayla uyumlu 1024×1024 kaynak ikonu taşır.

## Doğrulama

- 54 Swift Testing testi
- 17 test paketi
- Genel iOS Simulator derlemesi
- Release iOS arşivinde `CFBundleIconName = AppIcon` ve 120×120 uygulama ikonu
- iPhone 17 Pro simülatöründe normal ve erişilebilir Dynamic Type görsel QA

Erişilebilir boyut kontrolü:

![GrillMe Dynamic Type görünümü](grillme-dynamic-type-preview.png)

## Repo notu

Depodaki tek uygulama projesi kök dizindeki `GrillMe.xcodeproj` dosyasıdır.
