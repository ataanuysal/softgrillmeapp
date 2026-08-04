---
id: orientation-01
course: software-engineering-fundamentals
module: orientation
moduleOrder: 0
lessonOrder: 1
section: fundamentals
title: Yazılım nedir?
description: Yazılımın donanımdan farkını, neden değiştirilebilir olduğunu ve bilgisayarın talimatları nasıl işlediğini anlatır.
difficulty: beginner
estimatedMinutes: 15
prerequisites: []
objectives:
  - Yazılım ile donanım arasındaki farkı açıklamak
  - Talimat sırasının sonucu nasıl değiştirdiğini göstermek
  - Algoritma, kod ve program terimlerini birbirinden ayırmak
status: published
version: 1
---

# Yazılım nedir?

## Dersin amacı

Yazılım öğrenmeye başlayan çoğu kişi işe bir programlama dili seçerek başlar.
Bu, ev yapmayı öğrenmeye çekiç markası seçerek başlamak gibidir. Bu ders,
araçtan önce işin kendisini tanımlar: yazılım nedir, donanımdan farkı nedir ve
bilgisayar bir talimat listesini nasıl işler.

## Ön koşullar

- Yok. Bu eğitimin ilk dersidir.

## Kazanımlar

Bu dersin sonunda:

- Yazılımı, "bilgisayarın çalıştırdığı program" tanımının ötesinde
  anlatabilirsin.
- Donanım ile yazılım arasındaki farkı, esneklik açısından açıklayabilirsin.
- Bir talimat listesinin **sırasının** neden sonucu değiştirdiğini
  gösterebilirsin.
- "Program", "algoritma" ve "kod" terimlerini birbirinden ayırabilirsin.

## Temel kavramlar

| Terim | İngilizce | Kısa tanım |
| --- | --- | --- |
| Donanım | hardware | Bilgisayarın fiziksel, elle tutulur parçaları |
| Yazılım | software | Donanıma ne yapacağını söyleyen, değiştirilebilir talimatlar |
| Talimat | instruction | Bilgisayarın yapabileceği tek bir işlem |
| Program | program | Belirli bir işi yapmak üzere düzenlenmiş talimatlar bütünü |
| Algoritma | algorithm | Bir problemi çözen, adımları belirli ve sonlu yöntem |
| Kod | code | Bir algoritmanın, bir dilde yazılmış hâli |
| Yürütme | execution | Talimatların sırayla işletilmesi |

## Kavramsal açıklama

Bir bilgisayarın içinde, tek başına hiçbir şey "bilmeyen" devreler vardır. Bu
devreler yalnızca çok basit işlemleri yapabilir: iki sayıyı toplamak, iki
değeri karşılaştırmak, bir değeri bir yerden alıp başka yere koymak, "eğer şu
doğruysa şuradan devam et" demek.

**Donanım** bu yetenekleri sunar ama neyin ne zaman yapılacağına karar vermez.
Kararı veren şey **yazılımdır**: donanımın yapabildiği basit işlemlerden
oluşan, belirli bir sırada dizilmiş talimat listesi.

Aradaki asıl fark hız ya da karmaşıklık değil, **değiştirilebilirliktir**.
Donanımın davranışını değiştirmek için fiziksel olarak yeni bir devre üretmek
gerekir. Yazılımın davranışını değiştirmek için talimat listesini değiştirmek
yeterlidir. Aynı telefon, hiçbir parçası değişmeden bugün hesap makinesi, yarın
harita olabiliyorsa bunun sebebi budur.

Bu, bilgisayarın en önemli özelliğidir: **genel amaçlı** bir makinedir. Tek bir
iş için üretilmemiştir; hangi işi yapacağını ona verdiğin talimatlar belirler.

### Talimatlar sırayla işlenir

Bilgisayar talimatları, sen aksini söylemedikçe, yukarıdan aşağıya tek tek
işler. Bir talimat bitmeden sonraki başlamaz ve her talimat, kendinden
öncekilerin bıraktığı durumun üzerine çalışır.

Bu yüzden **sıra bir üslup tercihi değil, sonucun kendisidir**:

```text
A) kutuya 5 koy
   kutuya 3 ekle
   → kutuda 8 var

B) kutuya 3 ekle
   kutuya 5 koy
   → kutuda 5 var
```

Aynı iki talimat, farklı sırada, farklı sonuç verir.

### Program, algoritma, kod

Bu üç kelime günlük konuşmada birbirinin yerine kullanılır ama aynı şey
değildirler:

- **Algoritma** yöntemdir. "Listedeki en büyük sayıyı bul" işini çözen adım
  planı, hiçbir dilde yazılmamış hâliyle bile bir algoritmadır.
- **Kod** o yöntemin belirli bir dildeki yazımıdır. Aynı algoritma yüzlerce
  farklı dilde yazılabilir; algoritma değişmez, kod değişir.
- **Program**, bir işi baştan sona yapan bütündür. Genellikle birçok algoritma
  içerir.

> [!NOTE]
> Bu ayrım pratik bir sonuç doğurur: yeni bir dil öğrenmek, sıfırdan
> başlamak değildir. Algoritmalar taşınır, yalnızca yazım değişir.

## Gerçek hayattan benzetme

Bir yemek tarifi düşün.

- **Mutfak ve aletler** donanımdır: ocak, tencere, bıçak. Neyi yapabileceğinin
  sınırını çizerler ama kendi başlarına bir şey pişirmezler.
- **Tarif** yazılımdır: aynı mutfakta bugün çorba, yarın kek yapmanı sağlayan
  şey odur.
- **Tarifin adımları** talimatlardır. "Unu ekle" tek bir işlemdir.
- **Sıra** burada da sonucu belirler: yumurtayı çırpmadan önce mi sonra mı
  ekleyeceğin, kekin olup olmamasını değiştirir.

