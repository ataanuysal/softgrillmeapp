---
id: programming-fundamentals-03
course: software-engineering-fundamentals
module: programming-fundamentals
moduleOrder: 2
lessonOrder: 3
section: fundamentals
title: Koşullu ifadeler
description: Programın nasıl karar verdiğini, koşulların hangi sırayla değerlendirildiğini ve eksik dalın neden hata ürettiğini anlatır.
difficulty: beginner
estimatedMinutes: 20
prerequisites:
  - programming-fundamentals-02
relatedCodeLessons:
  - conditions
  - compound-conditions
objectives:
  - Bir koşulun hangi sırayla değerlendirildiğini okumak
  - Bileşik koşulları doğru kurmak
  - Ele alınmayan dalı fark etmek
status: published
version: 1
---

# Koşullu ifadeler

## Dersin amacı

Bir program, girdisine bakıp yol ayırdığı anda "hesap makinesi" olmaktan çıkar.
Bu ders karar yapısını, koşulların değerlendirilme sırasını ve en sık yapılan
hatayı — unutulan dalı — ele alır.

## Ön koşullar

- [Değişkenler ve atama](./02-variables-and-assignment.md)

## Kazanımlar

Bu dersin sonunda:

- Bir koşul zincirinin hangi dala gireceğini söyleyebilirsin.
- `VE` ile `VEYA` arasındaki farkı sonuç üzerinden gösterebilirsin.
- Bir koşul zincirinde ele alınmayan durumu bulabilirsin.
- Koşulları neden en dar olandan başlatman gerektiğini bilirsin.

## Temel kavramlar

| Terim | İngilizce | Kısa tanım |
| --- | --- | --- |
| Koşul | condition | Doğru ya da yanlış üreten ifade |
| Dal | branch | Koşulun sonucuna göre gidilen yol |
| Bileşik koşul | compound condition | `VE` / `VEYA` ile birleştirilmiş koşul |
| Kısa devre | short-circuit | Sonuç belli olunca kalanı değerlendirmeme |
| Kapsanmayan durum | uncovered case | Hiçbir dalın karşılamadığı girdi |

## Kavramsal açıklama

### Koşul zinciri yukarıdan aşağı okunur ve ilk doğruda durur

```text
EĞER puan >= 90 İSE      → "pekiyi"
DEĞİLSE EĞER puan >= 70  → "iyi"
DEĞİLSE EĞER puan >= 50  → "geçer"
DEĞİLSE                   → "kaldı"
```

`puan = 95` için üç koşul da doğrudur ama yalnızca ilki çalışır. Bu yüzden
**sıra sonucun bir parçasıdır**: geniş koşulu başa koyarsan dar olanlara hiç
sıra gelmez.

```text
yanlış sıra:
EĞER puan >= 50 İSE → "geçer"     // 95 de buraya düşer
DEĞİLSE EĞER puan >= 90 → "pekiyi" // hiç çalışmaz
```

### VE ile VEYA farkı sonucu tersine çevirir

| Koşul | Ne zaman doğru |
| --- | --- |
| `a VE b` | ikisi de doğruysa |
| `a VEYA b` | en az biri doğruysa |
| `DEĞİL a` | a yanlışsa |

Pratikte en sık karıştırılan yer olumsuzlamadır:

```text
DEĞİL (yas >= 18 VE uyeMi)
aynısıdır:
(yas < 18) VEYA (DEĞİL uyeMi)
```

Olumsuzlama içeri girerken `VE` `VEYA`ya döner. Bunu yanlış çevirmek, doğru
görünen ama tersini yapan kod üretir.

### Kısa devre: değerlendirilmeyen taraf

Çoğu dil `a VE b` ifadesinde `a` yanlışsa `b`'yi hiç çalıştırmaz. Bu yalnızca
hız değil, **güvenlik** meselesidir:

```text
EĞER liste boş değil VE liste[0] > 5 İSE
```

Sıra ters olsaydı boş listede `liste[0]` çökerdi. Koruyucu koşul her zaman
önce gelir.

### Her koşul zincirinin bir "geri kalan" dalı olmalıdır

```text
EĞER durum = "yeni"   İSE → ...
DEĞİLSE EĞER durum = "onaylı" İSE → ...
```

`durum = "iptal"` gelirse ne olur? Hiçbir şey. Program hata vermez, sessizce
hiçbir şey yapmaz — teşhis edilmesi en zor hata türü budur.

> [!WARNING]
> Bir koşul zinciri yazdığında kendine tek soru sor: *hiçbir dala girmeyen bir
> girdi var mı?* Varsa ya bir `DEĞİLSE` ekle ya da açıkça hata ver.

## Gerçek hayattan benzetme

