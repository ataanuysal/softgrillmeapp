---
id: programming-fundamentals-07
course: software-engineering-fundamentals
module: programming-fundamentals
moduleOrder: 2
lessonOrder: 7
section: debugging
title: Hatalar ve istisnalar
description: Hata türlerini ayırmayı, beklenen başarısızlığı programın bir parçası olarak tasarlamayı ve hata mesajını kanıt olarak okumayı anlatır.
difficulty: beginner
estimatedMinutes: 25
prerequisites:
  - programming-fundamentals-06
relatedCodeLessons:
  - error-types
  - logic-errors
  - stack-traces
objectives:
  - Derleme, çalışma ve mantık hatalarını ayırmak
  - Beklenen başarısızlığı tasarımın parçası yapmak
  - Hata mesajını ve çağrı izini kanıt olarak okumak
status: published
version: 1
---

# Hatalar ve istisnalar

## Dersin amacı

Hata, öğrenmenin kazası değil, programlamanın normal hâlidir. Bu ders hata
türlerini ayırır, hangisinin ne zaman ortaya çıktığını gösterir ve bir hata
mesajını suçlama değil **kanıt** olarak okumayı öğretir.

## Ön koşullar

- [Kapsam ve ömür](./06-scope-and-lifetime.md)

## Kazanımlar

Bu dersin sonunda:

- Üç hata türünü ne zaman ortaya çıktıklarına göre ayırabilirsin.
- Beklenen başarısızlık ile beklenmeyen hatayı ayırabilirsin.
- Bir çağrı izini (stack trace) yukarıdan aşağı okuyabilirsin.
- Hatayı gizleyen kodu tanıyabilirsin.

## Temel kavramlar

| Terim | İngilizce | Kısa tanım |
| --- | --- | --- |
| Derleme hatası | compile error | Program hiç başlayamadan yakalanan hata |
| Çalışma hatası | runtime error | Çalışırken ortaya çıkan ve programı durduran hata |
| Mantık hatası | logic error | Program çalışır ama yanlış sonuç üretir |
| İstisna | exception | Olağandışı durumu bildiren mekanizma |
| Çağrı izi | stack trace | Hata anındaki çağrı zinciri |
| Yutma | swallowing | Hatayı yakalayıp hiçbir şey yapmama |

## Kavramsal açıklama

### Üç hata türü, üç farklı an

| Tür | Ne zaman | Kim görür | Örnek |
| --- | --- | --- | --- |
| Derleme | Program başlamadan | Geliştirici | Yazım hatası, tip uyuşmazlığı |
| Çalışma | Çalışırken | Kullanıcı | Sıfıra bölme, olmayan indis |
| Mantık | Hiç "patlamaz" | Kimse — geç fark edilir | Yanlış formül |

Sıralama zararlılık sırasıdır ve tersinedir: en gürültülü olan en zararsızdır.
Derleme hatası seni durdurur; mantık hatası aylarca yanlış fatura kesebilir.

### Beklenen başarısızlık bir hata değildir

Bunları ayırmak gerekir:

```text
Beklenen  : kullanıcı sayı yerine harf yazdı
Beklenen  : dosya bulunamadı
Beklenen  : ağ yok
Beklenmeyen: kendi kodunda olmayan bir indise erişme
```

Beklenen durumlar **tasarımın parçasıdır** ve akışta bir dal olarak yer
almalıdır. Beklenmeyenler ise kodun kendi hatasıdır ve gizlenmemeli, görünür
olmalıdır.

```text
dosyaOku(yol)
  EĞER dosya yoksa İSE
    DÖNDÜR hata("Dosya bulunamadı: " + yol)   // beklenen: dal
  DÖNDÜR icerik
```

### Hata mesajı kanıttır, suçlama değil

Bir hata mesajı üç şey söyler: **ne oldu**, **nerede oldu**, **oraya nasıl
gelindi**. Üçüncüsü çağrı izidir ve genellikle en değerli kısımdır.

```text
Hata: indis aralık dışında (3), dizi uzunluğu 3
  at ortalamaHesapla(satir 12)
  at raporUret(satir 45)
  at main(satir 3)
```

Okuma sırası: en üstteki satır **hatanın oluştuğu yer**, aşağıya doğru
gidildikçe **oraya nasıl gelindiği**. Çoğu zaman hata en üstte oluşur ama
sebebi aşağıdaki bir satırdadır — yanlış veriyi kim gönderdi?

### Hatayı yutmak, hatadan beterdir

```text
DENE
  kaydet(veri)
YAKALA
  // hiçbir şey yapma
```

Bu kod hatayı çözmez, yalnızca görünmez yapar. Kullanıcı kaydettiğini sanır,
veri yoktur. Yakalanan bir hata ya çözülmeli, ya yukarı bildirilmeli ya da en
azından kaydedilmelidir.

> [!WARNING]
> "Şimdilik geçelim" diye bırakılan boş yakalama blokları, üretimde en uzun
> yaşayan kod parçalarıdır.

### Erken ve net başarısız ol

Bir sorun fark edildiği anda durmak, yanlış veriyle devam etmekten iyidir.
Yanlış veriyle devam eden program hatayı taşır ve çok daha uzakta, alakasız bir
yerde patlar.

