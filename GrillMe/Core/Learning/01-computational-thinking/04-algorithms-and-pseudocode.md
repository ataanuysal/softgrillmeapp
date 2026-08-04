---
id: computational-thinking-04
course: software-engineering-fundamentals
module: computational-thinking
moduleOrder: 1
lessonOrder: 4
section: fundamentals
title: Algoritma yazmak
description: Belirsizlik içermeyen, sonlu ve izlenebilir adım listeleri yazmayı ve pseudocode'un üç temel yapısını öğretir.
difficulty: beginner
estimatedMinutes: 25
prerequisites:
  - computational-thinking-03
objectives:
  - Bir algoritmanın taşıması gereken dört özelliği uygulamak
  - Sıra, karar ve tekrar yapılarıyla pseudocode yazmak
  - Bir algoritmayı elle adım adım izlemek
status: published
version: 1
---

# Algoritma yazmak

## Dersin amacı

Önceki üç derste problemi parçaladın, tekrarı gördün, ayrıntıyı yerine
koydun. Şimdi sıra bunları **yürütülebilir bir adım listesine** çevirmekte. Bu
ders, bir algoritmanın ne zaman "yazılmış" sayıldığını ve pseudocode'un üç
temel yapısını anlatır.

## Ön koşullar

- [Soyutlama](./03-abstraction.md)

## Kazanımlar

Bu dersin sonunda:

- Bir algoritmanın taşıması gereken dört özelliği sayabilirsin.
- Sıra, karar ve tekrar yapılarını kullanarak pseudocode yazabilirsin.
- Bir algoritmayı elle izleyip her adımdaki değerleri söyleyebilirsin.
- Belirsiz bir adımı fark edip netleştirebilirsin.

## Temel kavramlar

| Terim | İngilizce | Kısa tanım |
| --- | --- | --- |
| Algoritma | algorithm | Bir problemi çözen, adımları belirli ve sonlu yöntem |
| Sıra | sequence | Adımların birbiri ardına işlenmesi |
| Karar | selection | Bir koşula göre farklı yola sapma |
| Tekrar | iteration | Bir adım kümesinin birden çok kez işlenmesi |
| Değişken | variable | Değeri saklayan ve değişebilen isimli yer |
| İz sürme | tracing | Algoritmayı elle, adım adım çalıştırma |
| Sonlanma | termination | Algoritmanın er ya da geç durması |

## Kavramsal açıklama

### Bir algoritmanın dört özelliği

1. **Belirli:** Her adım tek bir anlama gelir. "Uygun bir değer seç" belirli
   değildir; "listedeki en küçük değeri seç" belirlidir.
2. **Sonlu:** Er ya da geç durur. Durmayan bir adım listesi algoritma değildir.
3. **Girdi ve çıktısı tanımlı:** Neyle başladığı ve neyle bittiği bellidir.
4. **Etkili:** Her adım, uygulayan tarafından gerçekten yapılabilir.

Bu dördü sağlanmadıysa elindeki şey bir algoritma değil, bir niyet
açıklamasıdır.

### Üç yapı yeter

Şaşırtıcı ama doğru: her algoritma yalnızca üç yapı ile yazılabilir.

**Sıra** — adımlar art arda işlenir:

```text
kutu ← 5
kutu ← kutu + 3
ÇIKTI: kutu        // 8
```

**Karar** — koşula göre yol ayrılır:

```text
EĞER not >= 50 İSE
  ÇIKTI: "geçti"
DEĞİLSE
  ÇIKTI: "kaldı"
```

**Tekrar** — bir küme adım birden çok kez işlenir:

```text
sayaç ← 1
TEKRARLA sayaç <= 3 İKEN
  ÇIKTI: sayaç
  sayaç ← sayaç + 1
```

Bunlardan hangisinin ne zaman kullanılacağını bilmek, bir dilin sözdizimini
bilmekten çok daha değerlidir; çünkü üç yapı da her dilde vardır.

### Değişken bir kutudur

Değişken, içine değer koyduğun isimli bir yerdir. İki işlem yapılır: değer
koymak (`←`) ve değeri okumak.