Havaalanı kontrol noktası. Sırayla sorular sorulur ve ilk eşleşen kural
uygulanır: diplomatik pasaport mu, öncelikli yolcu mu, normal sıra mı. Sıra
yanlış kurulursa öncelikli yolcu normal sıraya düşer — kural kitabı doğru,
sıralaması yanlıştır.

Ve hiçbir kurala uymayan bir yolcu geldiğinde birinin "bu durumda ne
yapıyoruz?" diye sorması gerekir. O soru sorulmadıysa yolcu orada bekler.

## Pseudocode örneği

```text
GİRDİ : sepet tutarı, üyelik durumu
ÇIKTI : kargo ücreti

kargoUcreti(tutar, uyeMi)
  EĞER tutar < 0 İSE
    DÖNDÜR hata("Tutar negatif olamaz")

  EĞER uyeMi VE tutar >= 250 İSE
    DÖNDÜR 0
  DEĞİLSE EĞER tutar >= 500 İSE
    DÖNDÜR 0
  DEĞİLSE
    DÖNDÜR 50
```

Üye için eşik daha düşük. Sıra önemli: üyelik koşulu önce denenmezse üye
kullanıcı 500'e kadar ücret öderdi.

## Adım adım çalışma modeli

| tutar | uyeMi | 1. dal | 2. dal | 3. dal | Sonuç |
| --- | --- | --- | --- | --- | --- |
| 300 | evet | negatif değil | `evet VE 300>=250` doğru | — | **0** |
| 300 | hayır | negatif değil | `hayır VE …` yanlış | `300>=500` yanlış | **50** |
| 600 | hayır | negatif değil | yanlış | `600>=500` doğru | **0** |
| −10 | evet | **negatif** | çalışmaz | çalışmaz | **hata** |

Son satırda ilk koşul kapı görevi gördü; sonraki iki dal hiç değerlendirilmedi.

## Yaygın yanlış anlamalar

> [!WARNING]
> **"Koşulların sırası önemli değil, hepsi kontrol ediliyor."** Zincir ilk
> doğruda durur. Geniş koşulu başa koymak, dar koşulları ölü koda çevirir.

> [!WARNING]
> **"`DEĞİL (a VE b)` ile `DEĞİL a VE DEĞİL b` aynı."** Değildir. Olumsuzlama
> içeri girerken bağlaç de değişir.

> [!WARNING]
> **"`DEĞİLSE` yazmasam da olur."** O zaman kapsanmayan girdi sessizce hiçbir
> şey yapmaz. Sessiz hata, gürültülü hatadan çok daha pahalıdır.

## Kontrol soruları

1. `puan = 95` için not zincirinde hangi dal çalışır, hangileri hiç
   değerlendirilmez?
2. `DEĞİL (yas >= 18 VE uyeMi)` ifadesini `VEYA` kullanarak yaz.
3. Kısa devre olmasaydı `liste boş değil VE liste[0] > 5` neden çökerdi?
4. Bir koşul zincirinde kapsanmayan durumu nasıl bulursun?

## Uygulama alıştırmaları

### Kavrama

"Sıra sonucun bir parçasıdır" cümlesini, yazılım dışından bir kural listesiyle
örnekle.

### Uygulama

Bir sinema bileti fiyatı hesaplayan pseudocode yaz. Kurallar: 6 yaş altı
ücretsiz, 65 yaş üstü yarı fiyat, öğrenci %25 indirimli, diğerleri tam. Kuralları
doğru sırayla diz ve 5, 20, 20 (öğrenci), 70 yaşları için iz tablosu çıkar.

### Analiz

Aşağıdaki kod hangi girdide sessizce hiçbir şey yapmaz? Düzelt.

```text
EĞER rol = "yonetici" İSE
  yetkiVer("hepsi")
DEĞİLSE EĞER rol = "editor" İSE
  yetkiVer("yazma")
```

## Küçük görev

Kullandığın bir uygulamada karar içeren bir davranış seç (bildirim gönderme,
indirim uygulama, erişim izni). Şunları yaz:

1. Kararı belirleyen girdiler
2. Kuralları doğru sırayla
3. Hiçbir kurala uymayan bir girdi ve o durumda ne olması gerektiği

## Özet

- Koşul zinciri yukarıdan aşağı okunur ve ilk doğru dalda durur; sıra sonucun
  parçasıdır.
- `VE`/`VEYA` olumsuzlanırken yer değiştirir; bu çeviriyi yanlış yapmak tersini
  yapan kod üretir.
- Kapsanmayan durum hata vermez, sessizce hiçbir şey yapmaz — bu yüzden her
  zincirin bir "geri kalan" dalı olmalıdır.

## Sonraki ders

- [Döngüler](./04-loops.md)

## Kaynaklar

- [How to Design Programs](https://htdp.org/)
- [Teach Yourself Computer Science](https://teachyourselfcs.com/)
