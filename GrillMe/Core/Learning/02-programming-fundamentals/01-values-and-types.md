---
id: programming-fundamentals-01
course: software-engineering-fundamentals
module: programming-fundamentals
moduleOrder: 2
lessonOrder: 1
section: fundamentals
title: Değerler ve tipler
description: Bir değerin tipinin ne olduğunu, tipin hangi işlemlere izin verdiğini ve tip hatalarının neden erken yakalandığını anlatır.
difficulty: beginner
estimatedMinutes: 20
prerequisites:
  - computational-thinking-05
relatedCodeLessons:
  - variables
objectives:
  - Değer ile tipi birbirinden ayırmak
  - Tipin hangi işlemlere izin verdiğini okumak
  - Tip dönüşümünün neden bedava olmadığını açıklamak
status: published
version: 1
---

# Değerler ve tipler

## Dersin amacı

Bir programın işlediği her şey bir **değerdir**: sayı, metin, doğru/yanlış, bir
liste. Her değerin bir **tipi** vardır ve tip, o değerle ne yapabileceğini
belirler. Bu ders tipin ne olduğunu ve neden bir kısıt değil, bir güvence
olduğunu anlatır.

## Ön koşullar

- [Çözümü sınamak](../01-computational-thinking/05-evaluating-solutions.md)

## Kazanımlar

Bu dersin sonunda:

- Değer ile tipi ayırabilirsin.
- Bir tipin hangi işlemlere izin verdiğini söyleyebilirsin.
- Tip dönüşümünün ne zaman bilgi kaybettirdiğini bilirsin.
- Tip hatasının neden erken yakalanmasının iyi olduğunu açıklayabilirsin.

## Temel kavramlar

| Terim | İngilizce | Kısa tanım |
| --- | --- | --- |
| Değer | value | Programın işlediği tek bir veri parçası |
| Tip | type | Bir değerin ne olduğu ve nelere izin verdiği |
| Tam sayı | integer | Kesirsiz sayı |
| Ondalık | floating point | Kesirli sayı |
| Metin | string | Karakter dizisi |
| Mantıksal | boolean | Yalnızca doğru veya yanlış |
| Tip dönüşümü | type conversion | Bir değeri başka bir tipe çevirme |
| Tip hatası | type error | Tipin izin vermediği bir işlemi denemek |

## Kavramsal açıklama

### Tip, değerin kullanma kılavuzudur

`5` ile `"5"` ekranda aynı görünür ama aynı şey değildir. Birincisi bir sayıdır
ve toplanabilir; ikincisi iki karakterlik bir metindir ve birleştirilebilir.

```text
5 + 3        → 8        (toplama)
"5" + "3"    → "53"     (birleştirme)
5 + "3"      → tip hatası
```

Üçüncü satır bir kaza değil, kasıtlı bir korumadır: dil, ne demek istediğini
tahmin etmek yerine sana sorar.

### Tip hangi işlemlere izin verdiğini söyler

Bir tipi öğrenmek, "hangi harfle yazılıyor"u değil **hangi işlemleri
desteklediğini** öğrenmektir:

| Tip | Anlamlı işlemler | Anlamsız işlemler |
| --- | --- | --- |
| Tam sayı | topla, çıkar, karşılaştır | büyük harfe çevir |
| Metin | birleştir, uzunluk al, ara | böl (matematiksel) |
| Mantıksal | ve, veya, değil | topla |
| Liste | ekle, gez, say | çarp |

Bu tablo ezberlenmez; her tipe "bu değerle ne yapmak mantıklı" diye sorarak
üretilir.

### Tam sayı ile ondalık aynı şey değildir

```text
7 / 2   → 3      (iki tam sayının bölümü tam sayıdır; kalan atılır)
7.0 / 2 → 3.5    (biri ondalıksa sonuç ondalıktır)
```

İlk satır çoğu yeni başlayanın ilk sessiz hatasıdır: program çalışır, hata
vermez, yanlış sonuç üretir.

### Dönüşüm bedava değildir

Bir değeri başka tipe çevirmek üç sonuçtan birini verir:

1. **Kayıpsız:** tam sayıdan ondalığa (`3` → `3.0`)
2. **Kayıplı:** ondalıktan tam sayıya (`3.9` → `3`, kesir atılır)
3. **Başarısız:** metinden sayıya, metin sayı değilse (`"abc"` → tanımsız)

Üçüncü durum bir hata değil, **beklenen bir olasılıktır**. İyi yazılmış kod
dönüşümün başarısız olabileceğini varsayar.

> [!WARNING]
> `"12abc"` gibi girdiler dilden dile farklı davranır: kimi dil `12` üretir,
> kimi hata verir. Bu ders bunlardan hiçbirini "doğru" ilan etmez; kuralın dile
> göre değiştiğini bilmek yeterli.

### Erken hata, geç hatadan iyidir

Bazı diller tip uyuşmazlığını program **çalışmadan önce** yakalar, bazıları
çalışırken. İkisinin farkı şudur:

| Ne zaman | Sonuç |
| --- | --- |
| Yazarken/derlerken | Sen görürsün, kullanıcı hiç görmez |
| Çalışırken | Kullanıcı görür, sen belki hiç görmezsin |

