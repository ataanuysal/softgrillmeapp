# GrillMe

GrillMe, sözdizimi ezberletmek yerine çalışan kodu okumayı ve programcı gibi
düşünmeyi öğreten bir iOS uygulamasıdır.

> Her gün kısa bir kodu tahmin et, bilgisayarın adımlarını görünür biçimde izle
> ve öğrendiğin zihinsel modeli yeni bir örneğe taşı.

Uygulama 30 günlük doğrusal bir öğrenme yolunu; tahmin, Kod Röntgeni, aktarım,
hata avcılığı ve Sokratik mentor döngüsüyle sunar.

![GrillMe 30 günlük öğrenme yolu](grillme-final-preview.png)

## Belgeler

- [INTENT.md](INTENT.md): Ürün vizyonu, hedef kullanıcı ve kapsam sınırları
- [MEMORY.md](MEMORY.md): Kalıcı kararlar ve güncel teknik durum
- [DESIGN.md](DESIGN.md): Öğrenme deneyimi, arayüz sistemi ve mimari
- [ROADMAP.md](ROADMAP.md): Tamamlanan teslim aşamaları ve kabul ölçütleri

## Tamamlanan ürün kapsamı

- Temelden çıkış değerlendirmesine uzanan 30 sıralı ders
- Değişken, koşul, döngü, fonksiyon, scope, `map`, `filter`, koleksiyon,
  nesne, mimari, debugging, asenkron sıra ve uygulama akışı içerikleri
- Çıktı tahmini, satır satır yürütme, bellek ve çıktı görünümü
- Fonksiyon çağrı yığını, mimari, hata ve dil lensleri
- Her derste yeni bir örneğe aktarım görevi
- Hipotez kurmadan hata satırı seçmeye izin vermeyen hata avcılığı
- Swift, Python ve JavaScript karşılaştırması
- 20 satırlık çıkış değerlendirmesi: çıktı, değer izi, çağrı sırası, hata
  noktası ve serbest açıklama görevleri
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
swift-format format --in-place --recursive GrillMe Tests
swift-format lint --recursive GrillMe Tests
```

## Proje yapısı

```text
GrillMe/
├── App/
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
    ├── LessonRun.swift
    ├── LearningAnalytics.swift
    └── ProgressStore.swift
Tests/
└── GrillMeCoreTests/
```

`Core`, SwiftUI'dan bağımsız ders, ölçüm ve oturum davranışını taşır. `App`,
çekirdek durumu ekrana bağlar ve yalnızca kullanılabildiğinde sistem dil
modeline erişir.

## Doğrulama

- 47 Swift Testing testi
- 16 test paketi
- Genel iOS Simulator derlemesi
- iPhone 17 Pro simülatöründe normal ve erişilebilir Dynamic Type görsel QA

Erişilebilir boyut kontrolü:

![GrillMe Dynamic Type görünümü](grillme-dynamic-type-preview.png)

## Repo notu

Kök dizindeki doğrulanmış uygulama `GrillMe.xcodeproj` dosyasıdır.
`grillmeapp/` altında daha önce oluşturulmuş ayrı UIKit iskeleti korunmaktadır;
kullanıcı kararı olmadan silinmemeli, taşınmamalı veya aktif projeyle
birleştirilmemelidir.
