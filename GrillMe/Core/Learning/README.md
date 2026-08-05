# Yazılım ve Bilgisayar Bilimi Temelleri

Bu klasör, GrillMe:Code uygulamasının **okuma katmanının** içerik kaynağıdır.
Uygulamadaki 40 kod okuma dersi bir beceriyi çalıştırır: satır satır kod
izlemek. Buradaki dersler ise o becerinin altındaki **kavramsal zemini** kurar —
bilgisayar neden böyle çalışır, bir problem nasıl algoritmaya dönüşür, veri
nasıl saklanır, sistemler nasıl büyür.

İki katman birbirinin yerine geçmez. Kod okuma pratiği "ne oluyor" sorusunu,
buradaki dersler "neden böyle" sorusunu cevaplar.

## Bu eğitim kimin için

- Kodlamaya başlamış ama parçaların nasıl birleştiğini göremeyenler
- Sözdizimi öğrenmiş, kavramsal boşluğu fark edenler
- Bilgisayar bilimi eğitimi almadan bu işe girenler
- Bildiklerini düzenli bir sıraya oturtmak isteyenler

Ön koşul yok. Herhangi bir programlama dili bilmek gerekmiyor.

## Programlama dili amaç değildir

Bu eğitimde önce **pseudocode** kullanılır: dile bağlı olmayan, insanın
okuyabildiği adım listesi. Sebep basit — bir döngünün mantığı Swift'te de
Python'da da aynıdır, farklı olan yalnızca yazımıdır. Önce mantığı kurarsan
sözdizimi ayrıntı hâline gelir; önce sözdizimini ezberlersen her yeni dilde
sıfırdan başlarsın.

Gerçek kod gerektiğinde kullanılan dil yalnızca bir anlatım aracıdır ve bu
dersin içinde açıkça belirtilir.

> [!NOTE]
> Kavramları anlamak, onları uygulayabilmekle aynı şey değildir. Her modülde
> okuma, alıştırma ve küçük proje ayrı adımlardır ve
> [PROGRESS.md](./PROGRESS.md) bunları ayrı ayrı takip eder.

## Nasıl çalışılır

1. [ROADMAP.md](./ROADMAP.md) dosyasından sıradaki aşamayı seç.
2. Modülün `README.md` dosyasını oku; hedefleri ve ön koşulları gör.
3. Dersleri sırayla oku. Her dersin sonundaki kontrol sorularını **yazarak**
   cevapla.
4. Alıştırmaları yap. Cevaplara bakmadan önce kendi çözümünü yaz.
5. Modülün küçük projesini bitir.
6. [PROGRESS.md](./PROGRESS.md) üzerinde işaretle.

Bir modülü bitirmeden sonrakine geçme. Sıra rastgele değil: her modül bir
öncekinin kavramlarına dayanır.

## Belgeler

| Dosya | İçeriği |
| --- | --- |
| [ROADMAP.md](./ROADMAP.md) | Aşamalar, hedefler, süre ve tamamlanma ölçütleri |
| [PROGRESS.md](./PROGRESS.md) | Kişisel ilerleme takibi |
| [GLOSSARY.md](./GLOSSARY.md) | Terim sözlüğü (Türkçe – İngilizce) |
| [RESOURCES.md](./RESOURCES.md) | Önerilen dış kaynaklar |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | Ders yazma ve katkı kuralları |

## Modüller

| # | Modül | Durum |
| --- | --- | --- |
| 00 | [Yönelim ve Çalışma Yöntemi](./00-orientation/README.md) | Yayında |
| 01 | [Hesaplamalı Düşünme](./01-computational-thinking/README.md) | Yayında |
| 02 | [Programlamanın Temelleri](./02-programming-fundamentals/README.md) | Yayında |
| 03 | [Program Tasarımı](./03-program-design/README.md) | Planlandı |
| 04 | [Veri Yapıları ve Algoritmalar](./04-data-structures-and-algorithms/README.md) | Planlandı |
| 05 | [Bilgisayar Mimarisi](./05-computer-architecture/README.md) | Planlandı |
| 06 | [İşletim Sistemleri](./06-operating-systems/README.md) | Planlandı |
| 07 | [Veritabanları](./07-databases/README.md) | Planlandı |
| 08 | [Bilgisayar Ağları](./08-computer-networks/README.md) | Planlandı |
| 09 | [Yazılım Mühendisliği](./09-software-engineering/README.md) | Planlandı |
| 10 | [Test ve Hata Ayıklama](./10-testing-and-debugging/README.md) | Planlandı |
| 11 | [Yazılım Mimarisi](./11-software-architecture/README.md) | Planlandı |
| 12 | [Dağıtık Sistemler](./12-distributed-systems/README.md) | Planlandı |
| 13 | [Güvenlik Temelleri](./13-security-fundamentals/README.md) | Planlandı |
| 14 | [Bitirme Projeleri](./14-capstone-projects/README.md) | Planlandı |

> [!WARNING]
> "Planlandı" durumundaki modüllerin yalnızca kapsam açıklaması vardır; ders
> içerikleri henüz yazılmamıştır ve uygulamada gösterilmez.

## Öğrenme sırası neden böyle

Eğitim şu zinciri takip eder:

```text
Problem → Veri → İşlem → Algoritma → Pseudocode → Kod
        → Test → Hata ayıklama → Tasarım → Mimari → Sistem
```

Her halka bir öncekine dayanır. Mimariye, tek bir fonksiyonun ne yaptığını
bilmeden başlanmaz; sistem tasarımına, tek bir makinenin nasıl çalıştığını
bilmeden başlanmaz.

## Kaynaklar

Bu müfredatın yönü aşağıdaki açık kaynaklardan esinlenmiştir. İçerikleri
kopyalanmamış, kendi anlatımımız yazılmıştır.

- [Teach Yourself Computer Science](https://teachyourselfcs.com/)
- [How to Design Programs](https://htdp.org/)
- [Structure and Interpretation of Computer Programs](https://sarabander.github.io/sicp/html/)
- [Nand2Tetris](https://www.nand2tetris.org/)
- [Operating Systems: Three Easy Pieces](https://pages.cs.wisc.edu/~remzi/OSTEP/)
- [OSSU Computer Science](https://github.com/ossu/computer-science)

Tam liste ve seviye bilgisi için [RESOURCES.md](./RESOURCES.md).
