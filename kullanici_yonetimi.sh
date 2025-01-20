#!/bin/bash

#ayarları burda tanımlamak için başlangıç noktası
export file_storage=$(grep "csvfilespath: " settings.yml | awk '{print $2}')
export wwidth=$(grep "w-width: " settings.yml | awk '{print $2}')
export wheight=$(grep "w-height: " settings.yml | awk '{print $2}')
export encrypt_type=$(grep "model1: " settings.yml | awk '{print $2}')

#benzersiz bir id
function uniq_id_gen() {
    local temp_id

    while true;do

        temp_id=$(date +%3N)
        if ! awk -F',' -v id="$temp_id" '$1 == id {exit 1}' "${file_storage}/kullanici.csv"; then
            echo $temp_id
            break
        fi
    done
}

# Kullanıcı ekleme fonksiyonu
function add_user() {
    input=$(zenity --forms --text="kullanıcı bilgileri" --title="Yeni Kullanıcı Ekle" \
        --add-entry="Kullanıcı Adı" \
        --add-password="Parola" \
        --add-list="Rol" --list-values="Admin|User")

    if [[ $? -eq 0 ]]; then
        IFS="|" read -r username password role <<< "$input"
        hashed_password=$(echo -n "$password" | ${encrypt_type} | cut -d' ' -f1)
        uniq_id=$(uniq_id_gen)
        echo "$uniq_id,$username,$hashed_password,$role" >> ${file_storage}/kullanici.csv
        zenity --info --title="Başarılı" --text="Yeni kullanıcı başarıyla eklendi!"
    else
        zenity --warning --title="HATA" --text="kullanıcı eklenirken hata meydana geldi!"
        return
    fi
}

# Kullanıcı listeleme fonksiyonu
function list_users() {
    zenity --text-info --title="Kullanıcı Listesi" --filename=${file_storage}/kullanici.csv
}

# Kullanıcı güncelleme fonksiyonu
function update_user() {
    user_id=$(awk -F ',' 'NR>1 {print $1}' ${file_storage}/kullanici.csv | zenity --list --title="Kullanıcı Seçimi" --column="ID")
    if [[ -n "$user_id" ]]; then
        input=$(zenity --forms --title="Kullanıcı Güncelle" \
            --add-entry="Yeni Kullanıcı Adı" \
            --add-password="Yeni Parola" \
            --add-list="Yeni Rol" --list-values="Admin|User")

        if [[ $? -eq 0 ]]; then
            IFS="|" read -r new_username new_password new_role <<< "$input"
            hashed_password=$(echo -n "$new_password" | ${encrypt_type} | cut -d' ' -f1)
            sed -i "/^$user_id,/c\\$user_id,$new_username,$hashed_password,$new_role" ${file_storage}/kullanici.csv
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
function delete_user() {
    user_id=$(awk -F ',' 'NR>1 {print $1}' ${file_storage}/kullanici.csv | zenity --list --title="Kullanıcı Sil" --column="ID")
    if [[ -n "$user_id" ]]; then
        zenity --question --title="Onay" --text="Bu kullanıcıyı silmek istediğinize emin misiniz?"
        if [[ $? -eq 0 ]]; then
            sed -i "/^$user_id,/d" ${file_storage}/kullanici.csv
            zenity --info --title="Başarılı" --text="Kullanıcı başarıyla silindi!"
        else
            zenity --info --title="İptal" --text="Silme işlemi iptal edildi."
        fi
    else
        zenity --error --title="Hata" --text="Kullanıcı seçilmedi!"
    fi
}

# Kullanıcı yönetimi menüsü
function manage_users() {
    while true; do
        choice=$(zenity --list --width=${wwidth} --height=${wheight} --text="bir işlem seçin" --title="Kullanıcı Yönetimi" \
            --column="Seçim" --column="İşlem" \
            1 "Yeni Kullanıcı Ekle" \
            2 "Kullanıcıları Listele" \
            3 "Kullanıcı Güncelle" \
            4 "Kullanıcı Sil" \
            5 "Çıkış")

        if [[ $? -ne 0 ]]; then
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