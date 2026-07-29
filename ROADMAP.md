# Ürün Yol Haritası

Yol haritası tarih taahhüdü değil, risk ve öğrenme değerine göre sıralanmış
teslim planıdır. 28 Temmuz 2026 itibarıyla Aşama 0–8'in ürün ve mühendislik
kapsamı tamamlanmıştır.

## Durum anahtarı

- ✅ Tamamlandı
- 🚧 Devam ediyor
- ⏳ Planlandı
- 💭 Keşif

## Aşama 0 — Ürün çekirdeği ✅

Amaç: Kod Röntgeni fikrini gerçek bir iOS ekranında doğrulamak.

- ✅ SwiftUI uygulama iskeleti
- ✅ İlk Swift dersi
- ✅ Çıktı tahmini
- ✅ Aktif satır vurgusu
- ✅ Bellek ve çıktı görünümü
- ✅ Doğru/yanlış tahmin değerlendirmesi
- ✅ Yeniden çözme
- ✅ Çekirdek durum testleri
- ✅ iOS cihaz ve simülatör derleme doğrulaması
- ✅ Gerçek simülatörde görsel kontrol

Kabul sonucu: İlk uçtan uca ders akışı çalışıyor.

## Aşama 1 — Üç derslik gerçek öğrenme yolu ✅

Amaç: Tek ekran demosundan tekrar kullanılabilir ders sistemine geçmek.

- ✅ Ders kimliği, sıra, konu ve öğrenme hedefi
- ✅ `LessonCatalog`, tamamlama durumu ve açık erişim testleri
- ✅ Ders 01: Değişkenin izini sür
- ✅ Ders 02: Koşul hangi yolu seçer?
- ✅ Ders 03: Döngüde değer nasıl değişir?
- ✅ Her ders için aktarım sorusu
- ✅ Ana ders haritası ve detay navigasyonu
- ✅ Tamamlandı ve açık ders durumları
- ✅ Tüm derslere açık, aranabilir ve bölüm filtreli İçindekiler kataloğu
- ✅ Yerel `FileProgressStore` ve gerçek dosya testleri

Kabul sonucu: Yol Haritası önerilen sırayı gösteriyor; kullanıcı her iki
görünümden istediği derse doğrudan girebiliyor ve ilerleme yeniden açılışta
korunuyor.

## Aşama 2 — 7 günlük temel paket ✅

Amaç: İlk haftada kod okuma alışkanlığı ve ölçülebilir gelişim oluşturmak.

1. ✅ Değer ve değişken
2. ✅ Karşılaştırma ve koşul
3. ✅ Döngüde değerin değişimi
4. ✅ Birden fazla koşul
5. ✅ Fonksiyon çağrısı
6. ✅ Parametre ve dönüş değeri
7. ✅ Karışık haftalık meydan okuma

Ürün işleri:

- ✅ Günlük seri
- ✅ Ders süresi ve ilerleme göstergesi
- ✅ İlk deneme ve tekrar denemesi quiz kaydı
- ✅ Quiz, ek pratik ve rubrik puanını ayıran haftalık özet
- ✅ Dynamic Type erişilebilir boyut kontrolü
- ✅ VoiceOver için semantik gruplar, durum etiketleri ve metinli eylemler
- ✅ Temel analitik olay sözleşmesi

Kabul sonucu: Yedi ders otomatik veri kontrolünden geçiyor; gelişim cihaz
üzerinde ölçülüyor ve haftalık meydan okuma önceki kavramları birleştiriyor.

## Aşama 3 — Fonksiyonlar ve veri akışı ✅

Amaç: Birden fazla kod bloğu arasındaki akışı takip etmek.

- ✅ Fonksiyon çağrı lensi
- ✅ Parametre ve argüman
- ✅ Return değeri
- ✅ Local ve global scope
- ✅ Pure function ve side effect
- ✅ Fonksiyon çağrı yığını görselleştirmesi
- ✅ Fonksiyon isimlendirme pratikleri
- ✅ `map` ve `filter` için sezgisel giriş

Kabul sonucu: İki veya üç fonksiyonlu kodun çağrı ve dönüş sırası çağrı
çerçeveleriyle açıklanabiliyor.

## Aşama 4 — Koleksiyonlar ve nesneler ✅

Amaç: Verinin yapı içinde nasıl tutulduğunu ve değiştiğini anlamak.

- ✅ Array/list
- ✅ Dictionary/map
- ✅ Index ve key
- ✅ Mutable ve immutable koleksiyon davranışı
- ✅ Class ve instance
- ✅ Property ve method
- ✅ Initializer
- ✅ Value ve reference davranışına giriş
- ✅ Composition ve inheritance karşılaştırması
- ✅ Mimari lens

Kabul sonucu: Instance, sahip olduğu veri ve method çağrısının etkisi mimari
ilişkilerle takip edilebiliyor.

## Aşama 5 — Hata avcılığı ✅

Amaç: Kod okumayı sistematik debugging becerisine dönüştürmek.

- ✅ Syntax, runtime ve logic error ayrımı
- ✅ Hata satırını işaretleme
- ✅ Beklenen ve gerçek değer karşılaştırması
- ✅ Edge case
- ✅ Optional değerler
- ✅ Stack trace okumaya giriş
- ✅ Hipotez kur ve kanıt ara durum makinesi
- ✅ Hata lensi

