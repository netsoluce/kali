#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd)/"
OUTPUT_DIR="$BASE_DIR/output"

show_menu(){
  clear
  echo "=== NetSoluce Audit Case Menu ==="
  echo "1) Scan réseau"
  echo "2) Détection de fuites"
  echo "3) Génération de rapport"
  echo "4) Scan avancé (OS + CVE)"
  echo "5) Quitter"
  echo -n "Choix [1-5] : "
}

while true; do
  show_menu
  read -r choice
  case $choice in
    1)
      echo "[*] Lance le scan réseau…"
      bash "$BASE_DIR/scan/network_scan.sh"
      read -n1 -rsp $'\nAppuyez sur une touche pour revenir au menu…'
      ;;
    2)
      echo "[*] Lance la détection de fuites…"
      python3 "$BASE_DIR/scan/leak_check.py"
      read -n1 -rsp $'\nAppuyez sur une touche pour revenir au menu…'
      ;;
    3)
      echo "[*] Génère le rapport…"
      python3 "$BASE_DIR/reporting/generate_report.py"
      read -n1 -rsp $'\nAppuyez sur une touche pour revenir au menu…'
      ;;
 4)
      echo "[*] Lance le scan avancé…"
      bash "$BASE_DIR/scan/enhanced_scan.sh"
      ;;
    5)
      echo "Au revoir !"
      exit 0
      ;;
    *)
      echo "Choix invalide…"
      sleep 1
      ;;
  esac
done
