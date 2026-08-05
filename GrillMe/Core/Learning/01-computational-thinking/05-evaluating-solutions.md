---
id: computational-thinking-05
course: software-engineering-fundamentals
module: computational-thinking
moduleOrder: 1
lessonOrder: 5
section: fundamentals
title: Çözümü sınamak
description: Bir algoritmanın doğru olup olmadığını uç durumlarla sınamayı ve iki çözümü karşılaştırmayı öğretir.
difficulty: beginner
estimatedMinutes: 25
prerequisites:
  - computational-thinking-04
objectives:
  - Bir çözümün doğruluğunu uç durumlarla sınamak
  - Yanlışlayan bir örnek üretmek
  - İki çözümü iş miktarına göre karşılaştırmak
relatedCodeLessons:
  - edge-cases
  - boundary-testing
status: published
version: 1
---

# Çözümü sınamak

## Dersin amacı

Bir algoritma yazdın. Peki doğru mu? Bu soruya "bana doğru göründü" diye cevap
verilmez. Bu ders, bir çözümü sınamanın iki yolunu öğretir: onu yanlışlayacak
bir örnek aramak ve yaptığı iş miktarını ölçmek.

## Ön koşullar

- [Algoritma yazmak](./04-algorithms-and-pseudocode.md)

## Kazanımlar

Bu dersin sonunda:

- Bir çözümü uç durumlarla sınayabilirsin.
- Bir algoritmayı yanlışlayan örnek üretebilirsin.
- İki çözümü, hızlarını ölçmeden karşılaştırabilirsin.
- "Çalışıyor" ile "doğru" arasındaki farkı bilirsin.

## Temel kavramlar

| Terim | İngilizce | Kısa tanım |
| --- | --- | --- |
| Doğruluk | correctness | Her geçerli girdi için beklenen çıktıyı üretme |
| Uç durum | edge case | Sınırda kalan, ender ama geçerli girdi |
| Karşı örnek | counterexample | Çözümün yanlış olduğunu gösteren tek girdi |
| Değişmez | invariant | Algoritma boyunca hep doğru kalan ifade |
| İş miktarı | work / cost | Girdi büyüdükçe yapılan adım sayısı |
| Ölçekleme | scaling | İş miktarının girdiyle birlikte nasıl büyüdüğü |

## Kavramsal açıklama

### "Çalıştı" bir kanıt değildir

Bir algoritmayı bir girdiyle deneyip doğru sonuç almak, onun doğru olduğunu
göstermez; yalnızca **o girdi için** yanlış olmadığını gösterir. Doğruluk
iddiası bütün geçerli girdileri kapsar.

Bu yüzden sınama, doğrulamayı değil **yanlışlamayı** hedefler: çözümü kıracak
bir girdi arayarak başlarsın. Bulamazsan güvenin artar; bulursan bir hata
yakalamış olursun. İkisi de kazançtır.

### Uç durumları nereden bulacaksın

Uç durumlar rastgele aranmaz; belirli yerlerde birikirler:

| Nerede | Örnek |
| --- | --- |
| Boşluk | Boş liste, boş metin |
| Tek eleman | Tek elemanlı liste |
| Sınır değeri | Tam olarak eşik değerine eşit girdi |
| Tekrar | Aynı değerden birden çok |
| İşaret | Negatif sayı, sıfır |
| Sıra | Zaten sıralı, tersten sıralı |
| Aşırılık | Çok büyük girdi |

Yazdığın her algoritma için bu listeyi tek tek geç. Çoğu hata ilk üç satırda
çıkar.

### Karşı örnek üretmek

Bir çözümün yanlış olduğunu göstermek için tek bir girdi yeter:

```text
İddia    : "en_büyüğü_bul, en_büyük ← 0 ile başlarsa da doğru çalışır"
Karşı örnek : [-5, -2, -9]
Beklenen : -2
Üretilen : 0
```

Tek satırlık bir girdi, tüm iddiayı çürüttü. Bu, yazılımda en ucuz kanıt
biçimidir.

