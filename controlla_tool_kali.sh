#!/bin/bash
# controlla_tool_kali.sh
# Controlla quali tool "utili" per cyber security sono presenti in lista_pacchetti.txt
# Con ricerca AI integrata per nuovi tool

INPUT="lista_pacchetti.txt"
if [ ! -f "$INPUT" ]; then
  echo "Errore: non trovo $INPUT nella cartella corrente."
  exit 1
fi

# API Key per Hugging Face (integrata o da variabile d'ambiente)
HF_API_KEY="${HF_API_KEY:-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}"

# Funzione per cercare nuovi tool con AI
search_new_tools_with_ai() {
  echo ""
  echo "🤖 RICERCA NUOVI TOOL CON AI"
  echo "======================================"
  echo "Questa funzione utilizza un'AI per cercare"
  echo "nuovi tool di cybersecurity NON presenti nella lista attuale"
  echo ""
  read -p "Vuoi procedere con la ricerca AI? (s/n): " ai_choice
  
  if [[ ! "$ai_choice" =~ ^[sS]$ ]]; then
    echo "ℹ️  Ricerca AI saltata"
    return
  fi
  
  # Scelta lingua
  echo ""
  read -p "Lingua dei risultati - [1] Solo Italiano [2] Italiano + Inglese: " lang_choice
  
  case "$lang_choice" in
    1)
      LANGUAGE="Italian only"
      LANG_NOTE="(Risultati in Italiano)"
      ;;
    2)
      LANGUAGE="Italian and English"
      LANG_NOTE="(Risultati in Italiano e Inglese)"
      ;;
    *)
      LANGUAGE="Italian only"
      LANG_NOTE="(Risultati in Italiano)"
      ;;
  esac
  
  echo ""
  echo "⏳ Preparazione lista tool esistenti..."
  
  # Crea lista di tutti i tool già monitorati
  all_tools_list=""
  for category in "${category_order[@]}"; do
    all_tools_list="$all_tools_list ${categories[$category]}"
  done
  
  # Prepara il prompt con la lista dei tool esistenti e richiesta dettagli
  PROMPT="You are a cybersecurity expert. I have a list of penetration testing tools that I'm already monitoring: $all_tools_list

Please suggest 10 NEW and DIFFERENT cybersecurity tools for penetration testing that are NOT in my list above.

For EACH tool, provide in $LANGUAGE:
1. 🔧 AI: TOOL_NAME
2. 📝 Brief description (2-3 lines explaining what it does)
3. 🏷️ Latest stable version available
4. 📚 Official documentation link or most updated guide URL
5. 💡 Primary use case (e.g., network scanning, web exploitation, forensics)

Format example:
---
🔧 AI: ToolName
📝 Description of what this tool does and why it's useful for penetration testing...
🏷️ Version: v2.5.0 (2024)
📚 Guide: https://official-site.com/docs
💡 Category: Web Application Security
---

Focus on:
- Tools released or significantly updated in 2024-2025
- Tools available in Kali Linux repositories or easily installable on Linux
- Popular and actively maintained tools
- Different categories: network scanning, web hacking, password cracking, forensics, exploitation, wireless attacks

