---
id: programming-fundamentals-05
course: software-engineering-fundamentals
module: programming-fundamentals
moduleOrder: 2
lessonOrder: 5
section: functions
title: Fonksiyonlar ve sözleşmeler
description: Fonksiyonu bir girdi-çıktı sözleşmesi olarak okumayı, yan etkiyi ve iyi bir imzanın neye benzediğini anlatır.
difficulty: beginner
estimatedMinutes: 25
prerequisites:
  - programming-fundamentals-04
relatedCodeLessons:
  - function-call
  - parameters-return
  - pure-side-effects
objectives:
  - Bir fonksiyonu girdi-çıktı sözleşmesi olarak okumak
  - Yan etkiyi tanımak ve gerektiğinde ayırmak
  - İmzaya bakarak ne yaptığını tahmin etmek
status: published
version: 1
---

# Fonksiyonlar ve sözleşmeler

## Dersin amacı

Fonksiyon, kodu kısaltma aracı değildir; **bir sözü yazıya dökmenin**
yoludur: "bana şunu ver, sana şunu döndürürüm." Bu ders o sözleşmeyi okumayı ve
yazmayı öğretir.

## Ön koşullar

- [Döngüler](./04-loops.md)

## Kazanımlar

Bu dersin sonunda:

- Bir fonksiyonun imzasından ne yaptığını tahmin edebilirsin.
- Saf fonksiyon ile yan etkili fonksiyonu ayırabilirsin.
- Bir fonksiyonun sözleşmesini (ön koşul, son koşul) yazabilirsin.
- Neden "bir fonksiyon bir iş yapar" kuralının test edilebilirliğe hizmet
  ettiğini bilirsin.

## Temel kavramlar

| Terim | İngilizce | Kısa tanım |
| --- | --- | --- |
| Fonksiyon | function | Girdi alıp çıktı üreten isimli işlem |
| Parametre | parameter | Fonksiyonun beklediği girdi |
| Argüman | argument | Çağrıda verilen gerçek değer |
| Dönüş değeri | return value | Fonksiyonun ürettiği sonuç |
| İmza | signature | Ad, parametreler ve dönüş tipi |
| Saf fonksiyon | pure function | Yan etkisi olmayan, aynı girdiye aynı çıktıyı veren |
| Yan etki | side effect | Dışarıdaki bir şeyi değiştirme |
| Ön koşul | precondition | Çağrıdan önce doğru olması gereken |
| Son koşul | postcondition | Dönüşten sonra doğru olan |

## Kavramsal açıklama

### İmza, sözleşmenin başlığıdır

```text
kdvEkle(tutar: Ondalık, oran: Ondalık) -> Ondalık
```

Bu tek satır sana üç şey söyler: adı, ne istediği ve ne verdiği. İyi bir imza
gövdeyi okumak zorunda bırakmaz.

Kötü imzanın belirtileri:

```text
islem(veri)                 // ne yapıyor?
hesapla(a, b, c, d, e)      // beş girdi: muhtemelen birden çok iş yapıyor
guncelle(kullanici) -> Bool // Bool ne demek? başarı mı, değişti mi?
```

### Saf fonksiyon: aynı girdi, aynı çıktı

Bir fonksiyon saftır eğer:

1. Aynı girdiyle her zaman aynı çıktıyı verirse, **ve**
2. Dışarıda hiçbir şeyi değiştirmezse.

```text
saf     : topla(a, b) -> a + b
saf değil: kaydet(kullanici)        // veritabanını değiştirir
saf değil: simdikiSaat()            // her çağrıda farklı sonuç
```

Saf fonksiyonların değeri şudur: test etmek için hiçbir hazırlık gerekmez, çağır
ve sonuca bak. Saf olmayanlar için ortam kurman gerekir.

### Yan etki kötü değildir, dağınık olması kötüdür

Bir program hiç yan etki üretmezse ekrana bir şey yazamaz, dosya kaydedemez —
işe yaramaz. Sorun yan etkinin varlığı değil, **her yere serpilmiş** olmasıdır.

Yaygın çözüm: hesabı saf tut, yan etkiyi kenara topla.

```text
karar ← indirimHesapla(sepet)   // saf: yalnızca hesaplar
uygula(karar)                   // yan etkili: dışarıyı değiştirir
```

Böylece zor olan kısım (hesap) kolayca test edilir; test edilmesi zor olan kısım
(yan etki) basit kalır.

### Sözleşme: ön koşul ve son koşul

```text
kokAl(sayi)
  ÖN KOŞUL : sayi >= 0
  SON KOŞUL: dönen değer * dönen değer ≈ sayi
```

Ön koşul çağıranın sorumluluğu, son koşul fonksiyonun sorumluluğudur. Bu ayrım
bir hata çıktığında **kimin hatalı olduğunu** söyler.

> [!NOTE]
> Ön koşulu kod içinde kontrol etmek de bir seçenektir. O zaman fonksiyon
> "geçersiz girdide hata döndürürüm" diye daha geniş bir söz vermiş olur.

### Bir fonksiyon bir iş yapar

Bir fonksiyonun ne yaptığını "ve" kullanmadan tek cümleyle anlatabiliyorsan
sınırı doğrudur. Anlatamıyorsan bölünmelidir — bu, ayrıştırma dersinde
öğrendiğin kuralın fonksiyon düzeyindeki hâlidir.