### Değişmez: her adımda doğru kalan şey

Bir döngünün neden doğru çalıştığını anlatmanın en berrak yolu, döngü boyunca
hep doğru kalan bir cümle bulmaktır:

```text
en_büyüğü_bul için değişmez:
  "Her turun sonunda en_büyük, o ana kadar bakılan
   elemanların en büyüğüdür."
```

Bu cümle başlangıçta doğruysa ve her tur onu bozmuyorsa, döngü bittiğinde de
doğrudur — ve döngü bittiğinde "bakılanlar" tüm listedir. Böylece sonuç
doğrudur. Bu, tek tek girdi denemekten daha güçlü bir argümandır.

### İş miktarı: aynı sonuç, farklı maliyet

İki çözüm de doğru olabilir ama aynı işi yapmayabilir. Ölçüyü saniyeyle değil,
**adım sayısıyla** koyarız; çünkü saniye makineye göre değişir, adım sayısı
değişmez.

Bir listede belirli bir değeri aramanın iki yolu:

| Yöntem | Ön koşul | 1.000 elemanda kaba adım |
| --- | --- | --- |
| Baştan sona gez | Yok | En kötü 1.000 |
| İkiye bölerek ara | Liste sıralı olmalı | En kötü ~10 |

İkincisi çok daha az iş yapar ama bir bedeli vardır: liste sıralı olmalıdır.
Bu, yazılımdaki en yaygın alışveriştir — kazanç bedava gelmez.

> [!NOTE]
> Bu derste ölçekleme kabaca ele alınıyor. Sıkı tanımı ve gösterimi (Büyük O)
> 04 · Veri Yapıları ve Algoritmalar modülünde işlenecek.

## Gerçek hayattan benzetme

Bir kilidi test etmeyi düşün. "Anahtarımla açılıyor" bilgisi kilidin iyi
olduğunu göstermez. Kilidin ne kadar iyi olduğunu, onu **açmaya çalışan** biri
gösterir.

Sözlükte kelime aramak da aynı ikiliktir: sayfaları tek tek çevirmek her zaman
çalışır ama yavaştır; ortadan açıp yön seçmek çok daha hızlıdır — ama yalnızca
sözlük sıralı olduğu için.

## Pseudocode örneği

Sınanacak çözüm:

```text
ikinci_en_büyük(sayılar)
  en_büyük  ← sayılar[0]
  ikinci    ← sayılar[1]
  HER s İÇİN sayılar İÇİNDE
    EĞER s > en_büyük İSE
      ikinci   ← en_büyük
      en_büyük ← s
  DÖNDÜR ikinci
```

Şimdi kırmaya çalış:

| Girdi | Beklenen | Üretilen | Sonuç |
| --- | --- | --- | --- |
| `[3, 1, 5]` | 3 | 3 | geçti |
| `[1, 9]` | 1 | 1 | geçti |
| `[9, 1]` | 1 | 9 | **kırıldı** |
| `[5]` | tanımsız | çöker | **kırıldı** |
| `[2, 7, 6]` | 6 | 2 | **kırıldı** |

Üç kusur çıktı: başlangıç değerleri sıraya bağlı, tek elemanlı liste ele
alınmamış ve "en büyüğü geçmeyen ama ikinciden büyük" değerler hiç
değerlendirilmiyor. Düzeltilmiş hâli:

```text
ikinci_en_büyük(sayılar)
  EĞER sayılar.sayısı < 2 İSE
    DÖNDÜR tanımsız

  en_büyük ← eksi_sonsuz
  ikinci   ← eksi_sonsuz

  HER s İÇİN sayılar İÇİNDE
    EĞER s > en_büyük İSE
      ikinci   ← en_büyük
      en_büyük ← s
    DEĞİLSE EĞER s > ikinci VE s < en_büyük İSE
      ikinci ← s

  EĞER ikinci = eksi_sonsuz İSE
    DÖNDÜR tanımsız        // bütün elemanlar eşit
  DÖNDÜR ikinci
```

