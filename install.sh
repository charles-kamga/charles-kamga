#!/usr/bin/env bash
# ==============================================================================
# Kamga's Hyprland Desktop Setup & Universal Auto-Installer
# Distributions supportées : Arch Linux, EndeavourOS, Debian, Ubuntu
# Compositor              : Hyprland + Serpantinum Desktop Shell
# ==============================================================================

set -euo pipefail

# Couleurs & Styles
BOLD='\033[1m'
NC='\033[0m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'

REPO_URL="https://github.com/charles-kamga/charles-kamga.git"
BRANCH="hyprland-config"
INSTALL_TMP="/tmp/kamga-hyprland-setup"

info()    { echo -e "${BLUE}${BOLD}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}${BOLD}[SUCCÈS]${NC} $1"; }
warn()    { echo -e "${YELLOW}${BOLD}[ATTENTION]${NC} $1"; }
error()   { echo -e "${RED}${BOLD}[ERREUR]${NC} $1"; }

banner() {
    clear || true
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
  ██████╗ ██╗  ██╗██████╗  ███████╗███████╗████████╗██╗   ██╗██████╗ 
 ██╔════╝ ██║  ██║██╔══██╗ ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
 ██║  ███╗███████║██████╔╝ ███████╗█████╗     ██║   ██║   ██║██████╔╝
 ╚██████╔╝██║  ██║██║  ██╗ ╚════██║██╔══╝     ██║   ╚██████╔╝██║     
  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ███████║███████╗   ██║    ╚═════╝ ╚═╝     
                           ╚══════╝╚══════╝   ╚═╝                     
EOF
    echo -e "       ${PURPLE}★ Kamga's Hyprland Desktop (Arch & Debian Support) ★${NC}\n"
}

banner

# 1. Vérification root
if [[ "$EUID" -eq 0 ]]; then
    error "Ne lancez pas ce script en root ou avec sudo !"
    echo "Lancez-le en utilisateur normal avec des privilèges sudo : ./install.sh"
    exit 1
fi

# 2. Gestion du mode pipe 'curl | bash'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
if [[ ! -d "$SCRIPT_DIR/dotfiles" ]]; then
    info "Installation directe détectée via le Web..."
    info "Téléchargement de la configuration depuis GitHub ($BRANCH)..."
    rm -rf "$INSTALL_TMP"
    git clone --depth=1 -b "$BRANCH" "$REPO_URL" "$INSTALL_TMP"
    cd "$INSTALL_TMP"
    exec bash "$INSTALL_TMP/install.sh" "$@"
fi

# 3. Détection de la distribution
DISTRO_FAMILY=""
if [[ -f /etc/arch-release ]] || command -v pacman >/dev/null 2>&1; then
    DISTRO_FAMILY="arch"
    info "Distribution détectée : Famille Arch Linux (Pacman / AUR)"
elif [[ -f /etc/debian_version ]] || command -v apt-get >/dev/null 2>&1; then
    DISTRO_FAMILY="debian"
    info "Distribution détectée : Famille Debian / Ubuntu (APT)"
else
    warn "Distribution non standard détectée. Tentative en mode universel..."
    DISTRO_FAMILY="unknown"
fi

# 4. Installation des paquets selon la distribution
mkdir -p "$HOME/.local/bin"

if [[ "$DISTRO_FAMILY" == "arch" ]]; then
    # Helper AUR
    AUR_HELPER=""
    if command -v yay >/dev/null 2>&1; then
        AUR_HELPER="yay"
    elif command -v paru >/dev/null 2>&1; then
        AUR_HELPER="paru"
    else
        info "Installation de l'assistant AUR yay..."
        sudo pacman -S --needed --noconfirm base-devel git
        git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
        (cd /tmp/yay-bin && makepkg -si --noconfirm)
        rm -rf /tmp/yay-bin
        AUR_HELPER="yay"
    fi
    success "Assistant AUR actif : $AUR_HELPER"

    info "Installation des paquets officiels..."
    sudo pacman -S --needed --noconfirm \
        hyprland hyprcursor hyprgraphics kitty \
        wl-clipboard cliphist grim slurp zbar qrencode playerctl brightnessctl \
        python python-pyqt6 python-pyqt6-svg qt6-wayland qt6ct \
        ttf-jetbrains-mono ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji \
        jq curl wget

    info "Installation des composants visuels via AUR..."
    $AUR_HELPER -S --needed --noconfirm matugen-bin quickshell || true

