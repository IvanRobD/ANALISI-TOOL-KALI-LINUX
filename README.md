# README.md

# Kali Tools Checker & AI Enhancer

Un repository completo per:

* Analizzare quali tool di cybersecurity sono installati su Kali Linux
* Generare report dettagliati degli strumenti presenti e mancanti
* Ricercare nuovi tool di cybersecurity tramite AI (locale o API Hugging Face)
* Installazione interattiva dei tool mancanti

## Caratteristiche principali

* ✅ Controllo automatico dei tool installati
* 📄 Generazione report in formato leggibile
* 🤖 Ricerca di nuovi tool tramite AI
* 🧰 Installazione interattiva dei tool mancanti
* 🌐 Supporto per lingua italiana e inglese

## Struttura della repository

```
kali-tools-repo/
│
├─ controlla_tool_kali.sh   # Script principale
├─ lista_pacchetti.txt      # Lista dei pacchetti da controllare
├─ reports/                 # Cartella in cui salvare i report generati
├─ docs/                    # Documentazione aggiuntiva
└─ README.md                # Questo file
```

## Come utilizzare

1. Clona la repository:

```bash
git clone https://github.com/tuo-username/kali-tools-repo.git
cd kali-tools-repo
```

2. Aggiungi la lista dei pacchetti da controllare in `lista_pacchetti.txt`

3. Imposta la tua API key per Hugging Face (opzionale, per ricerca AI):

```bash
export HF_API_KEY='tua_chiave_qui'
```

4. Esegui lo script:

```bash
bash controlla_tool_kali.sh
```

5. Segui le istruzioni per visualizzare il report, installare tool mancanti o effettuare ricerca AI.

## Requisiti

* Kali Linux
* Bash 5+
* Accesso a internet per installazioni e API AI (opzionale)
* Ollama (opzionale, per AI locale)
* API key Hugging Face (opzionale)

## Suggerimenti

* Lo script è pensato per **principianti di cybersecurity** per studiare e testare tool individualmente.
* Verifica sempre l'affidabilità dei nuovi tool suggeriti dall'AI prima di installarli.

## Licenza

Questo progetto è rilasciato sotto licenza MIT. Vedi LICENSE per dettagli.

---

© 2025 Cybersecurity Scripts
