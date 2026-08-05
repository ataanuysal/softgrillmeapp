---
course: software-engineering-fundamentals
module: programming-fundamentals
moduleOrder: 2
title: Programlamanın Temelleri
description: Değişken, tip, koşul, döngü, fonksiyon, kapsam ve hata kavramlarını dile bağlı kalmadan kurar.
status: published
version: 2
---

# 02 · Programlamanın Temelleri

**Durum:** Yayında
**Ön koşul:** [01 · Hesaplamalı Düşünme](../01-computational-thinking/README.md)
**Önerilen süre:** 2 hafta

## Bu modül ne yapar

Hesaplamalı düşünme modülünde problemi çözülebilir hâle getirdin. Bu modül o
çözümü ifade etmenin yapı taşlarını verir: değer, tip, değişken, koşul, döngü,
fonksiyon, kapsam ve hata.

Modül dilden bağımsızdır. Örnekler pseudocode'dur; herhangi bir dilde
karşılığını bulursun.

## Neden bu modül var

Sözdizimi öğrenmiş çoğu kişi bu kavramların **davranışını** hiç öğrenmez:
atamanın hangi sırayla çalıştığını, bir koşul zincirinin ilk doğruda
durduğunu, birikim değişkeninin neden döngü dışında tanımlandığını.

Kavram bilinmeden yazılan kod çalışabilir; ama neden çalıştığı bilinmediği için
bozulduğunda tamir edilemez.

## Öğrenme hedefleri

Bu modülün sonunda:

- Bir değerin tipinin hangi işlemlere izin verdiğini söyleyebilirsin.
- `x ← x + 1` satırını doğru sırada okuyabilirsin.
- Bir koşul zincirinde kapsanmayan durumu bulabilirsin.
- Bir döngünün duracağını kanıtlayabilirsin.
- Bir fonksiyonu girdi–çıktı sözleşmesi olarak okuyabilirsin.
- Bir ismin nereden görünür olduğunu ve değerin ne kadar yaşadığını
  ayırabilirsin.
- Beklenen başarısızlığı beklenmeyen hatadan ayırabilirsin.

## Dersler

| # | Ders | Süre |
| --- | --- | --- |
| 1 | [Değerler ve tipler](./01-values-and-types.md) | 20 dk |
| 2 | [Değişkenler ve atama](./02-variables-and-assignment.md) | 20 dk |
| 3 | [Koşullu ifadeler](./03-conditionals.md) | 20 dk |
| 4 | [Döngüler](./04-loops.md) | 25 dk |
| 5 | [Fonksiyonlar ve sözleşmeler](./05-functions-and-contracts.md) | 25 dk |
| 6 | [Kapsam ve ömür](./06-scope-and-lifetime.md) | 20 dk |
| 7 | [Hatalar ve istisnalar](./07-errors-and-exceptions.md) | 25 dk |

## Modül değerlendirmesi

### Kavramsal değerlendirme

Şu üç soruyu kaynağa bakmadan, yazarak cevapla:

1. `toplam ← toplam + 1` satırı neden matematiksel bir eşitlik değildir?
2. Bir döngünün duracağını nasıl kanıtlarsın?
3. Beklenen başarısızlık ile beklenmeyen hata arasındaki fark, kodda nasıl
   görünür?

### Küçük proje

**Bir not defteri uygulamasının çekirdek mantığını tasarla.** Kod yazma;
pseudocode ve sözleşme yaz.

1. Notun tiplerini belirle (başlık, içerik, tarih, sabitlenmiş mi).
2. Şu işlemler için imza ve sözleşme yaz: not ekle, not sil, notlarda ara,
   sabitlenmiş notları listele.
3. Her fonksiyonun saf mı yan etkili mi olduğunu işaretle.
4. Arama fonksiyonunun iz tablosunu üç farklı girdi için çıkar (eşleşme yok,
   tek eşleşme, çok eşleşme).
5. En az üç beklenen başarısızlığı ve dönecek mesajı yaz.

## Tamamlanma kontrol listesi

- [ ] Yedi dersi de okudum
- [ ] Her dersin kontrol sorularını kaynağa bakmadan cevapladım
- [ ] Her dersin üç alıştırmasını da yaptım
- [ ] Not defteri projesini bitirdim
- [ ] Öğrenme günlüğüme takıldığım noktaları yazdım
- [ ] [PROGRESS.md](../PROGRESS.md) üzerinde işaretledim

## Sonraki modüle geçiş koşulu

- Verilen bir pseudocode'un iz tablosunu yardım almadan çıkarabiliyorsun.
- Bir fonksiyonun imzasına bakıp ne yaptığını tahmin edebiliyorsun.
- Bir kod parçasında kapsanmayan durumu ve sonsuz döngü riskini
  gösterebiliyorsun.

## Kaynaklar

- [How to Design Programs](https://htdp.org/)
- [Structure and Interpretation of Computer Programs](https://sarabander.github.io/sicp/html/)
- [Teach Yourself Computer Science](https://teachyourselfcs.com/)
