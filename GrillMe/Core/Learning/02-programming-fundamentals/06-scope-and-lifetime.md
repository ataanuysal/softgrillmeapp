---
id: programming-fundamentals-06
course: software-engineering-fundamentals
module: programming-fundamentals
moduleOrder: 2
lessonOrder: 6
section: functions
title: Kapsam ve ömür
description: Bir ismin nereden görünür olduğunu, değerin ne kadar yaşadığını ve gölgelemenin neden hataya yol açtığını anlatır.
difficulty: beginner
estimatedMinutes: 20
prerequisites:
  - programming-fundamentals-05
relatedCodeLessons:
  - scope
  - pure-side-effects
objectives:
  - Bir ismin hangi bölgeden görünür olduğunu belirlemek
  - Değerin ömrünü çağrı yığınıyla ilişkilendirmek
  - Gölgeleme ve global durum risklerini tanımak
status: published
version: 1
---

# Kapsam ve ömür

## Dersin amacı

"Bu değişken burada neden görünmüyor?" ve "bu değer neden hâlâ eski?" —
ikisi de aynı iki kavramın sorularıdır: **kapsam** ve **ömür**. Bu ders ikisini
ayırır.

## Ön koşullar

- [Fonksiyonlar ve sözleşmeler](./05-functions-and-contracts.md)

## Kazanımlar

Bu dersin sonunda:

- Bir ismin nereden erişilebilir olduğunu söyleyebilirsin.
- Bir değerin ne zaman doğup ne zaman kaybolduğunu izleyebilirsin.
- Gölgelemenin neden sessiz hata ürettiğini açıklayabilirsin.
- Global durumun neden test etmeyi zorlaştırdığını bilirsin.

## Temel kavramlar

| Terim | İngilizce | Kısa tanım |
| --- | --- | --- |
| Kapsam | scope | Bir ismin görünür olduğu bölge |
| Ömür | lifetime | Bir değerin bellekte kaldığı süre |
| Yerel | local | Yalnızca tanımlandığı blokta görünen |
| Global | global | Her yerden görünen |
| Gölgeleme | shadowing | İç kapsamda aynı adı yeniden tanımlama |
| Çağrı yığını | call stack | Çalışan fonksiyon çağrılarının sırası |

## Kavramsal açıklama

### Kapsam bir soruyu cevaplar: bu isim buradan görünüyor mu?

```text
toplam ← 0                 // dış kapsam

hesapla()
  ara ← 5                  // yerel: yalnızca hesapla içinde
  toplam ← toplam + ara    // dıştaki isme erişilebilir

ÇIKTI: ara                 // HATA: ara burada tanımlı değil
```

Kural genellikle şudur: **iç kapsam dışarıyı görür, dış kapsam içeriyi
görmez.** Bunun sebebi keyfi değil — bir fonksiyonun içindeki geçici isimler
dışarıyı kirletmesin diye.

### Ömür, kapsamdan farklıdır

Kapsam "nereden görünür", ömür "ne kadar yaşar" sorusudur. Yerel bir değişken
fonksiyon çalıştığında doğar, fonksiyon dönünce kaybolur:

```text
hesapla()
  ara ← 5        // doğar
  DÖNDÜR ara * 2 // değer kopyalanıp döner
                 // ara kaybolur
```

Fonksiyonun ikinci çağrısı, birincinin `ara` değerini hatırlamaz. Bu iyi
haberdir: her çağrı temiz bir sayfadan başlar.

### Gölgeleme sessizdir

```text
indirim ← 10          // dış

hesapla(fiyat)
  indirim ← 50        // aynı ad, iç kapsam
  DÖNDÜR fiyat - indirim

ÇIKTI: indirim        // 10 — dıştaki hiç değişmedi
```

İki farklı değer, tek bir isim. Kodu okuyan kişi hangisine baktığını
karıştırırsa hata bulunamaz hâle gelir. Dil bu duruma çoğu zaman uyarı bile
vermez.

> [!WARNING]
> Aynı adı iç kapsamda yeniden tanımlaman gerekiyorsa, muhtemelen isimlerden
> biri yanlış seçilmiştir. `indirim` ve `uygulananIndirim` iki farklı kavramdır
> ve iki farklı ad hak eder.

### Global durum kolay başlar, zor biter

Her yerden erişilebilen bir değer başta pratiktir. Sorun şudur:

- Bir hata çıktığında **kim değiştirdi** sorusunun cevabı yoktur; her yer
  şüphelidir.
- Test etmek için önce o değeri kurmak, sonra temizlemek gerekir.
- İki iş aynı anda çalışıyorsa birbirinin değerini bozabilir.

Pratik kural: bir değeri en dar kapsamda tut; genişletmek her zaman
mümkündür, daraltmak geriye dönük olarak zordur.

