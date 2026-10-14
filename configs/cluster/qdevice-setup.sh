#!/usr/bin/env bash
# =============================================================================
# Corosync QDevice für den 4-Node-Cluster einrichten (externe 5. Stimme)
# ⚠️ BEISPIEL – <<PLATZHALTER>> ersetzen. Quelle:
#   https://pve.proxmox.com/pve-docs/pve-admin-guide.html#_corosync_external_vote_support
# Lizenz: MIT
# =============================================================================
set -euo pipefail

QNETD_IP="<<QDEVICE_IP>>"     # externer Pi/Mini-PC im MGMT-VLAN 10, NICHT im 2U-Chassis

cat <<INFO
Schritt 1 – auf dem EXTERNEN Gerät (Debian/Raspberry Pi OS):
    apt install corosync-qnetd
    # Root-SSH-Login muss für die Einrichtung vorübergehend möglich sein

Schritt 2 – auf ALLEN vier Proxmox-Nodes:
    apt install corosync-qdevice

Schritt 3 – auf EINEM Proxmox-Node:
    pvecm qdevice setup ${QNETD_IP}

Schritt 4 – Prüfen (erwartet: "Expected votes: 5", "Quorum: 3"):
    pvecm status
INFO

read -rp "Schritt 3 jetzt auf diesem Node ausführen? [y/N] " ans
if [[ "${ans,,}" == "y" ]]; then
  pvecm qdevice setup "$QNETD_IP"
  pvecm status
fi
