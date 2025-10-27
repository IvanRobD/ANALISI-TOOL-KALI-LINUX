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
      LANGUAGE="it"
      LANG_NOTE="(Risultati in Italiano)"
      ;;
    2)
      LANGUAGE="en"
      LANG_NOTE="(Risultati in Italiano e Inglese)"
      ;;
    *)
      LANGUAGE="it"
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
  
  # Controlla se Python3 è disponibile
  if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 non trovato!"
    echo "💡 Installa Python3: sudo apt install python3 python3-pip"
    return
  fi
  
  # Controlla se il modulo Python esiste
  if [ ! -f "ai_tool_search.py" ]; then
    echo "⚠️  File ai_tool_search.py non trovato nella directory corrente"
    echo "💡 Assicurati che ai_tool_search.py sia nella stessa cartella dello script"
    return
  fi
  
  # Installa requests se necessario
  if ! python3 -c "import requests" 2>/dev/null; then
    echo "📦 Installazione modulo Python 'requests'..."
    pip3 install requests --quiet || sudo pip3 install requests --quiet
  fi
  
  echo "⏳ Controllo disponibilità servizi AI..."
  
  # Prova prima Ollama locale (se disponibile)
  if command -v ollama &> /dev/null; then
    echo "✅ Ollama trovato! Utilizzo modello locale..."
    
    if ollama list 2>/dev/null | grep -q "NAME"; then
      echo "📡 Interrogazione AI locale in corso... $LANG_NOTE"
      
      PROMPT="Suggest 10 NEW cybersecurity tools for penetration testing NOT in this list: $all_tools_list. Format: tool name - description. Be concise."
      
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
  
  # Usa il modulo Python per chiamare l'API Hugging Face
  echo "🌐 Utilizzo API Hugging Face tramite modulo Python..."
  echo ""
  
  # Chiama lo script Python
  ai_output=$(python3 ai_tool_search.py $all_tools_list --lang $LANGUAGE 2>&1)
  exit_code=$?
  
  if [ $exit_code -eq 0 ]; then
    # Successo - mostra output
    echo "$ai_output"
    
    # Salva nel report
    echo "$ai_output" >> "$REPORT"
  else
    # Errore - mostra messaggi di debug
    echo "$ai_output"
    echo ""
    echo "💡 SUGGERIMENTI AGGIUNTIVI:"
    echo "   - Verifica che il file ai_tool_search.py sia presente"
    echo "   - Controlla che Python3 e requests siano installati"
    echo "   - Prova con Ollama per uso offline (vedi sopra)"
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
