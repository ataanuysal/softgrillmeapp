# Tasarım Belgesi

## Deneyim hedefi

GrillMe bir video kursu ya da mobil kod editörü değildir. Kullanıcıyı pasif
izleyiciden, kodun çalışması hakkında kanıt kullanan aktif bir okuyucuya
dönüştüren düşünme laboratuvarıdır.

```mermaid
flowchart LR
  A["Konuyu sade Türkçeyle öğren"] --> B["İlgili örneği incele"]
  B --> C["Örneği satır satır yürüt"]
  C --> D["İlgili lensleri kullan"]
  D --> E["En son farklı kodlu quiz"]
  E --> F["Geri bildirim veya pratik"]
  F --> G["Kendi cümlenle açıkla"]
  G --> H["İlerlemeyi kaydet"]
```

## Bilgi mimarisi

Uygulama iki tamamlayıcı giriş biçimi sunar:

1. **Yol Haritası:** 40 açık ders, on bölüm, önerilen sıra ve süre
2. **İçindekiler:** tüm derslere serbest erişim, bölüm filtresi ve Türkçe
   karakterlerden bağımsız kavram araması
3. **İlerleme özeti:** seri, tamamlanan ders, haftalık süre ve doğruluklar
4. **Konu anlatımı:** hedefi ve kalıcı zihinsel modeli sade Türkçeyle öğretme
5. **Kod Röntgeni örneği:** aktif satır, bellek, çıktı ve bağlamsal lensler
6. **Ders sonu quiz:** aynı zihinsel modeli farklı kodda bağımsız kullanma
7. **Hata avcılığı:** hipotez, satır seçimi ve kanıt
8. **Pratik/değerlendirme:** isimlendirme, kavram, mimari ve capstone görevleri
9. **Sokratik mentor:** cevabı vermeden öğrencinin açıklamasını ilerletme

## Müfredat yapısı

| Bölüm | Dersler | Ana beceri |
| --- | ---: | --- |
| Temeller | 1–4 | Değer, koşul, döngü ve karışık akış |
| Fonksiyonlar | 5–11 | Çağrı, parametre, return, scope, side effect, map/filter |
| Koleksiyonlar | 12–14 | Array, dictionary, index, key ve değişim |
| Nesneler | 15–21 | Class, instance, davranış, yaşam döngüsü ve mimari |
| Debugging | 22–27 | Hata türü, edge case, optional, stack trace ve hipotez |
| Asenkron | 28 | Olayların gerçekleşme sırası |
| Uygulama mimarisi | 29 | Gerçek uygulamadaki veri ve çağrı akışı |
| Değerlendirme | 30 | 20 satırlık bağımsız kod okuma görevi |
| Yazılım testi | 31–35 | Davranışı izole etme, sınırları ve gerilemeyi doğrulama |
| Teknik analiz | 36–40 | İsteği ölçülebilir, riskleri görünür bir uygulama planına çevirme |

## Kod Röntgeni lensleri

Lensler ders verisinden otomatik açılır; bir derste veri yoksa boş bir kontrol
gösterilmez.

| Lens | Gösterdiği zihinsel model |
| --- | --- |
| Akış | Çalışan satır ve yürütme sırası |
| Hafıza | Değişkenlerin o andaki değerleri |
| Çıktı | Programın dışarı ürettiği değer |
| Çağrı | Fonksiyon çerçeveleri, yerel değerler ve dönüş sırası |
| Mimari | Class, instance, değer ve fonksiyon ilişkileri |
| Hata | Beklenen/gerçek değer, hata türü ve kanıt |
| Dil | Aynı mantığın Swift, Python, JavaScript ve Java sözdizimi |

## Ders veri kalıbı

Her yayınlanabilir ders şunları taşır:

1. Kimlik, sıra, bölüm, konu, hedef, kalıcı çıkarım ve tahmini süre
2. Çalışabilir kaynak satırları
3. Sade konu anlatımı ve kalıcı ana fikir
4. Gerçek sıraya uygun en az iki rehberli örnek adımı
5. Bellek, çıktı ve varsa çağrı/mimari görüntüsü
6. Örnekten farklı kod kullanan ders sonu quiz
7. Gerekiyorsa hata, pratik veya değerlendirme görevi
8. Varsa dil varyantları ve syntax/mantık karşılaştırması

`LessonValidator`; boş kodu, seçenekler dışındaki doğru cevabı, geçersiz satır
numarasını, yetersiz yürütme izini, geçersiz süreyi ve bozuk aktarım görevini
reddeder.

## Etkileşim durumları

```mermaid
stateDiagram-v2
  [*] --> Konu
  Konu --> Örnek: anlatım okundu
  Örnek --> Örnek: sonraki adım
  Örnek --> Quiz: son örnek adımı geçildi
  Quiz --> Tamamlama: cevap seçildi
  Tamamlama --> HataHipotezi: hata görevi varsa
  HataHipotezi --> HataSatırı: hipotez yazıldı
  HataSatırı --> Sonuç: satır seçildi
  Tamamlama --> Sonuç: hata görevi yoksa
  Sonuç --> Konu: yeniden çöz
```

Kurallar:

- Yol Haritası sırayı önerir; Yol Haritası ve İçindekiler bütün dersleri açar.
- Her iki giriş biçimi de aynı ders ekranını ve aynı ilerleme kaydını kullanır.
- Quiz, konu anlatımı ve rehberli örnek tamamlanmadan açılamaz.
- Quiz kodu rehberli örneğin kodundan farklıdır.
- Yanlış quiz cevabı açıklayıcı geri bildirimi engellemez.
- Quiz yapılmadan ders tamamlanmış sayılmaz.
- Hata görevinde hipotez yazılmadan satır seçilemez.
- Yeniden çözme bütün geçici ders ve mentor durumunu temizler.
- Tamamlama tek bir `LessonRunResult` üretir; deneme ve olaylar birlikte
  kaydedilir.

## Mentor tasarımı

```mermaid
flowchart TD
  U["Kullanıcının açıklaması"] --> B["Tur bütçesi ve kavram eşleme"]
  B -->|Kavramlar tamam| F["Yerel kişisel geri bildirim"]
  B -->|Yönlendirme gerekli| A{"Sistem modeli kullanılabilir mi?"}
  A -->|Evet| M["Foundation Models yanıtı"]
  A -->|Hayır veya hata| L["Yerel Sokratik soru"]
  M --> S["Doğru cevap güvenlik filtresi"]
  S --> O["En fazla iki cümlelik soru"]
  L --> O
```

- Tur limiti ders başına altıdır.
- Model istemi hedefi, kodu, kullanıcı açıklamasını ve eşleşen kavramları taşır;
  `correctAnswer` alanını taşımaz.
- Üretilen metin doğru cevabı içerirse cevap yer tutucuyla gizlenir.
- iOS 26/Apple Intelligence uygunluğu yoksa ağ isteği yapılmadan yerel yanıt
  kullanılır.
- Mentor sonucu üretmez; kanıta götüren tek bir soru sorar.

## Ölçüm ve ilerleme

`LessonAttempt`; ders kimliği, tamamlama zamanı, süre, ilk tahmin doğruluğu ve
aktarım doğruluğunu saklar. Türetilen göstergeler:

- Günlük seri
- Son yedi günlük ders ve pratik süresi
- İlk tahmin doğruluğu
- Aktarım doğruluğu
- Aynı dersin tekrar deneme doğruluğu
- İlk üç ders ile capstone arasındaki gelişim

Olay sözleşmesi `lesson_started`, `prediction_submitted`,
`transfer_submitted`, `lesson_completed` adlarını kullanır. Olaylarda kişi adı,
e-posta veya serbest mentor metni bulunmaz. Olaylar şu an yalnızca uygulama
oturumunda tutulur; dış servise gönderilmez.

## Görsel sistem

- Koyu, odaklı ve yetişkinlere yönelik görünüm
- Mint: ilerleme, aktif satır ve birincil eylem
- İndigo: lens, dil ve mentor
- Amber: seri, dikkat ve öğretici sonuç
- Rounded sistem fontu; kod ve değerlerde monospaced sistem fontu
- Renk her zaman metin, ikon veya şekille desteklenir

## Erişilebilirlik

- Eylemler görünür metin veya açıklayıcı erişilebilirlik etiketi taşır.
- Ders satırları başlık, sıra ve tamamlanma durumunu tek VoiceOver açıklamasında
  birleştirir.
- İlerleme ve haftalık özetler semantik gruplardır.
- Dynamic Type, erişilebilir boyutlarda üst başlığı dikey düzene geçirir.
- Metinler büyüyebilir ve ana içerik dikey kaydırılabilir.
- Seçim durumları yalnızca renkle anlatılmaz; ikon ve metinle desteklenir.
- Birincil butonlarda en az 44 punto dokunma yüksekliği korunur.

## Teknik mimari

```mermaid
flowchart TD
  UI["SwiftUI App"] --> Catalog["LessonCatalog"]
  UI --> Journey["LessonJourney / DebugSession"]
  UI --> Run["LessonRun"]
  UI --> Mentor["OnDeviceMentor"]
  Mentor --> FM["Apple Foundation Models<br/>yalnızca uygunsa"]
  Mentor --> Local["SocraticMentorSession<br/>yerel yedek"]
  Run --> Progress["LessonProgress"]
  Progress --> Store["FileProgressStore"]
  Catalog --> Lesson["XRayLesson"]
  Lesson --> Lens["Lens / Dil / Görev verileri"]
  Tests["Swift Testing"] --> Catalog
  Tests --> Journey
  Tests --> Run
  Tests --> Progress
  Tests --> Local
```

### Core

- Ders ve müfredat verisi
- Durum makineleri ve değerlendirme
- Lens, dil, debugging ve görev modelleri
- Deneme, seri, haftalık özet, gelişim ve olay sözleşmesi
- Yerel Sokratik mentor, güvenli istem ve cevap filtresi
- JSON kalıcılığı

### App

- SwiftUI yerleşimi, tipografi, renk ve navigasyon
- Kullanıcı eylemlerini Core davranışlarına bağlama
- Foundation Models uygunluk kontrolü ve asenkron çağrı
- Uygun olmayan sistemlerde yerel mentor yedeği

## Kapsam sınırı

Bu sürümde backend, hesap, bulut senkronizasyonu, serbest kod derleme, sosyal
özellik veya ödeme yoktur. Karmaşık servis katmanları ancak doğrulanmış kullanıcı
ihtiyacı ortaya çıktığında eklenmelidir.
