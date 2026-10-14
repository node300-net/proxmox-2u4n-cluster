# 🏗️ Warum Enterprise-Hardware Jahrzehnte hält – und wo ihre Grenzen liegen

> Zurück zur [README](../README.md) · Vorher: [🗄️ Warum 2U-4-Node](why-2u4n.md) · Weiter: [🎯 Use Cases](use-cases.md)

Der Referenz-Cluster basiert auf **Intel Westmere-EP (2010)**. Er läuft 2026 – **16 Jahre später** – mit **Proxmox VE 9.2** auf Debian 13 (laut Spezifikation Phase 1 ✅ abgeschlossen). Warum ist das möglich, und was davon ist Physik, was Glück, was Marketing?

## 📚 Inhalt

1. [MTBF, AFR und was die Zahlen wirklich bedeuten](#-mtbf-afr-und-was-die-zahlen-wirklich-bedeuten)
2. [ECC-RAM: der unterschätzte Lebensretter](#-ecc-ram-der-unterschätzte-lebensretter)
3. [Bauteile für 24/7](#-bauteile-für-247)
4. [IPMI: der Server, der sich selbst beobachtet](#-ipmi-der-server-der-sich-selbst-beobachtet)
5. [Der Ersatzteilmarkt](#-der-ersatzteilmarkt)
6. [Firmware: Segen und Fluch](#-firmware-segen-und-fluch)
7. [Ehrliche Grenzen](#️-ehrliche-grenzen)

---

## 📉 MTBF, AFR und was die Zahlen wirklich bedeuten

**MTBF** (Mean Time Between Failures) ist eine **statistische Flottenzahl**, keine Lebensdauer. Umrechnung in eine jährliche Ausfallrate:

> **AFR ≈ 8'760 h ÷ MTBF**  → 1'000'000 h MTBF ≈ **0.88 % AFR** pro Jahr

| Erkenntnis | Quelle |
|---|---|
| Im Feld lagen die jährlichen Disk-**Austausch**raten typischerweise bei **2–4 %**, in einzelnen Systemen bis **13 %** – deutlich über den Datenblatt-AFRs (0.5–0.9 %). | ✅ Schroeder & Gibson, [*Disk failures in the real world*](https://www.usenix.org/conference/fast-07/disk-failures-real-world-what-does-mttf-1000000-hours-mean-you), USENIX FAST 2007 |
| Ausfallraten **steigen mit dem Alter** stetig an – kein „flacher Boden“ der Badewannenkurve nach den ersten Jahren. | ✅ ebenda |
| Laufende, öffentliche Ausfallstatistiken über Hunderttausende Laufwerke | ✅ [Backblaze Drive Stats](https://www.backblaze.com/cloud-storage/resources/hard-drive-test-data) |

> 🎓 **Didaktisch:** Enterprise-Hardware hält nicht „ewig“, weil jedes Teil unzerstörbar wäre, sondern weil sie **redundant gebaut**, **überwachbar** und **reparierbar** ist. Ein Lüfter, ein Netzteil, eine Disk, ein DIMM – alles ist ein **Verbrauchsteil mit Ersatz**.

---

## 🧠 ECC-RAM: der unterschätzte Lebensretter

| Fakt | Quelle |
|---|---|
| Rund **ein Drittel der Maschinen** und **über 8 % der DIMMs** in Googles Flotte hatten **mindestens einen korrigierbaren Fehler pro Jahr**. | ✅ Schroeder, Pinheiro, Weber: [*DRAM Errors in the Wild*](https://www.cs.toronto.edu/~bianca/papers/sigmetrics09.pdf), SIGMETRICS 2009 |
| Fehlerraten **steigen mit dem Alter** der Module; viele Fehler sind **Hard Errors** (defekte Zellen), nicht nur kosmische Strahlung. | ✅ ebenda |
| Das X8DTT-Board korrigiert **1-Bit-Fehler**, erkennt **2-Bit-Fehler** und unterstützt **SDDC** (Chipkill-ähnlich, x4/x8). | ✅ [SuperMicro 2026TT-Datenblatt](https://www.supermicro.com/products/system/2U/2026/SYS-2026TT-HIBXRF.cfm) |

**Warum das für ZFS und Proxmox wichtig ist:** ZFS prüft Daten **auf der Disk** mit Prüfsummen. Ein Bitfehler **im RAM**, bevor die Prüfsumme berechnet wird, ist für ZFS unsichtbar. ECC schliesst diese Lücke. Bei **400 GB RAM** und 24/7-Betrieb ist ECC keine Kür.

```bash
# Korrigierte/unkorrigierte Speicherfehler beobachten (EDAC-Treiber i7core_edac für Westmere)
apt install edac-utils && edac-util -v
ipmitool sel list | grep -i -E "ecc|memory"     # BMC-Eventlog
```

> ⚠️ Ob `i7core_edac` auf diesem Board alle Zähler liefert, hängt von BIOS und Kernel ab – im Zweifel ist das **IPMI-Eventlog** die verlässlichere Quelle.

---

## 🔩 Bauteile für 24/7

| Bauteil | Typisch Enterprise | Typisch Consumer | Warum relevant |
|---|---|---|---|
| CPU | Validiert für Dauerlast, niedrige TDP-Varianten (L5640: **60 W**) ✅ | Boost-optimiert | Weniger Hitze = weniger Alterung (⚠️ allgemeine Ingenieurregel, keine Messung) |
| Netzteile | Redundant, hot-swap, **PMBus**-Telemetrie ✅ | Einzeln, ohne Telemetrie | Ausfall ist planbar, Tausch ohne Downtime |
| Lüfter | Tachometer-überwacht, BMC regelt, hot-swap je nach Chassis ✅ | oft ohne Überwachung | Ein toter Lüfter löst einen Alarm aus statt einen Hitzetod |
| Disks | Enterprise-SSD (Kingston), **Constellation ES** (Enterprise-Nearline-HDD) | Desktop-Laufwerke | Für Dauerbetrieb und höhere Workloads spezifiziert (⚠️ exakte MTBF/Workload-Rating im Datenblatt des konkreten Modells prüfen) |
| Mainboard | Server-Layout, Kondensatoren/VRMs für Dauerbetrieb | variiert stark | ⚠️ Qualitative Aussage – Elkos altern trotzdem, besonders bei Hitze |

---

## 🧰 IPMI: der Server, der sich selbst beobachtet

Jeder Node hat einen eigenen **BMC (Nuvoton WPCM450)** mit **IPMI 2.0, KVM-over-LAN und Virtual Media** und einem **dedizierten LAN-Port** ✅ ([Datenblatt](https://www.supermicro.com/products/system/2U/2026/SYS-2026TT-HIBXRF.cfm)).

| Funktion | Nutzen im Alltag |
|---|---|
| 🖥️ KVM-over-LAN | BIOS, Installer, Rescue – ohne Monitor im Keller |
| 💿 Virtual Media | Proxmox-ISO aus der Ferne einhängen |
| 🌡️ Sensoren (Temp, Spannung, Lüfter) | Export nach Prometheus (`ipmi_exporter`) → Grafana |
| 📜 System Event Log | ECC-, PSU-, Lüfter-Ereignisse mit Zeitstempel |
| 🔌 Power-Control | Node aus/an/reset; ungenutzte Nodes nachts abschalten |

> 🔴 **Sicherheit:** BMC-Firmware dieser Generation ist **alt** und hatte in der Vergangenheit gravierende Schwachstellen (siehe z. B. [Rapid7: A Penetration Tester's Guide to IPMI and BMCs](https://www.rapid7.com/blog/post/2013/07/02/a-penetration-testers-guide-to-ipmi/)). **Regel:** IPMI nur im isolierten **VLAN 20**, nie ins Internet, nie in Lab-/DMZ-VLANs, Zugriff nur über Jumphost/VPN, Default-Passwörter ändern.

---

## 🛒 Der Ersatzteilmarkt

Rechenzentren tauschen Hardware in **Wellen** aus. Dadurch entsteht ein grosser **Gebrauchtmarkt** für genau die Teile, die dieser Cluster braucht:

| Teil | Verfügbarkeit (qualitativ) ⚠️ | Hinweis |
|---|---|---|
| DDR3 ECC REG 8/16 GB | Sehr gut, günstig | Gleiche Spannung (1.5 V/1.35 V) und Rank-Konfiguration pro Kanal beachten |
| Xeon 5600 (L/E/X) | Sehr gut | Gleicher Typ pro Board (Datenblatt) |
| PWS-1K41-Serie | Gut (Spare-PSUs sind laut Spec bereits vorhanden ✅) | Gleiches Modell in beiden Schächten |
| 2.5″-Caddies, Lüfter, Riser | Gut | Original-Teilenummern aus dem Datenblatt verwenden (z. B. MCP-220-00047-0B) |
| Komplette Nodes (X8DTT) | Mittel | Ideal als „Kalt-Ersatz“ |

> ⚠️ Preise und Verfügbarkeit sind **nicht recherchiert/garantiert** und schwanken stark. Gebrauchte Netzteile vor Einsatz unter Last testen.

---

## 💾 Firmware: Segen und Fluch

| | Bewertung |
|---|---|
| ✅ **Ausgereift** | Nach über einem Jahrzehnt sind die meisten BIOS-Bugs dieser Plattform bekannt und dokumentiert (Foren, Mailinglisten) |
| ✅ **Offene Standards** | IPMI, PXE, AHCI, ACPI – kein Hersteller-Cloud-Zwang |
| ⚠️ **End of Life** | SuperMicro führt die Systeme als **„Discontinued SKU (EOL)“** ✅ – keine neuen BIOS/BMC-Updates zu erwarten |
| ⚠️ **CPU-Microcode** | Mitigations für spekulative Ausführung (Spectre & Co.) sind auf Westmere **teilweise** verfügbar und kosten Leistung; Status pro Node prüfen (`grep . /sys/devices/system/cpu/vulnerabilities/*`) |
| ⚠️ **Kein UEFI Secure Boot** (typisch für diese Generation) | Proxmox installiert im Legacy-Modus mit GRUB; Secure-Boot-Kette nicht verfügbar |

---

## ⚖️ Ehrliche Grenzen

| Grenze | Detail | Auswirkung |
|---|---|---|
| ⚡ **Strom** | 8 Sockel aus 2010; schlechte Leistung pro Watt im Vergleich zu aktuellen CPUs ⚠️ | Laufende Kosten (siehe [Rechner](why-2u4n.md#-stromkosten--rechne-selbst)) |
| 🔊 **Lärm** | Kleine Hochdrehzahl-Lüfter | Nicht wohnraumtauglich |
| 🕰️ **Alterung** | Elkos, Lüfterlager, HDD-Mechanik, Lötstellen | Ausfallrate steigt mit dem Alter (Schroeder & Gibson 2007) ✅ → Ersatzteile & Backups |
| ❌ **Kein AVX/AVX2/AVX-512** | L5640 unterstützt SSE4.2 + **AES-NI**, aber **kein AVX** ✅ ([Intel ARK](https://www.intel.com/content/www/us/en/products/sku/47926/intel-xeon-processor-l5640-12m-cache-2-26-ghz-5-86-gts-intel-qpi/specifications.html)) | Software mit AVX-Pflicht läuft nicht (Beispiele: vorkompilierte TensorFlow-Wheels seit 1.6, MongoDB ≥ 5.0) |
| ❌ **x86-64-v3** | Westmere = **x86-64-v2**-Niveau | Gast-OS, die v3 voraussetzen (z. B. **RHEL 10**), starten nicht; AlmaLinux 10 bietet eine **v2-Variante** an ⚠️ prüfen |
| 🐢 **PCIe 2.0, SATA 3 Gb/s** | ~500 MB/s pro Lane, ~300 MB/s pro SATA-Port | NVMe/moderne SSDs werden ausgebremst |
| 🧩 **1 PCIe-Slot/Node** | 10GbE **oder** GPU **oder** HBA | Rollenplanung ([RC-3](reality-check.md#rc-3)) |
| 🔒 **Keine Firmware-Updates** | EOL | Nicht als Mandanten-Plattform für fremde, nicht vertrauenswürdige Workloads |

**🏁 Fazit:** Enterprise-Hardware hält lange, weil sie **überwachbar, redundant und reparierbar** ist – nicht weil sie nie altert. Wer **ECC, IPMI und Ersatzteile** nutzt und die **Grenzen (Strom, Lärm, AVX, Firmware)** akzeptiert, bekommt einen RAM-starken Lab-Cluster zu einem Bruchteil der Neupreise.
