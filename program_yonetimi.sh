#!/bin/bash

# Diskteki Alanı Göster
function show_disk_usage() {
    du -sh depo.csv kullanici.csv log.csv | zenity --text-info --title="Disk Kullanımı"
}

# Diske Yedekleme
function backup_files() {
    tar -czf backup.tar.gz depo.csv kullanici.csv
    zenity --info --text="Dosyalar yedeklendi: backup.tar.gz"
}

# Program Yönetim Menüsü
function program_management_menu() {
    choice=$(zenity --list --title="Program Yönetimi" \
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