Benzetmenin sınırı: tarifi okuyan insan, eksik bir adımı sağduyusuyla tamamlar.
Bilgisayar tamamlamaz. Yazmadığın hiçbir şeyi yapmaz, yazdığın her şeyi
harfiyen yapar.

## Pseudocode örneği

Aşağıdaki adım listesi hiçbir programlama diline ait değildir. **Pseudocode**,
mantığı dilin ayrıntılarından ayırmak için kullanılan, insanın okuyabildiği
adım yazımıdır.

```text
GİRDİ: iki sayı — birinci, ikinci
İŞLEM:
  toplam ← birinci + ikinci
  ortalama ← toplam / 2
ÇIKTI: ortalama
```

`←` işareti "değeri şuraya koy" demektir. Bu bir eşitlik iddiası değil, bir
yerleştirme işlemidir.

## Adım adım çalışma modeli

`birinci = 8`, `ikinci = 4` için bilgisayarın izlediği yol:

| Adım | İşlenen talimat | birinci | ikinci | toplam | ortalama |
| --- | --- | --- | --- | --- | --- |
| 0 | (başlangıç) | 8 | 4 | — | — |
| 1 | `toplam ← birinci + ikinci` | 8 | 4 | 12 | — |
| 2 | `ortalama ← toplam / 2` | 8 | 4 | 12 | 6 |
| 3 | `ÇIKTI: ortalama` | 8 | 4 | 12 | 6 → yazdırılır |

İki şeye dikkat et:

1. **Her satırda yalnızca bir şey değişir.** Bilgisayar aynı anda birden çok
   iş yapmaz (bunun istisnaları vardır ve ileride ayrı bir modülde ele
   alınır).
2. **2. adım, 1. adımın sonucuna dayanır.** İki satırın yerini değiştirseydin,
   `toplam` henüz var olmadığı için hesap yapılamazdı.

## Yaygın yanlış anlamalar

> [!WARNING]
> **"Bilgisayar ne demek istediğimi anlar."** Anlamaz. Niyetini değil,
> yazdığını çalıştırır. Programların çoğu hatası, bilgisayarın yanlış
> çalışmasından değil, yazılanın kastedilenden farklı olmasından doğar.

> [!WARNING]
> **"Yazılım = kod."** Kod yazılımın yazıya dökülmüş hâlidir. Yazılım; hangi
> problemi çözdüğü, verinin nasıl düzenlendiği ve parçaların nasıl birleştiği
> dahil olmak üzere daha büyük bir bütündür.

> [!WARNING]
> **"Önce bir dil seçmeliyim."** Dil, yöntemi ifade etme aracıdır. Yöntemi
> kuramadan seçilen dil, ezberlenmiş sözdiziminden başka bir şey vermez.

## Kontrol soruları

1. Donanım ile yazılım arasındaki temel fark nedir? Cevabında "esneklik"
   kelimesini kullanmadan açıkla.
2. Yukarıdaki pseudocode'da `toplam ← birinci + ikinci` ile
   `ortalama ← toplam / 2` satırlarının yeri değişirse ne olur? Neden?
3. "Algoritma" ile "kod" arasındaki farkı, günlük hayattan bir örnekle anlat.
4. Bir bilgisayarın "genel amaçlı makine" olması ne demektir?

## Uygulama alıştırmaları

### Kavrama

Yazılımın ne olduğunu, hiç teknik terim kullanmadan, dört cümleyle anlat.
Cümlelerinde "kod", "program" ve "bilgisayar" kelimelerini kullanma.

### Uygulama

Günlük hayatından bir işi (çay demlemek, otobüse binmek, kapıyı kilitlemek)
pseudocode olarak yaz. Kuralları:

- En az 5 adım olsun.
- Her adım tek bir işlem içersin.
- Adımlardan ikisinin yerini değiştir ve sonucun nasıl bozulduğunu bir cümleyle
  yaz.

### Analiz

Aşağıdaki adım listesini incele:

```text
GİRDİ: sıcaklık
İŞLEM:
  ÇIKTI: "Ceket giy"
  EĞER sıcaklık > 20 İSE
    ÇIKTI: "Ceket gerekmez"
ÇIKTI: bitti
```

`sıcaklık = 25` için ekrana ne yazılır? Bu davranış yazarın niyetiyle uyuşuyor
mu? Uyuşmuyorsa sorunun kaynağı hangi satırdadır?

## Küçük görev

Kullandığın bir uygulamayı seç (mesaj, harita, müzik — fark etmez). Şunları
yazılı olarak cevapla:

1. Bu uygulama hangi problemi çözüyor?
2. Kullanıcıdan hangi bilgileri alıyor? (girdi)
3. Kullanıcıya ne veriyor? (çıktı)
4. Arada hangi kararı vermek zorunda? (en az bir "eğer ... ise" cümlesi yaz)

Bu üç soru — girdi, işlem, çıktı — bundan sonraki her derste karşına çıkacak.

## Özet

- Yazılım, donanıma ne yapacağını söyleyen **değiştirilebilir** talimatlardır;
  bilgisayarı genel amaçlı yapan şey budur.
- Talimatlar sırayla işlenir ve her talimat kendinden öncekinin bıraktığı
  durumun üzerine çalışır; bu yüzden sıra sonucun kendisidir.
- Algoritma yöntemdir, kod o yöntemin bir dildeki yazımıdır; yöntemi kurmadan
  yazılan kod ezberden ibarettir.

## Sonraki ders

- [Nasıl çalışılır?](./02-how-to-study.md)

## Kaynaklar

- [Teach Yourself Computer Science](https://teachyourselfcs.com/)
- [Nand2Tetris — bilgisayarın katmanları](https://www.nand2tetris.org/)
