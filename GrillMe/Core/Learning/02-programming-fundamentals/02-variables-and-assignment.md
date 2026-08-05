---
id: programming-fundamentals-02
course: software-engineering-fundamentals
module: programming-fundamentals
moduleOrder: 2
lessonOrder: 2
section: fundamentals
title: Değişkenler ve atama
description: Değişkenin ne olduğunu, atamanın eşitlikten farkını ve değerin zaman içinde nasıl değiştiğini izlemeyi anlatır.
difficulty: beginner
estimatedMinutes: 20
prerequisites:
  - programming-fundamentals-01
relatedCodeLessons:
  - variables
objectives:
  - Atamayı matematiksel eşitlikten ayırmak
  - Bir değişkenin değerini adım adım izlemek
  - Değişmez ile değişken arasında bilinçli seçim yapmak
status: published
version: 1
---

# Değişkenler ve atama

## Dersin amacı

Bir programı okumak, büyük ölçüde **hangi değerin şu anda nerede olduğunu**
takip etmektir. Bu ders değişkenin ne olduğunu, atamanın nasıl çalıştığını ve
değerin zaman içindeki değişimini izlemeyi öğretir.

## Ön koşullar

- [Değerler ve tipler](./01-values-and-types.md)

## Kazanımlar

Bu dersin sonunda:

- Atama ile eşitliği karıştırmazsın.
- `x ← x + 1` satırını doğru sırada okuyabilirsin.
- Bir değişkenin değerini satır satır izleyebilirsin.
- Değişmez bir değeri ne zaman tercih edeceğini bilirsin.

## Temel kavramlar

| Terim | İngilizce | Kısa tanım |
| --- | --- | --- |
| Değişken | variable | Değer saklayan isimli yer |
| Atama | assignment | Bir değeri değişkene yazma |
| Değişmez | immutable | Bir kez atanıp bir daha değişmeyen değer |
| Yeniden atama | reassignment | Aynı değişkene yeni bir değer yazma |
| Durum | state | Programın o andaki bütün değişken değerleri |

## Kavramsal açıklama

### Atama bir iddia değil, bir işlemdir

Matematikte `x = x + 1` yanlıştır; hiçbir sayı kendisinin bir fazlasına eşit
değildir. Programlamada aynı satır **bir emirdir** ve üç adımda çalışır:

```text
toplam ← toplam + 1

1. Sağ taraf okunur : toplam'ın şu anki değeri alınır
2. Hesaplanır       : değer + 1
3. Sola yazılır     : sonuç toplam'a konur
```

Bu sıra kavranmadan hiçbir döngü doğru okunamaz. Sağ taraf **eski** değeri
kullanır, sol taraf **yeni** değeri alır.

### İsim, değerin kendisi değildir

Değişken bir kutudur; içindeki değer değişebilir ama kutu aynı kutudur.

```text
ad ← "Ada"
ad ← "Can"
```

İkinci satırdan sonra `"Ada"` artık hiçbir yerde değildir. Değişkeni okuduğunda
gördüğün şey **son atanan** değerdir; öncekiler kaybolur.

> [!NOTE]
> Bu yüzden bir programı okurken "bu değişkenin değeri ne" sorusunun cevabı
> her zaman "hangi satırdayız" sorusuna bağlıdır.

### Değişmez olmak bir kısıt değil, bir güvencedir

Çoğu dil "bir daha değişmeyecek" diyebileceğin bir tanım biçimi sunar. İki
kazancı vardır: okuyan kişi değeri bir kez okur ve bir daha aramaz; yanlışlıkla
değiştirme ihtimali ortadan kalkar.

Pratik kural: **varsayılan olarak değişmez tanımla, değişmesi gerektiğini
kanıtladığında değişkene çevir.**

### Aynı anda değişen değer sayısı okuma yükünü belirler

Uzun bir fonksiyonun okunmasını zorlaştıran şey satır sayısı değil, aynı anda
değişen değer sayısıdır. Üç değişken birlikte değişiyorsa, aklında tutman
gereken durum sayısı da o oranda artar.

## Gerçek hayattan benzetme

Bir tahtadaki skor. Skoru güncellerken önce mevcut sayıyı okursun, sonra
silersin, sonra yenisini yazarsın — tam olarak atamanın üç adımı. Eski skor
hiçbir yerde saklı değildir; kimse yazmadıysa kaybolmuştur.

## Pseudocode örneği