elif [[ "$DISTRO_FAMILY" == "debian" ]]; then
    info "Mise à jour des dépôts APT..."
    sudo apt-get update

    info "Installation des dépendances disponibles sur Debian..."
    sudo apt-get install -y \
        kitty \
        wl-clipboard \
        grim \
        slurp \
        zbar-tools \
        qrencode \
        playerctl \
        brightnessctl \
        python3 \
        python3-pyqt6 \
        python3-pyqt6.qtsvg \
        qt6-wayland \
        qt6ct \
        fonts-jetbrains-mono \
        fonts-noto \
        fonts-noto-color-emoji \
        curl \
        wget \
        git \
        jq \
        tar

    # cliphist (souvent absent des dépôts debian classiques)
    if ! command -v cliphist >/dev/null 2>&1; then
        info "Installation du binaire autonome cliphist..."
        LATEST_CLIPHIST=$(curl -fsSL https://api.github.com/repos/sentriz/cliphist/releases/latest | jq -r '.tag_name' 2>/dev/null || echo "v0.5.0")
        curl -fsSL "https://github.com/sentriz/cliphist/releases/download/${LATEST_CLIPHIST}/v${LATEST_CLIPHIST#v}-linux-amd64" -o "$HOME/.local/bin/cliphist" 2>/dev/null || true
        chmod +x "$HOME/.local/bin/cliphist" 2>/dev/null || true
    fi

    # matugen (binaire autonome si absent)
    if ! command -v matugen >/dev/null 2>&1; then
        info "Installation du binaire autonome matugen..."
        MATUGEN_URL=$(curl -fsSL https://api.github.com/repos/InioX/matugen/releases/latest | jq -r '.assets[] | select(.name | test("linux.*x86_64.*tar.gz")) | .browser_download_url' 2>/dev/null | head -n 1 || echo "")
        if [[ -n "$MATUGEN_URL" ]]; then
            curl -fsSL "$MATUGEN_URL" | tar -xz -C "$HOME/.local/bin/" 2>/dev/null || true
            chmod +x "$HOME/.local/bin/matugen" 2>/dev/null || true
        fi
    fi

    # Vérification de Hyprland sur Debian
    if ! command -v Hyprland >/dev/null 2>&1; then
        warn "Hyprland n'est pas encore installé sur ce système Debian."
        echo -e "${YELLOW}Sur Debian, Hyprland peut être installé via le dépôt officiel de paquets précompilés :${NC}"
        echo -e "  Voir : https://wiki.hypr.land/Getting-Started/Installation/#debian"
        echo -e "  Ou installer les paquets backports / testing si disponibles."
        echo ""
    else
        success "Hyprland est déjà présent sur le système."
    fi
fi

# 5. Vérification / Installation de Serpantinum Shell
if ! command -v serpantinum >/dev/null 2>&1; then
    info "Installation de l'environnement de bureau Serpantinum..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ilyamiro/serpantinum/master/install/install.sh)" || {
        warn "L'installateur direct de Serpantinum s'est exécuté avec des alertes, poursuite du déploiement..."
    }
fi

# 6. Sauvegarde des configurations existantes
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/.config/dotfiles_backup_$TIMESTAMP"

backup_if_exists() {
    local target="$1"
    if [[ -d "$target" || -f "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        info "Sauvegarde de $target vers $BACKUP_DIR/..."
        mv "$target" "$BACKUP_DIR/"
    fi
}

info "Sauvegarde des configurations actuelles si existantes..."
backup_if_exists "$HOME/.config/hypr"
backup_if_exists "$HOME/.config/kitty"
backup_if_exists "$HOME/.config/serpantinum"

# 7. Déploiement des nouvelles configurations
info "Déploiement des configurations Kamga Hyprland..."
mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share/applications" "$HOME/Pictures/Wallpapers"

# Hyprland
cp -r "$SCRIPT_DIR/dotfiles/config/hypr" "$HOME/.config/"
# Kitty
cp -r "$SCRIPT_DIR/dotfiles/config/kitty" "$HOME/.config/"
# Serpantinum
cp -r "$SCRIPT_DIR/dotfiles/config/serpantinum" "$HOME/.config/"
# Environment variables
mkdir -p "$HOME/.config/environment.d"
cp -r "$SCRIPT_DIR/dotfiles/config/environment.d/"* "$HOME/.config/environment.d/" 2>/dev/null || true

# Scripts utilitaires personnalisés
cp "$SCRIPT_DIR/dotfiles/bin/"* "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/"*
ln -sf "$HOME/.local/bin/qr-generator" "$HOME/.local/bin/qr-gen"

# Lanceurs d'applications
cp "$SCRIPT_DIR/dotfiles/applications/"*.desktop "$HOME/.local/share/applications/"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

# 8. S'assurer que ~/.local/bin est dans le PATH
add_path() {
    local rc="$1"
    if [[ -f "$rc" ]] && ! grep -q 'export PATH=.*\.local/bin' "$rc"; then
        echo -e '\n# Kamga dotfiles PATH\nexport PATH="$HOME/.local/bin:$PATH"' >> "$rc"
    fi
}
add_path "$HOME/.bashrc"
add_path "$HOME/.zshrc"

success "Installation et déploiement terminés avec succès !"
echo ""
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  Raccourcis Essentiels de ton Nouveau Bureau :${NC}"
echo -e "${CYAN}  • Super + Entrée${NC}      : Ouvrir le Terminal (Kitty)"
echo -e "${CYAN}  • Super + D${NC}           : Lanceur d'Applications"
echo -e "${CYAN}  • Super + F${NC}           : Navigateur Web (Firefox)"
echo -e "${CYAN}  • Super + Q${NC}           : Fermer la fenêtre active"
echo -e "${CYAN}  • Super + Alt + F${NC}     : Basculer Plein Écran (Maximized)"
echo -e "${CYAN}  • Super + Shift + F${NC}   : Basculer Fenêtre Flottante"
echo -e "${CYAN}  • Super + 1 à 0${NC}       : Changer de Bureau"
echo -e "${CYAN}  • Super + Shift + 1 à 0${NC} : Déplacer la fenêtre vers le bureau"
echo -e "${CYAN}  • Super + C${NC}           : Historique du Presse-papier"
echo -e "${CYAN}  • Super + V${NC}           : Contrôle du Volume"
echo -e "${CYAN}  • Super + W${NC}           : Sélecteur de Fond d'écran"
echo -e "${CYAN}  • Super + Espace${NC}      : Lecture / Pause Multimédia"
echo -e "${CYAN}  • qr-generator${NC}        : Studio QR Code Bento (PyQt6)"
echo -e "${CYAN}  • qr-scan${NC}             : Scanner QR Code à l'écran"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
info "Tu peux maintenant lancer ou relancer Hyprland pour profiter du bureau !"