IMPORTANT: Do NOT suggest any tool already in my list. Only suggest NEW tools. Provide response in $LANGUAGE."
  
  echo "⏳ Controllo disponibilità servizi AI..."
  
  # Prova prima Ollama locale (se disponibile)
  if command -v ollama &> /dev/null; then
    echo "✅ Ollama trovato! Utilizzo modello locale..."
    
    if ollama list 2>/dev/null | grep -q "NAME"; then
      echo "📡 Interrogazione AI locale in corso... $LANG_NOTE"
      
      response=$(ollama run llama2 "$PROMPT" 2>/dev/null || ollama run mistral "$PROMPT" 2>/dev/null)
      
      if [ -n "$response" ]; then
        echo ""
        echo "╔════════════════════════════════════════╗"
        echo "║  🤖 AI: NUOVI TOOL DI CYBERSECURITY   ║"
        echo "║      (Fonte: Ollama - Locale)         ║"
        echo "╚════════════════════════════════════════╝"
        echo ""
        echo "$response"
        echo ""
        echo "════════════════════════════════════════"
        
        # Salva nel report
        {
        echo ""
        echo "╔════════════════════════════════════════╗"
        echo "║  🤖 AI: NUOVI TOOL DI CYBERSECURITY   ║"
        echo "║      (Fonte: Ollama - Locale)         ║"
        echo "╚════════════════════════════════════════╝"
        echo ""
        echo "$response"
        echo ""
        echo "════════════════════════════════════════"
        } >> "$REPORT"
        
        return
      fi
    fi
  fi
  
  # Se Ollama non è disponibile, usa API Hugging Face
  echo "🌐 Utilizzo API Hugging Face (Inference Providers)..."
  
  if [ -z "$HF_API_KEY" ]; then
    echo "❌ API Key non trovata!"
    echo "💡 Puoi impostare la variabile d'ambiente:"
    echo "   export HF_API_KEY='tua_chiave_qui'"
    return
  fi
  
  echo "📡 Interrogazione AI in corso... $LANG_NOTE"
  echo "⏳ Attendere, l'AI sta cercando informazioni dettagliate..."
  
  # Escape del prompt per JSON (rimuove caratteri problematici)
  PROMPT_ESCAPED=$(echo "$PROMPT" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | tr '\n' ' ')
  
  # Tentativo con retry (max 3 tentativi)
  max_attempts=3
  attempt=1
  response=""
  
  while [ $attempt -le $max_attempts ]; do
    echo "🔄 Tentativo $attempt di $max_attempts..."
    
    # Chiamata API a Hugging Face (nuovo endpoint Inference Providers)
    response=$(curl -s -X POST \
      "https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2" \
      -H "Authorization: Bearer $HF_API_KEY" \
      -H "Content-Type: application/json" \
      --data-raw "{\"inputs\":\"$PROMPT_ESCAPED\",\"parameters\":{\"max_new_tokens\":1200,\"temperature\":0.7,\"return_full_text\":false}}" \
      2>/dev/null)
    
    # Controlla se c'è un errore di loading
    if echo "$response" | grep -q "currently loading"; then
      estimated_time=$(echo "$response" | grep -o '"estimated_time":[0-9.]*' | cut -d':' -f2)
      echo "⏳ Modello in caricamento... tempo stimato: ${estimated_time}s"
      
      if [ $attempt -lt $max_attempts ]; then
        echo "⏸️  Attendo 25 secondi prima del prossimo tentativo..."
        sleep 25
      fi
    else
      # Se non c'è errore di loading, esci dal loop
      break
    fi
    
    attempt=$((attempt + 1))
  done
  
  # Estrai il testo generato
  generated_text=$(echo "$response" | grep -o '"generated_text":"[^"]*"' | sed 's/"generated_text":"//;s/"$//' | sed 's/\\n/\n/g')
  
  if [ -n "$generated_text" ]; then
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║  🤖 AI: NUOVI TOOL DI CYBERSECURITY   ║"
    echo "║    (Fonte: Hugging Face Inference)    ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "$generated_text"
    echo ""
    echo "════════════════════════════════════════"
    echo ""
    echo "💡 NOTA: Verifica sempre l'affidabilità e la sicurezza"
    echo "   di nuovi tool prima di installarli sul tuo sistema!"
    echo "   Controlla i link delle guide ufficiali forniti."
    
    # Salva nel report con intestazione distintiva
    {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║  🤖 AI: NUOVI TOOL DI CYBERSECURITY   ║"
    echo "║    (Fonte: Hugging Face Inference)    ║"
    echo "║        Lingua: $LANGUAGE              ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "$generated_text"
    echo ""
    echo "════════════════════════════════════════"
    echo ""
    echo "⚠️  IMPORTANTE:"
    echo "- Verifica sempre l'affidabilità di nuovi tool prima di installarli"
    echo "- Controlla i link delle guide ufficiali forniti dall'AI"
    echo "- Assicurati che le versioni siano aggiornate al momento dell'installazione"
    echo "- Leggi sempre la documentazione prima dell'uso"
    } >> "$REPORT"
  else
    echo "❌ Errore nella risposta API dopo $max_attempts tentativi"
    echo "💡 Possibili cause:"
    echo "   - Modello temporaneamente non disponibile"
    echo "   - Quota API esaurita"
    echo "   - Problemi di connessione"
    echo ""
    
    # Controlla se c'è un messaggio di errore specifico
    error_msg=$(echo "$response" | grep -o '"error":"[^"]*"' | cut -d'"' -f4)
    if [ -n "$error_msg" ]; then
      echo "   📋 Dettagli errore: $error_msg"
    fi
    
    # Mostra raw response per debug (primi 200 caratteri)
    echo ""
    echo "   🔍 Debug (primi 200 caratteri della risposta):"
    echo "   $(echo "$response" | head -c 200)"
    echo ""
    echo "💡 SUGGERIMENTI:"
    echo "   1. Attendi qualche minuto e riprova"
    echo "   2. Verifica la connessione internet"
    echo "   3. Installa Ollama per usare AI locale (offline):"
    echo "      curl -fsSL https://ollama.com/install.sh | sh"
    echo "      ollama pull mistral"
  fi
}

