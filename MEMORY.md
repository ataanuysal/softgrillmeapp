# Proje Hafızası

Son güncelleme: 29 Temmuz 2026

Bu dosya, yeni bir çalışma oturumunda projeye hızla devam edebilmek için kalıcı
kararları ve güncel teknik durumu tutar.

## Ürün özeti

GrillMe bir öğrenme kavramı, GrillMe:Code ise onun kod okuma alanındaki
uygulamasıdır. Bu depo yalnızca GrillMe:Code'u içerir; kavramın diğer
uygulamaları ayrı depolarda yaşayacaktır.

GrillMe:Code, kodlamaya başlayan yetişkinlere önce kod okumayı ve çalışma
mantığını öğreten bir iOS uygulamasıdır. Her ders önce konu anlatımı sunar, sonra “Kod
Röntgeni” ile aktif satırı, belleği, çıktıyı ve gerektiğinde çağrı, mimari ya da
hata bağlamını rehberli örnekte gösterir; en son farklı kodlu quiz açılır.

## Onaylanmış kararlar

- Platform iOS, aktif arayüz SwiftUI ve minimum hedef iOS 17'dir.
- Görsel dil VS Code Dark+ temelli "IDE teması"dır: editör paleti, sözdizimi
  renkleri, dosya adı gibi ders satırları ve mavi durum çubuğu.
- Aktif proje `GrillMe.xcodeproj`, şema `GrillMe`, görünen ad `GrillMe:Code`,
  bundle kimliği `com.grillme.learn`, sürüm `1.4` (build 5) değeridir. Hedef ve
  şema adları teknik kimliktir; ürün adı yalnızca `CFBundleDisplayName`
  üzerinden gelir.
- Yol Haritası önerilen doğrusal sırayı gösterir; bütün dersler baştan
  erişilebilirdir ve tamamlanma yalnızca durum işareti olarak kullanılır.
- İçindekiler kataloğunda 40 dersin tümü açıktır; bölüm filtresi ve Türkçe
  karakterlerden bağımsız arama serbest gezinme sağlar.
- Swift ilk dildir. Dil lensi aynı zihinsel modeli Python, JavaScript ve Java ile
  karşılaştırır.
- Yanlış cevap ceza değil, görünür yürütme ve açıklama için başlangıçtır.
- İş mantığı SwiftUI'dan bağımsız `GrillMeCore` hedefinde tutulur.
- Yeni davranışlar başarısız testle tanımlanıp en küçük uygulamayla geçirilir.
- İlerleme cihazdaki JSON dosyasında saklanır; eski tamamlanma kayıtları yeni
  deneme modeliyle uyumlu okunur. Bozuk dosya yedeklenir; yükleme ve kayıt
  sorunu kullanıcıdan gizlenmez.
- Mentor doğrudan cevap vermez. En fazla altı tur kullanır ve doğru cevap
  sızıntıları filtrelenir.
- iOS 26 ve uygun Apple Intelligence cihazlarında Foundation Models kullanılır;
  diğer sistemlerde yerel Sokratik rehber bütün işlevi korur.
- Harici backend, hesap veya analitik servisi eklenmemiştir.

## Güncel çalışan durum

### Müfredat

- 30 derslik temel yol ve 10 derslik uzmanlaşma yolu; toplam 40 benzersiz,
  sıralı ders
- Bölümler: temeller, fonksiyonlar, koleksiyonlar, nesneler, hata ayıklama,
  asenkron düşünme, uygulama mimarisi, çıkış değerlendirmesi, yazılım testi ve
  teknik analiz
- İlk hafta için yedi ayrıntılı ders ve karışık meydan okuma
- Fonksiyon çağrı sırası, scope, pure/side effect, `map` ve `filter`
- Array, dictionary, index, key ve koleksiyon meydan okuması
- Class, instance, property, method, initializer, value/reference,
  composition/inheritance ve mimari meydan okuması (15–21. dersler)
- Syntax/runtime/logic/edge case/optional/stack trace ve hipotezli debugging
- Asenkron sıra ve gerçek uygulama akışı
- 20 satırlık capstone ve beş parçalı çıkış değerlendirmesi
- Arrange–Act–Assert, unit test, sınır değer, test double, integration ve
  regression
- Kabul kriteri, sistem akışı, veri sözleşmesi, etki/risk analizi ve teknik
  analiz capstone'u

### Ürün davranışı

- Baştan açık ders haritası ve tamamlanmış ders işaretleri
- Yol Haritası ve İçindekiler arasında kalıcı alt sekme navigasyonu
- Bütün derslere doğrudan erişim, on bölüm filtresi ve kavram araması
- Konu anlatımı → rehberli örnek → quiz → geri bildirim/pratik → tamamlama
  döngüsü
