#!/usr/bin/env bash
# =============================================================================
# OPNsense-VM auf NODE 0 (SEC-CORE) mit qm anlegen – Proxmox VE 9.x
# ⚠️ BEISPIEL – <<PLATZHALTER>> ersetzen. IPMI-KVM offen halten.
# Gilt sinngemäss auch für pfSense CE (anderes ISO).
# Quellen: https://pve.proxmox.com/pve-docs/qm.1.html · https://docs.opnsense.org/manual/install.html
# Lizenz: MIT
# =============================================================================
set -euo pipefail

VMID="<<VMID>>"                              # z. B. 100
NAME="opnsense-n0"
STORAGE="<<STORAGE>>"                        # z. B. local-zfs
ISO="local:iso/<<OPNSENSE_ISO>>"             # z. B. OPNsense-<<VER>>-dvd-amd64.iso (entpackt, nicht .bz2!)
BRIDGE="vmbr0"                               # VLAN-aware Bridge (siehe configs/network/)
WAN_VLAN="100"                               # Transit Firewalla ↔ OPNsense
LAN_TRUNKS="50;60;80;90"                     # VLANs, die OPNsense routen/filtern soll

qm create "$VMID" \
  --name "$NAME" \
  --ostype other \
  --machine q35 \
  --bios seabios \
  --cpu x86-64-v2-AES \
  --sockets 1 --cores 4 \
  --memory 8192 --balloon 0 \
  --scsihw virtio-scsi-single \
  --scsi0 "${STORAGE}:32,iothread=1,discard=on,ssd=1" \
  --ide2 "${ISO},media=cdrom" \
  --boot "order=scsi0;ide2" \
  --net0 "virtio,bridge=${BRIDGE},tag=${WAN_VLAN},firewall=0" \
  --net1 "virtio,bridge=${BRIDGE},trunks=${LAN_TRUNKS},firewall=0" \
  --agent enabled=0 \
  --onboot 1 \
  --startup "order=1,up=60" \
  --tags "firewall;sec-core"

# Hinweise:
#  - Ballooning aus (--balloon 0): Firewalls sollen nicht um RAM kämpfen.
#  - firewall=0 auf den NICs: die Proxmox-Firewall nicht zusätzlich vor die Firewall-VM hängen.
#  - net1 ohne tag + trunks=… → OPNsense bekommt die VLANs getaggt (vtnet1 → VLAN-Interfaces anlegen).
#  - Hardware-Offloading (CRC/TSO/LRO) in OPNsense unter Interfaces ▸ Settings bei virtio deaktivieren
#    (Empfehlung der OPNsense-Doku für virtualisierte Installationen – prüfen).
#  - Für HA: Disk per Storage-Replication auf einen 2. Node replizieren:
#      pvesr create-local-job ${VMID}-0 <<ZIEL_NODE>> --schedule "*/5"
#      ha-manager add vm:${VMID} --state started

qm start "$VMID"
echo "✅ VM ${VMID} gestartet → Konsole: qm terminal ${VMID} (oder noVNC in der GUI)"
