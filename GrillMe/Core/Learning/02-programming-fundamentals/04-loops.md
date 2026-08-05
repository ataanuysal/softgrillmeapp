---
id: programming-fundamentals-04
course: software-engineering-fundamentals
module: programming-fundamentals
moduleOrder: 2
lessonOrder: 4
section: fundamentals
title: Döngüler
description: Tekrarın nasıl kurulduğunu, döngünün neden durduğunu ve birikim değişkeninin her turda nasıl değiştiğini anlatır.
difficulty: beginner
estimatedMinutes: 25
prerequisites:
  - programming-fundamentals-03
relatedCodeLessons:
  - loops
  - arrays-index
objectives:
  - Bir döngünün her turunda neyin değiştiğini izlemek
  - Döngünün durma sebebini kanıtlamak
  - Sayaçlı ve koleksiyon üzerinde gezen döngüyü ayırmak
status: published
version: 1
---

# Döngüler

## Dersin amacı

Aynı işi elle yüz kez yazmak yerine bir kez yazıp tekrarlatmak — döngünün
tamamı budur. Zor olan kısım tekrar değil, **her turda neyin değiştiğini** ve
**ne zaman duracağını** görebilmektir.

## Ön koşullar

- [Koşullu ifadeler](./03-conditionals.md)

## Kazanımlar

Bu dersin sonunda:

- Bir döngünün her turundaki değerleri tabloya dökebilirsin.
- Döngünün duracağını gösterebilirsin.
- Sayaçlı döngü ile koleksiyon gezmeyi ayırt edebilirsin.
- Bir tur fazla veya eksik dönen döngüyü teşhis edebilirsin.

## Temel kavramlar

| Terim | İngilizce | Kısa tanım |
| --- | --- | --- |
| Döngü | loop | Bir adım kümesini tekrar tekrar işleme |
| Tur | iteration | Döngünün bir kez çalışması |
| Sayaç | counter | Turları sayan değişken |
| Birikim | accumulator | Turlar boyunca sonucu biriktiren değişken |
| Durma koşulu | termination condition | Döngünün biteceği durum |
| Bir fazla hata | off-by-one error | Bir tur fazla ya da eksik dönme |

## Kavramsal açıklama

### Her döngünün üç parçası vardır

```text
sayac ← 1                 // 1. başlangıç
TEKRARLA sayac <= 3 İKEN  // 2. devam koşulu
  ÇIKTI: sayac
  sayac ← sayac + 1       // 3. ilerleme
```

Üçünden biri eksikse döngü ya hiç çalışmaz ya hiç durmaz. En sık unutulan
üçüncüsüdür: koşulu yanlış yapacak olan şey döngünün **içinde** değişmelidir.

### Birikim değişkeni turlar arasında yaşar

```text
toplam ← 0
HER s İÇİN sayilar İÇİNDE
  toplam ← toplam + s
```

`toplam` döngünün dışında tanımlanır çünkü turlar arasında hatırlanması
gerekir. İçeride tanımlansaydı her turda sıfırlanır ve sonuç son elemana eşit
olurdu — çalışan ama yanlış bir program.

### İki döngü biçimi

| Biçim | Ne zaman |
| --- | --- |
| Koleksiyon üzerinde gez | Her elemanla bir şey yapacaksan |
| Sayaçlı | Konum (indis) gerekiyorsa ya da eleman yoksa |

Koleksiyon gezme daha güvenlidir çünkü sınırları kendisi bilir. Sayaçlı döngü
esnektir ama **bir fazla hatası** tam olarak orada doğar.

### Bir fazla hata

Bir listenin ilk elemanı çoğu dilde 0. sıradadır. Üç elemanlı listede geçerli
konumlar 0, 1, 2'dir — 3 yoktur.

```text
yanlış : sayac 0'dan liste.sayısı'na kadar   → son turda çöker
doğru  : sayac 0'dan liste.sayısı - 1'e kadar
```

Bu hatanın belirtisi genellikle "son elemanda çöküyor" ya da "son eleman
işlenmiyor"dur.

### Durmayı kanıtlamak

Döngüye bakıp şunu söyleyebilmelisin: *koşulu yanlış yapacak değer her turda
hedefe yaklaşıyor.*

```text
TEKRARLA kalan > 0 İKEN
  kalan ← kalan - 1     // her turda azalıyor → durur

TEKRARLA kalan > 0 İKEN
  ÇIKTI: kalan          // hiç değişmiyor → durmaz
```

> [!TIP]
> Sonsuz döngü şüphesi varsa, döngünün içinde durma koşulundaki değişkenin
> değiştiği satırı işaretle. İşaretleyecek satır bulamıyorsan hatan orada.

