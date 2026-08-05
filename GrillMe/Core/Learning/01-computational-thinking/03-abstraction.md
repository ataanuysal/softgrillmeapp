---
id: computational-thinking-03
course: software-engineering-fundamentals
module: computational-thinking
moduleOrder: 1
lessonOrder: 3
section: fundamentals
title: Soyutlama
description: Hangi ayrıntının önemli hangisinin gürültü olduğunu ayırmayı, isimlendirmeyi ve doğru soyutlama düzeyini seçmeyi öğretir.
difficulty: beginner
estimatedMinutes: 20
prerequisites:
  - computational-thinking-02
objectives:
  - Bir problemde hangi ayrıntının önemli olduğuna karar vermek
  - Arayüz ile uygulamayı birbirinden ayırmak
  - İsimlendirmeyi soyutlamanın parçası olarak kullanmak
relatedCodeLessons:
  - scope
  - pure-side-effects
status: published
version: 1
---

# Soyutlama

## Dersin amacı

Bir problemi çözerken her ayrıntıyı aynı anda düşünemezsin. **Soyutlama**
(abstraction), o an işe yaramayan ayrıntıyı bilinçli olarak dışarıda bırakma
becerisidir. Bu ders, neyin dışarıda bırakılabileceğini ve bunun bedelinin ne
olduğunu anlatır.

## Ön koşullar

- [Örüntü tanıma](./02-pattern-recognition.md)

## Kazanımlar

Bu dersin sonunda:

- Bir problemde hangi ayrıntının önemli olduğuna karar verebilirsin.
- Bir parçayı, içini bilmeden kullanılabilir hâle getirebilirsin.
- İsimlendirmenin neden soyutlamanın parçası olduğunu anlarsın.
- Yanlış soyutlama düzeyini fark edebilirsin.

## Temel kavramlar

| Terim | İngilizce | Kısa tanım |
| --- | --- | --- |
| Soyutlama | abstraction | İşe yaramayan ayrıntıyı dışarıda bırakma |
| Arayüz | interface | Bir parçanın dışarıya söz verdiği davranış |
| Uygulama | implementation | O sözün içeride nasıl yerine getirildiği |
| Bilgi gizleme | information hiding | Ayrıntıyı kullanıcıdan saklamak |
| Soyutlama düzeyi | level of abstraction | Ne kadar ayrıntıyla konuşulduğu |
| Sızdıran soyutlama | leaky abstraction | Gizlemesi gereken ayrıntıyı dışarı taşıyan soyutlama |

## Kavramsal açıklama

### Soyutlama, bilgiyi atmak değildir

Yaygın yanlış anlama şudur: soyutlama, ayrıntıyı yok saymak değildir; ayrıntıyı
**bir yere hapsetmektir**. Ayrıntı hâlâ vardır ve biri onu yazmıştır; ama onu
kullanan kişinin bilmesi gerekmez.

Bir harita düşün. Metro haritası, istasyonların gerçek coğrafi konumunu ve
tünellerin gerçek eğrilerini göstermez. Bu bir eksiklik değil, kasıtlı bir
tercihtir: haritanın cevaplaması gereken soru "hangi hatla nereye giderim"
sorusudur. Gerçek mesafeleri eklemek haritayı doğru değil, kullanılamaz yapar.

**Kural:** neyin dışarıda bırakılacağına, cevaplanacak soruya bakarak karar
verilir. Soruyu değiştirirsen doğru soyutlama da değişir — yürüyerek gidecek
biri için metro haritası yanlış modeldir.

### Arayüz ve uygulama

Her soyutlamanın iki yüzü vardır:

- **Arayüz:** ne yaptığı. "Bir sayı listesi ver, ortalamasını alırım."
- **Uygulama:** nasıl yaptığı. Toplayıp bölmek, ya da başka bir yöntem.

Kullanan taraf yalnızca arayüzü bilir. Bu ayrım işe yarar çünkü uygulama
değişse bile — daha hızlı bir yöntem bulunsa bile — kullanan hiçbir yerde
değişiklik yapmak zorunda kalmaz.

> [!NOTE]
> İyi bir soyutlamanın ölçüsü şudur: içini okumadan doğru kullanabiliyor
> musun? Kullanmak için içini açmak zorunda kalıyorsan, o soyutlama işini
> yapmıyordur.

### İsimlendirme soyutlamanın parçasıdır

