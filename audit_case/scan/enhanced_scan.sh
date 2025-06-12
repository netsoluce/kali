#!/usr/bin/env bash
#
# enhanced_scan.sh — Scan réseau avancé (OS, versions, CVE)

read -p "Entrez la plage IP à scanner (ex: 192.168.1.0/24) : " TARGET
TODAY=$(date +"%Y%m%d_%H%M")
OUT_DIR="../output"
XML_OUT="$OUT_DIR/scan_$TODAY.xml"
JSON_OUT="$OUT_DIR/scan_$TODAY.json"

mkdir -p "$OUT_DIR"

echo "[*] Lancement du scan Nmap avancé sur $TARGET..."
nmap -sV -O \
     --script vuln,vulners \
     --script-args vulners.showall=true \
     -oX "$XML_OUT" \
     "$TARGET"

echo "[*] Scan XML généré : $XML_OUT"
echo "[*] Conversion en JSON résumé..."
python3 << 'PYCODE'
import xml.etree.ElementTree as ET, json, sys, os

xml_file = sys.argv[1]
json_file = sys.argv[2]

tree = ET.parse(xml_file)
root = tree.getroot()

hosts = []
for host in root.findall('host'):
    addr = host.find('address').get('addr')
    os_el = host.find('os/osmatch')
    os_name = os_el.get('name') if os_el is not None else 'Inconnu'
    services = []
    for port in host.findall('ports/port'):
        svc = port.find('service')
        svc_info = {
            'port': port.get('portid'),
            'proto': port.get('protocol'),
            'name': svc.get('name') if svc is not None else '',
            'product': svc.get('product') or '',
            'version': svc.get('version') or '',
            'cves': []
        }
        # recherche des vulnérabilités via script vuln / vulners
        for script in port.findall('script'):
            if script.get('id') in ('vuln', 'vulners'):
                for elem in script.findall('table/elem'):
                    text = elem.text or ''
                    if text.startswith('CVE-'):
                        svc_info['cves'].append(text)
        services.append(svc_info)
    hosts.append({'ip': addr, 'os': os_name, 'services': services})

with open(json_file, 'w') as f:
    json.dump({'scan_date': root.get('startstr'), 'hosts': hosts}, f, indent=2)

print(f"[+] JSON résumé généré : {json_file}")
PYCODE "$XML_OUT" "$JSON_OUT"

echo "[√] Scan avancé terminé."
