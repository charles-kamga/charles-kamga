# Configuration des Agents Locaux Ollama (`geek` & `scribe`) + Harnais `aichat`

Ce dépôt (branche `ollama-agents-config`) contient l'architecture complète, les **Modelfiles**, les **outils de Function Calling (Shell local & Internet)** et les **harnais CLI ultra-légers** optimisés pour **Arch Linux / EndeavourOS** (Hyprland) sur GPU **NVIDIA RTX 3050 Ti Laptop (4 Go VRAM)**.

---

## 1. Architecture & Modèles Locaux

Afin d'éviter la saturation de la VRAM (4 Go) et la surcharge des harnais lourds (comme OpenCode ou Claude Code qui injectent 15 000+ tokens de prompt système et demandent `262144` tokens de contexte), cette configuration repose sur :
- Une fenêtre de contexte calibrée à **`num_ctx 8192`** (garantissant **78 % à 91 % d'exécution GPU** et **20 à 26 tok/s**).
- Deux agents spécialisés basés sur **Qwen 3.5 4B (`Q4_K_M`)** utilisant nativement le couple `RENDERER qwen3.5` / `PARSER qwen3.5` :

| Agent | Modèle de base Ollama | Taille | Capacités | Rôle & Spécialisation |
| :--- | :--- | :--- | :--- | :--- |
| **`geek:latest`** | `huihui_ai/qwen3.5-abliterated:4B` | 3,3 Go | `completion`, `vision`, `tools`, `thinking` | Opérateur Red Team, Pentester, chercheur en vulnérabilités et ingénieur sécurité **Arch Linux / EndeavourOS** (sans refus moralisateurs sur labo/réseau local). |
| **`scribe:latest`** | `diag-qwen35-text:latest` | 2,7 Go | `completion`, `tools`, `thinking` | Rédacteur technique et analyste de journaux système (`journalctl`, `/var/log/pacman.log`) haute vitesse (~25,5 tok/s). |

---

## 2. Structure du Dépôt

```text
.
├── install.sh                         # Script d'installation automatique (binaire aichat, configs, Modelfiles)
├── modelfiles/
│   ├── Modelfile.geek                 # Définition Ollama de l'agent Geek (Red Team & Arch Linux)
│   └── Modelfile.scribe               # Définition Ollama de l'agent Scribe (Logs & Documentation)
├── aichat/
│   ├── config.yaml                    # Configuration AIChat (ollama, max_input_tokens: 8192, function_calling)
│   └── functions/
│       ├── functions.json             # Schémas JSON des 3 outils exposés aux modèles
│       └── bin/
│           ├── execute_command        # Exécution de commandes shell Arch Linux (avec garde-fous de sécurité)
│           ├── web_fetch              # Récupération HTTP GET (pages web nettoyées, JSON, flux RSS)
│           └── web_search             # Recherche Internet en direct via DuckDuckGo (titres, extraits, URLs)
└── scripts/
    ├── geek-chat                      # Wrapper AIChat pour geek:latest (et scribe-chat via symlink)
    └── ollama-agent.py                # Harnais CLI natif (/api/chat, think=False) ultra-rapide
```

---

## 3. Outils de *Tool Calling* Intégrés

Les modèles peuvent appeler de manière autonome (individuellement ou en parallèle dans le même tour) les trois outils situés dans `aichat/functions/bin/` :

1. **`execute_command`** : Exécute une commande shell locale sur Arch Linux (`uname -r`, `ss -tuln`, `journalctl -p err -b`, `df -h`, etc.) avec un délai maximal de 20s et un blocage strict des commandes destructrices (`mkfs`, `wipefs`, `dd of=/dev/`, `nvme1n1`, `rm -rf /`).
2. **`web_fetch`** : Interroge n'importe quelle URL (`https://wttr.in/...`, `https://archlinux.org/feeds/news/`, API JSON) et nettoie automatiquement le HTML ou parse les flux RSS.
3. **`web_search`** : Effectue une recherche web en direct sur DuckDuckGo et retourne les 5 premiers résultats pertinents (titre, URL décodée, extrait).

> **Note technique `aichat` (`LLM_OUTPUT`)** : Les scripts d'outils détectent automatiquement la variable d'environnement `LLM_OUTPUT` passée par `aichat` afin de réinjecter la sortie de l'outil dans la boucle de raisonnement du LLM. Lorsqu'ils sont appelés par `ollama-agent.py`, ils écrivent directement sur `stdout`.

---

## 4. Installation Rapide

Sur une installation fraîche d'**EndeavourOS / Arch Linux** :

```bash
git clone -b ollama-agents-config git@github.com:charles-kamga/charles-kamga.git ~/ollama-agents
cd ~/ollama-agents
chmod +x install.sh
./install.sh
```

*(Optionnel : `aichat` peut aussi être installé depuis les dépôts officiels Arch Linux via `sudo pacman -S aichat`).*

---

## 5. Guide d'Utilisation

### A. Via le harnais natif `ollama-agent` (Recommandé pour la vitesse maximale)
Appelle directement l'endpoint natif `/api/chat` d'Ollama avec `think=False` par défaut (réponse en 2 à 5 secondes) :

```bash
# Requête directe avec Tool Calling (Shell + Recherche Web simultanés)
ollama-agent -m geek:latest "Vérifie la version de mon noyau avec execute_command et cherche les dernières news Arch Linux"

# Analyse de logs système avec Scribe (via pipe Unix ou outil)
journalctl -p err -b | ollama-agent -m scribe:latest "Résume ces erreurs par ordre chronologique"
ollama-agent -m scribe:latest "Utilise execute_command avec 'tail -n 20 /var/log/pacman.log' et résume les dernières transactions"

# Mode REPL interactif
ollama-agent -m geek:latest
```

### B. Via le harnais Rust `aichat` (`geek-chat` / `scribe-chat`)

```bash
# Session interactive complète (TUI)
geek-chat
scribe-chat

# Mode requête unique sans streaming ANSI (-S)
geek-chat -S "Liste mes ports en écoute avec execute_command ('ss -tuln') et analyse la surface exposée"

# Mode Assistant Shell Arch Linux (-e : génère la commande et propose de l'exécuter)
aichat -e "trouve tous les paquets orphelins avec pacman"
```

### C. Fonctions Shell directes (`~/.bashrc` / `~/.config/fish/functions/`)

```bash
geek() { ollama run geek:latest "$@"; }
scribe() { ollama run scribe:latest "$@"; }
```