## Adım adım çalışma modeli

Düzeltilmiş çözümün `[2, 7, 6]` üzerindeki izi:

| Adım | s | Hangi dal | en_büyük | ikinci |
| --- | --- | --- | --- | --- |
| 0 | — | başlangıç | −∞ | −∞ |
| 1 | 2 | 2 > −∞ → birinci dal | 2 | −∞ |
| 2 | 7 | 7 > 2 → birinci dal | 7 | 2 |
| 3 | 6 | 6 > 7 değil; 6 > 2 ve 6 < 7 → ikinci dal | 7 | 6 |
| 4 | — | döndür | 7 | **6** |

3. adım, ilk sürümde hiç var olmayan daldı; kusur tam olarak oradaydı.

## Yaygın yanlış anlamalar

> [!WARNING]
> **"Birkaç örnekte çalışıyorsa doğrudur."** Örnekler doğruluğu kanıtlamaz,
> yalnızca yanlışlığı gösterebilir. Güven, kırmaya çalışıp kıramamaktan gelir.

> [!WARNING]
> **"Hızlı olan her zaman daha iyidir."** Daha az iş yapan çözümün genellikle
> bir ön koşulu (sıralılık, ek bellek, hazırlık maliyeti) vardır. Küçük
> girdilerde basit çözüm çoğu zaman daha iyidir.

> [!WARNING]
> **"Uç durumlar ender, sonra bakarım."** Boş liste ve tek eleman ender
> değildir; gerçek kullanımda ilk gün karşına çıkarlar.

## Kontrol soruları

1. Neden sınama, doğrulamayı değil yanlışlamayı hedefler?
2. `ikinci_en_büyük` ilk sürümünde `[9, 1]` girdisi neden yanlış sonuç verdi?
3. Bir döngü değişmezinin, tek tek girdi denemekten güçlü olmasının sebebi
   nedir?
4. İkiye bölerek arama neden her listede kullanılamaz?

## Uygulama alıştırmaları

### Kavrama

"Karşı örnek" kavramını, yazılım dışından bir iddia ve onu çürüten tek bir
örnekle anlat.

### Uygulama

Aşağıdaki çözüm için en az beş uç durum yaz ve her biri için beklenen çıktıyı
belirt. En az birinin çözümü kırdığını göster.

```text
ortalama(sayılar)
  toplam ← 0
  HER s İÇİN sayılar İÇİNDE
    toplam ← toplam + s
  DÖNDÜR toplam / sayılar.sayısı
```

### Analiz

İki geliştirici aynı işi yapan iki çözüm yazmış:

- **A:** Listeyi her sorguda baştan sona gezip arıyor.
- **B:** Listeyi bir kez sıralayıp her sorguda ikiye bölerek arıyor.

Hangi durumda A, B'den daha iyidir? Cevabında sorgu sayısını ve sıralama
maliyetini birlikte değerlendir.

## Küçük görev

[Algoritma yazmak](./04-algorithms-and-pseudocode.md) dersinin uygulama
alıştırmasında yazdığın üç pseudocode'u aç. Her biri için:

1. Yukarıdaki uç durum tablosunu satır satır uygula.
2. Kıran bir girdi bulursan düzelt.
3. Döngüsü olan her çözüm için bir değişmez cümlesi yaz.

## Özet

- Bir çözümün doğruluğu deneyerek kanıtlanmaz; sınama, onu kıracak girdiyi
  aramaktır.
- Uç durumlar rastgele değildir: boşluk, tek eleman, sınır, tekrar, işaret ve
  sıra başlıklarında birikirler.
- İki doğru çözüm aynı işi yapmayabilir; karşılaştırma saniyeyle değil, girdi
  büyüdükçe artan adım sayısıyla yapılır.

## Sonraki ders

- Bu modülün son dersiydi. [Modül değerlendirmesine](./README.md) dön.

## Kaynaklar

- [How to Design Programs](https://htdp.org/)
- [Teach Yourself Computer Science](https://teachyourselfcs.com/)
