#!/bin/bash

#ayarları burda tanımlamak için başlangıç noktası
export file_storage=$(grep "csvfilespath: " settings.yml | awk '{print $2}')
export wwidth=$(grep "w-width: " settings.yml | awk '{print $2}')
export wheight=$(grep "w-height: " settings.yml | awk '{print $2}')
export encrypt_type=$(grep "model1: " settings.yml | awk '{print $2}')

# Gerekli dosyaları kontrol eden ve oluşturan fonksiyon
function check_files() {

    mkdir ${file_storage}

    if [[ ! -f "${file_storage}/log.csv" ]]; then
        echo "log.csv dosyası oluşturuluyor..."
        echo "Tarih,Islem,Hata" > ${file_storage}/log.csv

        if [[ $? -ne 0 ]]; then
            echo "log dosyası oluşturuken hata meydana geldi" >&2
        fi
    fi


    if [[ ! -f "${file_storage}/depo.csv" ]]; then
        echo "depo.csv dosyası oluşturuluyor..."
        echo "ID,Ad,Stok,Fiyat,Kategori" > ${file_storage}/depo.csv

        if [[ $? -ne 0 ]]; then
            echo "$(date) depo.csv oluşturuken haya meydana geldi" >> ${file_storage}/log.csv
            echo "depo.csv oluşturma hatası" >&2
        fi
    fi

    if [[ ! -f "${file_storage}/kullanici.csv" ]]; then
        echo "kullanici.csv dosyası oluşturuluyor..."
        echo "ID,KullaniciAdi,Parola,Role" > ${file_storage}/kullanici.csv
        echo "1,admin,21232f297a57a5a743894a0e4a801fc3,Admin" >> ${file_storage}/kullanici.csv

        if [[ $? -ne 0 ]]; then
            echo "$(date) kullanici.csv oluştururken hata meydana geldi" >> ${file_storage}/log.csv
            echo "kullanici.csv oluşturma hatası" >&2
        fi

    fi

}

# Kullanıcı giriş fonksiyonu
function user_login() {

    local attempts=0
    local max_attempts=$(grep "max-attempts" settings.yml | awk '{print $2}')
    local username=""
    local password=""

    while true; do
        login_data=$(zenity --forms --title="Kullanıcı Girişi" --text="Lütfen giriş bilgilerinizi girin:" \
            --add-entry="Kullanıcı Adı" \
            --add-password="Şifre")

        if [[ $? -ne 0 ]]; then
            zenity --error --text="Giriş işlemi iptal edildi. Program sonlandırılıyor."
            exit 0
        fi

        if [[ -n "$login_data" ]]; then
            username=$(echo "$login_data" | cut -d'|' -f1 | xargs)
            password=$(echo "$login_data" | cut -d'|' -f2 | xargs)
            hashed_password=$(echo -n "$password" | ${encrypt_type} | cut -d' ' -f1)

            user_info=$(awk -F ',' -v user="$username" -v pass="$hashed_password" 'NR>1 && $2==user && $3==pass {print $0}' ${file_storage}/kullanici.csv)
            if [[ -n "$user_info" ]]; then
                user_role=$(echo "$user_info" | cut -d',' -f4)
                zenity --info --title="Başarılı Giriş" --text="Hoş geldiniz, $username! Rolünüz: $user_role"
                return 0
            else
                ((attempts++))
                if [[ $attempts -ge $max_attempts ]]; then
                    zenity --error --text="Çok fazla hatalı giriş yaptınız. Program sonlandırılıyor."
                    exit 1
                else
                    zenity --error --text="Hatalı kullanıcı adı veya şifre. Kalan deneme hakkınız: $((max_attempts - attempts))"
                fi
            fi
        else
            zenity --error --text="Giriş bilgileri eksik!"
        fi
    done

    
}

function give_permission_directory() {

    chmod +777 ./urun_islemleri.sh
    chmod +777 ./kullanici_yonetimi.sh
    chmod +777 ./program_yonetimi.sh
    chmod +777 ./rapor_al.sh
    
}

function exit_process() {

    zenity --question --title="Çıkış Onayı" --text="Sistemden çıkmak istediğinizden emin misiniz?"
    if [[ $? -eq 0 ]]; then
        zenity --info --title="Çıkış" --text="Sistemden çıkılıyor!"        
        exit 0
    else
        zenity --info --title="İptal" --text="Çıkış işlemi iptal edildi."
    fi

}

# Ana menü fonksiyonu
function main_menu() {

    give_permission_directory #dizin için izinler
    local request

    while true; do
        if [[ "$user_role" == "Admin" ]]; then 

            request=$(zenity --list --title="Ana menü" --width=${wwidth} --height=${wheight} --text="admin için seçenekler" --column="Seçenekler" \
                "Ürün Islemleri" \
                "Rapor Islemleri" \
                "Kullanıcı Yönetimi" \
                "Program Yönetimi" \
                "Çıkış"
            )
        else 
            request=$(zenity --list --title="Ana menü" --width=${wwidth} --height=${wheight} --text="kullanıcı için seçenekler" --column="Seçenekler" \
                "Rapor Islemleri" \
                "Çıkış"
            )

        fi

        if [[ $? -ne 0 ]]; then
            zenity --error --text="Menüden çıkıldı. Program sonlandırılıyor."
            exit 0
        fi

        case $request in
            "Ürün Islemleri")
                    ./urun_islemleri.sh
                ;;
            "Rapor Islemleri")
                    ./rapor_al.sh
                ;;
            "Kullanıcı Yönetimi")
                    ./kullanici_yonetimi.sh
                ;;
            "Program Yönetimi")
                    ./program_yonetimi.sh
                ;;
            "Çıkış")
                exit_process
                ;;
            *)
                zenity --error --title="Hata" --text="Geçersiz bir seçim yaptınız!"
                ;;
        esac
    done
}

# Script başlangıcı
check_files | zenity --progress --title="bilgi" --text="dosyalar başarıyla kontrol edildi" 
user_login
main_menu