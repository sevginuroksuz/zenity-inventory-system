#!/bin/bash


#ayarları burda tanımlamak için başlangıç noktası
export file_storage=$(grep "csvfilespath: " settings.yml | awk '{print $2}')
export wwidth=$(grep "w-width: " settings.yml | awk '{print $2}')
export wheight=$(grep "w-height: " settings.yml | awk '{print $2}')
export encrypt_type=$(grep "model1: " settings.yml | awk '{print $2}')

# CSV Kontrol Fonksiyonu: Gerekli CSV dosyasını kontrol eder ve yoksa oluşturur.
function check_files() {
    for file in ${file_storage}/depo.csv; do
        if [[ ! -f "$file" ]]; then
            echo "No,Ad,Stok,Fiyat,Kategori" > "$file"
        fi
    done
}

# Stok Azalan Ürünler
function low_stock_report() {
    threshold=$(zenity --entry --title="Stok Eşiği" --text="Lütfen stok eşik değerini girin:")
    if [[ $? -eq 0 ]]; then
        awk -F',' -v threshold="$threshold" 'NR > 1 && $3 < threshold {print $0}' ${file_storage}/depo.csv > ${file_storage}/low_stock.csv
        zenity --text-info --title="Stokta Azalan Ürünler" --filename=${file_storage}/low_stock.csv
    else
        zenity --error --text="İşlem iptal edildi."
    fi
}

# En Yüksek Stok Miktarları
function high_stock_report() {
    top_n=$(zenity --entry --title="Ürün Sayısı" --text="Kaç ürün göstermek istersiniz?")
    if [[ $? -eq 0 ]]; then
        sort -t',' -k3 -nr ${file_storage}/depo.csv | head -n "$((top_n + 1))" > ${file_storage}/high_stock.csv
        zenity --text-info --title="En Yüksek Stok Ürünler" --filename=${file_storage}/high_stock.csv
    else
        zenity --error --text="İşlem iptal edildi."
    fi
}

# Kategori Bazlı Raporlama
function category_report() {
    selected_category=$(awk -F',' 'NR > 1 {print $5}' ${file_storage}/depo.csv | sort | uniq | zenity --list --title="Kategori Seçimi" --column="Kategori" --text="Bir kategori seçin:")

    if [[ -n "$selected_category" ]]; then
        filtered_file="${file_storage}/${selected_category}_raporu.csv"
        awk -F',' -v category="$selected_category" 'NR > 1 && $5 == category {print $0}' ${file_storage}/depo.csv > "$filtered_file"
        zenity --text-info --title="$selected_category Raporu" --filename="$filtered_file"
    else
        zenity --error --title="Hata" --text="Kategori seçilmedi!"
    fi
}

# Genel Özellik ve İstatistik Raporu
function statistics_report() {
    total_products=$(awk -F',' 'NR > 1 {count++} END {print count}' ${file_storage}/depo.csv)
    total_stock=$(awk -F',' 'NR > 1 {sum += $3} END {print sum}' ${file_storage}/depo.csv)
    avg_stock=$(awk -F',' 'NR > 1 {sum += $3; count++} END {if (count > 0) print sum / count; else print 0}' ${file_storage}/depo.csv)
    avg_price=$(awk -F',' 'NR > 1 {sum += $4; count++} END {if (count > 0) print sum / count; else print 0}' ${file_storage}/depo.csv)

    zenity --info --title="Genel Özellik ve İstatistik Raporu" \
        --text="Toplam Ürün Sayısı: $total_products\nToplam Stok Miktarı: $total_stock\nOrtalama Stok Miktarı: $avg_stock\nOrtalama Birim Fiyat: $avg_price"
}

# Menü: Kullanıcıdan işlem seçmesini ister ve ilgili fonksiyonu çağırır.
while true; do
    secim=$(zenity --list --text="işlem" --width=${wwidth} --height=${wheight} --title="Raporlama Menüsü" \
        --column="Seçim" --column="İşlem" \
        1 "Stokta Azalan Ürünler" \
        2 "En Yüksek Stok Miktarı" \
        3 "Kategori Bazlı Raporlama" \
        4 "Genel Özellik ve İstatistik Raporu" \
        5 "Çıkış")

    if [[ $? -ne 0 ]]; then
        return
    fi

    case "$secim" in
        1) low_stock_report ;;
        2) high_stock_report ;;
        3) category_report ;;
        4) statistics_report ;;
        5) exit 0 ;;
        *) zenity --error --title="Hata" --text="Geçersiz seçim!" ;;
    esac
done