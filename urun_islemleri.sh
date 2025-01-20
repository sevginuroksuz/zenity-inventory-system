#!/bin/bash

#ayarları burda tanımlamak için başlangıç noktası
export file_storage=$(grep "csvfilespath: " settings.yml | awk '{print $2}')
export wwidth=$(grep "w-width: " settings.yml | awk '{print $2}')
export wheight=$(grep "w-height: " settings.yml | awk '{print $2}')

# CSV Kontrol Fonksiyonu: Gerekli CSV dosyasını kontrol eder ve yoksa oluşturur.
function check_files() {
    for file in ${file_storage}/depo.csv; do
        if [[ ! -f "$file" ]]; then
            echo "No,Ad,Stok,Fiyat,Kategori" > "$file"
        fi
    done
}

# Eşsiz Ürün Numarası: Ürün numarasını otomatik olarak artırır.
function get_next_product_id() {
    if [[ ! -s ${file_storage}/depo.csv || $(wc -l < ${file_storage}/depo.csv) -eq 1 ]]; then
        echo 1
    else
        tail -n +2 ${file_storage}/depo.csv | awk -F',' '{print $1}' | sort -n | tail -1 | awk '{print $1 + 1}'
    fi
}

# Giriş Doğrulama: Sayısal ve pozitif girişleri kontrol eder.
function validate_input() {
    local value=$1
    if [[ "$value" =~ ^[0-9]+([.][0-9]+)?$ && $value -ge 0 ]]; then
        return 0  # Geçerli giriş
    else
        return 1  # Geçersiz giriş
    fi
}

# Ürün Ekleme: Kullanıcıdan ürün bilgileri alır ve CSV dosyasına ekler.
function add_product() {
    next_id=$(get_next_product_id)
    input=$(zenity --forms --title="Ürün Ekle" \
        --add-entry="Ürün Adı" \
        --add-entry="Stok Miktarı" \
        --add-entry="Birim Fiyatı" \
        --add-entry="Kategori")

    if [[ $? -eq 0 ]]; then
        IFS="|" read -r ad stok fiyat kategori <<< "$input"

        # Giriş Doğrulama
        if validate_input "$stok" && validate_input "$fiyat"; then
            existing_product=$(awk -F',' -v name="$ad" -v category="$kategori" 'NR>1 && $2==name {print $0}' ${file_storage}/depo.csv)

            if [[ -n "$existing_product" ]]; then
                zenity --error --text="Bu ürün zaten mevcut!"
            else
                echo "$next_id,$ad,$stok,$fiyat,$kategori" >> ${file_storage}/depo.csv
                zenity --info --text="Ürün başarıyla eklendi!"
            fi
        else
            zenity --error --text="Hatalı giriş! Stok ve fiyat 0'dan küçük veya geçersiz olamaz."
        fi
    else
        return
    fi
}

# Ürün Güncelleme: Kullanıcıdan yeni bilgiler alır ve ilgili ürünü günceller.
function update_product() {
    urun_no=$(zenity --entry --title="Ürün Güncelle" --text="Güncellenecek ürün numarasını girin:")
    if [[ $? -ne 0 ]]; then
        return
    fi

    if [[ -n "$urun_no" ]]; then
        product=$(grep "^$urun_no," ${file_storage}/depo.csv)
        if [[ -n "$product" ]]; then
            # Mevcut ürün bilgilerini al
            eski_ad=$(echo "$product" | cut -d',' -f2)
            eski_stok=$(echo "$product" | cut -d',' -f3)
            eski_fiyat=$(echo "$product" | cut -d',' -f4)
            eski_kategori=$(echo "$product" | cut -d',' -f5)

            # Yeni bilgiler için kullanıcıdan giriş alın
            input=$(zenity --forms --title="Ürün Güncelle" \
                --add-entry="Yeni Ürün Adı" \
                --add-entry="Yeni Stok Miktarı" \
                --add-entry="Yeni Birim Fiyatı" \
                --add-entry="Yeni Kategori" \
                --text="Mevcut Bilgiler: Ad=$eski_ad, Stok=$eski_stok, Fiyat=$eski_fiyat, Kategori=$eski_kategori")

            if [[ $? -eq 0 ]]; then
                IFS="|" read -r yeni_ad yeni_stok yeni_fiyat yeni_kategori <<< "$input"

                # Giriş Doğrulama
                if validate_input "$yeni_stok" && validate_input "$yeni_fiyat"; then
                    # Aynı ad ve kategori için kontrol
                    existing_product=$(awk -F',' -v name="$yeni_ad" -v category="$yeni_kategori" 'NR>1 && $2==name && $5==category {print $0}' ${file_storage}/depo.csv)

                    if [[ -n "$existing_product" && "$existing_product" != "$product" ]]; then
                        zenity --question --text="Bu ürün başka bir kategoride zaten mevcut. Yine de güncellemek ister misiniz?"
                        if [[ $? -ne 0 ]]; then
                            zenity --info --text="Güncelleme işlemi iptal edildi."
                            return
                        fi
                    fi

                    # ID'yi değiştirmeden diğer bilgileri güncelle
                    sed -i "/^$urun_no,/c\\$urun_no,$yeni_ad,$yeni_stok,$yeni_fiyat,$yeni_kategori" ${file_storage}/depo.csv
                    zenity --info --text="Ürün başarıyla güncellendi!"
                else
                    zenity --error --text="Hatalı giriş! Stok ve fiyat 0'dan küçük veya geçersiz olamaz."
                fi
            else
                return
            fi
        else
            zenity --error --text="Ürün bulunamadı."
        fi
    else
        zenity --error --text="Giriş yapılmadı."
    fi
}


# Ürün Listeleme: Mevcut ürünleri kullanıcıya gösterir.
function list_products() {
    zenity --text-info --title="Ürün Listeleme" --filename=${file_storage}/depo.csv
}

# Ürün Silme: Kullanıcıdan ürün numarasını alır ve siler.
function delete_product() {
    urun_no=$(zenity --entry --title="Ürün Sil" --text="Silinecek ürün numarasını girin:")
    if [[ $? -ne 0 ]]; then
        return
    fi

    if [[ -n "$urun_no" ]]; then
        zenity --question --text="Bu ürünü silmek istediğinizden emin misiniz?"
        if [[ $? -eq 0 ]]; then
            sed -i "/^$urun_no,/d" ${file_storage}/depo.csv
            zenity --info --text="Ürün başarıyla silindi!"
        else
            zenity --info --text="Silme işlemi iptal edildi."
        fi
    else
        zenity --error --text="Giriş yapılmadı."
    fi
}

# Başlatma: Gerekli dosyaları kontrol eder.
check_files

# Menü: Kullanıcıdan işlem seçmesini ister ve ilgili fonksiyonu çağırır.

while true; do
    secim=$(zenity --list --title="Ürün Yönetim Sistemi"  --width=${wwidth} --height=${wheight} --text="bir işlem seçin" --column="Seçim" --column="İşlem" \
        1 "Ürün Ekle" \
        2 "Ürün Listele" \
        3 "Ürün Güncelle" \
        4 "Ürün Sil")

    if [[ $? -ne 0 ]]; then
        exit 0
    fi

    case $secim in
        1) add_product ;;
        2) list_products ;;
        3) update_product ;;
        4) delete_product ;;
        *) zenity --error --text="Geçersiz seçim!" ;;
    esac
done