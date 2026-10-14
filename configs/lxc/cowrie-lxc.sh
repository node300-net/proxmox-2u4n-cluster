#!/usr/bin/env bash
# =============================================================================
# Cowrie SSH-Honeypot nativ in einem unprivilegierten LXC (NODE 1, VLAN 50 DMZ-HONEY)
# ⚠️ BEISPIEL – <<PLATZHALTER>> ersetzen. Egress von VLAN 50 auf der Firewall SPERREN!
# Besser noch: in einer VM betreiben (eigener Kernel) – siehe docs/reality-check.md#rc-n8
# Install-Schritte nach: https://docs.cowrie.org/en/latest/INSTALL.html
# Lizenz: MIT
# =============================================================================
set -euo pipefail

CTID="<<CTID>>"                 # z. B. 1501
STORAGE="<<STORAGE>>"           # z. B. local-zfs
IP_CIDR="<<IP>>/24"             # z. B. 10.10.50.22/24
GATEWAY="<<GATEWAY>>"           # z. B. 10.10.50.1

pveam update
TEMPLATE="$(pveam available --section system | awk '/debian-13-standard/ {print $2}' | sort -V | tail -n1)"
pveam download local "$TEMPLATE" || true

pct create "$CTID" "local:vztmpl/${TEMPLATE}" \
  --hostname honeypot-ssh \
  --unprivileged 1 \
  --cores 1 --memory 1024 --swap 512 \
  --rootfs "${STORAGE}:10" \
  --net0 "name=eth0,bridge=vmbr0,tag=50,ip=${IP_CIDR},gw=${GATEWAY},firewall=1" \
  --onboot 1 --tags "honeypot;dmz"

pct start "$CTID"; sleep 5

pct exec "$CTID" -- bash -euxc '
  apt-get update
  apt-get -y install git python3-venv python3-dev libssl-dev libffi-dev build-essential authbind
  id cowrie >/dev/null 2>&1 || adduser --disabled-password --gecos "" cowrie
  su - cowrie -c "
    git clone https://github.com/cowrie/cowrie.git ~/cowrie
    cd ~/cowrie
    python3 -m venv cowrie-env
    . cowrie-env/bin/activate
    python -m pip install --upgrade pip
    python -m pip install -e .
    cowrie start
  "
'

echo "✅ Cowrie lauscht auf 2222 (SSH) / 2223 (Telnet)."
echo "   Firewall: DNAT WAN:22 → ${IP_CIDR%/*}:2222 (nur wenn bewusst gewollt!)"
echo "   Logs: ~cowrie/cowrie/var/log/cowrie/cowrie.json → Wazuh/Loki"