## Gerçek hayattan benzetme

Bir ofis binası. Herkesin girebildiği lobi (global), yalnızca ekibin girdiği oda
(fonksiyon kapsamı), yalnızca senin çekmecen (blok kapsamı).

Ortak buzdolabına bir şey koyduğunda, kaybolduğunda kimin aldığını bilemezsin —
global durumun tam olarak yarattığı problem budur.

Ömür ise farklı bir sorudur: toplantı odasındaki yazı tahtası, toplantı bitince
silinir. Bir sonraki toplantı yazılanları hatırlamaz.

## Pseudocode örneği

```text
kdvOrani ← 0.2                     // dış kapsam: ayar

fatura(tutar)
  vergi   ← tutar * kdvOrani       // dıştaki ayarı okur
  toplam  ← tutar + vergi
  DÖNDÜR toplam                    // vergi ve toplam burada ölür

ÇIKTI: fatura(100)
ÇIKTI: vergi                       // HATA: vergi tanımlı değil
```

## Adım adım çalışma modeli

`fatura(100)` çağrısının izi:

| Adım | Çağrı yığını | Görünür isimler | Değerler |
| --- | --- | --- | --- |
| 1 | program | kdvOrani | 0.2 |
| 2 | program → fatura | kdvOrani, tutar | 0.2, 100 |
| 3 | program → fatura | + vergi | 20 |
| 4 | program → fatura | + toplam | 120 |
| 5 | program | kdvOrani | 0.2 (vergi ve toplam yok oldu) |

5. adımda `vergi` ve `toplam` bellekte artık yok. Fonksiyon dönerken yalnızca
**değeri** yukarı taşır, isimleri değil.

## Yaygın yanlış anlamalar

> [!WARNING]
> **"Kapsam ile ömür aynı şey."** Değil. Kapsam görünürlükle, ömür bellekte
> kalma süresiyle ilgilidir. Bir değer hâlâ yaşıyor olabilir ama bulunduğun
> yerden görünmüyordur.

> [!WARNING]
> **"Global yapmak zaman kazandırır."** Kısa vadede evet. Hata çıktığında
> aramaya nereden başlayacağını bilememek o kazancı fazlasıyla geri alır.

> [!WARNING]
> **"Aynı adı kullanmakta sakınca yok, dil hallediyor."** Dil hallediyor, insan
> halledemiyor. Gölgeleme derleyiciyi değil, okuyanı yanıltır.

## Kontrol soruları

1. İç kapsam dışarıyı görür ama tersi olmaz. Bu kuralın gerekçesi nedir?
2. Yukarıdaki izde 5. adımda `vergi` neden yok?
3. Gölgeleme neden derleyici hatası vermez ama yine de tehlikelidir?
4. Global bir değerin testi zorlaştırmasının iki sebebini yaz.

## Uygulama alıştırmaları

### Kavrama

Kapsam ile ömür farkını, yazılım dışından tek bir örnekle (ikisini de içeren)
anlat.

### Uygulama

Bir sayacı üç farklı biçimde tasarla ve her birinin kapsam/ömür sonucunu yaz:

1. Global değişken olarak
2. Fonksiyona parametre olarak verilip geri döndürülerek
3. Bir nesnenin içinde tutularak

Hangisini seçerdin ve neden?

### Analiz

Aşağıdaki kod ne yazar? Yazarın niyeti toplamı biriktirmekse hata nerede?

```text
toplam ← 0

ekle(deger)
  toplam ← 0
  toplam ← toplam + deger
  DÖNDÜR toplam

ÇIKTI: ekle(5)
ÇIKTI: ekle(3)
ÇIKTI: toplam
```

## Küçük görev

Kendi yazdığın (ya da okuduğun) bir kod parçasını aç. Her değişken için:

1. Hangi kapsamda tanımlı?
2. Ne zaman doğuyor, ne zaman ölüyor?
3. Daha dar bir kapsama taşınabilir mi?

Üçüncü soruya "evet" dediğin her satır, gelecekteki bir hatayı önceden
kapatmandır.

## Özet

- Kapsam ismin nereden görünür olduğunu, ömür değerin ne kadar yaşadığını
  söyler; ikisi farklı sorulardır.
- Fonksiyon dönerken değeri yukarı taşır, isimleri değil; her çağrı temiz
  sayfadan başlar.
- Global durum aramayı ve test etmeyi zorlaştırır; değeri en dar kapsamda tut,
  genişletmek her zaman mümkündür.

## Sonraki ders

- [Hatalar ve istisnalar](./07-errors-and-exceptions.md)

## Kaynaklar

- [Structure and Interpretation of Computer Programs](https://sarabander.github.io/sicp/html/)
- [How to Design Programs](https://htdp.org/)
