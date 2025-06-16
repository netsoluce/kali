#!/usr/bin/env python3
import xml.etree.ElementTree as ET
import json, sys, os

def main():
    if len(sys.argv) != 3:
        print("Usage: convert_scan_xml_to_json.py <xml_in> <json_out>")
        sys.exit(1)
    xml_file, json_file = sys.argv[1], sys.argv[2]
    tree = ET.parse(xml_file)
    root = tree.getroot()
    hosts = []
    for host in root.findall('host'):
        addr_el = host.find("address[@addr]")
        addr = addr_el.get('addr') if addr_el is not None else 'Inconnu'
        os_el = host.find('os/osmatch')
        os_name = os_el.get('name') if os_el is not None else 'Inconnu'
        services = []
        for port in host.findall('ports/port'):
            svc = port.find('service')
            info = {
                'port': port.get('portid'),
                'proto': port.get('protocol'),
                'name': svc.get('name','') if svc is not None else '',
                'product': svc.get('product','') if svc is not None else '',
                'version': svc.get('version','') if svc is not None else '',
                'cves': []
            }
            for script in port.findall('script'):
                if script.get('id') in ('vuln','vulners'):
                    for table in script.findall('table'):
                        for elem in table.findall('elem'):
                            txt = elem.text or ''
                            if txt.startswith('CVE-'):
                                info['cves'].append(txt)
            services.append(info)
        hosts.append({'ip': addr, 'os': os_name, 'services': services})
    os.makedirs(os.path.dirname(json_file), exist_ok=True)
    with open(json_file, 'w') as f:
        json.dump({'scan_date': root.get('startstr'), 'hosts': hosts}, f, indent=2)
    print(f"[+] JSON externe généré : {json_file}")

if __name__ == "__main__":
    main()