- Akış, bellek, çıktı, çağrı, mimari, hata ve dil lensleri
- Swift/Python/JavaScript/Java kod seçimi ve syntax/mantık ayrımı
- Hipotez kurulmadan hata satırı seçilemeyen `DebugSession`
- İsimlendirme, kavram ve mimari pratik görevleri
- Ders süresi, quiz doğruluğu, ek pratik yüzdesi ve rubrik puanı kayıtları
- Günlük seri, üç bağımsız ölçümlü haftalık özet ve aynı boyuttaki quizleri
  karşılaştıran başlangıç/çıkış raporu
- Cihazda kalıcı, kişisel verisiz öğrenme analitiği olayları
- Rubrikli capstone cevapları ve eksik kanıtta kapalı ders tamamlama
- Bütçeli, kişiselleştirilmiş Sokratik mentor ve güvenlik filtresi
- Dynamic Type erişilebilir boyutlarında uyarlanan yerleşim
- İstek iptalinde eski cihaz içi mentor yanıtını eklemeyen görev yaşam döngüsü
- Gerçek XCUITest hedefi, paylaşılan şema ve GitHub Actions kalite hattı

## Çekirdek model

- `XRayLesson`, `CodeLine`, `TraceStep`, `TransferChallenge`
- `LessonCatalog`, `LessonCatalogItem`, `LessonContentsSection`, `LessonValidator`
- `CodeLens`, `CallFrame`, `ArchitectureSnapshot`
- `DebugChallenge`, `DebugSession`
- `PracticeChallenge`, `AssessmentTask`
- `CodeLanguage`, `CodeVariant`, `LanguageComparison`
- `SocraticMentorSession`, `MentorPromptBuilder`, `MentorSafetyFilter`
- `ConceptMatcher`, `MentorCoordinator`, `MentorTurn`, `LessonTeaching`
- `ReviewQueue`, `ReviewItem`, `ReviewReason`
- `CodeHighlighter`, `CodeToken`, `CodeTokenKind`, `DailyGoal`
- `LessonJourney`, `LessonTeachingContent`, `LessonQuiz`
- `LessonEvidence`, `LessonEvidenceEvaluation`, `AssessmentRubric`
- `LessonRun`, `LessonAttempt`, `LessonProgress`, `FileProgressStore`
- `LearningEvent`, `WeeklySummary`, `LearningGrowthReport`,
  `LearningDashboardSnapshot`

## Önemli dosyalar

- `GrillMe/App/ContentView.swift`: Açılış zinciri (splash → onboarding → sekmeler)
- `GrillMe/App/LessonMapView.swift`: Yol Haritası ve ders satırları
- `GrillMe/App/LessonContentsView.swift`: İçindekiler ve arama
- `GrillMe/App/LessonDetailView.swift`: Ders deneyiminin tamamı
- `GrillMe/App/EditorViews.swift`: Kod kartı ve yürütme adımı paneli
- `GrillMe/App/OnDeviceMentor.swift`: Foundation Models adaptörü ve uygunluk
- `GrillMe/Core/GrillMeCore.swift`: Ana ders ve oturum modeli
- `GrillMe/Core/WeekOneLessons.swift`: İlk hafta içeriği
- `GrillMe/Core/RoadmapLessons.swift`: 8–40. derslerin veri tabanlı tanımı
- `GrillMe/Core/AdvancedLenses.swift`: Çağrı, mimari, hata ve görev modelleri
- `GrillMe/Core/LanguageBridge.swift`: Dil karşılaştırma modeli
- `GrillMe/Core/SocraticMentor.swift`: Yerel mentor, istem ve güvenlik
- `GrillMe/Core/ConceptMatcher.swift`: Türkçe ek toleranslı kavram eşleştirme
- `GrillMe/Core/MentorCoordinator.swift`: Mentor akış kararı ve güvenli paketleme
- `GrillMe/Core/ReviewQueue.swift`: Aralıklı tekrar kuyruğu
- `GrillMe/Core/CodeHighlighter.swift`: Sözdizimi token'ları
- `GrillMe/Core/DailyGoal.swift`: Günlük ritim seçimi
- `GrillMe/App/IDETheme.swift`: Dark+ paleti ve editör kabuğu bileşenleri
- `GrillMe/App/SplashView.swift`: Açılış ekranı ve marka işareti
- `GrillMe/App/OnboardingView.swift`: Altı ekranlık ilk açılış akışı
- `GrillMe/Core/LessonJourney.swift`: Konu → örnek → quiz durum makinesi
- `GrillMe/Core/LessonEvidence.swift`: Zorunlu kanıt ve bağımsız ölçüm motoru
- `GrillMe/Core/LearningAnalytics.swift`: Olay sözleşmesi
- `GrillMe/Core/LessonRun.swift`: Oturum sonucu ve dashboard
- `GrillMe/Core/ProgressStore.swift`: Deneme kayıtları ve kalıcılık
- `GrillMe/App/Assets.xcassets/`: App Store için `AppIcon` asset kataloğu
- `Scripts/generate-app-icon.swift`: 1024×1024 alfa kanalsız kaynak ikon üretimi
- `Tests/GrillMeCoreTests/`: 25 Swift Testing paketi
- `GrillMeUITests/`: Uygulama açılışı ve navigasyon duman testi
- `.github/workflows/ci.yml`: Lint, çekirdek test, build ve UI test hattı