```text
toplam ← 0        // kutuya 0 kondu
toplam ← toplam + 5
// sağ taraf önce okunur (0), 5 eklenir (5), sonra kutuya yazılır
```

Son satır matematiksel bir eşitlik değildir; "önce oku, hesapla, sonra yaz"
sırasıdır. Bu sıra kavranmadan hiçbir döngü doğru okunamaz.

### Tekrarın durması tesadüf değildir

Her tekrarın bir **durma sebebi** olmalıdır ve bu sebep, tekrarın içinde
gerçekten oluşmalıdır:

```text
sayaç ← 1
TEKRARLA sayaç <= 3 İKEN
  ÇIKTI: sayaç
  // sayaç hiç artmıyor → bu döngü asla durmaz
```

Bir tekrar yazdığında kendine tek bir soru sor: *koşulu yanlış yapacak olan
şey, döngünün içinde değişiyor mu?*

### Belirsizliği yok et

Pseudocode "yaklaşık anlatım" değildir. Aşağıdaki iki satırın ikisi de Türkçe
ama yalnızca biri algoritmadır:

```text
belirsiz : Listeyi düzgün bir şekilde sırala
belirli  : Liste bitene kadar: yan yana iki elemanı karşılaştır,
           soldaki büyükse yerlerini değiştir
```

> [!TIP]
> Testi basit: yazdıklarını, konuyu hiç bilmeyen birine ver. Sonucu senin
> beklediğin gibi üretebiliyorsa algoritma yazmışsındır.

## Gerçek hayattan benzetme

Bir yol tarifi düşün.

- "Şehir merkezine git" — belirsiz.
- "Düz git, üçüncü ışıktan sağa dön, 200 metre sonra soldaki bina" — belirli.

Tarifte de üç yapı vardır: sırayla ilerlersin (sıra), "ışık kırmızıysa bekle"
(karar), "tabelayı görene kadar devam et" (tekrar). Ve tarifin bir sonlanma
koşulu vardır: tabelayı görürsün. Görmeyeceğin bir tabelaya kadar yürümen
söylenirse tarif hatalıdır.

## Pseudocode örneği

Problem: **Bir sayı listesindeki en büyük değeri bul.**

```text
GİRDİ : sayılar (en az bir eleman)
ÇIKTI : listedeki en büyük değer

en_büyüğü_bul(sayılar)
  EĞER sayılar boş İSE
    DÖNDÜR tanımsız

  en_büyük ← sayılar[0]

  HER s İÇİN sayılar[1..son] İÇİNDE
    EĞER s > en_büyük İSE
      en_büyük ← s

  DÖNDÜR en_büyük
```

Üç yapının hepsi burada: sıra (satırlar art arda), karar (`EĞER`), tekrar
(`HER … İÇİN`). Ayrıca boş liste için ne yapılacağı açıkça yazılmış — bu
"belirli olma" şartının gereğidir.

## Adım adım çalışma modeli

`en_büyüğü_bul([3, 9, 4, 9, 1])` izi:

| Adım | Bakılan (s) | Karşılaştırma | en_büyük |
| --- | --- | --- | --- |
| 0 | — | başlangıç: ilk eleman alındı | 3 |
| 1 | 9 | 9 > 3 → doğru | 9 |
| 2 | 4 | 4 > 9 → yanlış | 9 |
| 3 | 9 | 9 > 9 → yanlış | 9 |
| 4 | 1 | 1 > 9 → yanlış | 9 |
| 5 | — | döndür | 9 |

Üç gözlem:

1. **3. adım hiçbir şey değiştirmedi.** `>` yerine `>=` yazsaydık sonuç yine 9
   olurdu — ama "ilk mi son mu bulunan alınır" sorusunun cevabı değişirdi. Eşit
   değerlerde hangisinin seçildiği önemliyse, bu tercih bilinçli olmalıdır.
2. **Başlangıç değeri 0 olsaydı**, tüm sayılar negatif olan bir listede sonuç
   yanlış çıkardı. Bu yüzden ilk eleman seçildi.