Kabul sonucu: Kullanıcı satır seçmeden önce test edilebilir bir hipotez
yazmak zorunda; seçimden sonra kanıt ve açıklama görüyor.

## Aşama 6 — 30 günlük çekirdek yol ✅

Amaç: Ürünün ana vaadini eksiksiz karşılamak.

- ✅ Kodun temel mekaniği
- ✅ Akış
- ✅ Fonksiyonlar
- ✅ Veri yapıları
- ✅ Class ve nesneler
- ✅ Debugging
- ✅ Asenkron düşünmeye giriş
- ✅ Gerçek uygulama yapısına giriş
- ✅ 30 benzersiz ve sıralı ders

Çıkış değerlendirmesi:

- ✅ 20 satırlık yeni kod
- ✅ Çıktı tahmini
- ✅ Değer izleme
- ✅ Fonksiyon çağrı sırası
- ✅ Hata noktası tahmini
- ✅ Kodu kendi cümlesiyle açıklama
- ✅ Her görev için zorunlu cevap alanı, kavram rubriği ve anlık geri bildirim
- ✅ Eksik kanıtta tamamlamayı kapatan bitirme koşulu

Kabul sonucu: İlk üç ders başlangıç ölçümü, 30. ders çıkış ölçümü olarak
kullanılıyor; gelişim raporu iki doğruluk değerini ve farkı gösteriyor.

## Aşama 7 — Dil köprüsü ve mentor ✅

Amaç: Zihinsel modeli yeni dillere ve bağımsız öğrenmeye taşımak.

- ✅ Aynı örneğin Swift, Python, JavaScript ve Java karşılığı
- ✅ Dil lensi
- ✅ Syntax farkı ile mantık farkını ayıran karşılaştırma
- ✅ Soru sorarak ilerleten cihaz içi AI mentor
- ✅ Kullanıcı açıklamasındaki kavramlara kişiselleştirilmiş geri bildirim
- ✅ Ders başına altı turluk maliyet/işlem bütçesi
- ✅ Doğru cevabı isteme taşıtmayan güvenli istem
- ✅ Olası cevap sızıntısını temizleyen güvenlik filtresi
- ✅ Model kullanılamadığında çevrimdışı yerel Sokratik yedek

Kabul sonucu: iOS 26 ve uygun Apple Intelligence cihazlarında Foundation Models
kullanılıyor; diğer tüm iOS 17+ sistemlerde ana öğrenme döngüsü yerel mentorla
eksiksiz çalışıyor.

## Aşama 8 — Yazılım testi ve teknik analiz ✅

Amaç: Temel kod okuma becerisini yazılım kalitesi ve uygulanabilir teknik
planlama becerisine taşımak.

Yazılım testi ünitesi:

- ✅ Arrange–Act–Assert ile testin anatomisi
- ✅ Davranışı izole eden unit test
- ✅ Sınır değer testi
- ✅ Test double ile kontrol edilemeyen bağımlılığı değiştirme
- ✅ Integration ve regression ayrımı

Teknik analiz ünitesi:

- ✅ Ölçülebilir kabul kriterleri
- ✅ Uçtan uca sistem akışı
- ✅ Veri sözleşmeleri ve garantiler
- ✅ Değişiklik etki ve risk analizi
- ✅ İstekten uygulanabilir plana teknik analiz capstone'u

Kabul sonucu: 30 derslik temel yol korunuyor; 31–40. dersler Yol Haritası'nda
önerilen sırada, her iki görünümde de doğrudan erişilebilir biçimde sunuluyor.

## Sürekli kalite hattı ✅

- ✅ Yeni iş davranışları önce başarısız testlerle tanımlandı.
- ✅ 40 dersin veri sözleşmesi otomatik doğrulanıyor.
- ✅ 71 Swift Testing testi ve 19 çekirdek test paketi tanımlı.
- ✅ Uygulama açılışı, sekme geçişi ve derse girişi kapsayan XCUITest hedefi.
- ✅ Paylaşılan Xcode şeması ve GitHub Actions kalite hattı.
- ✅ Swift format/lint kontrolü yapılıyor.
- ✅ CI genel iOS Simulator hedefini derleyecek şekilde yapılandırıldı.
- ✅ Release arşivinde `AppIcon` adı ve 120×120 dağıtım ikonu doğrulanıyor.
- ✅ CI kullanılabilir ilk iPhone simülatörünü seçip UI duman testini çalıştırıyor.
- ✅ Erişilebilir Dynamic Type için tek sütun kartlar, dikey başlıklar, menü
  picker ve kaydırılabilir kod düzeni.
- ✅ `README.md`, `INTENT.md`, `MEMORY.md`, `DESIGN.md` güncel tutuldu.

## MVP sonrasına bırakılanlar

Bu maddeler tamamlanan roadmap'in parçası değildir; gerçek kullanıcı sinyali
olmadan ürün kapsamına alınmayacaktır:

- Hesap ve bulut senkronizasyonu
- Sosyal profil ve liderlik tablosu
- Kullanıcıların serbest kod çalıştırması
- Topluluk tarafından oluşturulan dersler
- Web veya Android istemcisi
- Ödeme ve abonelik sistemi
- Profesyonel konuların tamamı: CI/CD, deployment, monitoring ve güvenlik
