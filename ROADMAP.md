# Ürün Yol Haritası

Yol haritası tarih taahhüdü değil, risk ve öğrenme değerine göre sıralanmış
teslim planıdır. Her aşama, bir sonrakine geçmeden önce çalışan ve test edilmiş
bir kullanıcı değeri üretmelidir.

## Durum anahtarı

- ✅ Tamamlandı
- 🚧 Sırada
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

## Aşama 1 — İki derslik gerçek öğrenme yolu 🚧

Amaç: Tek ekran demosundan tekrar kullanılabilir ders sistemine geçmek.

### Alan modeli

- Ders kimliği, sıra, konu ve öğrenme hedefi ekle
- `LessonCatalog` oluştur
- Ders tamamlama durumunu modelle
- Katalog ve kilit açma davranışlarını test et

### İçerik

- Ders 01: Değişkenin izini sür
- Ders 02: Koşul hangi yolu seçer?
- İkinci derste doğru ve yanlış branch yürütme izi
- Her ders için aktarım sorusu

### Arayüz

- Ana ders haritası
- Tamamlandı, sıradaki ve kilitli durumları
- Ders detayına navigasyon
- Son tamamlanan derse geri dönme

### Kalıcılık

- Yerel `ProgressStore`
- Uygulama kapanınca tamamlanan dersleri koruma
- Store davranışlarını gerçek bir geçici depoyla test etme

Kabul ölçütleri:

- Kullanıcı ana ekrandan iki dersi sırayla tamamlayabilir.
- Birinci ders tamamlanmadan ikinci ders açılmaz.
- İlerleme uygulama yeniden açıldığında korunur.
- Kritik iş kuralları otomatik testlidir.

## Aşama 2 — 7 günlük temel paket ⏳

Amaç: İlk haftada kod okuma alışkanlığı ve ölçülebilir gelişim oluşturmak.

Önerilen ders sırası:

1. Değer ve değişken
2. Karşılaştırma ve koşul
3. Birden fazla koşul
4. Döngüde değerin değişimi
5. Fonksiyon çağrısı
6. Parametre ve dönüş değeri
7. Karışık haftalık meydan okuma

Ürün işleri:

- Günlük seri
- Ders süresi ve ilerleme göstergesi
- İlk deneme/ikinci deneme tahmin kaydı
- Haftalık özet
- Dynamic Type ve VoiceOver kontrolü
- Temel analitik olay sözleşmesi

Kabul ölçütleri:

- Yedi ders içerik kalite kontrolünden geçer.
- Kullanıcı gelişimi cihaz üzerinde ölçülebilir.
- Haftalık meydan okuma önceki altı dersin kavramlarını birleştirir.

## Aşama 3 — Fonksiyonlar ve veri akışı ⏳

Amaç: Kullanıcının birden fazla kod bloğu arasındaki akışı takip edebilmesi.

- Fonksiyon çağrı lensi
- Parametre ve argüman
- Return değeri
- Local ve global scope
- Pure function ve side effect
- Fonksiyon çağrı yığını görselleştirmesi
- “Bu fonksiyonun iyi adı ne olmalı?” görevleri
- Map ve filter'a sezgisel giriş

Kabul ölçütü: Kullanıcı iki veya üç fonksiyonlu basit bir kodun çağrı ve dönüş
sırasını açıklayabilir.

## Aşama 4 — Koleksiyonlar ve nesneler ⏳

Amaç: Kullanıcının verinin yapı içinde nasıl tutulduğunu ve değiştiğini anlaması.

- Array/list
- Dictionary/map
- Index ve key
- Mutable ve immutable koleksiyon
- Class ve instance
- Property ve method
- Initializer
- Value ve reference davranışına giriş
- Composition ve inheritance karşılaştırması
- Mimari lensin ilk sürümü

Kabul ölçütü: Kullanıcı bir instance'ın hangi veriye sahip olduğunu ve bir method
çağrısının bu veriyi nasıl değiştirdiğini takip edebilir.

## Aşama 5 — Hata avcılığı ⏳

Amaç: Kod okumayı sistematik debugging becerisine dönüştürmek.

- Syntax, runtime ve logic error ayrımı
- Hata satırını işaretleme
- Beklenen ve gerçek değer karşılaştırması
- Edge case
- Optional değerler
- Stack trace okumaya giriş
- Hipotez kur ve kanıt ara döngüsü
- Hata lensi

Kabul ölçütü: Kullanıcı basit bir hatada rastgele değişiklik yapmak yerine
test edilebilir bir hipotez kurabilir.

## Aşama 6 — 30 günlük çekirdek yol ⏳

Amaç: Ürünün ana vaadini eksiksiz karşılamak.

İçerik bölümleri:

- Kodun temel mekaniği
- Akış
- Fonksiyonlar
- Veri yapıları
- Class ve nesneler
- Debugging
- Asenkron düşünmeye giriş
- Gerçek uygulama yapısına giriş

Çıkış değerlendirmesi:

- 20–30 satırlık yeni kod
- Çıktı tahmini
- Değer izleme
- Fonksiyon çağrı sırası
- Hata noktası tahmini
- Kodu kendi cümlesiyle açıklama

Kabul ölçütü: Başlangıç ve çıkış değerlendirmeleri arasında kod okuma
performansında ölçülebilir gelişim görülür.

## Aşama 7 — Dil köprüsü ve mentor 💭

Amaç: Öğrenilen zihinsel modeli yeni dillere ve bağımsız öğrenmeye taşımak.

- Aynı örneğin Swift, Python ve JavaScript karşılığı
- Dil lensi
- Syntax farkı ile mantık farkını ayırma
- Soru sorarak ilerleten AI mentor
- Kullanıcının açıklamasına kişiselleştirilmiş geri bildirim
- Güvenli cevap sınırları ve maliyet kontrolü

Bu aşama, çekirdek öğrenme döngüsünün AI olmadan değer ürettiği kanıtlandıktan
sonra başlamalıdır.

## Sürekli kalite hattı

Her aşamada:

- Yeni iş davranışı önce başarısız testle tanımlanır.
- Tüm testler geçmeden özellik tamamlanmış sayılmaz.
- Ders veri sözleşmesi otomatik doğrulanır.
- Genel iOS hedefi ve en az bir simülatör hedefi derlenir.
- Kritik ekranlar görsel olarak kontrol edilir.
- Erişilebilirlik regresyonları gözden geçirilir.
- `MEMORY.md` güncel durumla yenilenir.

## MVP sonrasına bırakılanlar

- Hesap ve bulut senkronizasyonu
- Sosyal profil ve liderlik tablosu
- Kullanıcıların serbest kod çalıştırması
- Topluluk tarafından oluşturulan dersler
- Web veya Android istemcisi
- Gelişmiş ödeme ve abonelik sistemi
- Profesyonel konuların tamamı: CI/CD, deployment, monitoring ve güvenlik
