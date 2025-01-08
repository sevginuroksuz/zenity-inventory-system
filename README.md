# Ürün Yönetim Sistemi

Bu proje, bir ürün yönetim sistemi olarak tasarlanmıştır. Zenity GUI arayüzü kullanılarak kullanıcı dostu bir deneyim sağlanmıştır. Sistem, ürünlerin eklenmesi, güncellenmesi, silinmesi ve çeşitli raporların oluşturulmasını destekler. Ayrıca kullanıcı yönetimi ve veri güvenliği gibi özellikler sunar.

---
## Proje Tanıtımı

Bu proje ile ilgili daha fazla bilgi için YouTube videosunu izleyebilirsiniz:

[![Proje Tanıtım Videosu](https://img.youtube.com/vi/<VideoID>/0.jpg)](https://www.youtube.com/watch?v=oyBw2Qt5e7U)

## Proje Github Linki
[![Proje Github]()](https://github.com/sevginuroksuz/zenity-inventory-system)


## Özellikler

### 1. **Ürün Yönetimi**
- **Ürün Ekleme**: Yeni ürün ekleme fonksiyonu.
- **Ürün Güncelleme**: Mevcut ürün bilgilerini güncelleme.
- **Ürün Silme**: Ürünleri veri tabanından kaldırma.
- **Ürün Listeleme**: Depodaki tüm ürünleri görüntüleme.

### 2. **Raporlama**
- **Stokta Azalan Ürünler**: Belirli bir stok eşik değerinin altındaki ürünleri listeler.
- **En Yüksek Stok Miktarı**: En yüksek stoğa sahip ürünlerin listesini oluşturur.
- **Kategori Bazlı Raporlama**: Ürünleri kategori bazında ayırır ve raporlar.
- **Genel İstatistikler**: Toplam ürün sayısı, stok miktarı ve ortalama birim fiyat gibi genel istatistikleri görüntüler.

### 3. **Kullanıcı Yönetimi**
- **Yeni Kullanıcı Ekleme**: Admin veya kullanıcı rolü ile yeni kullanıcı ekleme.
- **Kullanıcı Güncelleme**: Mevcut kullanıcı bilgilerini güncelleme.
- **Kullanıcı Silme**: Kullanıcıyı sistemden kaldırma.
- **Kullanıcı Listeleme**: Tüm kullanıcıları listeleme.

---

## Kurulum

### Gerekli Bağımlılıklar

Bu projeyi çalıştırmak için aşağıdaki yazılımların sisteminizde kurulu olması gerekir:
- **Zenity**: GTK+ için GUI araçları sağlayan bir program.
- **Bash**: Proje, Bash betikleriyle çalışır.

### Adımlar
1. Proje dosyalarını indirin veya klonlayın:
    ```bash
    git clone <repo-url>
    cd <repo-dizin>
    ```

2. Gerekli CSV dosyalarını kontrol etmek ve oluşturmak için sistemin başlatılması:
    ```bash
    ./envanter_sistemi.sh
    ```

3. Zenity'nin doğru çalıştığını doğrulayın.

---

## Kullanım

1. Sistemi başlatmak için aşağıdaki komutu çalıştırın:
    ```bash
    ./envanter_sistemi.sh
    ```

2. **Kullanıcı Girişi** yapın.
   - Admin veya kullanıcı rolüyle giriş yapabilirsiniz.

3. Menüde ilgili işlemleri seçerek ürün yönetimi, raporlama veya kullanıcı yönetimi işlemlerini gerçekleştirin.

---

## Proje Yapısı

- **envanter_sistemi.sh**: Projenin ana dosyası.
- **kullanici_yonetimi.sh**: Kullanıcı işlemleri için fonksiyonlar.
- **depo.csv**: Ürün verilerini saklamak için kullanılan dosya.
- **kullanici.csv**: Kullanıcı bilgilerini saklamak için kullanılan dosya.
- **log.csv**: Sistem hata ve işlem kayıtları.

---

## Çalışma İzinleri

Tüm script dosyalarına çalışma izni vermek için aşağıdaki komutu çalıştırabilirsiniz:

```bash
chmod +x *.sh
```

Bu komut, tüm .sh dosyalarını yürütülebilir hale getirir. Bu işlemden sonra, script'leri aşağıdaki gibi doğrudan çalıştırabilirsiniz:

```bash
./envanter_sistemi.sh
```

---

## Raporlama İşlemleri

### Örnek Raporlar
1. **Stok Eşiği**: Stok miktarı belirli bir değerin altındaki ürünleri gösterir.
2. **Kategori Bazlı Raporlama**: Meyve, sebze gibi kategorilere göre ürünleri ayırır.
3. **Genel İstatistik**:
   - Toplam ürün sayısı.
   - Toplam stok miktarı.
   - Ortalama stok miktarı.
---

## Geliştirme

Projeye katkıda bulunmak isterseniz:
1. Fork yapın.
2. Yeni bir dal oluşturun: `git checkout -b yeni-ozellik`
3. Değişikliklerinizi yapın ve commit edin.
4. Dalınıza push yapın ve bir pull request gönderin.

---

## Lisans
Bu proje MIT Lisansı altında lisanslanmıştır. Daha fazla bilgi için `LICENSE` dosyasına bakın.

---

## İletişim
Herhangi bir sorunuz veya öneriniz varsa, lütfen benimle iletişime geçin!

