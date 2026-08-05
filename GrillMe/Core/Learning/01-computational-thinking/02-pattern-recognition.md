---
id: computational-thinking-02
course: software-engineering-fundamentals
module: computational-thinking
moduleOrder: 1
lessonOrder: 2
section: fundamentals
title: Örüntü tanıma
description: Alt problemler arasındaki tekrarı fark etmeyi, tekrarı tek bir çözüme indirgemeyi ve yanlış örüntüden kaçınmayı öğretir.
difficulty: beginner
estimatedMinutes: 20
prerequisites:
  - computational-thinking-01
objectives:
  - Alt problemler arasındaki gerçek tekrarı fark etmek
  - Değişen kısmı değişmeyen kısımdan ayırmak
  - Yüzeysel benzerliği gerçek örüntüden ayırt etmek
relatedCodeLessons:
  - loops
  - map-intro
status: published
version: 1
---

# Örüntü tanıma

## Dersin amacı

Bir problemi parçalara ayırdığında, parçaların birbirine benzediğini fark
edersin. Bu benzerlikleri görmek — **örüntü tanıma** (pattern recognition) —
aynı işi tekrar tekrar çözmeni engeller. Bu ders, gerçek tekrarı yüzeysel
benzerlikten ayırmayı öğretir; çünkü yanlış görülen bir örüntü, tekrardan daha
pahalıya mal olur.

## Ön koşullar

- [Problemi parçalara ayırmak](./01-decomposition.md)

## Kazanımlar

Bu dersin sonunda:

- Alt problemler arasındaki gerçek tekrarı fark edebilirsin.
- Tekrarı tek bir çözüme indirgeyebilirsin.
- Değişen kısmı, değişmeyen kısımdan ayırabilirsin.
- Yüzeysel benzerliği gerçek örüntüden ayırt edebilirsin.

## Temel kavramlar

| Terim | İngilizce | Kısa tanım |
| --- | --- | --- |
| Örüntü | pattern | Farklı yerlerde tekrar eden yapı |
| Genelleme | generalization | Birden çok durumu tek bir çözümle karşılama |
| Parametre | parameter | Çözümün, çağrıldığı yere göre değişen kısmı |
| Değişmez kısım | invariant | Her durumda aynı kalan yapı |
| Yanlış örüntü | false pattern | Benzer görünen ama aynı olmayan durumlar |

## Kavramsal açıklama

### Tekrarı görmek

Şu üç işi düşün:

```text
A) Öğrenci notlarının ortalamasını al
B) Ürün fiyatlarının ortalamasını al
C) Günlük sıcaklıkların ortalamasını al
```

Üçü farklı problem gibi görünür ama yapıları aynıdır: bir sayı listesi al,
hepsini topla, sayıya böl. Farklı olan tek şey **listedeki sayıların ne
anlama geldiğidir** ve bu, hesap için önemsizdir.

Örüntüyü görmek şu soruyla başlar: *bu iki işi yan yana yazsam, aralarındaki
tek fark ne olurdu?*

### Değişen ile değişmeyeni ayır

Örüntü tanımanın asıl işi budur. Bir tekrarı çözüme dönüştürmek için önce
hangi kısmın sabit, hangisinin değişken olduğunu belirlemelisin:

```text
Değişmeyen : listeyi baştan sona gez, bir birikim değeri tut, sonucu döndür
Değişen    : hangi liste, birikime ne yapılacağı
```

Değişen kısımlar **parametre** olur. Bu, "bir işi bir kez çöz, farklı
girdilerle tekrar tekrar kullan" fikrinin temelidir.

### Aynı yapı, farklı iş

Aynı gezinme yapısı, birikime yapılan işlem değiştirilerek bambaşka sonuçlar
verir:

| Amaç | Başlangıç | Her adımda yapılan |
| --- | --- | --- |
| Toplam | 0 | `birikim ← birikim + eleman` |
| Sayma | 0 | `birikim ← birikim + 1` |
| En büyük | ilk eleman | `EĞER eleman > birikim İSE birikim ← eleman` |
| Birleştirme | boş metin | `birikim ← birikim + eleman` |

