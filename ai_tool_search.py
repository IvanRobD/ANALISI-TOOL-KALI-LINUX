#!/usr/bin/env python3
"""
ai_tool_search.py
Modulo Python per suggerire nuovi tool di cybersecurity
Usa logica Python nativa senza dipendenze da AI esterne
"""

import sys
import re
from datetime import datetime

# Database completo di tool di cybersecurity aggiornato al 2024-2025
CYBERSECURITY_TOOLS = {
    # Ricognizione e OSINT
    "subfinder": {
        "desc": "Tool veloce per enumerazione di sottodomini tramite fonti passive e API multiple",
        "version": "v2.6.3",
        "url": "https://github.com/projectdiscovery/subfinder",
        "category": "Ricognizione e OSINT",
        "year": 2024,
        "popularity": 9
    },
    "assetfinder": {
        "desc": "Trova domini e sottodomini correlati a un dominio target",
        "version": "v0.1.1",
        "url": "https://github.com/tomnomnom/assetfinder",
        "category": "Ricognizione e OSINT",
        "year": 2024,
        "popularity": 8
    },
    "shodan": {
        "desc": "CLI per interrogare il motore di ricerca Shodan per dispositivi IoT e server esposti",
        "version": "v1.31.0",
        "url": "https://cli.shodan.io/",
        "category": "Ricognizione e OSINT",
        "year": 2024,
        "popularity": 10
    },
    "maigret": {
        "desc": "Ricerca username su 3000+ siti web per OSINT",
        "version": "v0.5.0",
        "url": "https://github.com/soxoj/maigret",
        "category": "Ricognizione e OSINT",
        "year": 2024,
        "popularity": 8
    },
    
    # Vulnerability Scanning
    "nuclei": {
        "desc": "Scanner di vulnerabilità veloce e customizzabile basato su template YAML",
        "version": "v3.1.5",
        "url": "https://github.com/projectdiscovery/nuclei",
        "category": "Vulnerability Assessment",
        "year": 2025,
        "popularity": 10
    },
    "trivy": {
        "desc": "Scanner di vulnerabilità per container, filesystem, git repositories",
        "version": "v0.48.0",
        "url": "https://github.com/aquasecurity/trivy",
        "category": "Vulnerability Assessment",
        "year": 2024,
        "popularity": 9
    },
    
    # Web Hacking
    "feroxbuster": {
        "desc": "Tool di content discovery scritto in Rust, estremamente veloce e ricorsivo",
        "version": "v2.10.1",
        "url": "https://github.com/epi052/feroxbuster",
        "category": "Web Hacking",
        "year": 2024,
        "popularity": 9
    },
    "ffuf": {
        "desc": "Fast web fuzzer scritto in Go per discovery e bruteforcing",
        "version": "v2.1.0",
        "url": "https://github.com/ffuf/ffuf",
        "category": "Web Hacking",
        "year": 2024,
        "popularity": 10
    },
    "httpx": {
        "desc": "HTTP toolkit multi-purpose per probing, analisi e discovery",
        "version": "v1.3.7",
        "url": "https://github.com/projectdiscovery/httpx",
        "category": "Web Hacking",
        "year": 2024,
        "popularity": 9
    },
    "katana": {
        "desc": "Web crawler e spider sviluppato da ProjectDiscovery per mapping completo",
        "version": "v1.0.4",
        "url": "https://github.com/projectdiscovery/katana",
        "category": "Web Hacking",
        "year": 2024,
        "popularity": 8
    },
    "gospider": {
        "desc": "Fast web spider scritto in Go per scoprire link e endpoint",
        "version": "v1.1.6",
        "url": "https://github.com/jaeles-project/gospider",
        "category": "Web Hacking",
        "year": 2024,
        "popularity": 7
    },
    "dalfox": {
        "desc": "Potente scanner XSS open source basato su DOM e reflection",
        "version": "v2.9.0",
        "url": "https://github.com/hahwul/dalfox",
        "category": "Web Hacking",
        "year": 2024,
        "popularity": 8
    },
    
    # Network Scanning
    "rustscan": {
        "desc": "Port scanner ultra-veloce scritto in Rust che integra nmap",
        "version": "v2.1.1",
        "url": "https://github.com/RustScan/RustScan",
        "category": "Network Scanning",
        "year": 2024,
        "popularity": 9
    },
    "naabu": {
        "desc": "Port scanner veloce scritto in Go da ProjectDiscovery",
        "version": "v2.2.0",
        "url": "https://github.com/projectdiscovery/naabu",
        "category": "Network Scanning",
        "year": 2024,
        "popularity": 8
    },
    
    # Exploitation
    "ghauri": {
        "desc": "Tool automatico per SQL injection avanzato, alternativa a sqlmap",
        "version": "v1.2.5",
        "url": "https://github.com/r0oth3x49/ghauri",
        "category": "Exploitation",
        "year": 2024,
        "popularity": 7
    },
    
    # Password Cracking
    "hashid": {
        "desc": "Identifica diversi tipi di hash crittografici",
        "version": "v3.1.4",
        "url": "https://github.com/psypanda/hashID",
        "category": "Password Cracking",
        "year": 2024,
        "popularity": 8
    },
    
    # Forensics
    "volatility3": {
        "desc": "Framework per analisi di memoria RAM (versione 3 riscritta in Python3)",
        "version": "v2.5.0",
        "url": "https://github.com/volatilityfoundation/volatility3",
        "category": "Forensics",
        "year": 2024,
        "popularity": 9
    },
    
    # Wireless
    "bettercap": {
        "desc": "Framework completo per attacchi network/wireless e MITM",
        "version": "v2.32.0",
        "url": "https://github.com/bettercap/bettercap",
        "category": "Wireless Hacking",
        "year": 2024,
        "popularity": 9
    },
    
    # Cloud Security
    "cloudfox": {
        "desc": "Tool per enumerazione e privilege escalation su AWS",
        "version": "v1.12.0",
        "url": "https://github.com/BishopFox/cloudfox",
        "category": "Cloud Security",
        "year": 2024,
        "popularity": 8
    },
    "pacu": {
        "desc": "Framework di exploitation per AWS scritto in Python",
        "version": "v1.5.0",
        "url": "https://github.com/RhinoSecurityLabs/pacu",
        "category": "Cloud Security",
        "year": 2024,
        "popularity": 8
    },
    
    # API Security
    "arjun": {
        "desc": "Scopre parametri nascosti in applicazioni web e API",
        "version": "v2.2.1",
        "url": "https://github.com/s0md3v/Arjun",
        "category": "API Security",
        "year": 2024,
        "popularity": 8
    },
    
    # Post-Exploitation
    "ligolo-ng": {
        "desc": "Tool di tunneling e pivoting moderno, successore di ligolo",
        "version": "v0.5.1",
        "url": "https://github.com/nicocha30/ligolo-ng",
        "category": "Post-Exploitation",
        "year": 2024,
        "popularity": 9
    },
}