Bu yüzden "derleyici kızıyor" cümlesi genellikle iyi haberdir.

## Gerçek hayattan benzetme

Mutfaktaki kaplar. Tencerede su kaynatabilirsin, kavanozda kaynatamazsın —
kavanoz yanlış olduğu için değil, o iş için tasarlanmadığı için. Kapağı olmayan
bir kaba sıvı koyup çantana atarsan sorun mutfakta değil, yolda çıkar.

Tip sistemi, kabı çantaya koymadan önce "bu kapak tutmaz" diyen kişidir.

## Pseudocode örneği

```text
GİRDİ : kullanıcının yazdığı metin
ÇIKTI : yaş bilgisi ya da hata

yasOku(metin)
  EĞER metin sayıya çevrilemiyorsa İSE
    DÖNDÜR hata("Sayı bekleniyordu")

  yas ← sayiyaCevir(metin)

  EĞER yas < 0 İSE
    DÖNDÜR hata("Yaş negatif olamaz")

  DÖNDÜR yas
```

Dikkat: tip kontrolü (`sayıya çevrilebilir mi`) ile anlam kontrolü (`negatif
mi`) ayrı adımlardır. Tip doğru olabilir ama değer yine de anlamsız olabilir.

## Adım adım çalışma modeli

Üç farklı girdi için:

| Girdi | 1. kontrol | 2. kontrol | Sonuç |
| --- | --- | --- | --- |
| `"34"` | çevrilebilir | 34 < 0 değil | 34 |
| `"-5"` | çevrilebilir | −5 < 0 | hata: negatif |
| `"abc"` | çevrilemez | çalışmaz | hata: sayı bekleniyordu |

Üçüncü satırda ikinci kontrol **hiç çalışmadı**. Bir kontrolün diğerini
korumasına "kapı" denir; sıraları değişirse `"abc"` ikinci satırda çöker.

## Yaygın yanlış anlamalar

> [!WARNING]
> **"Tip, dilin beni zorladığı bir formalite."** Tip, değerle ne
> yapabileceğinin tarifidir. Onu yazmak zorunda olmadığın dillerde de vardır —
> yalnızca görünmez.

> [!WARNING]
> **"Sayı sayıdır."** Tam sayı ile ondalık farklı davranır. `7 / 2` sonucunun
> `3` çıkması dilin hatası değil, tam sayı bölmesinin tanımıdır.

> [!WARNING]
> **"Dönüşüm her zaman çalışır."** Metinden sayıya dönüşüm başarısız
> olabilir; bu ihtimali ele almayan kod, kullanıcının ilk yazım hatasında
> çöker.

## Kontrol soruları

1. `5` ile `"5"` arasındaki fark nedir? Her biriyle yapabileceğin bir işlem
   söyle.
2. `9 / 2` neden `4` üretebilir? Bunu nasıl `4.5` yaparsın?
3. Kayıplı dönüşüme bir örnek ver ve neyin kaybolduğunu söyle.
4. Hatanın çalışma anında değil, yazma anında yakalanması neden daha iyidir?

## Uygulama alıştırmaları

### Kavrama

"Tip, değerin kullanma kılavuzudur" cümlesini kendi kelimelerinle ve yazılım
dışından bir örnekle açıkla.

### Uygulama

Bir alışveriş sepetinin toplamını hesaplayan pseudocode yaz. Şu tiplerin hepsi
geçsin: tam sayı (adet), ondalık (fiyat), metin (ürün adı), mantıksal (indirim
var mı). Her değişkenin tipini yorum satırında belirt.

### Analiz

Aşağıdaki kod her zaman doğru çalışır mı?

```text
ortalamaPuan(puanlar)
  toplam ← 0
  HER p İÇİN puanlar İÇİNDE
    toplam ← toplam + p
  DÖNDÜR toplam / puanlar.sayısı
```

`puanlar = [7, 8]` için sonuç ne olur? Beklenen `7.5` ise sorun nerede ve nasıl
düzeltilir?

## Küçük görev

Kullandığın bir uygulamanın tek bir formunu seç (kayıt, adres, ödeme). Her alan
için üç şeyi yaz:

1. Değerin tipi ne?
2. Kullanıcı yanlış tipte bir şey yazarsa ne olmalı?
3. Tipi doğru ama anlamı yanlış bir değer örneği ver (örneğin doğum yılı 3025).

Üçüncü madde, tip kontrolünün neden yetmediğini gösterir.

## Özet

- Her değerin bir tipi vardır ve tip, o değerle hangi işlemin anlamlı olduğunu
  söyler.
- Tam sayı ve ondalık farklı davranır; tam sayı bölmesi sessizce kalan atar.
- Dönüşüm kayıpsız, kayıplı ya da başarısız olabilir; üçüncü ihtimali ele
  almayan kod kullanıcının ilk hatasında çöker.

## Sonraki ders

- [Değişkenler ve atama](./02-variables-and-assignment.md)

## Kaynaklar

- [How to Design Programs](https://htdp.org/)
- [Teach Yourself Computer Science](https://teachyourselfcs.com/)