## Gerçek hayattan benzetme

Bir merdiveni çıkmak. Her basamakta aynı hareketi yaparsın (tur), kaçıncı
basamakta olduğunu bilirsin (sayaç) ve yorgunluğun birikir (birikim). Merdiven
biterse durursun (durma koşulu).

Basamak saymayı bilmiyorsan ya son basamakta boşluğa adım atarsın ya bir
basamak eksik çıkarsın — bir fazla hatasının günlük hâli.

## Pseudocode örneği

```text
GİRDİ : puanlar listesi
ÇIKTI : geçen sayısı ve ortalama

sinifOzeti(puanlar)
  EĞER puanlar boş İSE
    DÖNDÜR 0, tanımsız

  toplam ← 0
  gecen  ← 0

  HER p İÇİN puanlar İÇİNDE
    toplam ← toplam + p
    EĞER p >= 50 İSE
      gecen ← gecen + 1

  DÖNDÜR gecen, toplam / puanlar.sayısı
```

## Adım adım çalışma modeli

`puanlar = [80, 30, 55]` için:

| Tur | p | `p >= 50` | toplam | gecen |
| --- | --- | --- | --- | --- |
| 0 | — | — | 0 | 0 |
| 1 | 80 | doğru | 80 | 1 |
| 2 | 30 | yanlış | 110 | 1 |
| 3 | 55 | doğru | 165 | 2 |
| son | — | — | **165** | **2** |

`toplam` her turda değişti, `gecen` yalnızca iki turda. İki değişkenin farklı
ritimde değişmesi normaldir; izlerken ikisini ayrı sütunda tutmak bu yüzden
gerekir.

Ortalama: `165 / 3 = 55`. Boş liste kontrolü olmasaydı bu bölme sıfıra bölme
olurdu.

## Yaygın yanlış anlamalar

> [!WARNING]
> **"Birikim değişkenini döngünün içinde tanımlayabilirim."** Tanımlarsan her
> turda sıfırlanır. Turlar arasında yaşaması gereken her değer döngünün
> dışında tanımlanır.

> [!WARNING]
> **"Döngü nasılsa biter."** Bitmesini sağlayan şey, durma koşulundaki değerin
> döngü içinde değişmesidir. Değişmiyorsa program donar.

> [!WARNING]
> **"Liste üç elemanlıysa son indis 3'tür."** Çoğu dilde 2'dir. Bu tek karakter
> farkı, çalışan kod ile çöken kod arasındaki farktır.

## Kontrol soruları

1. Bir döngünün üç parçası nedir? Biri eksik olursa ne olur?
2. `toplam` neden döngünün dışında tanımlanıyor?
3. Yukarıdaki tabloda `gecen` neden 2. turda değişmedi?
4. Bir döngünün duracağını nasıl kanıtlarsın?

## Uygulama alıştırmaları

### Kavrama

"Bir fazla hatası"nı, yazılım dışından bir sayma örneğiyle anlat.

### Uygulama

Bir metindeki sesli harfleri sayan pseudocode yaz. Sonra `"merhaba"` girdisi
için tur tur iz tablosu çıkar. Boş metin girdisinde ne olduğunu da yaz.

### Analiz

Aşağıdaki döngü ne zaman durur? Durmuyorsa neden ve nasıl düzeltilir?

```text
kalan ← 10
TEKRARLA kalan != 0 İKEN
  kalan ← kalan - 3
  ÇIKTI: kalan
```

## Küçük görev

[Algoritma yazmak](../01-computational-thinking/04-algorithms-and-pseudocode.md)
dersinde yazdığın döngülü çözümleri aç. Her biri için:

1. Üç parçayı (başlangıç, koşul, ilerleme) işaretle.
2. Durma kanıtını bir cümleyle yaz.
3. Boş girdi ve tek elemanlı girdi için ne olduğunu tabloya dök.

## Özet

- Her döngü üç parçadan oluşur: başlangıç, devam koşulu ve ilerleme; ilerleme
  eksikse döngü durmaz.
- Turlar arasında hatırlanması gereken değerler döngünün dışında tanımlanır.
- Sayaçlı döngülerde bir fazla hatası kaçınılmaz bir risktir; koleksiyon
  üzerinde gezmek sınırları kendisi bildiği için daha güvenlidir.

## Sonraki ders

- [Fonksiyonlar ve sözleşmeler](./05-functions-and-contracts.md)

## Kaynaklar

- [How to Design Programs](https://htdp.org/)
- [Structure and Interpretation of Computer Programs](https://sarabander.github.io/sicp/html/)
