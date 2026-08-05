---
id: computational-thinking-01
course: software-engineering-fundamentals
module: computational-thinking
moduleOrder: 1
lessonOrder: 1
section: fundamentals
title: Problemi parçalara ayırmak
description: Büyük bir problemi, tek tek çözülebilecek bağımsız alt problemlere ayırmayı ve girdi-işlem-çıktı tanımını yapmayı öğretir.
difficulty: beginner
estimatedMinutes: 20
prerequisites:
  - orientation-03
objectives:
  - Bir problemi girdi, işlem ve çıktı olarak tanımlamak
  - Problemi bağımsız çözülebilir alt problemlere ayırmak
  - Parçalar arasındaki bağımlılığı görünür kılmak
relatedCodeLessons:
  - function-call
  - parameters-return
status: published
version: 1
---

# Problemi parçalara ayırmak

## Dersin amacı

"Nereden başlayacağımı bilmiyorum" cümlesi neredeyse her zaman aynı şeyi
anlatır: problem hâlâ tek ve büyük bir yığın hâlindedir. Bu ders, o yığını tek
tek çözülebilecek parçalara ayırmayı öğretir. Bu işleme **ayrıştırma**
(decomposition) denir.

## Ön koşullar

- [Öğrenme ortamını kurmak](../00-orientation/03-setting-up-a-learning-environment.md)

## Kazanımlar

Bu dersin sonunda:

- Bir problemi girdi, işlem ve çıktı olarak tanımlayabilirsin.
- Bir problemi bağımsız çözülebilir alt problemlere ayırabilirsin.
- İyi bir parçalanmayı kötüsünden ayırt edebilirsin.
- Parçalar arasındaki bağımlılığı görünür kılabilirsin.

## Temel kavramlar

| Terim | İngilizce | Kısa tanım |
| --- | --- | --- |
| Ayrıştırma | decomposition | Bir problemi daha küçük alt problemlere bölme |
| Alt problem | subproblem | Tek başına çözülebilen, daha küçük problem |
| Girdi | input | Çözümün dışarıdan aldığı bilgi |
| Çıktı | output | Çözümün ürettiği sonuç |
| Bağımlılık | dependency | Bir parçanın başka bir parçanın sonucuna ihtiyaç duyması |
| Sorumluluk | responsibility | Bir parçanın yapmakla yükümlü olduğu tek iş |

## Kavramsal açıklama

### Önce sınırı çiz: girdi, işlem, çıktı

Bir problemi çözmeye başlamadan önce üç soruyu cevapla:

1. **Ne biliyorum?** (girdi)
2. **Ne üretmem gerekiyor?** (çıktı)
3. **Birinciden ikinciye nasıl gidilir?** (işlem)

Üçüncü soru cevaplanamıyorsa, sorun genellikle ilk ikisinin net olmamasıdır.
"Kullanıcıya iyi bir öneri göster" bir problem tanımı değildir çünkü ne
girdisi ne çıktısı bellidir. "Kullanıcının son 10 dinlediği parçadan, henüz
dinlemediği 5 parça öner" tanımlıdır.

### Parçalara ayırmak

Tanımlı bir problem bile tek adımda çözülemeyecek kadar büyük olabilir. O zaman
onu alt problemlere bölersin. İyi bir bölmenin üç özelliği vardır:

- **Her parçanın tek bir sorumluluğu vardır.** Parçanın ne yaptığını tek
  cümleyle, "ve" kullanmadan anlatabiliyorsan iyidir.
- **Her parça tek başına anlaşılabilir.** Diğer parçaların içini bilmeye gerek
  kalmadan ne yaptığı anlaşılır.
- **Parçalar arasındaki bağ azdır.** Bir parçayı değiştirmek diğerlerini
  bozmuyorsa bölme başarılıdır.

### "Ve" kelimesi bir uyarıdır

Bir parçayı anlatırken "ve" kullanmak zorunda kalıyorsan, o parça muhtemelen
iki iş yapıyordur:

```text
kötü : "Kullanıcı verisini oku ve doğrula ve kaydet"
iyi  : "Kullanıcı verisini oku"
       "Kullanıcı verisini doğrula"
       "Kullanıcı verisini kaydet"
```

Üçe ayrılmış hâlde, doğrulama kuralı değiştiğinde okuma ve kaydetme adımlarına
dokunmazsın.

### Bağımlılığı görünür kıl

Parçalar çoğu zaman bağımsız değildir; biri diğerinin sonucunu kullanır. Bunu
gizlemek yerine yazılı hâle getir:

```text
1. Veriyi oku            → ham_veri üretir
2. Veriyi doğrula        → ham_veri ister, temiz_veri üretir
3. Hesapla               → temiz_veri ister, sonuç üretir
4. Sonucu göster         → sonuç ister
```

Bu liste sana iki şey verir: hangi sırayla çalışacağını ve bir parça
bozulduğunda hangilerinin etkileneceğini.

> [!NOTE]
> Parçalara ayırmanın amacı problemi küçültmek değil, **aynı anda düşünmen
> gereken şey sayısını** küçültmektir.

## Gerçek hayattan benzetme

Bir ev taşıma işini düşün. "Evi taşı" tek başına yapılamaz; ne zaman
başladığını bile bilemezsin. Ama şöyle bölünürse her parça yapılabilir hâle
gelir:

- Eşyaları kutulara koy
- Kutuları etiketle
- Nakliye ayarla
- Yeni evde kutuları odalara dağıt
- Kutuları aç

Bağımlılık burada da vardır: etiketleme, kutulamadan sonra gelir; dağıtım,
etiket olmadan yapılamaz. Ve "kutuları etiketle" işini biri yaparken, diğerinin
nakliye ayarlaması mümkündür — çünkü parçalar birbirinin içini bilmiyor.