## Gerçek hayattan benzetme

Arabanın gösterge paneli. Yakıt lambası beklenen bir durumu bildirir; motor
arıza lambası beklenmeyen bir durumu. Lambayı bantla kapatmak (hatayı yutmak)
sorunu çözmez, yalnızca haberi keser.

Çağrı izi ise kaza raporudur: nerede durdun, oraya hangi yoldan geldin.

## Pseudocode örneği

```text
GİRDİ : kullanıcının yazdığı metin, puanlar listesi
ÇIKTI : ortalama ya da açıklamalı hata

guvenliOrtalama(puanlar)
  EĞER puanlar boş İSE
    DÖNDÜR hata("Puan listesi boş")      // beklenen

  toplam ← 0
  HER p İÇİN puanlar İÇİNDE
    EĞER p < 0 VEYA p > 100 İSE
      DÖNDÜR hata("Geçersiz puan: " + p) // beklenen
    toplam ← toplam + p

  DÖNDÜR toplam / puanlar.sayısı
```

Boş liste kontrolü olmasaydı son satır sıfıra bölme — bir **çalışma hatası** —
üretirdi. Kontrol, beklenen bir durumu hataya dönüşmeden karşılıyor.

## Adım adım çalışma modeli

| Girdi | 1. kontrol | Döngü | Son satır | Sonuç |
| --- | --- | --- | --- | --- |
| `[70, 90]` | boş değil | ikisi de geçerli | 160 / 2 | **80** |
| `[]` | **boş** | çalışmaz | çalışmaz | hata: liste boş |
| `[70, 130]` | boş değil | 130 geçersiz | çalışmaz | hata: geçersiz puan |
| `[-5]` | boş değil | −5 geçersiz | çalışmaz | hata: geçersiz puan |

İkinci ve üçüncü satırda program **çökmedi**; beklenen bir sonuç döndürdü. Fark
budur: hata mesajı bir çıktıdır, çökme değil.

## Yaygın yanlış anlamalar

> [!WARNING]
> **"Hata almamak iyi koddur."** Hata almamak, hataların gizlendiği anlamına da
> gelebilir. İyi kod hataları görünür kılar.

> [!WARNING]
> **"Çağrı izinin en üstündeki satır suçludur."** Hatanın **oluştuğu** yerdir;
> sebebi genellikle aşağıdaki bir çağrının gönderdiği veridir.

> [!WARNING]
> **"try/catch koyunca güvenli olur."** Yakalayıp hiçbir şey yapmamak
> güvenlik değil, sessizliktir. Yakalanan hata çözülmeli, bildirilmeli ya da
> kaydedilmelidir.

## Kontrol soruları

1. Üç hata türünü, ortaya çıktıkları ana göre sırala. Hangisi en tehlikelidir
   ve neden?
2. "Beklenen başarısızlık" ile "beklenmeyen hata" arasındaki fark nedir? Birer
   örnek ver.
3. Çağrı izini hangi sırayla okursun ve her satır sana ne söyler?
4. Boş bir yakalama bloğu neden hatadan daha zararlıdır?

## Uygulama alıştırmaları

### Kavrama

Bir mantık hatasının, derleme hatasından neden daha pahalı olabileceğini
yazılım dışından bir örnekle anlat.

### Uygulama

Bir kullanıcı kayıt akışının pseudocode'unu yaz. En az üç beklenen başarısızlık
(geçersiz e-posta, zayıf parola, kullanıcı zaten var) akışta ayrı dal olarak
yer alsın ve her biri farklı bir mesaj döndürsün.

### Analiz

Aşağıdaki kodda kaç sorun var? Her biri için hangi hata türüne yol açtığını yaz.

```text
ortalama(puanlar)
  DENE
    toplam ← 0
    HER p İÇİN puanlar İÇİNDE
      toplam ← toplam + p
    DÖNDÜR toplam / puanlar.sayısı
  YAKALA
    DÖNDÜR 0
```

## Küçük görev

Kullandığın bir uygulamada karşılaştığın son hata mesajını hatırla (ya da
kasten bir hata üret). Şunları yaz:

1. Bu beklenen mi, beklenmeyen mi bir durumdu?
2. Mesaj sana ne olduğunu söyledi mi, yoksa yalnızca "bir şeyler ters gitti" mi
   dedi?
3. Sen yazsaydın mesaj ne olurdu? Kullanıcının ne yapması gerektiğini söyle.

## Özet

- Üç hata türü üç farklı anda ortaya çıkar; en sessiz olan mantık hatası en
  pahalıya mal olur.
- Beklenen başarısızlık tasarımın parçasıdır ve akışta bir dal olarak yazılır;
  beklenmeyen hata gizlenmemelidir.
- Hata mesajı ve çağrı izi kanıttır: ne olduğunu, nerede olduğunu ve oraya
  nasıl gelindiğini söyler.

## Sonraki ders

- Bu modülün son dersiydi. [Modül değerlendirmesine](./README.md) dön.

## Kaynaklar

- [How to Design Programs](https://htdp.org/)
- [Operating Systems: Three Easy Pieces](https://pages.cs.wisc.edu/~remzi/OSTEP/)
