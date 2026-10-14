# 🔍 Reality Check – Grenzen, Risiken & Abweichungen

> Zurück zur [README](../README.md) · Companion: [sovereign-datacenter/docs/reality-check.md](https://github.com/node300-net/sovereign-datacenter/blob/main/docs/reality-check.md)

Die Hardwarespezifikation (**SM-2026TT-SPEC-V1**, als `.docx` übergeben) wird **unverändert übernommen**. Dieses Dokument ergänzt sie um **sachliche, respektvolle Hinweise**. Die Nummern **RC-1 bis RC-11** sind mit dem Companion-Repo identisch (dort teils ausführlicher); **RC-N1 ff.** sind **neu** in diesem Repo.

| Legende | |
|---|---|
| 🟢 | Unkritisch, nur Hinweis |
| 🟡 | Funktioniert mit Einschränkungen / Prüfung nötig |
| 🔴 | Hohes Risiko oder wahrscheinlich inkompatibel – vor Betrieb klären |

## 📋 Übersicht

| # | Thema | Status | Kurzfassung |
|---|---|---|---|
| [RC-1](#rc-1) | Netzteile „2'800 W“ | 🟡 | 1+1 redundant ⇒ nutzbar ≈ 1'400 W; Gold vs. Platinum prüfen |
| [RC-2](#rc-2) | 250–285-W-GPUs im 2U-Twin | 🔴 | Passen nicht ins Gehäuse, keine GPU-Stromstecker → extern |
| [RC-3](#rc-3) | **1 PCIe-Slot pro Node** | 🔴 | X710 **oder** GPU – nicht beides |
| [RC-4](#rc-4) | TB5-eGPU auf Westmere (NODE 1) | 🔴 | Experimentell, kein TB-Support im Board |
| [RC-5](#rc-5) | Kühlung NODE 3 | 🟡 | Alle Nodes teilen die Lüfter |
| [RC-6](#rc-6) | RAM-Slots | 🟡 | 12 Slots/Node laut SuperMicro, Spec impliziert 18 |
| [RC-7](#rc-7) | Huawei nur 2× SFP+ | 🟡 | Ring/DAC statt Stern |
| [RC-8](#rc-8) | „iLO“ = IPMI | 🟢 | Begriff; Sicherheit beachten |
| [RC-9](#rc-9) | eGPU-Kenndaten | 🟡 | Werte am Gerät prüfen |
| [RC-10](#rc-10) | **Westmere-Grenzen** | 🟡 | Kein AVX, PCIe 2.0, kein Firmware-Support |
| [RC-11](#rc-11) | Firewalla-Ports | 🟢 | Herstellerangaben prüfen |
| [RC-N1](#rc-n1) | **Quorum & HA im Einzelchassis** | 🔴 | HA ≠ Chassis-Redundanz; QDevice extern |
| [RC-N2](#rc-n2) | „96–192 TB“ Storage | 🟡 | Rechnung & SATA-Grenzen |
| [RC-N3](#rc-n3) | x86-64-v3-Gastsysteme | 🔴 | RHEL 10 & Co. starten nicht |
| [RC-N4](#rc-n4) | Ceph auf dieser Hardware | 🟡 | Lernprojekt, nicht Fundament |
| [RC-N5](#rc-n5) | X710 im PCIe-2.0-Slot & SFP+-Module | 🟡 | Bandbreite reicht; Modul-Kompatibilität |
| [RC-N6](#rc-n6) | GPU auf dem Firewall-Node | 🟡 | Angriffsfläche & Slot-Konflikt |
| [RC-N7](#rc-n7) | NVIDIA-Treiber für Pascal | 🟡 | R580 letzter Branch, Security-only bis 10/2028 |
| [RC-N8](#rc-n8) | Honeypots in LXC | 🟡 | Kernel geteilt → VM oder unprivileged + Egress-Sperre |
| [RC-N9](#rc-n9) | Strom- & Lärmzahlen | 🟡 | Keine Messwerte vorhanden |

---

<a id="rc-1"></a>
## RC-1 🟡 Netzteile: „2'800 W max., N+1“

- **Spec:** 2× 1400 W PWS-1K41P-1R (**Platinum**), „2800 W max., N+1“, + 2 Spare-Module.
- **Realität:** Bei **1+1-Redundanz** muss **ein** Netzteil die Last allein tragen ⇒ nutzbar ≈ **1'400 W** bei 180–240 V (bei 100–140 V nur 1'100 W) ✅ ([SuperMicro](https://www.supermicro.com/products/system/2U/2026/SYS-2026TT-HIBXRF.cfm)). 2'800 W ist die Summe der Typenschilder.
- **Neu:** SuperMicro führt das 2026TT-HIBXRF mit einem **„Gold Level“**-1400-W-Netzteil. Ob die verbauten Module Platinum sind, hängt vom Modul ab ⚠️ → **Typenschild prüfen**.
- ✅ **Empfehlung:** Last per PMBus/IPMI und Messsteckdose überwachen; Elektrofachkraft gemäss Sicherheitshinweis der Spec.

<a id="rc-2"></a>
## RC-2 🔴 250–285-W-GPUs in einem 2U-Twin-Node

- Jeder Node hat **einen Low-Profile-PCIe-x16-Slot** über Riser RSC-R1U-E16R ✅; Dual-Slot-Full-Height-Karten passen **nicht** ins Gehäuse, und die Boards haben **keine** 6/8-Pin-GPU-Stromanschlüsse.
- NVIDIA nennt für die RTX 3070 Ti **290 W** Board Power (Spec: 285 W) – unerheblich, aber notiert.
- ✅ **Empfehlung:** GPUs **ausserhalb** des Chassis mit **eigenem ATX-Netzteil** und eigener Kühlung; Chassis geschlossen halten.

<a id="rc-3"></a>
## RC-3 🔴 Ein PCIe-Slot pro Node: X710 vs. GPU

- **Spec:** pro Node **X710 Dual-SFP+** und bei N0/N1/N2 zusätzlich **GPU/eGPU**.
- **Realität:** **1 (x16) PCI-E (Low Profile)** pro Node ✅ ([SuperMicro](https://www.supermicro.com/products/system/2U/2026/SYS-2026TT-HIBXRF.cfm)). X710 und GPU-Riser/TB-Adapter **konkurrieren**. Bifurcation bietet das BIOS dieser Generation typischerweise nicht ⚠️.
- ✅ **Optionen:** (1) pro Node **entweder** 10GbE **oder** GPU; (2) aktive PCIe-Switch-Karte (teuer, mechanisch schwierig); (3) bei HIBXF-Boards **onboard InfiniBand** (QSFP, 20 Gb/s DDR) als zweites schnelles Netz (IPoIB) nutzen ✅.
- 💡 **Konsequenz für dieses Repo:** Der Use-Case-Katalog plant **GPU-Lasten auf NODE 2** und **10GbE auf N1/N3**; siehe [RC-N6](#rc-n6).

<a id="rc-4"></a>
## RC-4 🔴 Thunderbolt 5 auf Westmere (NODE 1)

- Westmere/5520-Boards haben **keinen** TB-Controller/Header und keine TB-Firmware-Unterstützung; der Slot ist **PCIe 2.0**.
- Das **ROG XG Mobile GC31** (2021) nutzt laut ASUS die proprietäre **„XG Mobile interface (PCIe Gen3 x8)“**, nicht Thunderbolt ✅ ([ASUS](https://rog.asus.com/external-graphics-docks/2021-rog-xg-mobile-model/spec/)).
- ✅ **Einordnung:** experimentell. Cowrie/OpenCanary brauchen **keine GPU**.

<a id="rc-5"></a>
## RC-5 🟡 Kühlung NODE 3

- **Spec (.docx):** „GPU-Slot dediziert unbelegt (Kühlungsentlastung)“. *(Das ältere Repo schrieb „passiv gekühlt“ – das steht so nicht in der Spezifikation; hier korrigiert.)*
- **Realität:** **Alle** CPUs haben passive Kühlkörper (SNK-P0037P) und werden von **4 gemeinsamen Chassis-Lüftern** gekühlt ✅. Ein freier Slot entlastet NODE 3 leicht, die Nodes bleiben thermisch gekoppelt.
- ✅ Blenden, Air-Shrouds und Bay-Blanks montiert lassen; Temperaturen per IPMI überwachen.

<a id="rc-6"></a>
## RC-6 🟡 RAM-Bestückung vs. Slotanzahl

- **Spec:** N0 „12× 8 GB, 6 Slots frei“, N1/N2 „16× 8 GB, 2 Slots frei“, N3 „6× 8 GB, 12 Slots frei“ ⇒ impliziert **18 Slots**.
- **SuperMicro:** **12 DIMM-Slots** pro Node, max. 192 GB RDIMM ✅.
- **Konsequenz:** 128 GB entstehen z. B. aus **8× 16 GB**. Summe **400 GB** stimmt. `dmidecode -t memory` prüfen.

<a id="rc-7"></a>
## RC-7 🟡 Core-Switch-Ports

- Huawei S220S-24LP4JX: 24× GE PoE+, **2× 10GE SFP+**, 2× 2.5GE SFP (Datenblatt). 4 Nodes × 2 X710-Ports passen nicht.
- ✅ Ring/Punkt-zu-Punkt per **DAC** (Phase 3 sieht DAC-Kabel vor) – Details im [Companion-Repo](https://github.com/node300-net/sovereign-datacenter/blob/main/docs/architecture.md).

<a id="rc-8"></a>
## RC-8 🟢 „iLO“ vs. IPMI

iLO ist HPEs BMC-Marke; das 2026TT nutzt **SuperMicro IPMI 2.0** (Nuvoton WPCM450) ✅. ⚠️ Alte BMC-Firmware ⇒ nur VLAN 20, nur via Jumphost.

<a id="rc-9"></a>
## RC-9 🟡 eGPU-Kenndaten

Spec: XG Mobile RTX 3080 „8 GB GDDR6, 140 W“. ASUS GC31: RTX 3080 Laptop GPU **16 GB, bis 150 W**; die RTX-3070-Variante hat 8 GB ✅. Mit `nvidia-smi` verifizieren.

<a id="rc-10"></a>
## RC-10 🟡 Westmere-Plattformgrenzen

| Grenze | Detail |
|---|---|
| ❌ Kein AVX/AVX2/AVX-512 | L5640: SSE4.2 + AES-NI, **kein AVX** ✅ ([Intel ARK](https://www.intel.com/content/www/us/en/products/sku/47926/intel-xeon-processor-l5640-12m-cache-2-26-ghz-5-86-gts-intel-qpi/specifications.html)) |
| PCIe 2.0 | ~8 GB/s auf x16; ein „PCIe 5.0“-Riser (NODE 0) ändert daran nichts |
| VT-d (5520) | Interrupt-Remapping-Errata bei manchen Revisionen; `allow_unsafe_interrupts=1` schwächt die Isolation (Sicherheits-Trade-off) |
| SATA | ICH10R, **3 Gb/s** ✅ |
| Firmware | **EOL** ✅, keine BIOS/BMC-Updates |
| Leistung/Watt | Schlecht verglichen mit aktuellen CPUs ⚠️ |

<a id="rc-11"></a>
## RC-11 🟢 Firewalla Gold Pro

Spec: „Gigabit WAN/LAN (25 W)“; Hersteller bewirbt **10GbE- und 2.5GbE-Ports** ⚠️ – am Gerät prüfen. Details: [firewalla-gold-pro-msp](https://github.com/node300-net/firewalla-gold-pro-msp).

---

<a id="rc-n1"></a>
## RC-N1 🔴 Quorum & HA im Einzelchassis

- **4 Nodes = 4 Stimmen, Quorum 3.** Ein Ausfall ✅, zwei Ausfälle oder ein 2:2-Split ❌ → **QDevice** auf **externer** Hardware (Pi/Mini-PC) ✅ ([Admin Guide](https://pve.proxmox.com/pve-docs/pve-admin-guide.html#_corosync_external_vote_support)). Beispiel: [`configs/cluster/qdevice-setup.sh`](../configs/cluster/qdevice-setup.sh).
- **Gemeinsame Fehlerpunkte:** PSU-Käfig, Backplane, Lüfter, Stromkreis, Rack, Raum. HA hilft gegen **Node**-Defekte, nicht gegen diese.
- **Corosync** braucht **niedrige Latenz** und sollte einen **eigenen** Link haben (hier VLAN 30 am Zyxel) plus einen zweiten Link als Fallback ✅.
- ✅ **Empfehlung:** PBS-Sync/Backups **ausserhalb** des Chassis; QDevice auf **unabhängiger** Hardware (eigenes Netzteil, idealerweise USV). Gegen einen Totalausfall des Chassis hilft es nicht – wohl aber bei Ausfall/Wartung von **zwei** Nodes oder einer Netzwerk-Teilung.

<a id="rc-n2"></a>
## RC-N2 🟡 „24× frei für 96–192 TB“

- 192 TB ÷ 24 Bays = **8 TB pro 2.5″-Laufwerk**. Im 2.5″-Format sind solche Kapazitäten praktisch nur mit **SSDs** erreichbar (2.5″-HDDs sind deutlich kleiner) ⚠️ – entsprechend teuer.
- „24× frei“ widerspricht der Spec selbst: Pro Node ist bereits **eine** SSD/HDD verbaut ⇒ **20 frei**.
- **SATA 3 Gb/s** (ICH10R) begrenzt jede SSD auf ~300 MB/s ✅. ⚠️ Ob der ICH10R/BIOS-Kombination sehr grosse Laufwerke zuverlässig erkennt, vorab mit **einem** Laufwerk testen.
- ✅ Realistisch für Phase 3 (4 Bulk-Disks): PBS-Datastore oder ZFS-Mirror auf NODE 3.

<a id="rc-n3"></a>
## RC-N3 🔴 x86-64-v3-Gastsysteme starten nicht

- Westmere erfüllt **x86-64-v2** (SSE4.2, POPCNT, SSSE3), aber **nicht v3** (AVX2, FMA, BMI). Der Proxmox-Default-CPU-Typ **`x86-64-v2-AES`** passt ✅; `host` reicht die echten Flags durch.
- **RHEL 10** setzt **x86-64-v3** voraus ⇒ ❌ (gilt auch für davon abgeleitete Builds ohne v2-Variante). AlmaLinux bietet für Version 10 eine **x86-64-v2-Variante** an ⚠️ – prüfen.
- **AVX-Pflicht** in Software: vorkompilierte TensorFlow-Wheels (seit 1.6), **MongoDB ≥ 5.0** (betrifft u. a. Apps, die MongoDB mitbringen), manche ML-/Vektor-DB-Images ❌.
- ✅ **Empfehlung:** Debian 12/13, Ubuntu 22.04/24.04 als Gast-Standard; bei neuen Images zuerst `grep -m1 -o avx /proc/cpuinfo` vs. Anforderungen prüfen.

<a id="rc-n4"></a>
## RC-N4 🟡 Ceph auf dieser Hardware

- 4 Nodes ✅, aber: **1 Datendisk/Node**, SATA 3 Gb/s, **10GbE nur dort, wo kein GPU-Konflikt** ([RC-3](#rc-3)), Huawei mit nur 2× SFP+ ([RC-7](#rc-7)).
- 3-fach-Replikation ⇒ **⅓ nutzbar**.
- ✅ Als **Lernumgebung** hervorragend (Ceph Tentacle 20.2 ist in PVE 9.2 verfügbar ✅); als Speicher-Fundament: **ZFS + Replikation + PBS**.

<a id="rc-n5"></a>
## RC-N5 🟡 X710 im PCIe-2.0-Slot & SFP+-Module

- X710-DA2 ist eine **PCIe-3.0-x8**-Karte. Im **PCIe-2.0**-Slot laufen 8 Lanes mit ~4 GB/s ≈ 32 Gb/s ⇒ **reicht rechnerisch für 2× 10 GbE** ⚠️ (eigene Ableitung; Overhead nicht berücksichtigt).
- Intel-X710-Karten akzeptieren standardmässig nur **qualifizierte SFP+-Module/DACs**; fremde Module werden u. U. als „unsupported“ abgelehnt 🟦 (häufige Community-Berichte). ⚠️ DAC-Kabel für Phase 3 entsprechend codiert kaufen und `dmesg | grep i40e` prüfen.

<a id="rc-n6"></a>
## RC-N6 🟡 GPU auf dem Firewall-Node (NODE 0)

- **Spec:** GTX 1080 Ti an NODE 0 („Parallel ML & Filter-Rules“).
- **Bedenken:** (1) **Slot-Konflikt** mit der X710 ([RC-3](#rc-3)); (2) Passthrough + proprietäre Treiber + ML-Software auf dem **sicherheitskritischsten** Node erhöhen die **Angriffsfläche**; (3) Westmere-VT-d-Errata ([RC-10](#rc-10)) schwächen ggf. die DMA-Isolation.
- ✅ **Vorschlag:** Firewall-Node **schlank** halten; GPU-Lasten auf **NODE 2** bündeln (Ollama, Jellyfin, ML). Bleibt die 1080 Ti auf N0, dann **nur** in einer isolierten VM im SERVICES-VLAN, nie im Firewall-Gast.

<a id="rc-n7"></a>
## RC-N7 🟡 NVIDIA-Treiber für Pascal (GTX 1080 Ti)

- **R580** ist der **letzte Treiber-Branch** für Maxwell/Pascal/Volta; GeForce-Karten erhalten ab Oktober 2025 nur noch **kritische Sicherheitsupdates bis Oktober 2028** ✅ ([NVIDIA](https://nvidia.custhelp.com/app/answers/detail/a_id/5676/~/support-plan-for-maxwell%2C-pascal%2C-and-volta-series-geforce-gpus) · [Unix Legacy](https://nvidia.custhelp.com/app/answers/detail/a_id/3142/~/support-timeframes-for-unix-legacy-gpu-releases)).
- Folge: Neuere CUDA-Versionen/Frameworks können Pascal irgendwann nicht mehr bedienen. RTX 3070 Ti (Ampere) ist davon nicht betroffen.

<a id="rc-n8"></a>
## RC-N8 🟡 Honeypots in LXC

- LXC teilt den **Host-Kernel**. Ein Kernel-Exploit aus einem Container trifft den **Proxmox-Host**.
- ✅ Cowrie/OpenCanary in **unprivilegierten** LXCs oder (besser) in einer **VM**; **VLAN 50 Egress sperren**; Logs nur nach aussen schieben (Push), nie Pull-Zugriff aus dem Honeypot ins MGMT.

<a id="rc-n9"></a>
## RC-N9 🟡 Strom & Lärm – keine Messwerte

- Die Spec nennt **> 1'200 W Peak** inkl. GPUs. Für Leerlauf/Durchschnitt und Lautstärke gibt es **keine** Messungen; alle Zahlen in [why-2u4n.md](why-2u4n.md#-stromkosten--rechne-selbst) sind **Annahmen** ⚠️.
- ✅ Beiträge mit echten Messwerten (Messsteckdose, `ipmitool dcmi power reading`, dB(A) in 1 m) sind sehr willkommen → [CONTRIBUTING](../CONTRIBUTING.md).

---

> 💬 *Keiner dieser Punkte macht das Projekt schlecht – genau an diesen Grenzen lernt man, wie Cluster, Hardware und Sicherheit wirklich funktionieren.* 🛠️
