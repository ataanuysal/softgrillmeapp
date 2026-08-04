---
id: orientation-02
course: software-engineering-fundamentals
module: orientation
moduleOrder: 0
lessonOrder: 2
section: fundamentals
title: Nasıl çalışılır?
description: Yazılım öğrenirken hangi yöntemlerin işe yaradığını, tanıma ile hatırlamanın farkını ve sürdürülebilir bir çalışma planının nasıl kurulduğunu anlatır.
difficulty: beginner
estimatedMinutes: 20
prerequisites:
  - orientation-01
objectives:
  - Tanıma ile hatırlamayı birbirinden ayırt etmek
  - Kendini test etmeyi çalışmanın parçası hâline getirmek
  - Tekrar aralıklarını planlamak
status: published
version: 1
---

# Nasıl çalışılır?

## Dersin amacı

Yazılım öğrenmeyi bırakanların çoğu konuyu zor bulduğu için değil, ilerlediğini
göremediği için bırakır. Bu ders, ilerlemenin neden görünmez olduğunu ve
görünür hâle nasıl geleceğini anlatır.

## Ön koşullar

- [Yazılım nedir?](./01-what-is-software.md)

## Kazanımlar

Bu dersin sonunda:

- "Anladım" hissi ile gerçekten yapabilmek arasındaki farkı ayırt edebilirsin.
- Kendini test etmeyi çalışmanın parçası hâline getirebilirsin.
- Bir konuyu ne zaman tekrar edeceğini planlayabilirsin.
- Takıldığında ne yapacağına dair yazılı bir kuralın olur.

## Temel kavramlar

| Terim | İngilizce | Kısa tanım |
| --- | --- | --- |
| Tanıma | recognition | Bir şeyi gördüğünde tanıdık bulmak |
| Hatırlama | recall | Bir şeyi önünde yokken üretebilmek |
| Aktif hatırlama | active recall | Bilgiyi kaynağa bakmadan kendi kendine üretme çalışması |
| Aralıklı tekrar | spaced repetition | Tekrarı, unutmaya yaklaşırken yapmak |
| Araya karıştırma | interleaving | Farklı konu türlerini aynı oturumda karıştırarak çalışmak |
| Zihinsel model | mental model | Bir sistemin kafandaki, tahmin üretebilen temsili |

## Kavramsal açıklama

### Tanıma, hatırlama değildir

Bir açıklamayı okurken "evet, mantıklı" diye düşünmek çok kolaydır. Buna
**tanıma** denir: bilgi önündeyken onu anlamlandırabiliyorsun. Ama gerçek soru
şudur — kaynak kapalıyken aynı şeyi üretebiliyor musun?

Öğrenmenin ölçüsü budur ve ikisi düzenli olarak karıştırılır. Bir eğitim
videosunu izleyip "öğrendim" hissiyle kalkmak, tanımayı hatırlama sanmaktır.

> [!TIP]
> Basit kural: bir konuyu bitirdiğini, kaynağa bakmadan **birine
> anlatabildiğinde** varsay. Anlatacak kimse yoksa yaz. Yazarken tıkandığın
> yer, tam olarak öğrenmediğin yerdir.

### Zorluk kötü bir işaret değildir

Kolay geçen çalışma, genellikle az iz bırakan çalışmadır. Kendine soru sormak,
cevabı hatırlamaya çalışırken zorlanmak ve hata yapmak rahatsız edicidir ama
bilginin kalıcı hâle geldiği yer tam olarak orasıdır.

Bu, "ne kadar acı çekersen o kadar öğrenirsin" demek değildir. Kastedilen şey
**üretme çabasıdır**: cevabı okumak yerine üretmeye çalışmak.

### Kod okumak, kod yazmak kadar önemlidir

Yazılımın büyük kısmı yazmak değil, var olanı okumak ve ne yaptığını
anlamaktır. Bir kod parçasının ne yapacağını **çalıştırmadan önce tahmin
etmek**, öğrenmenin en verimli hâllerinden biridir: tahminin yanlış çıktığında,
zihnindeki modelin nerede bozuk olduğunu tam olarak görürsün.

GrillMe:Code uygulamasındaki kod okuma dersleri de bu yüzden önce tahmin
sorar, sonra anlatır.

### Tekrar, unutmadan hemen önce yapılır

Öğrendiğin şey zamanla silinir. Ama tam unutmak üzereyken yapılan tekrar, taze
bilginin tekrarından çok daha güçlüdür. Pratik bir başlangıç aralığı:

| Tekrar | Ne zaman |
| --- | --- |
| 1. | Aynı gün, kısa bir gözden geçirme |
| 2. | Ertesi gün |
| 3. | 3 gün sonra |
| 4. | 1 hafta sonra |
| 5. | 2–3 hafta sonra |

Bu aralıklar kesin değildir; kişiye ve konuya göre değişir. Önemli olan
tekrarın **giderek seyrelmesidir**.

### Süre değil, düzen

Haftada bir gün 6 saat çalışmak, günde 40 dakika çalışmaktan zayıftır. Sebep
motivasyon değil, unutma eğrisidir: aralar uzadıkça her oturumun başında
kaybettiğini geri kazanmakla vakit geçirirsin.

## Gerçek hayattan benzetme

Bir enstrüman öğrenmeyi düşün.

- Nota okumayı bilmek, **tanımadır**.
- Notaya bakmadan bir parçayı çalabilmek, **hatırlamadır**.
- Her gün 30 dakika çalışan biri, ayda bir gün 8 saat çalışandan hızlı
  ilerler.