## Pseudocode örneği

Problem: **Bir sınıfın not ortalamasını hesapla ve geçenleri listele.**

Önce sınır:

```text
GİRDİ : öğrenci listesi (her öğrencinin adı ve notu)
ÇIKTI : ortalama, geçen öğrencilerin adları
```

Sonra parçalar:

```text
PARÇA 1 — ortalama_hesapla(notlar)
  toplam ← 0
  HER not İÇİN notlar İÇİNDE
    toplam ← toplam + not
  DÖNDÜR toplam / notlar.sayısı

PARÇA 2 — geçenleri_bul(öğrenciler, sınır)
  geçenler ← boş liste
  HER öğrenci İÇİN öğrenciler İÇİNDE
    EĞER öğrenci.not >= sınır İSE
      geçenler'e öğrenci.ad ekle
  DÖNDÜR geçenler

ANA AKIŞ
  ortalama ← ortalama_hesapla(öğrenciler.notları)
  geçenler ← geçenleri_bul(öğrenciler, 50)
  ÇIKTI: ortalama, geçenler
```

İki parça birbirini çağırmıyor. Geçme sınırı 50'den 60'a çıksa yalnızca ana
akıştaki tek sayı değişir.

## Adım adım çalışma modeli

`öğrenciler = [Ada 70, Bora 40, Ceren 90]`, `sınır = 50` için:

| Adım | Çalışan parça | toplam | ortalama | geçenler |
| --- | --- | --- | --- | --- |
| 1 | ortalama_hesapla başladı | 0 | — | — |
| 2 | Ada'nın notu eklendi | 70 | — | — |
| 3 | Bora'nın notu eklendi | 110 | — | — |
| 4 | Ceren'in notu eklendi | 200 | — | — |
| 5 | Bölme yapıldı | 200 | 66.6 | — |
| 6 | geçenleri_bul: Ada 70 ≥ 50 | 200 | 66.6 | [Ada] |
| 7 | Bora 40 ≥ 50 değil | 200 | 66.6 | [Ada] |
| 8 | Ceren 90 ≥ 50 | 200 | 66.6 | [Ada, Ceren] |
| 9 | ÇIKTI | 200 | 66.6 | [Ada, Ceren] |

Dikkat: `geçenler` listesi 6. adımda ilk kez doluyor ve 7. adımda hiç
değişmiyor. Bir adımın "hiçbir şey yapmaması" da bir davranıştır.

## Yaygın yanlış anlamalar

> [!WARNING]
> **"Parçalara ayırmak, kodu dosyalara bölmektir."** Değildir. Ayrıştırma
> problem düzeyinde yapılır ve kod yazılmadan önce biter. Dosya düzeni bunun
> sonucudur, kendisi değil.

> [!WARNING]
> **"Ne kadar çok parça o kadar iyi."** Aşırı bölünmüş bir problem, tek tek
> anlamsız parçalardan oluşur ve bütünü takip etmek zorlaşır. Ölçü sayı değil,
> her parçanın tek bir işi anlaşılır biçimde yapmasıdır.

> [!WARNING]
> **"Parçaları sonra düşünürüm, önce yazmaya başlayayım."** Ayrıştırılmamış bir
> problemde yazmaya başlamak, sonradan her şeyi dağıtan kararlar almana yol
> açar. Ayrıştırma en ucuz aşamadadır: henüz sadece metin yazıyorsun.

## Kontrol soruları

1. Bir problemi tanımlarken cevaplaman gereken üç soru nedir?
2. Bir parçayı anlatırken "ve" kullanman neyin işaretidir?
3. Yukarıdaki örnekte geçme sınırını değiştirmek neden yalnızca tek bir yeri
   etkiliyor?
4. Parçalar arasındaki bağımlılığı yazılı hâle getirmek sana hangi iki bilgiyi
   verir?

## Uygulama alıştırmaları

### Kavrama

"Ayrıştırma" kavramını, yazılımla ilgisi olmayan bir örnekle anlat. Örneğinde
en az bir bağımlılık bulunsun ve bunu belirt.

### Uygulama

Şu problemi ayrıştır: **Bir kütüphanenin kitap ödünç verme sistemi.**

Üret:

1. Girdi–işlem–çıktı tanımı
2. En az beş alt problem, her biri tek cümleyle ve "ve" kullanmadan
3. Bağımlılık listesi (hangi parça hangisinin sonucunu istiyor)

### Analiz

Aşağıdaki parçalanma neden zayıf? En az iki sorun belirle ve düzeltilmiş
hâlini yaz.

```text
PARÇA 1 — kullanıcı_işlemleri(veri)
  kullanıcıyı kaydet, e-posta gönder, raporu güncelle,
  hata varsa kayıt dosyasına yaz
PARÇA 2 — yardımcı(veri)
  gerekeni yap
```

## Küçük görev

Kullandığın bir uygulamanın **tek bir ekranını** seç (giriş ekranı, arama
sonuçları, sepet — fark etmez). O ekranın arkasında çalışması gereken işleri
alt problemler hâlinde yaz. Kuralları:

- En az dört parça
- Her parça tek cümle, "ve" yok
- Sonuna bağımlılık listesi

## Özet

- Problem, girdi ve çıktısı net değilse çözülemez; ilk iş sınırı çizmektir.
- İyi bir parça tek bir işi yapar, tek başına anlaşılır ve diğerlerine az
  bağlıdır.
- Bağımlılıkları yazmak sana hem çalışma sırasını hem de bir değişikliğin
  etkisini verir.

## Sonraki ders

- [Örüntü tanıma](./02-pattern-recognition.md)

## Kaynaklar

- [How to Design Programs](https://htdp.org/)
- [Teach Yourself Computer Science](https://teachyourselfcs.com/)