## Doğrulama durumu

- 121 Swift Testing testi ve 25 test paketi geçmelidir.
- 1 XCUITest duman testi uygulama açılışı, onboarding atlamayı, sekmeleri ve
  derse girişi doğrular; hem temiz kurulumda hem tekrar açılışta geçer.
- Genel iOS Simulator build ve UI test adımları CI sözleşmesinde yer alır.
- Release iOS arşivinde birincil ikon adı `AppIcon` ve
  `AppIcon60x60@2x.png` boyutu 120×120 olmalıdır.
- 30 Temmuz 2026: `swift test` (116/116), `xcodebuild` derlemesi ve
  `swift-format lint --strict` geçti; uygulama iPhone 17 simülatöründe açılış,
  onboarding ve ilk ders akışı boyunca elle denendi.
- `grillme-final-preview.png` ve `grillme-dynamic-type-preview.png` 30 Temmuz
  2026'da IDE temasıyla iPhone 17 simülatöründe yeniden yakalandı. Belgelerde
  atıf yapılmayan dört eski önizleme görseli aynı gün silindi.

## İçerik kapsamının gerçek sayıları

Belgelerin özellik listesi ile müfredatın kapsama derinliği aynı şey değildir.
29 Temmuz 2026 ölçümü (40 ders üzerinden):

| Özellik | Ders sayısı |
| --- | ---: |
| En az üç farklı bellek durumundan geçen yürütme izi | 38 |
| Dört veya daha fazla adımlı yürütme izi | 28 |
| Kendi konu anlatımı (bölüm şablonu yok) | 40 |
| Dört seçenekli quiz | 40 |
| Üç soruluk quiz havuzu | 40 |
| Tekrar kuyruğuna girebilen ders | 40 |
| Hata avcılığı görevi | 11 |
| Pratik sorusu | 18 |
| Değerlendirme görevi ve rubrik | 2 |
| Dil varyantı ve dil lensi | 5 |

Diğer ölçümler: ders kodunun ortanca uzunluğu 6, en kısası 4 satırdır (test ile
korunuyor; hata avı taşıyan dersler en az 6 satır). 20 satırlık tek ders çıkış
değerlendirmesidir. Kurstaki toplam cevaplanabilir soru sayısı 60'tan
161'e çıktı; gelişim raporu artık örneklem boyutunu taşıyor ve üç çıkış quizi
tamamlanmadan yüzde göstermiyor.

Bu tablo bir hata listesi değil, içerik borcunun envanteridir; yeni ders
yazarken veya bir özelliği "tamamlandı" saymadan önce buraya bakılmalıdır.
İlk üç satır `RoadmapCurriculumTests` ile korunuyor; alt dört satır açık borç.

Test:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
CLANG_MODULE_CACHE_PATH=/private/tmp/grillme-module-cache \
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/grillme-module-cache \
swift test
```

Derleme:

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

## Repo yapısı

Depoda tek uygulama projesi vardır: kök dizindeki SwiftUI tabanlı
`GrillMe.xcodeproj`.

## Sıradaki önerilen çalışma

Ürün ve mühendislik bulguları kodda kapatıldı. Sonraki adım yeni kapsam eklemek
değil, gerçek kullanıcılarla öğrenme etkisini doğrulamaktır:

1. 5–10 hedef kullanıcıyla ilk hafta kullanılabilirlik testi yap.
2. Yerel olayları bir gizlilik kararı sonrası analitik servisine bağlayıp
   başlangıç/çıkış gelişimini ölç.
3. Kavram rubriği puanlarını öğretmen değerlendirmesiyle karşılaştırıp eşikleri
   kalibre et.

## Açık ürün kararları

- Ürün adı GrillMe olarak mı kalacak?
- Ücretsiz/premium sınırı nerede olacak?
- Yerel analitik olayları herhangi bir backend'e gönderilecek mi?
- 40 derslik içerik için editoryal yayın süreci nasıl işleyecek?
