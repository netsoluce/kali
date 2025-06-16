#!/usr/bin/env bash
#
# external_scan.sh — Audit externe d'IP/Domaine public

read -rp "Entrer IP publique ou domaine (ex: 8.8.8.8 ou example.com) : " TARGET

# Choix du mode de scan de ports
echo "1) Rapide  (top 100 ports, -F)"
echo "2) Complet (tous les ports, -p-)"
read -rp "Mode ports [1-2] : " PMODE
case "$PMODE" in
  1) PORT_ARGS="-F" ;;
  2) PORT_ARGS="-p-" ;;
  *) echo "Invalide, Rapide par défaut."; PORT_ARGS="-F" ;;
esac

# Choix du timing template Nmap
echo "Choisissez timing Nmap (0=Paranoid … 5=Insane) :"
read -rp "Template [0-5] : " TMPL
case "$TMPL" in
  0) TIMING="-T0" ;;
  1) TIMING="-T1" ;;
  2) TIMING="-T2" ;;
  3) TIMING="-T3" ;;
  4) TIMING="-T4" ;;
  5) TIMING="-T5" ;;
  *) echo "Invalide, -T3 par défaut."; TIMING="-T3" ;;
esac

# Intervalle d'affichage des stats
read -rp "Intervalle stats (--stats-every) (ex: 30s, 1m) [défaut 30s] : " STATS
STATS="${STATS:-30s}"

# Préparation des chemins de sortie
TODAY=$(date +"%Y%m%d_%H%M")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="$SCRIPT_DIR/../output"
XML_OUT="$OUT_DIR/external_${TODAY}.xml"
JSON_OUT="$OUT_DIR/external_${TODAY}.json"
mkdir -p "$OUT_DIR"

# Lancement du scan Nmap
echo "[*] Audit externe sur $TARGET ($PORT_ARGS $TIMING), stats tous les $STATS…"
nmap -Pn -sV -O $PORT_ARGS $TIMING \
     --stats-every "$STATS" \
     --script vuln,vulners --script-args vulners.showall=true \
     -oX "$XML_OUT" "$TARGET"

# Conversion du XML en JSON résumé
echo "[*] Conversion du XML en JSON résumé…"
python3 "$(dirname "$0")/convert_scan_xml_to_json.py" "$XML_OUT" "$JSON_OUT"
# Lancement des audits passifs via APIs tierces
echo "[*] Lancement des audits passifs via APIs tierces…"
python3 "$(dirname "$0")/external_apis.py" "$TARGET"
echo "[√] Audit externe terminé."