Bir parçayı ne yaptığını anlatmayan bir isimle adlandırdığında, soyutlamanın
tamamını çöpe atmış olursun; çünkü kullanan kişi ne yaptığını anlamak için yine
içini okumak zorunda kalır.

```text
kötü : islem1(x, y)
       yardimci(veri)
       process(data)
iyi  : ortalama(sayılar)
       gecerli_mi(eposta)
       kdv_ekle(tutar, oran)
```

İsim, arayüzün en görünür parçasıdır.

### Soyutlama düzeyini karıştırma

Bir açıklamanın içinde farklı ayrıntı düzeylerini karıştırmak, okuyanı
yorar:

```text
kötü:
  siparişi_hazırla()
  stok_kontrol()
  veritabanı_bağlantısını_aç()
  ürünleri_paketle()
  soket_zaman_aşımını_30_yap()

iyi:
  siparişi_hazırla()
  stok_kontrol()
  ürünleri_paketle()
```

İkinci listede veritabanı ve ağ ayrıntıları yok olmadı; yalnızca kendi
düzeylerine indiler. Bir metnin paragraflarıyla dipnotlarının aynı yerde
yazılmaması gibi.

### Her soyutlama biraz sızdırır

Hiçbir soyutlama mükemmel değildir. "Dosyayı oku" basit bir arayüzdür ama
dosya çok büyükse bellek biter, disk yavaşsa işlem uzar. Bu ayrıntılar, ne
kadar iyi gizlenirse gizlensin, bir noktada kendini gösterir. Buna **sızdıran
soyutlama** denir.

Bu, soyutlamanın işe yaramadığı anlamına gelmez; yalnızca bir gün alt katmanı
öğrenmen gerekeceği anlamına gelir. Bu eğitimin ilerleyen modüllerinin
(mimari, işletim sistemleri, ağlar) varlık sebebi budur.

## Gerçek hayattan benzetme

Araba kullanmayı düşün. Direksiyon, pedallar ve vites bir arayüzdür; motorun
nasıl çalıştığını bilmeden arabayı kullanabilirsin. Motor değişse — benzinliden
elektriğe geçilse — kullanma biçimin büyük ölçüde aynı kalır.

Ama soyutlama sızar: rampada kalkış yaparken, buzda frenlerken ya da motor
sesi değiştiğinde alttaki gerçeklik kendini gösterir. İyi sürücü, arayüzü
kullanır ama altında ne olduğuna dair kaba bir modele de sahiptir.

## Pseudocode örneği

Soyutlamasız hâl — her yerde aynı ayrıntı:

```text
kullanıcı_kaydet(ad, eposta)
  EĞER eposta içinde "@" yok İSE
    HATA "geçersiz e-posta"
  EĞER eposta uzunluğu < 5 İSE
    HATA "geçersiz e-posta"
  EĞER eposta "." ile bitiyor İSE
    HATA "geçersiz e-posta"
  veritabanına_yaz(ad, eposta)

bülten_kaydet(eposta)
  EĞER eposta içinde "@" yok İSE
    HATA "geçersiz e-posta"
  EĞER eposta uzunluğu < 5 İSE
    HATA "geçersiz e-posta"
  ...
```

Soyutlanmış hâl:

```text
eposta_gecerli_mi(eposta)
  EĞER eposta içinde "@" yok İSE       DÖNDÜR yanlış
  EĞER eposta uzunluğu < 5 İSE         DÖNDÜR yanlış
  EĞER eposta "." ile bitiyor İSE      DÖNDÜR yanlış
  DÖNDÜR doğru

kullanıcı_kaydet(ad, eposta)
  EĞER eposta_gecerli_mi(eposta) değilse İSE
    HATA "geçersiz e-posta"
  veritabanına_yaz(ad, eposta)

bülten_kaydet(eposta)
  EĞER eposta_gecerli_mi(eposta) değilse İSE
    HATA "geçersiz e-posta"
  listeye_ekle(eposta)
```

Kazanç yalnızca kısalık değil: e-posta kuralı değiştiğinde **tek bir yer**
değişir ve `kullanıcı_kaydet` fonksiyonunu okuyan kişi, doğrulamanın
ayrıntısıyla uğraşmadan asıl akışı görür.

## Adım adım çalışma modeli

`kullanıcı_kaydet("Ada", "ada@site.com")` çağrısının izi:

| Adım | Nerede | Yapılan | Sonuç |
| --- | --- | --- | --- |
| 1 | kullanıcı_kaydet | `eposta_gecerli_mi` çağrıldı | denetim başladı |
| 2 | eposta_gecerli_mi | "@" arandı | bulundu, devam |
| 3 | eposta_gecerli_mi | uzunluk 12 ≥ 5 | devam |
| 4 | eposta_gecerli_mi | "." ile bitmiyor | devam |
| 5 | eposta_gecerli_mi | doğru döndürüldü | denetim bitti |
| 6 | kullanıcı_kaydet | `veritabanına_yaz` çağrıldı | kayıt yapıldı |

Dikkat: 1. ve 6. adımlar tek bir düzeyde konuşuyor ("doğrula, kaydet").
2–5. adımlar bir alt düzeyde. Bu ayrımı korumak, soyutlamanın kendisidir.

## Yaygın yanlış anlamalar

> [!WARNING]
> **"Soyutlama = az kod."** Soyutlama bazen toplam satır sayısını artırır. Amaç
> kısalık değil, **aynı anda düşünülmesi gereken şeyin azalmasıdır**.

> [!WARNING]
> **"Her şeyi soyutlamalıyım."** Tek bir yerde kullanılan ve hiç değişmeyecek
> bir ayrıntıyı ayrı bir parçaya çıkarmak, okuyanı gereksiz yere bir yerden
> başka bir yere gönderir. Soyutlama, tekrar veya karmaşıklık varken kazanç
> sağlar.

> [!WARNING]
> **"İyi bir soyutlama her şeyi gizler."** Hiçbir soyutlama alt katmanı tamamen
> gizleyemez. Amaç kusursuz gizlemek değil, çoğu zaman düşünmek zorunda
> kalmamaktır.

## Kontrol soruları

1. Soyutlama ile "bilgiyi yok saymak" arasındaki fark nedir?
2. Bir parçanın arayüzü ile uygulaması arasındaki farkı, bu dersteki
   `eposta_gecerli_mi` örneği üzerinden anlat.
3. Neyin dışarıda bırakılacağına neye bakarak karar verilir?
4. "Sızdıran soyutlama" ne demektir? Metro haritası örneği nerede sızar?

## Uygulama alıştırmaları

### Kavrama

Günlük hayattan bir soyutlama örneği seç (para, saat, adres, menü…). Şunları
yaz: arayüzü nedir, uygulaması nedir, hangi durumda sızar?

### Uygulama

Aşağıdaki pseudocode'da soyutlama düzeyleri karışmış. Yeniden yaz: ana akış tek
düzeyde kalsın, ayrıntılar isimlendirilmiş parçalara insin.

```text
rapor_hazırla(kayıtlar)
  toplam ← 0
  HER k İÇİN kayıtlar İÇİNDE
    EĞER k.tarih bu ay içinde İSE
      toplam ← toplam + k.tutar
  dosya ← dosya_aç("rapor.txt")
  dosya.yaz("Toplam: " + toplam)
  dosya.kapat()
  eposta_sunucusuna_bağlan("smtp.site.com", 587)
  eposta_gönder("yonetim@site.com", "rapor.txt")
```

### Analiz

Bir geliştirici, uygulamasındaki tek bir yerde kullanılan üç satırlık bir
hesabı ayrı bir parçaya çıkarıp `hesapla_v2` adını vermiş. Bu kararın iki
sorununu belirle ve nasıl düzeltileceğini yaz.

## Küçük görev

[Problemi parçalara ayırmak](./01-decomposition.md) dersinin küçük görevinde
yazdığın parça listesini aç. Her parça için:

1. Arayüzünü tek cümleyle yaz ("ne verirsin, ne alırsın").
2. İçindeki hangi ayrıntının dışarıdan görünmemesi gerektiğini belirle.
3. İsimlerin, içini okumadan ne yaptığını anlatıp anlatmadığını kontrol et;
   anlatmayanları yeniden adlandır.

## Özet

- Soyutlama, ayrıntıyı yok saymak değil, onu tek bir yere hapsedip geri kalanı
  o ayrıntıdan kurtarmaktır.
- Bir soyutlamanın iki yüzü vardır: dışarıya verdiği söz (arayüz) ve o sözü
  nasıl tuttuğu (uygulama); kullanan yalnızca birincisini bilmelidir.
- İsim, arayüzün en görünür parçasıdır; kötü isim soyutlamayı geçersiz kılar.

## Sonraki ders

- [Algoritma yazmak](./04-algorithms-and-pseudocode.md)

## Kaynaklar

- [Structure and Interpretation of Computer Programs](https://sarabander.github.io/sicp/html/)
- [How to Design Programs](https://htdp.org/)
