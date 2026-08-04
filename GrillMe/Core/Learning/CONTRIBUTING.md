# Katkı Kuralları

Bu klasör GrillMe:Code uygulamasının okuma katmanının içerik kaynağıdır.
Buradaki her Markdown dosyası uygulamada bir ders olarak görünebilir; bu yüzden
biçim kuralları katıdır.

## Genel ilkeler

- **Dil Türkçedir.** Teknik terimin İngilizce karşılığı ilk geçtiği yerde
  parantez içinde verilir: `soyutlama (abstraction)`.
- **Programlama dilinden bağımsız yaz.** Önce pseudocode kullan. Gerçek kod
  gerekiyorsa dilin yalnızca anlatım aracı olduğunu derste açıkça belirt.
- **Henüz öğretilmemiş kavrama dayanma.** Zorunluysa tek cümlelik ön açıklama
  ver ve ilgili derse bağlantı koy.
- **Emin olmadığın bilgiyi kesinmiş gibi yazma.** Belirsizse belirt.
- **Telifli içerik kopyalama.** Kaynaktan hareketle kendi anlatımını yaz;
  doğrudan alıntıdan kaçın.
- Her dersin sonunda kullanılan kaynakları bağlantılarıyla belirt.

## Ders dosyası biçimi

Her ders dosyası bir **front matter** ile başlar:

```yaml
---
id: orientation-01
section: fundamentals
order: 1
title: Yazılım nedir?
description: Yazılımın donanımdan farkını ve neden değiştirilebilir olduğunu anlar.
estimatedMinutes: 15
prerequisites: []
status: published
version: 1
---
```

| Alan | Zorunlu | Açıklama |
| --- | --- | --- |
| `id` | Evet | **Benzersiz ve değişmez.** Başlık veya dosya adı değişse bile değişmez |
| `section` | Evet | Uygulamadaki `CurriculumSection` değerlerinden biri |
| `order` | Evet | Modül içindeki sıra |
| `title` | Evet | Ders başlığı |
| `description` | Evet | Tek cümlelik özet |
| `estimatedMinutes` | Evet | Kaba okuma süresi |
| `prerequisites` | Hayır | Var olan ders `id` değerleri |
| `status` | Evet | `published` \| `draft` \| `comingSoon` |
| `version` | Evet | İçerik değiştikçe artar |

> [!WARNING]
> `id` alanı kullanıcı ilerlemesinin anahtarıdır. Değiştirirsen o dersi
> tamamlamış herkesin ilerlemesi kaybolur. Başlık veya dosya adını serbestçe
> değiştirebilirsin; `id` sabittir.

Yalnızca `status: published` olan dersler uygulamada görünür. `draft` ve
`comingSoon` dersleri normal kullanıcıya gösterilmez.

## Ders yapısı

Ders gövdesi [lesson-template.md](./templates/lesson-template.md) dosyasındaki
on beş bölümü izler. Bölüm başlıklarını değiştirme; sıralarını koru.

Üç uyarı kutusu kullanılabilir:

```markdown
> [!NOTE]
> Hatırlanması gereken bilgi.

> [!TIP]
> Pratik öğrenme önerisi.

> [!WARNING]
> Yaygın hata veya yanlış anlama.
```

## Alıştırmalar

Üç seviye zorunludur:

| Seviye | İstenen |
| --- | --- |
| **Kavrama** | Kavramı kendi cümleleriyle açıklamak |
| **Uygulama** | Pseudocode veya küçük bir kod parçası üretmek |
| **Analiz** | Verilen bir çözümün doğruluğunu veya tasarımını değerlendirmek |

Cevaplar alıştırmanın altına yazılmaz. Gerekiyorsa aynı modülde bir
`solutions/` klasörü açılır.

Her modülde en az: bir kavramsal değerlendirme, üç kısa alıştırma, bir küçük
proje, bir tamamlanma kontrol listesi ve sonraki modüle geçiş koşulları
bulunur.

## Doğrulama

Bir ders eklemeden önce:

- [ ] `id` benzersiz mi?
- [ ] `prerequisites` içindeki her kimlik var olan bir derse mi işaret ediyor?
- [ ] Şablondaki bölümlerin hepsi var mı?
- [ ] Markdown bağlantıları çalışıyor mu?
- [ ] Kullanılan her teknik terim ya tanımlanmış ya
      [GLOSSARY.md](./GLOSSARY.md) içinde mi?
- [ ] Kaynaklar belirtilmiş mi?

Bu kuralların bir kısmı otomatik testlerle korunur; testler kırılırsa içerik
uygulamaya girmez.

## Uygulama tarafı

İçerik dosyaları Markdown olarak kalır. Uygulama bunları derleme sırasında
paketler ve okur; ders metni Swift koduna kopyalanmaz.
