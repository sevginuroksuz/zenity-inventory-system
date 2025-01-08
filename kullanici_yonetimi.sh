#!/bin/bash

# Kullanıcı ekleme fonksiyonu
add_user() {
    input=$(zenity --forms --title="Yeni Kullanıcı Ekle" \
        --add-entry="Kullanıcı Adı" \
        --add-password="Parola" \
        --add-list="Rol" --list-values="Admin|Kullanıcı")

    if [[ $? -eq 0 ]]; then
        IFS="|" read -r username password role <<< "$input"
        hashed_password=$(echo -n "$password" | md5sum | cut -d' ' -f1)
        last_id=$(tail -n 1 kullanici.csv | cut -d',' -f1)
        if [[ -z "$last_id" || ! "$last_id" =~ ^[0-9]+$ ]]; then
            last_id=0
        fi
        new_id=$((last_id + 1))
        echo "$new_id,$username,$hashed_password,$role" >> kullanici.csv
        zenity --info --title="Başarılı" --text="Yeni kullanıcı başarıyla eklendi!"
    else
        zenity --info --title="İptal" --text="İşlem iptal edildi."
        exit 0
    fi
}

# Kullanıcı listeleme fonksiyonu
list_users() {
    zenity --text-info --title="Kullanıcı Listesi" --filename=kullanici.csv
}

# Kullanıcı güncelleme fonksiyonu
update_user() {
    user_id=$(awk -F ',' 'NR>1 {print $1}' kullanici.csv | zenity --list --title="Kullanıcı Seçimi" --column="ID")
    if [[ -n "$user_id" ]]; then
        input=$(zenity --forms --title="Kullanıcı Güncelle" \
            --add-entry="Yeni Kullanıcı Adı" \
            --add-password="Yeni Parola" \
            --add-list="Yeni Rol" --list-values="Admin|Kullanıcı")

        if [[ $? -eq 0 ]]; then
            IFS="|" read -r new_username new_password new_role <<< "$input"
            hashed_password=$(echo -n "$new_password" | md5sum | cut -d' ' -f1)
            sed -i "/^$user_id,/c\\$user_id,$new_username,$hashed_password,$new_role" kullanici.csv
            zenity --info --title="Başarılı" --text="Kullanıcı başarıyla güncellendi!"
        else
            zenity --info --title="İptal" --text="İşlem iptal edildi."
            exit 0
        fi
    else
        zenity --error --title="Hata" --text="Kullanıcı seçilmedi!"
    fi
}

# Kullanıcı silme fonksiyonu
delete_user() {
    user_id=$(awk -F ',' 'NR>1 {print $1}' kullanici.csv | zenity --list --title="Kullanıcı Sil" --column="ID")
    if [[ -n "$user_id" ]]; then
        zenity --question --title="Onay" --text="Bu kullanıcıyı silmek istediğinize emin misiniz?"
        if [[ $? -eq 0 ]]; then
            sed -i "/^$user_id,/d" kullanici.csv
            zenity --info --title="Başarılı" --text="Kullanıcı başarıyla silindi!"
        else
            zenity --info --title="İptal" --text="Silme işlemi iptal edildi."
        fi
    else
        zenity --error --title="Hata" --text="Kullanıcı seçilmedi!"
    fi
}

# Kullanıcı yönetimi menüsü
manage_users() {
    while true; do
        choice=$(zenity --list --title="Kullanıcı Yönetimi" \
            --column="Seçim" --column="İşlem" \
            1 "Yeni Kullanıcı Ekle" \
            2 "Kullanıcıları Listele" \
            3 "Kullanıcı Güncelle" \
            4 "Kullanıcı Sil" \
            5 "Çıkış")

        if [[ $? -ne 0 ]]; then
            zenity --info --title="İptal" --text="İşlem iptal edildi. Program sonlandırılıyor."
            exit 0
        fi

        case "$choice" in
            1) add_user ;;
            2) list_users ;;
            3) update_user ;;
            4) delete_user ;;
            5) exit 0 ;;
            *) zenity --error --title="Hata" --text="Geçersiz seçim!" ;;
        esac
    done
}

# Kullanıcı yönetim menüsünü çalıştır
manage_users