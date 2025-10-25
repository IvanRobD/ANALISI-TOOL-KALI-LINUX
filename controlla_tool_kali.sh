#!/bin/bash
# controlla_tool_kali.sh
# Controlla quali tool "utili" per cyber security sono presenti in lista_pacchetti.txt

INPUT="lista_pacchetti.txt"
if [ ! -f "$INPUT" ]; then
  echo "Errore: non trovo $INPUT nella cartella corrente."
  exit 1
fi

# Lista dei tool che consideriamo "utili"
tools=(
nmap masscan netdiscover whois dnsenum dnsrecon theharvester amass maltego
nikto wpscan lynis openvas gvm nuclei metasploit-framework searchsploit
sqlmap commix beef-xss msfvenom linpeas linenum pwncat netcat socat sshpass
hydra medusa john hashcat crunch cewl rockyou burpsuite owasp-zap ettercap
wireshark tshark mitmproxy aircrack-ng reaver fern-wifi-cracker ghidra
radare2 apktool dex2jar jd-gui strace ltrace binwalk autopsy sleuthkit
volatility3 foremost scalpel bulk-extractor tor torsocks proxychains4 anonsurf
curl wget net-tools iproute2 vim nano python3 pip git htop lsof ncdu
)

# Prepara lista di nomi installati (primo campo prima della slash se 'apt list' è stato usato)
awk -F/ '{print $1}' "$INPUT" | sed '/^Listing.../d' | sort -u > installed_names.tmp

# File di output
> presenti.txt
> mancanti.txt

for t in "${tools[@]}"; do
  if grep -xq "$t" installed_names.tmp; then
    echo "$t" >> presenti.txt
  else
    echo "$t" >> mancanti.txt
  fi
done

# Riepilogo
echo "------ RIEPILOGO ------"
echo "Totale tool controllati: ${#tools[@]}"
echo "Presenti: $(wc -l < presenti.txt | tr -d ' ')"
echo "Mancanti: $(wc -l < mancanti.txt | tr -d ' ')"
echo
echo "File generati: presenti.txt (tool trovati), mancanti.txt (tool assenti)"
echo "Se vuoi, incolla qui il contenuto di presenti.txt e te lo analizzo / ordino per priorità."

# pulizia temporanei
rm -f installed_names.tmp