# Definizione categorie e tool
declare -A categories
categories=(
  ["Ricognizione e Scansione"]="nmap masscan netdiscover whois dnsenum dnsrecon theharvester amass maltego"
  ["Vulnerability Assessment"]="nikto wpscan lynis openvas gvm nuclei"
  ["Exploitation"]="metasploit-framework searchsploit sqlmap commix beef-xss msfvenom"
  ["Post-Exploitation & Privilege Escalation"]="linpeas linenum pwncat netcat socat sshpass"
  ["Password Attacks"]="hydra medusa john hashcat crunch cewl rockyou"
  ["Web e Network Hacking"]="burpsuite owasp-zap ettercap wireshark tshark mitmproxy aircrack-ng reaver fern-wifi-cracker"
  ["Reverse Engineering & Malware Analysis"]="ghidra radare2 apktool dex2jar jd-gui strace ltrace binwalk"
  ["Forensics"]="autopsy sleuthkit volatility3 foremost scalpel bulk-extractor"
  ["Anonimato e Offuscamento"]="tor torsocks proxychains4 anonsurf"
  ["Utility da Tenere Sempre"]="curl wget net-tools iproute2 vim nano python3 pip git htop lsof ncdu"
)

# Ordine di visualizzazione delle categorie
category_order=(
  "Ricognizione e Scansione"
  "Vulnerability Assessment"
  "Exploitation"
  "Post-Exploitation & Privilege Escalation"
  "Password Attacks"
  "Web e Network Hacking"
  "Reverse Engineering & Malware Analysis"
  "Forensics"
  "Anonimato e Offuscamento"
  "Utility da Tenere Sempre"
)

# Emoji per le categorie
declare -A category_icons
category_icons=(
  ["Ricognizione e Scansione"]="🔎"
  ["Vulnerability Assessment"]="💉"
  ["Exploitation"]="🧱"
  ["Post-Exploitation & Privilege Escalation"]="🧠"
  ["Password Attacks"]="🧰"
  ["Web e Network Hacking"]="🌐"
  ["Reverse Engineering & Malware Analysis"]="🧬"
  ["Forensics"]="🧩"
  ["Anonimato e Offuscamento"]="🕶️"
  ["Utility da Tenere Sempre"]="🧮"
)

# Prepara lista di nomi installati
awk -F/ '{print $1}' "$INPUT" | sed '/^Listing.../d' | sort -u > installed_names.tmp

# Contatori
total_tools=0
present_count=0
missing_count=0

# Array per memorizzare strumenti mancanti
declare -a missing_tools

# Nome file report
REPORT="report_tool_kali_$(date +%Y%m%d_%H%M%S).txt"

# Output formattato
echo "======================================"
echo "  ANALISI TOOL KALI LINUX"
echo "======================================"
echo ""

# Inizia anche il report
{
echo "======================================"
echo "  ANALISI TOOL KALI LINUX"
echo "  Data: $(date '+%d/%m/%Y %H:%M:%S')"
echo "======================================"
echo ""
} > "$REPORT"

# Analizza ogni categoria
for category in "${category_order[@]}"; do
  tools_str="${categories[$category]}"
  icon="${category_icons[$category]}"
  
  echo "$icon $category"
  echo ""
  
  {
  echo "$icon $category"
  echo ""
  } >> "$REPORT"
  
  for tool in $tools_str; do
    total_tools=$((total_tools + 1))
    
    if grep -xq "$tool" installed_names.tmp; then
      echo "✅ $tool"
      echo "✅ $tool" >> "$REPORT"
      present_count=$((present_count + 1))
    else
      echo "❌ $tool"
      echo "❌ $tool" >> "$REPORT"
      missing_count=$((missing_count + 1))
      missing_tools+=("$tool")
    fi
  done
  
  echo ""
  echo "" >> "$REPORT"
