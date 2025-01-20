#!/bin/bash

#ayarları burda tanımlamak için başlangıç noktası
export file_storage=$(grep "csvfilespath: " settings.yml | awk '{print $2}')
export wwidth=$(grep "w-width: " settings.yml | awk '{print $2}')
export wheight=$(grep "w-height: " settings.yml | awk '{print $2}')
export encrypt_type=$(grep "model1: " settings.yml | awk '{print $2}')

# Diskteki Alanı Göster
function show_disk_usage() {
    du -sh ${file_storage}/depo.csv ${file_storage}/kullanici.csv ${file_storage}/log.csv | zenity --text-info --title="Disk Kullanımı"
    
    if [[ $? -ne 0 ]]; then
        return
    fi
}

# Diske Yedekleme
function backup_files() {
    tar -czf backup.tar.gz ${file_storage}/depo.csv ${file_storage}/kullanici.csv
    zenity --info --text="Dosyalar yedeklendi: backup.tar.gz"
}

# Program Yönetim Menüsü
function program_management_menu() {
    choice=$(zenity --list --width=${wwidth} --height=${wheight} --title="Program Yönetimi" \
        --column="Seçim" --column="İşlem" \
        1 "Diskteki Alanı Göster" \
        2 "Diske Yedekle")

    case "$choice" in
        1) show_disk_usage ;;
        2) backup_files ;;
        *) zenity --error --text="Geçersiz seçim!" ;;
    esac
}

# Başlatma
program_management_menu