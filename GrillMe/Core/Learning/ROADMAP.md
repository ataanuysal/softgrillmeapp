# Öğrenme Yol Haritası

Bu tablo bir takvim taahhüdü değil, bağımlılık sırasıdır. Süreler haftada
5–7 saat çalışan bir kişi içindir ve kaba tahmindir.

## Aşamalar

| Aşama | Konu | Ön koşullar | Öğrenme hedefleri | Önerilen süre | Ana kaynak | Uygulama | Tamamlanma ölçütü |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 0 | [Yönelim ve Çalışma Yöntemi](./00-orientation/README.md) | Yok | Yazılımın ne olduğunu ve nasıl çalışılacağını anlamak | 1 hafta | Teach Yourself CS | Çalışma planı kurma | Kendi çalışma ritmini yazılı olarak tanımlamak |
| 1 | [Hesaplamalı Düşünme](./01-computational-thinking/README.md) | Aşama 0 | Problemi girdi, işlem, çıktı ve kısıtlara ayırmak | 2 hafta | HtDP | Günlük bir problemi pseudocode'a çevirme | Yeni bir problemi yardımsız pseudocode'a dökebilmek |
| 2 | [Programlamanın Temelleri](./02-programming-fundamentals/README.md) | Aşama 1 | Değer, değişken, koşul, döngü ve fonksiyon mantığı | 3 hafta | HtDP, SICP (giriş) | Küçük hesaplama programları | Bir programın çıktısını çalıştırmadan tahmin edebilmek |
| 3 | [Program Tasarımı](./03-program-design/README.md) | Aşama 2 | Soyutlama, modülerlik, durum yönetimi | 3 hafta | SICP, A Philosophy of Software Design | Bir programı yeniden yapılandırma | Bir çözümü sorumluluklara bölebilmek |
| 4 | [Veri Yapıları ve Algoritmalar](./04-data-structures-and-algorithms/README.md) | Aşama 3 | Liste, sözlük, ağaç, sıralama, arama ve karmaşıklık | 5 hafta | Teach Yourself CS | Veri yapısı seçimi gerektiren görev | İki çözümü maliyet açısından karşılaştırabilmek |
| 5 | [Bilgisayar Mimarisi](./05-computer-architecture/README.md) | Aşama 2 | CPU, bellek, komut döngüsü, sayı gösterimi | 4 hafta | Nand2Tetris | Basit bir işlem hattını izleme | Bir satır kodun donanımda karşılığını anlatabilmek |
| 6 | [İşletim Sistemleri](./06-operating-systems/README.md) | Aşama 5 | Süreç, iş parçacığı, bellek yönetimi, dosya sistemi | 5 hafta | OSTEP | Süreç ve bellek gözlemi | Eşzamanlılık sorunlarını tarif edebilmek |
| 7 | [Veritabanları](./07-databases/README.md) | Aşama 4 | İlişkisel model, indeks, işlem, tutarlılık | 4 hafta | Designing Data-Intensive Applications | Küçük bir şema tasarımı | Bir sorgunun neden yavaş olduğunu açıklayabilmek |
| 8 | [Bilgisayar Ağları](./08-computer-networks/README.md) | Aşama 6 | Katmanlar, IP, TCP, HTTP, gecikme | 4 hafta | Teach Yourself CS | Bir isteğin yolculuğunu çıkarma | Bir web isteğinin adımlarını sayabilmek |
| 9 | [Yazılım Mühendisliği](./09-software-engineering/README.md) | Aşama 3 | Sürüm kontrolü, temiz kod, refactoring, iş birliği | 3 hafta | Refactoring | Mevcut bir kodu iyileştirme | Bir değişikliğin etkisini önceden çıkarabilmek |
| 10 | [Test ve Hata Ayıklama](./10-testing-and-debugging/README.md) | Aşama 9 | Test türleri, sınır değer, hipotezli debugging | 3 hafta | Refactoring | Bir hatayı hipotezle bulma | Bir hatayı tekrarlanabilir testle sabitleyebilmek |
| 11 | [Yazılım Mimarisi](./11-software-architecture/README.md) | Aşama 10 | Katmanlar, bağımlılık yönü, sınırlar | 4 hafta | A Philosophy of Software Design | Bir sistemin katmanlarını çizme | Bir tasarım kararının bedelini savunabilmek |
| 12 | [Dağıtık Sistemler](./12-distributed-systems/README.md) | Aşama 11 | Ağ üzerinden tutarlılık, hata modelleri, ölçekleme | 5 hafta | Designing Data-Intensive Applications | Bir hata senaryosu analizi | Kısmi hataların sonucunu tahmin edebilmek |
| 13 | [Güvenlik Temelleri](./13-security-fundamentals/README.md) | Aşama 8 | Tehdit modeli, kimlik doğrulama, yaygın açıklar | 3 hafta | OSSU | Basit bir tehdit modeli çıkarma | Bir özelliğin saldırı yüzeyini listeleyebilmek |
| 14 | [Bitirme Projeleri](./14-capstone-projects/README.md) | Aşama 11 | Öğrenilenleri tek bir üründe birleştirmek | 6 hafta | — | Uçtan uca proje | Tasarımını başkasına savunabilmek |

## Sıra neden bu

- **Mimari (5) programlamadan sonra gelir**, çünkü bir komutun donanımda ne
  yaptığını anlamak için önce komutun ne olduğunu bilmek gerekir.
- **İşletim sistemleri (6) mimariden sonra gelir**, çünkü süreç ve bellek
  yönetimi CPU ve RAM kavramlarına dayanır.
- **Dağıtık sistemler (12) en sonda**, çünkü tek makinenin nasıl bozulduğunu
  bilmeden çok makinenin nasıl bozulduğu anlaşılmaz.
- **Test (10) mühendislikten sonra**, çünkü neyi test edeceğini bilmek için
  önce iyi yapılandırılmış kod görmek gerekir.

> [!TIP]
> Aşama 4 ve 5 birbirine paralel çalışılabilir; ikisi de Aşama 2'ye dayanır ama
> birbirine dayanmaz.

## Kaynaklar

- [Teach Yourself Computer Science](https://teachyourselfcs.com/)
- [OSSU Computer Science](https://github.com/ossu/computer-science)