- Yalnızca bildiğin parçaları çalmak keyiflidir ama seni geliştirmez;
  gelişim, zorlandığın yerde olur.

Yazılımda da aynısı geçerlidir. Fark şu ki enstrümanda ilerlemediğini
duyarsın; yazılımda ilerlemediğini fark etmek için kendini sınaman gerekir.

## Pseudocode örneği

Kendi çalışma döngün de bir algoritma olarak yazılabilir:

```text
GİRDİ: konu, günlük_süre
İŞLEM:
  oku(konu)
  kapat(kaynak)
  cevapla(kontrol_soruları)      // kaynağa bakmadan
  EĞER cevaplar eksikse İSE
    tekrar_oku(eksik_kısım)
  uygula(alıştırma)
  planla(tekrar, 1_gün_sonra)
ÇIKTI: konu için ilk tur tamam
```

Dikkat: `kapat(kaynak)` adımı isteğe bağlı değildir. Onu atlarsan yaptığın şey
öğrenmek değil, okumaktır.

## Adım adım çalışma modeli

Bir konuyu 15 günde nasıl sağlamlaştırdığının izi:

| Gün | Yapılan | Zihindeki durum |
| --- | --- | --- |
| 1 | Ders okundu, sorular yazılarak cevaplandı | Taze ama kırılgan |
| 1 | Alıştırma yapıldı | İlk uygulama denemesi, hatalar görüldü |
| 2 | Kısa tekrar (5 dk, sadece sorular) | Eksik kalan iki nokta belirlendi |
| 4 | Tekrar + küçük görev | Kavram bağlama oturdu |
| 11 | Son tekrar | Kaynağa bakmadan anlatılabiliyor |

Toplam süre bir saati geçmez. Aynı saati tek oturumda harcasaydın, 11. günde
hatırladığın çok daha az olurdu.

## Yaygın yanlış anlamalar

> [!WARNING]
> **"Not almak öğrenmektir."** Kaynağı kopyalayarak alınan not, çoğunlukla
> dikkat harcamadan yapılan bir el işidir. Not, kaynağa bakmadan ve kendi
> cümlelerinle yazıldığında öğrenme aracına dönüşür.

> [!WARNING]
> **"Bu konuyu tam anlamadan devam edemem."** Bazı kavramlar ancak sonraki
> konuyu gördükten sonra yerine oturur. Belirli bir noktadan sonra takılmak
> yerine ilerlemek ve geri dönmek daha verimlidir. Sınırını önceden belirle
> (örneğin 30 dakika), sonra devam et.

> [!WARNING]
> **"Kurs bitirmek ilerlemektir."** Bitirilen kurs sayısı bir ölçü değildir.
> Ölçü, kaynağa bakmadan çözebildiğin problemdir.

## Kontrol soruları

1. Tanıma ile hatırlama arasındaki farkı, bu dersten bir örnek vermeden
   açıkla.
2. Neden tekrar aralıkları giderek uzuyor? Aralıkları sabit tutsaydın ne
   olurdu?
3. Kod okurken tahmin etmenin, doğrudan açıklamayı okumaya göre avantajı
   nedir?
4. Haftada tek uzun oturumun zayıf kalmasının sebebi nedir?

## Uygulama alıştırmaları

### Kavrama

Son bir ayda öğrenmeye çalıştığın bir konuyu düşün. Onu öğrenirken hangi
yöntemi kullandın ve bu yöntem tanımayı mı hatırlamayı mı çalıştırdı? Bir
paragrafla yaz.

### Uygulama

Kendine bu haftaya ait bir çalışma planı yaz. Şu alanları içersin:

```text
Günler          : ...
Günlük süre     : ...
Oturum yapısı   : ... dk okuma, ... dk kaynak kapalı test, ... dk alıştırma
Tekrar günleri  : ...
Takılma kuralı  : ... dakika sonra ...
```

### Analiz

Aşağıdaki iki çalışma planını karşılaştır ve hangisinin daha etkili olduğunu
gerekçeleriyle yaz:

- **A:** Cumartesi 5 saat video izlemek, notları renkli kalemle işaretlemek.
- **B:** Haftada 5 gün 45 dakika; her oturumun son 15 dakikasında kaynak
  kapalı soru cevaplamak.

Cevabında en az iki kavram kullan: tanıma/hatırlama, aralıklı tekrar, üretme
çabası.

## Küçük görev

Bir önceki dersi ([Yazılım nedir?](./01-what-is-software.md)) kaynağa
bakmadan, beş maddede özetle. Sonra dersi aç ve karşılaştır:

- Hangi maddeyi eksik yazdın?
- Hangi maddeyi yanlış hatırladın?

Yanlış hatırladığın madde, tekrar listendeki ilk sıradır. Bunu bir yere not
et — bu, kendi zayıf noktanı ölçmenin en ucuz yoludur.

## Özet

- Anlamak ile yapabilmek farklıdır; ölçü, kaynak kapalıyken üretebildiğindir.
- Kolay geçen çalışma az iz bırakır; üretme çabası ve hata öğrenmenin
  maliyetidir, kusuru değil.
- Kısa ve düzenli oturumlar, seyrekleşen tekrarlarla birleştiğinde uzun tek
  oturumları geçer.

## Sonraki ders

- [Öğrenme ortamını kurmak](./03-setting-up-a-learning-environment.md)

## Kaynaklar

- [Teach Yourself Computer Science — çalışma yöntemi bölümü](https://teachyourselfcs.com/)
- [OSSU Computer Science — nasıl çalışılır](https://github.com/ossu/computer-science)
