#!/bin/bash
read -p "Entrez la plage IP à scanner (ex: 192.168.1.0/24) : " TARGET
echo "[*] Scan Nmap en cours sur $TARGET..."
nmap -sV --script=vuln -oN ../output/scan_result.txt $TARGET
echo "[*] Scan terminé. Résultats enregistrés dans output/scan_result.txt"