done

# Riepilogo finale
echo "======================================"
echo "📊 RIEPILOGO"
echo "======================================"
echo ""
echo "Totale strumenti controllati: $total_tools"
echo "Presenti sul tuo Kali: $present_count ✅"
echo "Mancanti: $missing_count ❌"
echo ""

# Scrivi anche nel report
{
echo "======================================"
echo "📊 RIEPILOGO"
echo "======================================"
echo ""
echo "Totale strumenti controllati: $total_tools"
echo "Presenti sul tuo Kali: $present_count ✅"
echo "Mancanti: $missing_count ❌"
echo ""
} >> "$REPORT"

# Lista strumenti mancanti
if [ $missing_count -gt 0 ]; then
  echo "🔍 STRUMENTI MANCANTI:"
  echo ""
  printf '%s, ' "${missing_tools[@]}" | sed 's/, $/\n/'
  echo ""
  
  # Scrivi anche nel report
  {
  echo "🔍 STRUMENTI MANCANTI:"
  echo ""
  printf '%s, ' "${missing_tools[@]}" | sed 's/, $/\n/'
  echo ""
  } >> "$REPORT"
  
  echo "======================================"
  echo ""
  
  # Chiedi se vuole installare
  read -p "Vuoi procedere con l'installazione interattiva? (s/n): " install_choice
  
  if [[ "$install_choice" =~ ^[sS]$ ]]; then
    echo ""
    echo "🔧 INSTALLAZIONE INTERATTIVA"
    echo "======================================"
    echo "Per ogni tool potrai scegliere:"
    echo "  [i] = Installa"
    echo "  [s] = Salta"
    echo "  [q] = Esci dall'installazione"
    echo "======================================"
    echo ""
    
    installed_tools=()
    skipped_tools=()
    
    for tool in "${missing_tools[@]}"; do
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "📦 Tool: $tool"
      read -p "Cosa vuoi fare? [i/s/q]: " action
      
      case "$action" in
        [iI])
          echo "⏳ Installazione di $tool in corso..."
          sudo apt install -y "$tool"
          if [ $? -eq 0 ]; then
            echo "✅ $tool installato con successo!"
            installed_tools+=("$tool")
          else
            echo "❌ Errore durante l'installazione di $tool"
          fi
          echo ""
          ;;
        [sS])
          echo "⏭️  $tool saltato"
          skipped_tools+=("$tool")
          echo ""
          ;;
        [qQ])
          echo "🛑 Installazione interrotta dall'utente"
          break
          ;;
        *)
          echo "⚠️  Scelta non valida, salto $tool"
          skipped_tools+=("$tool")
          echo ""
          ;;
      esac
    done
    
    echo "======================================"
    echo "✅ Processo di installazione completato!"
    echo "======================================"
    
    # Salva log installazioni nel report
    {
    echo ""
    echo "======================================"
    echo "📝 LOG INSTALLAZIONI"
    echo "======================================"
    echo "Tool installati: ${#installed_tools[@]}"
    if [ ${#installed_tools[@]} -gt 0 ]; then
      printf '%s, ' "${installed_tools[@]}" | sed 's/, $/\n/'
    fi
    echo ""
    echo "Tool saltati: ${#skipped_tools[@]}"
    if [ ${#skipped_tools[@]} -gt 0 ]; then
      printf '%s, ' "${skipped_tools[@]}" | sed 's/, $/\n/'
    fi
    echo ""
    } >> "$REPORT"
  else
    echo "ℹ️  Installazione saltata"
  fi
fi

# Pulizia temporanei
rm -f installed_names.tmp

echo ""
echo "======================================"
echo "✨ Analisi completata!"
echo "======================================"
echo "📄 Report salvato in: $REPORT"
echo ""

# Chiama funzione ricerca AI
search_new_tools_with_ai

echo ""
echo "======================================"
echo "🎯 Script terminato con successo!"
echo "======================================"
