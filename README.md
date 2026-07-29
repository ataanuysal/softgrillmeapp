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

## Ürün durumu

Uygulama uçtan uca çalışır ve 40 dersin tamamı oynanabilir. Ancak **hiçbir ders
henüz gerçek bir öğrenciyle denenmedi**; aşağıdaki kapsam tablosu neyin ne kadar
derinleştiğini olduğu gibi gösterir.

### Her derste var

- 40 dersin tamamına Yol Haritası ve İçindekiler üzerinden serbest erişim;
  önerilen sıra, bölüm filtresi ve Türkçe karakterlerden bağımsız arama
- Konu anlatımı → rehberli örnek → farklı kodlu quiz sırasını zorunlu tutan
  ders yolculuğu
- Rehberli örnekten farklı kod kullanan, üç seçenekli ders sonu quizi
- Aktif satır, bellek ve çıktı görünümü
- Quiz yapılmadan dersin tamamlanmasını engelleyen bitirme koşulu
- Tur bütçeli, cevabı vermeyen Sokratik mentor ve cevap sızıntısı filtresi

### Bir kısım derste var

| Yetenek | Ders sayısı |
| --- | ---: |
| Hipotez zorunlu hata avcılığı | 6 / 40 |
| Pratik soruları | 5 / 40 |
| Rubrikli açık uçlu değerlendirme | 2 / 40 |
| Swift, Python, JavaScript ve Java karşılaştırması | 1 / 40 |

### Bilinen içerik borcu

- 33 derste yürütme izi üç adımlık bir şablondan üretilir; bellek adım adım
  değil, tek seferde dolar. Satır satır izleme bu derslerde gerçek anlamda
  gösterilmez.
- Konu anlatımındaki "sık hata" metni ders başına değil bölüm başına yazılmıştır;
  40 derste 10 farklı metin vardır.
- Ders kodlarının ortanca uzunluğu 5 satırdır. 20 satırlık tek kod çıkış
  değerlendirmesidir, yani o uzunluk sınavdan önce hiç çalışılmaz.
- Bütün quizler üç seçeneklidir; şans başarısı %33'tür ve gelişim raporu üç
  başlangıç sorusunu tek bir çıkış sorusuyla karşılaştırır.

### Konu kapsamı

- Değişken, koşul, döngü, fonksiyon, scope, `map`, `filter`, koleksiyon,
  nesne, mimari, debugging, asenkron sıra ve uygulama akışı
- Yazılım testi: Arrange–Act–Assert, unit test, sınır değer, test double,
  integration ve regression
- Teknik analiz: kabul kriteri, sistem akışı, veri sözleşmesi, etki/risk analizi
  ve uygulanabilir teknik plan
- 20 satırlık çıkış değerlendirmesi: çıktı, değer izi, çağrı sırası, hata noktası
  ve serbest açıklama görevleri; her biri cevap alanı, kavram rubriği ve örnek
  yaklaşım taşır

### Platform ve altyapı

- Quiz doğruluğu, ek pratik yüzdesi ve rubrik puanını birbirine karıştırmadan
  saklayan ders ölçümü; günlük seri, haftalık özet ve başlangıç/çıkış raporu
- Cihaz üzerinde JSON tabanlı, eski kayıtlarla uyumlu ilerleme; bozuk dosyayı
  yedekleyen kurtarma ve kullanıcıya görünen kayıt hataları
- Kişisel verisiz ve cihazda kalıcı öğrenme olayı sözleşmesi
- iOS 26 ve desteklenen cihazlarda Apple Foundation Models, diğer durumlarda
  çevrimdışı yerel rehber
- Dynamic Type erişilebilirlik boyutlarına uyarlanan SwiftUI arayüzü ve
  metinli erişilebilir eylemler; büyük yazıda dikey kartlar, menü tipi dil
  seçimi ve yatay kaydırılabilir kod
- Uygulama açılışı, iki ana sekme ve derse giriş için gerçek XCUITest hedefi
- Format, 79 çekirdek test, uygulama derlemesi ve UI duman testini çalıştıran CI

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
swift test
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
    ├── ConceptMatcher.swift
    ├── LessonJourney.swift
    ├── LessonEvidence.swift
    ├── LessonRun.swift
    ├── LearningAnalytics.swift
    └── ProgressStore.swift
Tests/
└── GrillMeCoreTests/
GrillMeUITests/
└── GrillMeUITests.swift
.github/workflows/
└── ci.yml
Scripts/
└── generate-app-icon.swift
```

`Core`, SwiftUI'dan bağımsız ders, ölçüm ve oturum davranışını taşır. `App`,
çekirdek durumu ekrana bağlar ve yalnızca kullanılabildiğinde sistem dil
modeline erişir. `Assets.xcassets`, App Store dağıtımı için `AppIcon` setini;
üretim betiği ise markayla uyumlu 1024×1024 kaynak ikonu taşır.

## Doğrulama

- 79 Swift Testing testi
- 20 çekirdek test paketi
- 1 XCUITest duman testi
- GitHub Actions kalite hattı
- CI içinde genel iOS Simulator derleme adımı
- `CFBundleIconName = AppIcon` ve 1024×1024 kaynak ikon için paketleme testleri
- Uygulama ve UI test kaynaklarında iOS 17 hedefli, uyarısız Swift tip kontrolü

Önceki erişilebilir boyut kontrolü:

![GrillMe Dynamic Type görünümü](grillme-dynamic-type-preview.png)

## Repo notu

Depodaki tek uygulama projesi kök dizindeki `GrillMe.xcodeproj` dosyasıdır.
