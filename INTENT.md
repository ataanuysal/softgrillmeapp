# Ürün Niyeti

## Vizyon

GrillMe bir öğrenme kavramının adıdır; bu belge onun kod okuma alanındaki
uygulaması olan **GrillMe:Code**'u tanımlar. Kavramın diğer alanlardaki
uygulamaları (örneğin GrillMe:Music) ayrı ürünlerdir ve bu belgenin kapsamı
dışındadır.

GrillMe:Code'un amacı insanlara tek bir programlama dilini ezberletmek değil,
kodu okuyabilen ve çalışan bir programın zihinsel modelini kurabilen bir düşünme
biçimi kazandırmaktır.

Uygulamanın temel vaadi:

> Her gün 10 dakika çalış. Daha önce görmediğin basit bir kodu korkmadan oku,
> değerlerin nasıl değiştiğini takip et ve kodun ne yaptığını kendi cümlelerinle
> açıkla.

## Çözülen problem

Başlangıç seviyesindeki birçok kişi:

- Değişken, koşul ve fonksiyon tanımlarını ayrı ayrı bilir ama birlikte çalışan
  kodu takip edemez.
- Eğitimlerde sözdizimi ezberler fakat kodun neden o sırayla çalıştığını
  anlayamaz.
- Hata yaptığında hangi soruyu soracağını bilmez.
- Uzun video kurslarında pasif kalır ve öğrendiğini yeni bir örneğe taşıyamaz.
- “Ben yazılımı anlayamıyorum” sonucuna varır.

GrillMe:Code bu sorunu kısa konu anlatımları, görünür rehberli örnekler, ders sonu
quizleri ve sürekli geri bildirimle çözer.

## Hedef kullanıcı

Birincil hedef:

- Kodlamaya birkaç kez başlamış yetişkinler
- Syntax ve eğitim seçenekleri arasında kaybolmuş kişiler
- Basit kodu görünce nereden okumaya başlayacağını bilemeyenler
- Kod yazmadan önce temel mantığı oturtmak isteyenler

İkincil hedef:

- Kod bilen ancak fonksiyon, class, state veya asenkron akış gibi kavramların
  zihinsel modelini sağlamlaştırmak isteyenler
- Kendi kendine öğrenirken kod okuma pratiğine ihtiyaç duyan öğrenciler

## Başarı tanımı

Kullanıcı 30 günlük temel yolu tamamladığında:

1. Daha önce görmediği 20–30 satırlık basit bir kodun genel amacını açıklayabilir.
2. Değişkenlerin değerlerini çalışma sırasına göre takip edebilir.
3. Koşul, döngü ve fonksiyon çağrılarının akışı nasıl değiştirdiğini gösterebilir.
4. Basit bir mantık hatasının oluşabileceği satırı tahmin edebilir.
5. Aynı mantığın Swift, Python, JavaScript veya Java karşılığını tanıyabilir.
6. Bilmediği kod karşısında “nereden başlamalıyım?” yerine doğru soruları
   sorabilir.

## Ürün ilkeleri

### Önce öğret, sonra bağımsız uygulat

Her ders önce kavramı sade Türkçeyle anlatır, ardından çalışan bir örneği adım
adım gösterir. Quiz en son gelir ve anlatımdakinden farklı kod kullanır. Yanlış
cevap başarısızlık değil, geri bildirimin başlangıç noktasıdır.

### Önerilen sıra, serbest erişim

Yol haritası yeni başlayanlara güvenli bir öğrenme sırası önerir. Her iki
görünüm de bütün dersleri baştan açık tutar; kullanıcı bildiği konuyu tekrar
etmek veya merak ettiği içeriğe doğrudan gitmek için Yol Haritası ya da
İçindekiler üzerinden derse gidebilir.

### Kod görünür şekilde çalışmalı

Aktif satır, bellek, çıktı ve çağrı akışı aynı anda izlenebilir olmalıdır.
“Çıktı 12” demek tek başına yeterli değildir.

### Ezber yerine neden

Her konu beş soruya cevap vermelidir:

1. Bu nedir?
2. Neden buna ihtiyaç duyulmuş?
3. Kod çalışırken içeride ne oluyor?
4. Yanlış kullanılırsa ne olur?
5. Gerçek bir projede nerede görülür?

### Kısa ve aktif oturumlar

Bir ders 5–10 dakika içinde tamamlanabilmeli; anlatım kısa tutulmalı ve kullanıcı
örneği izledikten sonra seçim yapmalı, sıralamalı, tahmin etmeli veya
açıklamalıdır.

### Dil, mantığın aracı olmalı

İlk gerçek örnekler Swift ile başlar. Ürün tek bir dil kursuna dönüşmemeli; aynı
zihinsel model ileride Python, JavaScript ve Java ile karşılaştırılabilmelidir.

### Mentor cevabı hemen vermemeli

Sokratik mentor çözümü üretmekten önce kullanıcının varsayımını ortaya çıkarır
ve onu doğru sorularla ilerletir. Desteklenen cihazlarda cihaz içi dil modeli
kullanılsa bile doğru cevap isteme eklenmez, olası cevap sızıntısı filtrelenir
ve ders başına tur bütçesi korunur.

## Tamamlanan çekirdek kapsam

İlk anlamlı 30 günlük sürüm:

- Temel değerler ve değişkenler
- Çalışma sırası
- Boolean ifadeler ve koşullar
- Döngüler
- Fonksiyon, parametre ve dönüş değeri
- Scope
- Basit koleksiyonlar
- Class, instance, property ve method
- Tahmin, satır izleme, bellek ve çıktı lensleri
- Çağrı, mimari, hata ve dil lensleri
- Hipotez tabanlı hata avcılığı
- Swift, Python, JavaScript ve Java dil karşılaştırması
- Bütçeli cihaz içi/yerel Sokratik mentor
- Başlangıç ve çıkış gelişim ölçümü
- Ders ilerlemesinin cihazda saklanması
- Erişilebilir ve tek elle kullanılabilir iPhone deneyimi

Temel yolun ardından gelen uzmanlaşma kapsamı:

- Yazılım testinin Arrange–Act–Assert zihinsel modeli
- Unit test, sınır değer ve test double kullanımı
- Integration ve regression ayrımı
- İsteği ölçülebilir kabul kriterlerine dönüştürme
- Sistem akışı ve veri sözleşmesi çıkarma
- Değişikliğin etki ve risklerini belirleme
- Teknik analiz bulgularını uygulanabilir plana dönüştürme

## Şimdilik kapsam dışı

- Tam özellikli kod editörü veya derleyici
- Kullanıcının serbest biçimde büyük projeler yazması
- Canlı backend, hesap sistemi ve sosyal özellikler
- Rekabetçi liderlik tablosu
- Her programlama dilini aynı anda öğretme
- AI'ın doğrudan ödev veya çözüm üretmesi
- İleri algoritmaların ve profesyonel araçların MVP'ye sıkıştırılması

## Kuzey yıldızı

Ana ürün ölçüsü ders tamamlama sayısı değil, kullanıcının yeni bir kod örneğinde
doğru yürütme tahmini yapabilmesidir.

İlk ölçülebilir sinyaller:

- İlk dersin tamamlanma oranı
- Bir hafta içindeki geri dönüş oranı
- İlk deneme ve ikinci deneme quiz doğruluğu arasındaki gelişim
- Ek pratik doğruluğu ile açık uçlu rubrik puanının birbirinden bağımsız gelişimi
- Kullanıcının yardımsız tamamladığı yürütme izi sayısı
- “Bu kodu kendi cümlenle açıkla” görevlerindeki gelişim
