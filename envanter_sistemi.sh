#!/bin/bash

# Gerekli dosyaları kontrol eden ve oluşturan fonksiyon
check_files() {
    if [[ ! -f "depo.csv" ]]; then
        echo "depo.csv dosyası oluşturuluyor..."
        echo "ID,Ad,Stok,Fiyat,Kategori" > depo.csv
    fi
    if [[ ! -f "kullanici.csv" ]]; then
        echo "kullanici.csv dosyası oluşturuluyor..."
        echo "ID,KullaniciAdi,Parola,Role" > kullanici.csv
        echo "1,admin,21232f297a57a5a743894a0e4a801fc3,Admin" >> kullanici.csv
    fi
    if [[ ! -f "log.csv" ]]; then
        echo "log.csv dosyası oluşturuluyor..."
        echo "Tarih,Islem,Hata" > log.csv
    fi
}

# Kullanıcı giriş fonksiyonu
user_login() {
    local attempts=0
    local max_attempts=3
    local username=""
    local password=""

    while (( attempts < max_attempts )); do
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
            hashed_password=$(echo -n "$password" | md5sum | cut -d' ' -f1)

            user_info=$(awk -F ',' -v user="$username" -v pass="$hashed_password" 'NR>1 && $2==user && $3==pass {print $0}' kullanici.csv)
            if [[ -n "$user_info" ]]; then
                user_role=$(echo "$user_info" | cut -d',' -f4)
                zenity --info --title="Başarılı Giriş" --text="Hoş geldiniz, $username! Rolünüz: $user_role"
                return 0
            else
                ((attempts++))
                zenity --error --text="Hatalı kullanıcı adı veya şifre. Kalan deneme hakkınız: $((max_attempts - attempts))"
            fi
        else
            zenity --error --text="Giriş bilgileri eksik!"
        fi
    done

    zenity --error --text="Çok fazla hatalı giriş yaptınız. Program sonlandırılıyor."
    exit 1
}

# Yetki kontrol fonksiyonu
check_permissions() {
    local action=$1  # İşlem türü: "modify", "view", "report"

    case $user_role in
        "Admin")
            return 0  # Admin tüm işlemlere izinlidir
            ;;
        "Kullanıcı")
            if [[ "$action" == "view" || "$action" == "report" ]]; then
                return 0  # Kullanıcı yalnızca görüntüleme ve rapor alma işlemlerine izinlidir
            else
                zenity --error --title="Yetki Hatası" --text="Bu işlemi yapma yetkiniz yok!"
                return 1
            fi
            ;;
        *)
            zenity --error --title="Yetki Hatası" --text="Geçersiz rol!"
            return 1
            ;;
    esac
}

# Ana menü fonksiyonu
main_menu() {
    while true; do
        secim=$(zenity --list --title="Ana Menü" --column="Seçenekler" \
            "Ürün Islemleri" \
            "Rapor Islemleri" \
            "Kullanıcı Yönetimi" \
            "Program Yönetimi" \
            "Çıkış")

        if [[ $? -ne 0 ]]; then
            zenity --error --text="Menüden çıkıldı. Program sonlandırılıyor."
            exit 0
        fi

        case $secim in
            "Ürün Islemleri")
                if check_permissions "modify"; then
                    ./urun_islemleri.sh
                fi
                ;;
            "Rapor Islemleri")
                if check_permissions "report"; then
                    ./rapor_al.sh
                fi
                ;;
            "Kullanıcı Yönetimi")
                if check_permissions "modify"; then
                    ./kullanici_yonetimi.sh
                fi
                ;;
            "Program Yönetimi")
                if check_permissions "modify"; then
                    ./program_yonetimi.sh
                fi
                ;;
            "Çıkış")
                zenity --question --title="Çıkış Onayı" --text="Sistemden çıkmak istediğinizden emin misiniz?"
                if [[ $? -eq 0 ]]; then
                    zenity --info --title="Çıkış" --text="Sistemden çıkılıyor!"
                    exit 0
                else
                    zenity --info --title="İptal" --text="Çıkış işlemi iptal edildi."
                fi
                ;;
            *)
                zenity --error --title="Hata" --text="Geçersiz bir seçim yaptınız!"
                ;;
        esac
    done
}

# Script başlangıcı
check_files
user_login
main_menu