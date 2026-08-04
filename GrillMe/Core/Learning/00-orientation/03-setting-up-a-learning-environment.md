---
id: orientation-03
course: software-engineering-fundamentals
module: orientation
moduleOrder: 0
lessonOrder: 3
section: fundamentals
title: Öğrenme ortamını kurmak
description: Öğrenmek için gerçekte neyin gerekli, neyin gereksiz olduğunu ve ilerlemeyi görünür kılan basit bir düzenin nasıl kurulacağını anlatır.
difficulty: beginner
estimatedMinutes: 15
prerequisites:
  - orientation-02
objectives:
  - Öğrenmek için gereken en küçük düzeneği kurmak
  - Araç seçimini erteleme aracı olmaktan çıkarmak
  - İlerlemeyi görünür kılan bir kayıt düzeni tutmak
status: published
version: 1
---

# Öğrenme ortamını kurmak

## Dersin amacı

"Ortam kurmak" denince akla kurulum listeleri gelir. Bu ders farklı bir şey
söylüyor: öğrenmek için gereken araç listesi çok kısadır ve o listeyi
uzatmak, öğrenmeyi erteleyen en yaygın yollardan biridir. Burada gerçekten
gerekli olanı, gereksiz olandan ayıracağız.

## Ön koşullar

- [Nasıl çalışılır?](./02-how-to-study.md)

## Kazanımlar

Bu dersin sonunda:

- Öğrenmeye başlamak için neyin yeterli olduğunu bilirsin.
- Araç seçimini erteleme aracı olmaktan çıkarırsın.
- İlerlemeni görünür kılan basit bir kayıt düzeni kurabilirsin.
- Takıldığında izleyeceğin adımları önceden belirlemiş olursun.

## Temel kavramlar

| Terim | İngilizce | Kısa tanım |
| --- | --- | --- |
| Metin düzenleyici | text editor | Düz metin ve kod yazmaya yarayan program |
| Sürüm kontrolü | version control | Dosyaların değişim geçmişini saklayan sistem |
| Öğrenme günlüğü | learning log | Ne öğrendiğini ve nerede takıldığını kaydettiğin not |
| Araç yorgunluğu | tooling fatigue | Öğrenmek yerine araç kurmakla vakit geçirme hâli |
| En küçük düzenek | minimal setup | İşi yapmaya yeten en az sayıda araç |

## Kavramsal açıklama

### Gerçekten gereken üç şey

1. **Yazabileceğin bir yer.** Bir metin düzenleyici ya da defter. Bu dersin
   alıştırmalarının çoğu pseudocode ve düz metindir; hiçbir kurulum
   gerektirmez.
2. **Kaynağı kapatabildiğin bir düzen.** Kendini test edebilmek için, çalışma
   sırasında cevabın görünmediği bir an olmalı.
3. **Ne öğrendiğini yazdığın bir kayıt.** Buna öğrenme günlüğü diyoruz.

Bunların dışındaki her şey — hangi düzenleyici, hangi tema, hangi dil, hangi
kurs platformu — sonradan gelir ve büyük ölçüde değiştirilebilir.

> [!NOTE]
> Bu eğitimin ilk iki modülünde tek satır kod yazmayacaksın. Yani şu anda
> hiçbir programlama aracı kurmana gerek yok.

### Araç yorgunluğu

Öğrenmeye başlayan kişilerin sık düştüğü tuzak şudur: hangi dili öğreneceğine,
hangi düzenleyiciyi kullanacağına, hangi kursu alacağına karar vermeye
çalışırken haftalar geçer. Karar hiç verilmez çünkü her seçeneğin bir eleştirisi
vardır.

Bunun tek çözümü **kararı küçültmektir**. Seçim geri alınamaz olsaydı zor
olurdu; ama düzenleyici değiştirmek beş dakikadır, dil değiştirmek ise
algoritmalarını kaybetmene yol açmaz. Öyleyse ilk seçim, "doğru" olan değil,
**bugün başlamanı sağlayan** seçimdir.

### İlerlemeyi görünür kılmak

Bir önceki derste ilerlemenin görünmezliğinden bahsettik. Görünür kılmanın en
ucuz yolu, her oturumun sonunda üç satır yazmaktır:

```text
Tarih      :
Ne çalıştım:
Ne anladım :
Nerede takıldım:
```

Bu dört satır, iki hafta sonra kendine "hiç ilerlemedim" dediğinde
başvuracağın kanıttır. Aynı zamanda tekrar listeni de kendiliğinden üretir:
"nerede takıldım" satırları, bir sonraki tekrarın gündemidir.

### Takılma kuralı

Takılmak öğrenmenin normal parçasıdır; zararlı olan, takılınca ne yapacağını
bilmemektir. Önceden bir kural belirle. Örnek bir kural:

```text
1. 15 dakika kendim uğraşırım.
2. Sorunu tek cümleyle yazarım. (Çoğu zaman burada çözülür.)
3. Dersin ilgili bölümünü tekrar okurum.
4. Hâlâ çözülmediyse not eder, devam eder, ertesi gün dönerim.
```

Buradaki 2. adım küçük görünür ama en etkili olanıdır: bir sorunu net bir
cümleye indirgeyemiyorsan, sorunun ne olduğunu henüz bilmiyorsundur.

