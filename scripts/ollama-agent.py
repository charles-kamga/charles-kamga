#!/usr/bin/env python3
"""
Harnais CLI natif ultra-léger pour Ollama (geek:latest & scribe:latest)
Utilise directement l'API native /api/chat d'Ollama (num_ctx=8192, think=False)
avec 3 outils intégrés : execute_command, web_fetch, web_search.
"""
import argparse
import json
import os
import subprocess
import sys
import urllib.request

OLLAMA_URL = os.environ.get("OLLAMA_CHAT_URL", "http://127.0.0.1:11434/api/chat")

TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "execute_command",
            "description": "Exécute une commande shell sur le système Arch Linux local et retourne la sortie standard (stdout/stderr).",
            "parameters": {
                "type": "object",
                "properties": {
                    "command": {
                        "type": "string",
                        "description": "La commande shell Linux à exécuter (ex: 'uname -r', 'ss -tuln', 'journalctl -n 20')"
                    }
                },
                "required": ["command"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "web_fetch",
            "description": "Récupère le contenu texte, JSON ou flux RSS d'une URL sur Internet via une requête HTTP GET.",
            "parameters": {
                "type": "object",
                "properties": {
                    "url": {
                        "type": "string",
                        "description": "L'URL complète (http/https) à interroger"
                    }
                },
                "required": ["url"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "web_search",
            "description": "Effectue une recherche sur Internet (DuckDuckGo) et retourne les premiers résultats (titres, extraits et URLs).",
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "Les mots-clés de la recherche Internet"
                    }
                },
                "required": ["query"]
            }
        }
    }
]

DEFAULT_BIN_DIR = os.path.expanduser("~/.config/aichat/functions/bin")
BIN_DIR = os.environ.get("AICHAT_FUNCTIONS_BIN", DEFAULT_BIN_DIR)

def run_tool(name: str, args: dict) -> str:
    tool_bin = os.path.join(BIN_DIR, name)
    if os.path.isfile(tool_bin) and os.access(tool_bin, os.X_OK):
        try:
            res = subprocess.run(
                [tool_bin, json.dumps(args, ensure_ascii=False)],
                capture_output=True,
                text=True,
                timeout=25
            )
            return (res.stdout + res.stderr).strip() or "(sortie vide)"
        except Exception as e:
            return f"Erreur outil {name}: {e}"
    return f"Outil introuvable ({tool_bin})"

def call_ollama(model: str, messages: list, think: bool = False) -> dict:
    payload = {
        "model": model,
        "messages": messages,
        "tools": TOOLS,
        "stream": False,
        "think": think,
        "options": {
            "temperature": 0.0,
            "num_ctx": 8192
        }
    }
    req = urllib.request.Request(
        OLLAMA_URL,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req, timeout=180) as resp:
        return json.loads(resp.read().decode("utf-8"))

def process_turn(model: str, messages: list, think: bool = False, quiet: bool = False):
    for _ in range(5):
        res = call_ollama(model, messages, think=think)
        msg = res.get("message", {})
        tool_calls = msg.get("tool_calls", [])
        if tool_calls:
            messages.append(msg)
            for tc in tool_calls:
                fn = tc.get("function", {})
                fname = fn.get("name", "")
                fargs = fn.get("arguments", {})
                if not quiet:
                    sys.stderr.write(f"\033[36m[outil] {fname}({json.dumps(fargs, ensure_ascii=False)})\033[0m\n")
                out = run_tool(fname, fargs)
                messages.append({"role": "tool", "content": out})
        else:
            content = msg.get("content", "").strip()
            print(content)
            messages.append(msg)
            return

def main():
    parser = argparse.ArgumentParser(description="Harnais CLI natif Ollama (geek / scribe)")
    parser.add_argument("-m", "--model", default="geek:latest", help="Modèle Ollama (défaut: geek:latest)")
    parser.add_argument("--think", action="store_true", help="Activer le mode raisonnement <think>")
    parser.add_argument("-q", "--quiet", action="store_true", help="Masquer les logs d'appels d'outils sur stderr")
    parser.add_argument("prompt", nargs="*", help="Requête directe (omis = mode interactif REPL)")
    args = parser.parse_args()

    piped_in = ""
    if not sys.stdin.isatty():
        piped_in = sys.stdin.read().strip()

    user_prompt = " ".join(args.prompt).strip()
    if piped_in:
        user_prompt = f"{user_prompt}\n\n---\n{piped_in}" if user_prompt else piped_in

    messages = []
    if user_prompt:
        messages.append({"role": "user", "content": user_prompt})
        process_turn(args.model, messages, think=args.think, quiet=args.quiet)
        return

    print(f"\033[1;32m=== Session Interactive ({args.model}) — Tape 'exit' ou Ctrl+D pour quitter ===\033[0m")
    while True:
        try:
            line = input(f"\033[1;34m{args.model.split(':')[0]}>\033[0m ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            break
        if not line or line.lower() in ("exit", "quit", ":q"):
            break
        messages.append({"role": "user", "content": line})
        process_turn(args.model, messages, think=args.think, quiet=args.quiet)

if __name__ == "__main__":
    main()
