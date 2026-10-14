# 🧰 configs/ – Beispielkonfigurationen

> [!CAUTION]
> Alles hier sind **Beispiele**. Platzhalter sind als `<<PLATZHALTER>>` markiert und **müssen** ersetzt werden. Skripte zuerst **lesen**, dann auf einem Test-Node ausführen. IPMI-KVM offen halten.

| Datei | Zweck | Node | Typ |
|---|---|---|---|
| [`lxc/adguard-lxc.sh`](lxc/adguard-lxc.sh) | AdGuard Home als unprivilegierter LXC per `pct create` (+ TUN-Hinweis für WireGuard/Tailscale) | N0 / N3 | Bash |
| [`lxc/cowrie-lxc.sh`](lxc/cowrie-lxc.sh) | Cowrie nativ in einem LXC (VLAN 50) | N1 | Bash |
| [`lxc/nvidia-share.lxc.conf.example`](lxc/nvidia-share.lxc.conf.example) | NVIDIA-GPU mit mehreren LXCs teilen (Jellyfin, Ollama) | N2 | LXC-Config |
| [`docker/cowrie/docker-compose.yml`](docker/cowrie/docker-compose.yml) | Cowrie als gehärteter Docker-Container | N1 | Compose |
| [`vm/opnsense-vm.sh`](vm/opnsense-vm.sh) | OPNsense-/pfSense-VM per `qm create` mit WAN-Transit + VLAN-Trunk | N0 | Bash |
| [`network/interfaces.vlan.example`](network/interfaces.vlan.example) | VLAN-aware Bridge, Mgmt-VLAN-Interface, Corosync-Link, Storage-Link, SPAN-Bridge | alle | ifupdown2 |
| [`opencanary/opencanary.conf.example`](opencanary/opencanary.conf.example) | OpenCanary mit FTP/HTTP/RDP/MySQL/SNMP-Ködern, Syslog an N3 | N1 | JSON |
| [`cluster/qdevice-setup.sh`](cluster/qdevice-setup.sh) | QDevice als 5. Stimme für den 4-Node-Cluster | extern + alle | Bash |

Weitere Beispiele (SDN, VFIO/GPU-Passthrough, nftables, Ansible, Terraform) im Companion-Repo: [sovereign-datacenter/configs](https://github.com/node300-net/sovereign-datacenter/tree/main/configs).

**Lizenz:** Dateien in `configs/` (ausser `*.md`) unter **MIT**.