## Gerçek hayattan benzetme

Koşmaya başlamak isteyen biri düşün. Gereken şey ayakkabı ve dışarı çıkmaktır.
Ama pek çok kişi önce en iyi ayakkabıyı araştırır, nabız saati alır, beslenme
planı okur — ve haftalarca koşmaz.

Araçlar koşuyu iyileştirir; koşunun yerine geçmez. Yazılımda da düzenleyici,
tema ve eklentiler işi kolaylaştırır ama kimseyi öğrenmiş yapmaz.

## Pseudocode örneği

Bir çalışma oturumunun düzeneği:

```text
GİRDİ: konu, süre
İŞLEM:
  hazırla(sessiz_ortam, kaynak, günlük)
  oku(konu)
  kapat(kaynak)
  yaz(kendi_cümlelerinle_özet)
  EĞER takıldın İSE
    uygula(takılma_kuralı)
  kaydet(günlük: tarih, konu, anlaşılan, takılan)
ÇIKTI: bir oturum tamamlandı ve iz bıraktı
```

## Adım adım çalışma modeli

İlk haftanın ilk oturumunda düzeneğin nasıl oluştuğu:

| Adım | Yapılan | Sonuç |
| --- | --- | --- |
| 1 | Bir metin dosyası açıldı: `ogrenme-gunlugu.md` | Kayıt yeri var |
| 2 | Çalışma sözleşmesi yazıldı (gün, süre, tekrar) | Plan var |
| 3 | Takılma kuralı yazıldı | Tıkanınca ne yapılacağı belli |
| 4 | İlk ders okundu ve kaynak kapatıldı | Test edilebilir hâle geldi |
| 5 | Günlüğe dört satır yazıldı | İlerleme görünür oldu |

Beş adımın hiçbiri kurulum gerektirmez.

## Yaygın yanlış anlamalar

> [!WARNING]
> **"Doğru aracı seçmezsem baştan yanlış öğrenirim."** Araçlar değişir,
> kavramlar kalır. Bir döngünün mantığını hangi düzenleyicide öğrendiğinin
> hiçbir önemi yoktur.

> [!WARNING]
> **"Güçlü bir bilgisayarım olmadan olmaz."** Bu eğitimin tamamı düz metinle
> takip edilebilir. Donanım, ancak büyük projeler ve derleme süreleri devreye
> girdiğinde bir kısıt hâline gelir.

> [!WARNING]
> **"Günlük tutmak zaman kaybı."** Günlük, tekrar listeni üreten ve ilerlemeni
> kanıtlayan tek şeydir. Oturum başına bir dakikadan azdır.

## Kontrol soruları

1. Öğrenmeye başlamak için gerçekten gereken üç şey nedir?
2. Araç seçimini kolaylaştıran temel fikir nedir? ("Kararı küçültmek" ne
   demek?)
3. Takılma kuralındaki "sorunu tek cümleyle yaz" adımı neden bu kadar etkili?
4. Öğrenme günlüğü, tekrar planını nasıl kendiliğinden üretir?

## Uygulama alıştırmaları

### Kavrama

"Araç yorgunluğu" kavramını, yazılım dışından bir örnekle anlat.

### Uygulama

Kendi takılma kuralını yaz. En az üç adım içersin ve her adımda **ne kadar
süre** harcayacağın belirtilsin. Kuralı, sonraki modüllerde gerçekten
uygulayacağın şekilde yaz — uygulanamayacak kadar iddialı bir kural, kural
değildir.

### Analiz

Bir kişi şöyle bir plan yapıyor: "Önce en iyi düzenleyiciyi seçeceğim, sonra
üç farklı dilden hangisinin daha iyi olduğunu araştıracağım, sonra tam
kapsamlı bir kurs bulacağım, sonra başlayacağım."

Bu planın hangi noktaları hatalı? En az iki sorun belirle ve her biri için
somut bir düzeltme öner.

## Küçük görev

Bir metin dosyası aç ve içine şunları yaz:

1. **Çalışma sözleşmen** (00 modülünün proje görevi).
2. **Takılma kuralın.**
3. **İlk günlük kaydın:** bugün bu üç dersi okudun; ne anladın, nerede
   takıldın?

Bu dosya bundan sonraki tüm modüllerde açık kalacak. Sonraki modüle geçmeden
önce [PROGRESS.md](../PROGRESS.md) üzerinde 00 modülünü işaretle.

## Özet

- Öğrenmeye başlamak için yazabileceğin bir yer, kaynağı kapatabildiğin bir an
  ve bir kayıt yeterlidir.
- Araç kararlarını küçült; hepsi geri alınabilir ve hiçbiri öğrenmenin yerine
  geçmez.
- Günlük ve takılma kuralı, ilerlemeyi görünür kılan ve tıkanmayı yönetilebilir
  hâle getiren iki basit araçtır.

## Sonraki ders

- [01 · Hesaplamalı Düşünme](../01-computational-thinking/README.md)

## Kaynaklar

- [Teach Yourself Computer Science](https://teachyourselfcs.com/)
- [OSSU Computer Science](https://github.com/ossu/computer-science)
