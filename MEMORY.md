# Proje Hafızası

Son güncelleme: 28 Temmuz 2026

Bu dosya, yeni bir çalışma oturumunda projeye hızla devam edebilmek için kalıcı
kararları ve güncel teknik durumu tutar. Geçici fikirler burada kesin karar gibi
yazılmamalıdır.

## Ürün özeti

GrillMe, kodlama öğrenmek isteyen kişilere önce kod okumayı ve kodun çalışma
mantığını öğretir. Merkez deneyim “Kod Röntgeni”dir: kullanıcı çıktıyı tahmin
eder, sonra aktif satırı, belleği ve çıktıyı adım adım izler.

## Onaylanmış kararlar

- Platform iOS'tur.
- Aktif uygulama SwiftUI ile geliştirilmektedir.
- Minimum hedef iOS 17'dir.
- İlk gerçek kod örneklerinde Swift kullanılır.
- Ürün yalnızca syntax öğreten klasik bir kurs olmayacaktır.
- Birincil kullanıcı, kodlamaya başlamış fakat mantığı oturtamamış yetişkindir.
- 30 günlük hedef, 20–30 satırlık basit kodu okuyup açıklayabilmektir.
- İlk MVP temeller, akış, fonksiyonlar, veri yapıları ve class kavramlarına
  odaklanacaktır.
- Yanlış cevap cezalandırılmayacak; yürütme mantığını görünür kılan bir öğrenme
  fırsatı olacaktır.
- İş mantığı SwiftUI'dan bağımsız ve otomatik test edilebilir tutulacaktır.
- Yeni davranışlar test önce yazılarak geliştirilecektir.

## Güncel çalışan durum

Aktif proje:

- `GrillMe.xcodeproj`
- Şema: `GrillMe`
- Bundle kimliği: `com.grillme.learn`

Çalışan ilk dikey dilim:

- “Değerin izini sür”, “Hangi yol çalışır?” ve “Her turda ne değişir?” dersleri
- `var`, `let`, `if`, `else`, `for`, `in` ve `print` içeren gerçek Swift
  örnekleri
- Sıralı `LessonCatalog`
- Tamamlandı, açık ve kilitli ders durumları
- Önceki dersler tamamlandıkça sıradaki dersi açma
- Ders haritası ve ders detay navigasyonu
- Cihazda JSON tabanlı kalıcı ilerleme
- Doğru/yanlış tahmin değerlendirmesi
- Üç derse özel yürütme izleri
- Aktif kaynak satırı vurgusu
- Bellek ve çıktı panelleri
- Her ders sonunda yeni kodla aktarım tahmini
- Aktarım cevabı için gerekçeli geri bildirim
- Tamamlama ve yeniden çözme akışı

Doğrulama durumu:

- 15 Swift Testing testi geçiyor.
- Genel iOS simülatör hedefi derleniyor.
- iPhone simülatör hedefi derleniyor.
- Uygulama iOS 26.5 iPhone 17 Pro simülatöründe açıldı.
- Üç derslik harita `grillme-transfer-preview.png` olarak görsel kontrol edildi.

## Çekirdek model

- `CodeLine`: Kaynak satır numarası ve metni
- `TraceStep`: Çalışan satır, Türkçe açıklama, bellek görüntüsü ve isteğe bağlı
  çıktı
- `TransferChallenge`: Yeni kod, seçenekler, doğru cevap ve gerekçeli açıklama
- `XRayLesson`: Kod, soru, seçenekler, doğru cevap, yürütme izi ve aktarım görevi
- `XRaySessionPhase`: `predicting`, `tracing(step:)`, `transfer`, `complete`
- `XRaySession`: İlk tahmin, aktarım cevabı ve mevcut yürütme durumu
- `LessonCatalog`: Ders sırası ve kilit açma kuralları
- `LessonCatalogItem`: Ders ile mevcut erişim durumunu birleştiren görünüm modeli
- `LessonProgress`: Tamamlanan ders kimlikleri
- `FileProgressStore`: İlerlemeyi JSON dosyasına yazan gerçek depo

## Önemli dosyalar

- `GrillMe/App/GrillMeApp.swift`: Uygulama giriş noktası
- `GrillMe/App/ContentView.swift`: Ders haritası ve Kod Röntgeni arayüzü
- `GrillMe/Core/GrillMeCore.swift`: Alan modeli ve oturum durumu
- `GrillMe/Core/IntroLesson.swift`: Değişkenler ve koşullar dersleri
- `GrillMe/Core/LoopsLesson.swift`: Döngüler dersi
- `GrillMe/Core/LessonCatalog.swift`: Ders sırası ve erişim durumları
- `GrillMe/Core/ProgressStore.swift`: Kalıcı ilerleme
- `Tests/GrillMeCoreTests/`: Çekirdek davranış testleri
- `INTENT.md`: Ürün amacı ve kapsamı
- `DESIGN.md`: Deneyim ve teknik tasarım
- `ROADMAP.md`: Sıradaki teslimler

## Test komutu

Sandbox içindeki güvenilir komut:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
CLANG_MODULE_CACHE_PATH=/private/tmp/grillme-clang-cache \
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/grillme-swiftpm-cache \
swift test --disable-sandbox
```

## Derleme komutu

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild \
  -project GrillMe.xcodeproj \
  -scheme GrillMe \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  -derivedDataPath /private/tmp/grillme-derived-data \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Repo uyarısı

`grillmeapp/` altında ayrıca UIKit ve storyboard tabanlı ikinci bir
Xcode iskeleti vardır. Bu iskelet aktif SwiftUI uygulaması değildir. Kullanıcı
hangi projenin kalacağına karar vermeden:

- Klasörü silme.
- Dosyaları SwiftUI projesine otomatik olarak taşıma.
- Stage durumunu geri alma.
- İki Xcode projesini sessizce birleştirme.

Aktif geliştirme şu anda `GrillMe.xcodeproj` üzerinden ilerlemelidir.

## Sıradaki önerilen çalışma

Bir sonraki dikey dilim:

1. Fonksiyon çağrısı için dördüncü dersi testle tanımla.
2. İlk üç ders tamamlanınca dördüncü dersi aç.
3. İlk tahmin ve aktarım doğruluğunu ilerleme verisine kaydet.
4. Dynamic Type ve VoiceOver ile temel akışı doğrula.

## Açık ürün kararları

- Ürün adı son hâliyle GrillMe mi kalacak?
- 30 günlük yol doğrusal mı, beceri ağacı mı olacak?
- İlk sürüm yalnızca Swift mi gösterecek, yoksa erken aşamada dil karşılaştırması
  açılacak mı?
- Ücretsiz/premium sınırı nerede olacak?
- AI mentor MVP'de mi, daha sonraki bir sürümde mi yer alacak?
- `grillmeapp/` UIKit iskeleti korunacak mı?
