# 🤝 Beitragen

Danke für dein Interesse an **Proxmox VE auf einem 2U-4-Node-Cluster**! Companion-Repos: [node300-net/sovereign-datacenter](https://github.com/node300-net/sovereign-datacenter) · [node300-net/firewalla-gold-pro-msp](https://github.com/node300-net/firewalla-gold-pro-msp).

## Grundsätze

1. **Ehrlich bleiben.** Keine erfundenen Benchmarks, Preise oder Kompatibilitäten. Jede Aussage braucht einen **Link** (✅ Primärquelle, 🟦 Community) oder die Markierung **⚠️ Schätzung/unverifiziert** mit Begründung.
2. **Messwerte statt Vermutungen.** Strom (Messsteckdose, `ipmitool dcmi power reading`), Lärm (dB(A) in 1 m), Durchsatz (`iperf3`, `fio`) – immer mit **Methode, Datum, Firmware-/PVE-Version**.
3. **Spezifikation respektieren.** Die User-Spezifikation (SM-2026TT-SPEC-V1) wird zitiert, nicht umgeschrieben. Abweichungen gehören in den [Reality Check](docs/reality-check.md).
4. **Platzhalter statt Secrets.** Keine echten IPs, Hostnamen, API-Tokens, Passwörter, Terraform-State, Cowrie-Logs mit echten Angreifer-IPs (vorher anonymisieren). Platzhalter-Format: `<<NAME>>`.
5. **Sprache.** Dokumentation auf **Deutsch**; Fachbegriffe (Quorum, Fencing, Passthrough …) dürfen Englisch bleiben.
6. **Mermaid prüfen.** Diagramme vor dem PR mit `mmdc` oder dem [Mermaid Live Editor](https://mermaid.live/) rendern.

## Workflow

```bash
git checkout -b docs/kurze-beschreibung
# Änderungen …
bash -n configs/**/*.sh            # Syntax-Check der Skripte
git add -A
git commit -m "docs: Strommessung NODE 3 im Leerlauf ergänzt"   # docs:/feat:/fix:/chore:
# Pull Request mit Quellen-Links
```

## Besonders willkommen

- ⚡ **Echte Strom- & Lärmmessungen** des SYS-2026TT (Leerlauf, Last, mit/ohne GPU)
- 🎮 Erfahrungsberichte zu **GPU-Passthrough auf Westmere** (Interrupt-Remapping, Ollama-GPU-Erkennung ohne AVX)
- 🐙 **Ceph**-Tests auf SATA-3-Gb/s-Hardware
- 🧩 Weitere Use-Cases mit Sizing (z. B. Matrix/Synapse, Paperless-ngx, Immich – AVX-Anforderungen prüfen!)

## Lizenz

Mit deinem Beitrag akzeptierst du: Code/Configs unter **MIT**, Doku unter **CC BY-SA 4.0** (siehe [LICENSE](LICENSE)).
