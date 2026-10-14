#!/usr/bin/env bash
# =============================================================================
# AdGuard Home als unprivilegierter LXC auf Proxmox VE 9.x   (auf einem PVE-Node ausführen)
# ⚠️ BEISPIEL – alle <<PLATZHALTER>> ersetzen. Zuerst lesen, dann ausführen.
# Lizenz: MIT (siehe LICENSE)
# =============================================================================
set -euo pipefail

CTID="<<CTID>>"                         # z. B. 1101
HOSTNAME="adguard-n0"
NODE_STORAGE="<<STORAGE>>"              # z. B. local-zfs
TEMPLATE_STORAGE="local"
BRIDGE="vmbr0"
VLAN_TAG="<<VLAN>>"                     # z. B. 80 (SERVICES) oder 10 (MGMT)
IP_CIDR="<<IP>>/24"                     # z. B. 10.10.80.53/24
GATEWAY="<<GATEWAY>>"                   # z. B. 10.10.80.1 (OPNsense)
SSH_PUBKEY_FILE="<<PFAD_ZUM_PUBKEY>>"   # z. B. /root/.ssh/id_ed25519.pub

# 1) Aktuelles Debian-13-Template finden (Dateiname ändert sich mit jeder Version!)
pveam update
TEMPLATE="$(pveam available --section system | awk '/debian-13-standard/ {print $2}' | sort -V | tail -n1)"
[ -n "$TEMPLATE" ] || { echo "Kein debian-13-Template gefunden – 'pveam available' prüfen"; exit 1; }
pveam download "$TEMPLATE_STORAGE" "$TEMPLATE" || true   # schon vorhanden = ok

# 2) Container anlegen: unprivileged, minimal
pct create "$CTID" "${TEMPLATE_STORAGE}:vztmpl/${TEMPLATE}" \
  --hostname "$HOSTNAME" \
  --unprivileged 1 \
  --features nesting=1 \
  --cores 1 --memory 512 --swap 256 \
  --rootfs "${NODE_STORAGE}:4" \
  --net0 "name=eth0,bridge=${BRIDGE},tag=${VLAN_TAG},ip=${IP_CIDR},gw=${GATEWAY},firewall=1" \
  --nameserver 1.1.1.1 \
  --ssh-public-keys "$SSH_PUBKEY_FILE" \
  --onboot 1 --startup order=2 \
  --tags "dns;adguard"

pct start "$CTID"
sleep 5

# 3) AdGuard Home mit dem offiziellen Installationsskript installieren
#    Quelle: https://github.com/AdguardTeam/AdGuardHome#automated-install-linux-and-mac
pct exec "$CTID" -- bash -c "apt-get update && apt-get -y install curl ca-certificates && \
  curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v"

echo "✅ Fertig. Web-Setup: http://${IP_CIDR%/*}:3000  → Upstream z. B. Unbound <<UNBOUND_IP>>:5335"

# -----------------------------------------------------------------------------
# Optional: TUN-Device für WireGuard-/Tailscale-LXC (NICHT für AdGuard nötig)
# In /etc/pve/lxc/<CTID>.conf ergänzen:
#   lxc.cgroup2.devices.allow: c 10:200 rwm
#   lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
# Quelle: https://tailscale.com/kb/1130/lxc-unprivileged
# -----------------------------------------------------------------------------