## Gerçek hayattan benzetme

Kuru temizlemeci. Sözleşme nettir: kirli gömlek verirsin, temiz gömlek
alırsın. Ön koşul gömleğin yıkanabilir olması, son koşul lekenin çıkmış
olmasıdır.

İçeride hangi makinenin kullanıldığını bilmen gerekmez — bu, soyutlama
dersindeki arayüz/uygulama ayrımının aynısıdır. Ama dükkân aynı zamanda senin
adına fatura kesip komşuna haber veriyorsa, artık bir iş değil üç iş yapıyor
demektir.

## Pseudocode örneği

```text
GİRDİ : sepet tutarı, kupon kodu
ÇIKTI : ödenecek tutar

indirimliTutar(tutar, kupon)
  ÖN KOŞUL: tutar >= 0

  EĞER kupon = "YOK" İSE
    DÖNDÜR tutar

  oran ← kuponOrani(kupon)      // saf: koddan orana
  EĞER oran = 0 İSE
    DÖNDÜR tutar

  DÖNDÜR tutar - (tutar * oran)
```

Bu fonksiyon saftır: hiçbir şeyi kaydetmez, ekrana yazmaz, aynı girdiyle her
zaman aynı sonucu verir.

## Adım adım çalışma modeli

`tutar = 200`, `kupon = "BAHAR20"` (oran 0.2) için:

| Adım | Nerede | Yapılan | tutar | oran | sonuç |
| --- | --- | --- | --- | --- | --- |
| 1 | indirimliTutar | ön koşul: 200 >= 0 | 200 | — | — |
| 2 | indirimliTutar | kupon "YOK" değil | 200 | — | — |
| 3 | kuponOrani | kod orana çevrildi | 200 | 0.2 | — |
| 4 | indirimliTutar | oran 0 değil | 200 | 0.2 | — |
| 5 | indirimliTutar | 200 − 40 | 200 | 0.2 | **160** |

3. adımda çağrı bir alt fonksiyona indi ve sonuç yukarı döndü. Fonksiyon
çağrısını izlemek, tam olarak bu inip çıkmayı takip etmektir.

## Yaygın yanlış anlamalar

> [!WARNING]
> **"Fonksiyon kodu kısaltmak içindir."** Kısalık bir yan üründür. Asıl amaç
> bir işi isimlendirip sözleşmeye bağlamak, böylece içine bakmadan
> kullanılabilir kılmaktır.

> [!WARNING]
> **"Saf fonksiyon her zaman daha iyidir."** Saf fonksiyon test etmesi kolaydır
> ama bir program tamamen saf olamaz. Amaç saflığı zorlamak değil, yan etkiyi
> az sayıda ve belirli yere toplamaktır.

> [!WARNING]
> **"Parametre sayısı önemli değil."** Beş parametre genellikle fonksiyonun
> birden çok iş yaptığının ya da parametrelerin bir arada tek bir kavram
> oluşturduğunun işaretidir.

## Kontrol soruları

1. Bir fonksiyonun imzası hangi üç bilgiyi verir?
2. `simdikiSaat()` neden saf değildir? Bu, test etmeyi nasıl zorlaştırır?
3. Ön koşul ile son koşul arasındaki sorumluluk farkı nedir?
4. Yan etkiyi kenara toplamak neyi kolaylaştırır?

## Uygulama alıştırmaları

### Kavrama

Saf fonksiyon ile yan etkili fonksiyonu, yazılım dışından birer örnekle anlat.

### Uygulama

Bir kullanıcının parolasının güçlü olup olmadığını değerlendiren pseudocode
yaz. İmzayı, ön koşulu ve son koşulu ayrıca belirt. Fonksiyonun saf olmasına
dikkat et — ekrana bir şey yazma, yalnızca sonuç döndür.

### Analiz

Aşağıdaki fonksiyon kaç iş yapıyor? Böl ve yeni imzaları yaz.

```text
siparisiTamamla(sepet)
  toplam ← sepetToplami(sepet)
  vergi  ← toplam * 0.2
  veritabaninaYaz(sepet, toplam + vergi)
  epostaGonder(sepet.kullanici, "Siparişiniz alındı")
  DÖNDÜR toplam + vergi
```

## Küçük görev

Bir önceki modülün asansör projesini aç (ya da kendi seçtiğin bir sistemi).
Tasarladığın her parça için:

1. İmzasını yaz: ad, girdiler, çıktı.
2. Saf mı, yan etkili mi işaretle.
3. Yan etkili olanları tek bir katmanda toplayabilir miydin? Bir cümleyle
   cevapla.

## Özet

- Fonksiyon bir sözleşmedir; imza o sözleşmenin okunabilir başlığıdır.
- Saf fonksiyon aynı girdiye aynı çıktıyı verir ve dışarıyı değiştirmez; test
  etmesi bu yüzden ucuzdur.
- Yan etki gereklidir ama dağınık olmamalıdır: hesabı saf tut, etkiyi kenara
  topla.

## Sonraki ders

- [Kapsam ve ömür](./06-scope-and-lifetime.md)

## Kaynaklar

- [How to Design Programs](https://htdp.org/)
- [Structure and Interpretation of Computer Programs](https://sarabander.github.io/sicp/html/)