def analyze_existing_tools(existing_tools):
    """
    Analizza i tool esistenti per capire quali categorie sono coperte
    """
    existing_lower = [t.lower().strip() for t in existing_tools]
    
    # Conta quanti tool per categoria sono già presenti
    categories_coverage = {}
    
    for tool_name, tool_info in CYBERSECURITY_TOOLS.items():
        category = tool_info["category"]
        if category not in categories_coverage:
            categories_coverage[category] = {"total": 0, "missing": 0}
        
        categories_coverage[category]["total"] += 1
        
        if tool_name not in existing_lower:
            categories_coverage[category]["missing"] += 1
    
    return existing_lower, categories_coverage

def suggest_new_tools(existing_tools, language="it", max_suggestions=10):
    """
    Suggerisce nuovi tool basandosi su logica Python intelligente
    Prioritizza: popolarità, anno, categorie mancanti
    """
    
    existing_lower, categories_coverage = analyze_existing_tools(existing_tools)
    
    # Filtra tool non presenti
    new_tools = []
    for tool_name, tool_info in CYBERSECURITY_TOOLS.items():
        if tool_name not in existing_lower:
            # Calcola score basato su popolarità, anno e coverage categoria
            score = tool_info["popularity"]
            
            # Bonus per tool recenti
            if tool_info["year"] >= 2024:
                score += 2
            
            # Bonus per categorie poco coperte
            category = tool_info["category"]
            if category in categories_coverage:
                coverage_ratio = categories_coverage[category]["missing"] / categories_coverage[category]["total"]
                score += coverage_ratio * 3
            
            new_tools.append((tool_name, tool_info, score))
    
    # Ordina per score decrescente
    new_tools.sort(key=lambda x: x[2], reverse=True)
    
    # Prendi i top N
    suggested = new_tools[:max_suggestions]
    
    # Formatta output
    output = []
    
    if language == "it":
        lang_intro = "italiano"
    else:
        lang_intro = "italiano e inglese"
    
    output.append(f"Analisi completata! Ho trovato {len(new_tools)} tool NON presenti nella tua lista.")
    output.append(f"Ecco i {len(suggested)} più rilevanti per il 2024-2025:\n")
    
    for i, (tool_name, tool_info, score) in enumerate(suggested, 1):
        output.append("---")
        output.append(f"🔧 AI: {tool_name}")
        output.append(f"📝 {tool_info['desc']}")
        output.append(f"🏷️ Versione: {tool_info['version']} ({tool_info['year']})")
        output.append(f"📚 Guida: {tool_info['url']}")
        output.append(f"💡 Categoria: {tool_info['category']}")
        output.append(f"⭐ Popolarità: {tool_info['popularity']}/10")
        output.append("---\n")
    
    # Aggiungi statistiche
    output.append("\n📊 STATISTICHE COPERTURA PER CATEGORIA:")
    output.append("=" * 50)
    
    for category, data in sorted(categories_coverage.items()):
        missing = data["missing"]
        total = data["total"]
        covered = total - missing
        percentage = (covered / total * 100) if total > 0 else 0
        
        bar_length = 20
        filled = int(bar_length * covered / total) if total > 0 else 0
        bar = "█" * filled + "░" * (bar_length - filled)
        
        output.append(f"{category:30s} [{bar}] {percentage:.0f}% ({covered}/{total})")
    
    return "\n".join(output)

