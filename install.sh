#!/usr/bin/env bash
# Script d'installation portable pour les agents locaux Ollama (Geek & Scribe) + Harnais AIChat
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"
USER_AICHAT_CFG="$HOME/.config/aichat"
AICHAT_VERSION="v0.30.0"

echo "==> [1/4] Vérification / Installation du binaire AIChat ($AICHAT_VERSION)..."
mkdir -p "$LOCAL_BIN"
if ! command -v aichat >/dev/null 2>&1; then
    echo "  -> Téléchargement du binaire statique aichat ($AICHAT_VERSION)..."
    curl -sL "https://github.com/sigoden/aichat/releases/download/${AICHAT_VERSION}/aichat-${AICHAT_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
        | tar -xz -C "$LOCAL_BIN/"
    chmod +x "$LOCAL_BIN/aichat"
else
    echo "  -> aichat déjà présent ($(command -v aichat))"
fi

echo "==> [2/4] Déploiement de la configuration AIChat et des outils dans $USER_AICHAT_CFG..."
mkdir -p "$USER_AICHAT_CFG/functions/bin"
cp "$REPO_DIR/aichat/config.yaml" "$USER_AICHAT_CFG/config.yaml"
cp "$REPO_DIR/aichat/functions/functions.json" "$USER_AICHAT_CFG/functions/functions.json"
cp "$REPO_DIR/aichat/functions/bin/"* "$USER_AICHAT_CFG/functions/bin/"
chmod +x "$USER_AICHAT_CFG/functions/bin/"*

echo "==> [3/4] Installation des lanceurs CLI dans $LOCAL_BIN..."
cp "$REPO_DIR/scripts/geek-chat" "$LOCAL_BIN/geek-chat"
chmod +x "$LOCAL_BIN/geek-chat"
ln -sf "$LOCAL_BIN/geek-chat" "$LOCAL_BIN/scribe-chat"

cp "$REPO_DIR/scripts/ollama-agent.py" "$LOCAL_BIN/ollama-agent"
chmod +x "$LOCAL_BIN/ollama-agent"

echo "==> [4/4] Construction des modèles Ollama (geek & scribe)..."
if command -v ollama >/dev/null 2>&1; then
    ollama create geek -f "$REPO_DIR/modelfiles/Modelfile.geek" || echo "  [!] Modèle de base pour geek manquant dans Ollama"
    ollama create scribe -f "$REPO_DIR/modelfiles/Modelfile.scribe" || echo "  [!] Modèle de base pour scribe manquant dans Ollama"
else
    echo "  [!] Ollama n'est pas installé ou démarré. Lance 'ollama create' après l'installation d'Ollama."
fi

echo ""
echo "Installation terminée avec succès !"
echo "Commandes disponibles :"
echo "  - geek-chat            (REPL interactif TUI avec Geek + Tool Calling)"
echo "  - scribe-chat          (REPL interactif TUI avec Scribe + Tool Calling)"
echo "  - ollama-agent         (Harnais CLI natif /api/chat ultra-rapide)"
echo "  - aichat -e \"...\"      (Assistant de commandes shell Arch Linux)"
