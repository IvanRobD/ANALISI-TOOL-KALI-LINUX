#!/usr/bin/env python3
"""
ai_tool_search.py
Modulo Python per cercare nuovi tool di cybersecurity con AI
"""

import requests
import json
import sys
import time

# API Key Hugging Face
HF_API_KEY = "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"
API_URL = "https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2"

def search_new_tools(existing_tools, language="Italian only", max_retries=3):
    """
    Cerca nuovi tool di cybersecurity usando Hugging Face API
    
    Args:
        existing_tools: Lista di tool già monitorati
        language: Lingua dei risultati ("Italian only" o "Italian and English")
        max_retries: Numero massimo di tentativi
    
    Returns:
        str: Testo con i tool suggeriti o None in caso di errore
    """
    
    # Prepara il prompt
    tools_list = " ".join(existing_tools)
    
    prompt = f"""You are a cybersecurity expert. I have a list of penetration testing tools that I'm already monitoring: {tools_list}

Please suggest 10 NEW and DIFFERENT cybersecurity tools for penetration testing that are NOT in my list above.

For EACH tool, provide in {language}:
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

IMPORTANT: Do NOT suggest any tool already in my list. Only suggest NEW tools. Provide response in {language}."""

    headers = {
        "Authorization": f"Bearer {HF_API_KEY}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "inputs": prompt,
        "parameters": {
            "max_new_tokens": 1200,
            "temperature": 0.7,
            "return_full_text": False
        }
    }
    
    # Tentativi con retry
    for attempt in range(1, max_retries + 1):
        print(f"🔄 Tentativo {attempt} di {max_retries}...", file=sys.stderr)
        
        try:
            response = requests.post(API_URL, headers=headers, json=payload, timeout=30)
            
            if response.status_code == 200:
                result = response.json()
                
                # Controlla se il modello sta caricando
                if isinstance(result, dict) and "error" in result:
                    error_msg = result.get("error", "")
                    if "currently loading" in error_msg.lower():
                        estimated_time = result.get("estimated_time", 20)
                        print(f"⏳ Modello in caricamento... tempo stimato: {estimated_time}s", file=sys.stderr)
                        
                        if attempt < max_retries:
                            print(f"⏸️  Attendo 25 secondi prima del prossimo tentativo...", file=sys.stderr)
                            time.sleep(25)
                            continue
                    else:
                        print(f"❌ Errore API: {error_msg}", file=sys.stderr)
                        return None
                
                # Estrai il testo generato
                if isinstance(result, list) and len(result) > 0:
                    generated_text = result[0].get("generated_text", "")
                    if generated_text:
                        return generated_text
                elif isinstance(result, dict):
                    generated_text = result.get("generated_text", "")
                    if generated_text:
                        return generated_text
                
                print(f"⚠️  Risposta ricevuta ma formato inatteso", file=sys.stderr)
                
            elif response.status_code == 503:
                print(f"⏳ Servizio temporaneamente non disponibile (503)", file=sys.stderr)
                if attempt < max_retries:
                    print(f"⏸️  Attendo 25 secondi prima del prossimo tentativo...", file=sys.stderr)
                    time.sleep(25)
                    continue
            else:
                print(f"❌ Errore HTTP {response.status_code}: {response.text[:200]}", file=sys.stderr)
                
        except requests.exceptions.Timeout:
            print(f"⏱️  Timeout della richiesta", file=sys.stderr)
        except requests.exceptions.RequestException as e:
            print(f"❌ Errore di connessione: {e}", file=sys.stderr)
        except json.JSONDecodeError:
            print(f"❌ Errore nel parsing della risposta JSON", file=sys.stderr)
        
        if attempt < max_retries:
            time.sleep(5)
    
    return None


def main():
    """Funzione principale per uso da command line"""
    
    if len(sys.argv) < 2:
        print("Uso: python3 ai_tool_search.py <tool1> <tool2> ... [--lang it|en]")
        sys.exit(1)
    
    # Parse argomenti
    tools = []
    language = "Italian only"
    
    for arg in sys.argv[1:]:
        if arg == "--lang":
            continue
        elif arg == "it":
            language = "Italian only"
        elif arg == "en":
            language = "Italian and English"
        else:
            tools.append(arg)
    
    if not tools:
        print("❌ Nessun tool specificato", file=sys.stderr)
        sys.exit(1)
    
    print(f"📡 Interrogazione AI in corso... ({language})", file=sys.stderr)
    print(f"⏳ Attendere, l'AI sta cercando informazioni dettagliate...", file=sys.stderr)
    print("", file=sys.stderr)
    
    result = search_new_tools(tools, language)
    
    if result:
        print("")
        print("╔════════════════════════════════════════╗")
        print("║  🤖 AI: NUOVI TOOL DI CYBERSECURITY   ║")
        print("║    (Fonte: Hugging Face Inference)    ║")
        print("╚════════════════════════════════════════╝")
        print("")
        print(result)
        print("")
        print("════════════════════════════════════════")
        print("")
        print("💡 NOTA: Verifica sempre l'affidabilità e la sicurezza")
        print("   di nuovi tool prima di installarli sul tuo sistema!")
        print("   Controlla i link delle guide ufficiali forniti.")
    else:
        print("")
        print("❌ Impossibile ottenere suggerimenti dall'AI", file=sys.stderr)
        print("💡 SUGGERIMENTI:", file=sys.stderr)
        print("   1. Verifica la connessione internet", file=sys.stderr)
        print("   2. Attendi qualche minuto e riprova", file=sys.stderr)
        print("   3. Controlla che la API key sia valida", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