def main():
    """Funzione principale"""
    
    if len(sys.argv) < 2:
        print("Uso: python3 ai_tool_search.py <tool1> <tool2> ... [--lang it|en]")
        sys.exit(1)
    
    # Parse argomenti
    tools = []
    language = "it"
    
    i = 1
    while i < len(sys.argv):
        arg = sys.argv[i]
        if arg == "--lang":
            i += 1
            if i < len(sys.argv):
                language = sys.argv[i]
        else:
            tools.append(arg)
        i += 1
    
    if not tools:
        print("❌ Nessun tool specificato", file=sys.stderr)
        sys.exit(1)
    
    print(f"🐍 Analisi intelligente con Python nativo...", file=sys.stderr)
    print(f"📋 Tool monitorati: {len(tools)}", file=sys.stderr)
    print(f"🔍 Cerco nuovi tool nel database aggiornato...", file=sys.stderr)
    print("", file=sys.stderr)
    
    result = suggest_new_tools(tools, language)
    
    if result:
        print("")
        print("╔════════════════════════════════════════╗")
        print("║  🤖 AI: NUOVI TOOL DI CYBERSECURITY   ║")
        print("║    (Fonte: Intelligenza Python)       ║")
        print("╚════════════════════════════════════════╝")
        print("")
        print(result)
        print("")
        print("════════════════════════════════════════")
        print("")
        print("💡 NOTA: Questi suggerimenti sono basati su un database curato")
        print("   di tool popolari aggiornato al 2024-2025.")
        print("   Verifica sempre l'affidabilità prima dell'installazione!")
    else:
        print("")
        print("❌ Impossibile generare suggerimenti", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
