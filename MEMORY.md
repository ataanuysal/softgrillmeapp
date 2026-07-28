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

- “Değerin izini sür” başlangıç dersi
- `var`, `if` ve `print` içeren gerçek Swift örneği
- Üç çıktı seçeneği
- Doğru/yanlış tahmin değerlendirmesi
- Dört adımlı yürütme izi
- Aktif kaynak satırı vurgusu
- Bellek ve çıktı panelleri
- Tamamlama ve yeniden çözme akışı

Doğrulama durumu:

- Üç Swift Testing testi geçiyor.
- Genel iOS cihaz hedefi derleniyor.
- iPhone simülatör hedefi derleniyor.
- Uygulama iOS 26.5 iPhone 17 Pro simülatöründe açıldı.
- İlk ekran `grillme-preview.png` olarak görsel kontrol edildi.

## Çekirdek model

- `CodeLine`: Kaynak satır numarası ve metni
- `TraceStep`: Çalışan satır, Türkçe açıklama, bellek görüntüsü ve isteğe bağlı
  çıktı
- `XRayLesson`: Kod, soru, seçenekler, doğru cevap ve yürütme izi
- `XRaySessionPhase`: `predicting`, `tracing(step:)`, `complete`
- `XRaySession`: Kullanıcının seçimi ve mevcut yürütme durumu

## Önemli dosyalar

- `GrillMe/App/GrillMeApp.swift`: Uygulama giriş noktası
- `GrillMe/App/ContentView.swift`: İlk Kod Röntgeni arayüzü
- `GrillMe/Core/GrillMeCore.swift`: Alan modeli ve oturum durumu
- `GrillMe/Core/IntroLesson.swift`: İlk ders içeriği
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

`grillmeapp/` altında ayrıca UIKit ve storyboard tabanlı, stage edilmiş ikinci bir
Xcode iskeleti vardır. Bu iskelet aktif SwiftUI uygulaması değildir. Kullanıcı
hangi projenin kalacağına karar vermeden:

- Klasörü silme.
- Dosyaları SwiftUI projesine otomatik olarak taşıma.
- Stage durumunu geri alma.
- İki Xcode projesini sessizce birleştirme.

Aktif geliştirme şu anda `GrillMe.xcodeproj` üzerinden ilerlemelidir.

## Sıradaki önerilen çalışma

Bir sonraki dikey dilim:

1. Ders kataloğu modelini testle tanımla.
2. Koşullar için ikinci dersi ekle.
3. Ana ders haritasını oluştur.
4. İlk ve ikinci ders arasında ilerlemeyi cihazda sakla.

## Açık ürün kararları

- Ürün adı son hâliyle GrillMe mi kalacak?
- 30 günlük yol doğrusal mı, beceri ağacı mı olacak?
- İlk sürüm yalnızca Swift mi gösterecek, yoksa erken aşamada dil karşılaştırması
  açılacak mı?
- Ücretsiz/premium sınırı nerede olacak?
- AI mentor MVP'de mi, daha sonraki bir sürümde mi yer alacak?
- `grillmeapp/` UIKit iskeleti korunacak mı?