Dört farklı iş, tek bir örüntü. Bunu bir kez gördüğünde, "listeyi gez ve bir
şey biriktir" şeklindeki her problemi tanıdık bulursun.

### Yanlış örüntü tehlikelidir

İki şeyin benzer görünmesi, aynı olduğu anlamına gelmez. Klasik örnek:

```text
A) Kullanıcının doğum tarihinden yaşını hesapla
B) Ürünün üretim tarihinden kaç yıllık olduğunu hesapla
```

Bugün ikisi de "iki tarih arasındaki yıl farkı"dır. Ama A'da yaş, doğum günü
geçmediyse bir eksiktir; B'de ise böyle bir kural yoktur. Bunları tek bir
çözüme bağlarsan, ilerideki her kural değişikliği iki tarafı birden bozar.

> [!TIP]
> Ölçüt şu: iki durum bugün aynı olduğu için değil, **her zaman aynı kalacağı
> için** birleştirilmelidir. Değişme sebepleri farklıysa, kod benzerliği
> tesadüftür.

### Ne zaman birleştirmeli

Pratik bir yaklaşım: bir yapıyı ikinci kez yazdığında not al, üçüncü kez
yazdığında birleştir. İki örnek, hangi kısmın gerçekten değişken olduğunu
göstermeye çoğu zaman yetmez; üçüncüsü gösterir.

## Gerçek hayattan benzetme

Bir kafenin menüsünü düşün. Latte, cappuccino ve mocha farklı içeceklerdir ama
hazırlanışları aynı iskelete oturur: espresso çek, süt hazırla, birleştir,
sun. Değişen; süt miktarı, köpük oranı ve eklenen malzemedir.

Barista her içecek için ayrı bir yöntem ezberlemez; tek bir iskelet öğrenir ve
değişkenleri ayarlar. Ama **filtre kahve** bu iskelete girmez — espresso
kullanmaz. Onu zorla aynı yönteme sokmaya çalışmak, yanlış örüntüdür.

## Pseudocode örneği

Önce tekrar eden hâli:

```text
ortalama_not(notlar)
  toplam ← 0
  HER n İÇİN notlar İÇİNDE
    toplam ← toplam + n
  DÖNDÜR toplam / notlar.sayısı

ortalama_fiyat(fiyatlar)
  toplam ← 0
  HER f İÇİN fiyatlar İÇİNDE
    toplam ← toplam + f
  DÖNDÜR toplam / fiyatlar.sayısı
```

İki tanım arasındaki tek fark isimlerdir. Genellenmiş hâli:

```text
ortalama(sayılar)
  EĞER sayılar boş İSE
    DÖNDÜR tanımsız
  toplam ← 0
  HER s İÇİN sayılar İÇİNDE
    toplam ← toplam + s
  DÖNDÜR toplam / sayılar.sayısı
```

Bir adım daha ileri: birikimin nasıl yapılacağını da dışarıdan al.

```text
birikimle(liste, başlangıç, işlem)
  birikim ← başlangıç
  HER eleman İÇİN liste İÇİNDE
    birikim ← işlem(birikim, eleman)
  DÖNDÜR birikim

toplam    ← birikimle(sayılar, 0, (a, b) → a + b)
en_büyük  ← birikimle(sayılar, sayılar[0], (a, b) → EĞER b > a İSE b DEĞİLSE a)
```

İkinci hâl daha güçlüdür ama daha soyuttur. Hangisinin doğru olduğu, kaç farklı
birikim türüne ihtiyacın olduğuna bağlıdır — güç her zaman bedava değildir.

## Adım adım çalışma modeli

`birikimle([4, 9, 2], 0, toplama)` çağrısının izi:

| Adım | eleman | işlem | birikim |
| --- | --- | --- | --- |
| 0 | — | başlangıç atandı | 0 |
| 1 | 4 | 0 + 4 | 4 |
| 2 | 9 | 4 + 9 | 13 |
| 3 | 2 | 13 + 2 | 15 |
| 4 | — | döndür | 15 |

Aynı çağrı, `başlangıç = 4` ve işlem "büyüğü seç" olsaydı:

| Adım | eleman | işlem | birikim |
| --- | --- | --- | --- |
| 0 | — | başlangıç atandı | 4 |
| 1 | 4 | 4 > 4 değil | 4 |
| 2 | 9 | 9 > 4 | 9 |
| 3 | 2 | 2 > 9 değil | 9 |
| 4 | — | döndür | 9 |

İskelet aynı, sonuç bambaşka. Örüntünün gücü budur.

## Yaygın yanlış anlamalar

> [!WARNING]
> **"Benzeyen her kod birleştirilmelidir."** Hayır. Ölçüt görünüm değil,
> **değişme sebebidir**. Farklı sebeplerle değişecek iki kod, bugün aynı görünse
> bile ayrı kalmalıdır.

> [!WARNING]
> **"Genelleme her zaman iyidir."** Aşırı genelleştirilmiş bir çözüm, hiçbir
> durumu iyi karşılamayan ve okunması zor bir yapıya dönüşür. Elinde tek bir
> kullanım varken genelleme yapma.

> [!WARNING]
> **"Örüntüyü baştan tasarlarım."** Örüntüler genellikle keşfedilir, icat
> edilmez. Birkaç somut durumu yazmadan doğru soyutlamayı bulmak zordur.

## Kontrol soruları

1. Bir tekrarı çözüme dönüştürmek için önce neyi belirlemen gerekir?
2. İki kod parçasının birleştirilip birleştirilmeyeceğine hangi ölçütle karar
   verilir?
3. `birikimle` örneğinde `başlangıç` değeri neden dışarıdan alınıyor? Sabit 0
   olsaydı hangi kullanım bozulurdu?
4. Yanlış örüntü, tekrardan neden daha pahalıdır?

## Uygulama alıştırmaları

### Kavrama

"Değişen kısım" ile "değişmeyen kısım" ayrımını, yazılım dışından bir örnekle
anlat.

### Uygulama

Aşağıdaki üç işi tek bir genelleştirilmiş pseudocode ile yaz. Hangi kısımların
parametre olduğunu ayrıca belirt.

```text
A) Listedeki çift sayıları say
B) Listedeki 100'den büyük sayıları say
C) Listedeki boş olmayan metinleri say
```

### Analiz

Bir geliştirici şu iki işi tek bir çözüme bağlamış:

```text
A) Sipariş toplamına %20 KDV ekle
B) Çalışan maaşına %20 zam yap
```

Gerekçesi: "İkisi de bir sayıyı %20 artırıyor." Bu birleştirme neden risklidir?
Hangi değişiklik ikisini birden bozar? Nasıl ayırırdın?

## Küçük görev

Kullandığın bir uygulamada tekrar eden **üç** ekran veya davranış bul (örneğin
liste ekranları, form doğrulamaları, bildirim türleri). Her biri için:

1. Ortak iskeleti tek paragrafta anlat.
2. Değişen kısımları listele.
3. Bunlardan birinin aslında **yanlış örüntü** olup olmadığını tartış.

## Özet

- Örüntü tanıma, farklı problemlerdeki aynı yapıyı görmek ve tekrar tekrar aynı
  işi çözmemektir.
- İşin özü, değişen kısmı değişmeyenden ayırmak ve değişeni parametreye
  çevirmektir.
- Benzerlik tek başına yeterli değildir; birleştirme kararı, iki durumun aynı
  sebeple değişip değişmeyeceğine bakılarak verilir.

## Sonraki ders

- [Soyutlama](./03-abstraction.md)

## Kaynaklar

- [How to Design Programs](https://htdp.org/)
- [Structure and Interpretation of Computer Programs](https://sarabander.github.io/sicp/html/)