```text
GİRDİ : sepetteki ürün fiyatları
ÇIKTI : toplam ve en pahalı ürün

sepetOzeti(fiyatlar)
  toplam   ← 0
  enPahali ← 0

  HER f İÇİN fiyatlar İÇİNDE
    toplam ← toplam + f
    EĞER f > enPahali İSE
      enPahali ← f

  DÖNDÜR toplam, enPahali
```

İki değişken aynı döngüde farklı kurallarla değişiyor: biri her turda, diğeri
yalnızca koşul sağlandığında.

## Adım adım çalışma modeli

`fiyatlar = [40, 90, 60]` için:

| Adım | Satır | f | toplam | enPahali |
| --- | --- | --- | --- | --- |
| 0 | başlangıç | — | 0 | 0 |
| 1 | `toplam ← toplam + f` | 40 | 40 | 0 |
| 2 | `40 > 0` doğru | 40 | 40 | 40 |
| 3 | `toplam ← toplam + f` | 90 | 130 | 40 |
| 4 | `90 > 40` doğru | 90 | 130 | 90 |
| 5 | `toplam ← toplam + f` | 60 | 190 | 90 |
| 6 | `60 > 90` yanlış | 60 | 190 | 90 |
| 7 | döndür | — | **190** | **90** |

6. adımda `enPahali` **hiç değişmedi**. Bir satırın çalışıp hiçbir şeyi
değiştirmemesi de bir davranıştır ve izlerken atlanmamalıdır.

## Yaygın yanlış anlamalar

> [!WARNING]
> **"`x = x + 1` matematiksel olarak yanlış."** Programlamada `=` bir eşitlik
> iddiası değil, bir yazma işlemidir. Pseudocode bu yüzden `←` kullanır.

> [!WARNING]
> **"Tanımlarken verdiğim değer hep orada kalır."** Kalmaz; her yeniden atama
> öncekini siler. Bir değerin korunmasını istiyorsan onu ayrı bir değişkende
> saklamalısın.

> [!WARNING]
> **"Değişmez tanımlamak kodu kısıtlar."** Tersine, okumayı kolaylaştırır:
> okuyan kişi o değerin bir daha değişmediğini bilir ve kalan satırları tarama
> zorunluluğundan kurtulur.

## Kontrol soruları

1. `toplam ← toplam + f` satırı hangi sırayla çalışır? Üç adımı yaz.
2. Yukarıdaki tabloda 6. adımda ne oldu ve bunu izlemek neden önemli?
3. `enPahali` 0 yerine listenin ilk elemanıyla başlasaydı hangi girdi düzelirdi?
4. "Önce değişmez tanımla" neden iyi bir varsayılan kuraldır?

## Uygulama alıştırmaları

### Kavrama

Atama ile matematiksel eşitliğin farkını, yazılım dışından bir örnekle anlat.

### Uygulama

Bir sayı listesindeki **en küçük** değeri bulan pseudocode yaz. Sonra
`[5, 5, 5]` ve `[-3, -7]` girdileri için iz tablosu çıkar. Başlangıç değerini
neden öyle seçtiğini bir cümleyle açıkla.

### Analiz

Aşağıdaki kod ne yazar? Yazarın niyeti "iki değişkenin değerini takas etmek"
ise sorun nerede ve nasıl düzeltilir?

```text
a ← 1
b ← 2
a ← b
b ← a
ÇIKTI: a, b
```

## Küçük görev

Bir önceki dersin küçük görevinde yazdığın form alanlarını aç. Her alan için:

1. Bu değer oturum boyunca değişiyor mu, yoksa bir kez mi belirleniyor?
2. Değişmez olarak tanımlanabilecekleri işaretle.
3. Aynı anda değişen kaç değer var? Üçten fazlaysa hangilerini tek bir yapı
   altında toplayabilirdin?

## Özet

- Atama bir eşitlik iddiası değil, "oku, hesapla, yaz" sırasıyla çalışan bir
  işlemdir.
- Bir değişkenin değeri her zaman "hangi satırdayız" sorusuna bağlıdır; eski
  değerler saklanmaz.
- Varsayılan değişmezliktir; değişkenlik gerekçe ister, çünkü aynı anda değişen
  her değer okuma yükünü artırır.

## Sonraki ders

- [Koşullu ifadeler](./03-conditionals.md)

## Kaynaklar

- [How to Design Programs](https://htdp.org/)
- [Structure and Interpretation of Computer Programs](https://sarabander.github.io/sicp/html/)