3. **Boş liste kontrolü olmasaydı**, `sayılar[0]` satırı çalışamazdı.

## Yaygın yanlış anlamalar

> [!WARNING]
> **"Pseudocode gevşek yazılabilir, nasıl olsa insan okuyacak."** Pseudocode'un
> amacı dil ayrıntısından kurtulmaktır, belirsizlikten değil. "Gerekeni yap"
> yazan bir adım, kod yazma aşamasında karar vermeni erteler ve orada hata
> üretir.

> [!WARNING]
> **"`toplam ← toplam + 5` bir denklemdir."** Değildir. Sağ taraf okunur, sonuç
> hesaplanır, sonra sol tarafa yazılır. Matematikteki eşitlikten farkı budur.

> [!WARNING]
> **"Döngü nasılsa durur."** Durmasını sağlayan şey döngünün içinde değişen bir
> değerdir. Değişmiyorsa durmaz.

## Kontrol soruları

1. Bir algoritmanın dört özelliği nedir? Her biri için, o özelliği sağlamayan
   bir örnek ver.
2. `en_büyüğü_bul` fonksiyonunda `en_büyük` neden 0 ile değil, ilk elemanla
   başlatılıyor?
3. Bir tekrarın sonlanacağından nasıl emin olursun?
4. `EĞER s > en_büyük` yerine `EĞER s >= en_büyük` yazılsaydı hangi durum
   değişirdi, hangisi değişmezdi?

## Uygulama alıştırmaları

### Kavrama

"Belirli adım" kavramını, bir yemek tarifinden belirsiz bir adım ve onun
düzeltilmiş hâlini vererek anlat.

### Uygulama

Aşağıdaki üç problemi pseudocode olarak yaz. Her birinde girdi ve çıktıyı
ayrıca belirt, uç durumları ele al:

1. Bir listedeki çift sayıların toplamını bul.
2. Bir metnin tersten yazılışını üret.
3. İki listeyi karşılaştır ve yalnızca ikisinde de bulunan elemanları döndür.

### Analiz

Aşağıdaki algoritma her zaman doğru çalışır mı? Çalışmadığı bir girdi bul ve
düzelt.

```text
ortalama_üstü_sayı(sayılar)
  toplam ← 0
  HER s İÇİN sayılar İÇİNDE
    toplam ← toplam + s
  ortalama ← toplam / sayılar.sayısı

  sayaç ← 0
  HER s İÇİN sayılar İÇİNDE
    EĞER s > ortalama İSE
      sayaç ← sayaç + 1
  DÖNDÜR sayaç
```

## Küçük görev

**Bir algoritmayı elle izle.** Aşağıdaki pseudocode için, `[5, 2, 8, 1]`
girdisiyle bir iz tablosu çıkar. Tabloda her adımda `i`, `j` ve listenin
durumunu göster.

```text
sırala(liste)
  HER i İÇİN 0'dan liste.sayısı-2'ye
    HER j İÇİN 0'dan liste.sayısı-2-i'ye
      EĞER liste[j] > liste[j+1] İSE
        yer_değiştir(liste[j], liste[j+1])
  DÖNDÜR liste
```

Tabloyu çıkardıktan sonra şu soruyu cevapla: liste zaten sıralıysa bu
algoritma kaç karşılaştırma yapar? Bu bir sorun mu?

## Özet

- Algoritma; belirli, sonlu, girdi–çıktısı tanımlı ve gerçekten yapılabilir
  adımlardan oluşur.
- Her algoritma sıra, karar ve tekrar olmak üzere üç yapıyla yazılabilir; bu
  üçü her dilde aynıdır.
- Bir algoritmanın doğruluğu, elle izlenerek ve uç durumlar denenerek
  görülür — okunarak değil.

## Sonraki ders

- [Çözümü sınamak](./05-evaluating-solutions.md)

## Kaynaklar

- [How to Design Programs](https://htdp.org/)
- [Structure and Interpretation of Computer Programs](https://sarabander.github.io/sicp/html/)
