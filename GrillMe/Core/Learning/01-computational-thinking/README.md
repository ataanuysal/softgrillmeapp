---
course: software-engineering-fundamentals
module: computational-thinking
moduleOrder: 1
title: Hesaplamalı Düşünme
description: Bir problemi bilgisayarın çözebileceği hâle getirmeyi öğretir: ayrıştırma, örüntü, soyutlama ve algoritma.
status: published
version: 1
---
# 01 · Hesaplamalı Düşünme

**Durum:** Yayında
**Ön koşul:** [00 · Yönelim ve Çalışma Yöntemi](../00-orientation/README.md)
**Önerilen süre:** 2 hafta

## Bu modül ne yapar

Bir problemi, bilgisayarın çözebileceği hâle getirmeyi öğretir. Bu, kod yazmak
değildir; koddan **önce** gelen adımdır ve çoğu kişinin atladığı adım tam
olarak budur.

Dört alışkanlık kuracaksın:

1. Büyük problemi, tek tek çözülebilecek parçalara ayırmak
2. Parçalar arasındaki tekrarı görmek
3. Ayrıntıyı eleyip işe yarayan modeli çıkarmak
4. Adımları belirsizlik bırakmayacak şekilde yazmak

## Neden bu modül var

"Ne yazacağımı bilmiyorum" diyen birinin sorunu genellikle dil bilgisi değil,
problemin hâlâ tek ve büyük bir yığın olarak durmasıdır. Parçalanmamış bir
problem, hangi dili bilirsen bil yazılamaz.

Bu modül dilden bağımsızdır. Tek satır gerçek kod içermez; hepsi pseudocode'la
çalışılır.

## Öğrenme hedefleri

Bu modülün sonunda:

- Bir problemi girdi, işlem ve çıktı olarak tanımlayabilirsin.
- Problemi bağımsız çözülebilir alt problemlere ayırabilirsin.
- Tekrarlayan yapıları fark edip tek bir çözüme indirgeyebilirsin.
- Hangi ayrıntının önemli, hangisinin gürültü olduğunu ayırabilirsin.
- Belirsizlik içermeyen, sonlu ve izlenebilir bir algoritma yazabilirsin.
- Bir çözümün doğru olup olmadığını, uç durumlarla sınayabilirsin.

## Dersler

| # | Ders | Süre |
| --- | --- | --- |
| 1 | [Problemi parçalara ayırmak](./01-decomposition.md) | 20 dk |
| 2 | [Örüntü tanıma](./02-pattern-recognition.md) | 20 dk |
| 3 | [Soyutlama](./03-abstraction.md) | 20 dk |
| 4 | [Algoritma yazmak](./04-algorithms-and-pseudocode.md) | 25 dk |
| 5 | [Çözümü sınamak](./05-evaluating-solutions.md) | 25 dk |

## Modül değerlendirmesi

### Kavramsal değerlendirme

Şu soruyu yazarak cevapla: "Bir problemi parçalara ayırmak ile soyutlama
yapmak arasındaki fark nedir?" Cevabında her ikisi için de birer örnek ver ve
örneklerin bu derslerde geçmemiş olmasına dikkat et.

### Küçük proje

**Bir asansörün karar mantığını tasarla.**

Aşağıdakileri sırayla üret:

1. Problemin girdi–işlem–çıktı tanımı
2. En az dört alt probleme ayrılmış hâli
3. Tekrarlayan yapıların listesi (en az iki tane)
4. Hangi ayrıntıları modelin dışında bıraktığın ve neden
5. Ana kararın pseudocode'u (çağrıya nasıl cevap verilir)
6. En az beş uç durum ve algoritmanın her birinde ne yaptığı

Kod yazma. Bu bir tasarım görevidir.

## Tamamlanma kontrol listesi

- [ ] Beş dersi de okudum
- [ ] Her dersin kontrol sorularını kaynağa bakmadan cevapladım
- [ ] Her dersin üç alıştırmasını da yaptım
- [ ] Asansör projesini bitirdim
- [ ] Öğrenme günlüğüme takıldığım noktaları yazdım
- [ ] [PROGRESS.md](../PROGRESS.md) üzerinde işaretledim

## Sonraki modüle geçiş koşulu

- Tanımadığın bir problemi, yardım almadan girdi–işlem–çıktı olarak
  yazabiliyorsun.
- Bir algoritmayı elle, adım adım izleyip her adımda değerlerin ne olduğunu
  söyleyebiliyorsun.
- Bir çözümün yanlış olduğunu gösteren bir uç durum üretebiliyorsun.

Bu üçü sağlanmadan 02 · Programlamanın Temelleri modülüne geçmek, sözdizimi
ezberlemekle sonuçlanır.

## Kaynaklar

- [How to Design Programs](https://htdp.org/)
- [Teach Yourself Computer Science](https://teachyourselfcs.com/)
