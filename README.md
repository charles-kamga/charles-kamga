# 🚀 Kamga's Hyprland Desktop Environment

Configuration moderne, fluide et élégante pour **Hyprland** sur **Arch Linux**, **EndeavourOS**, **Debian** & **Ubuntu**, propulsée par le shell **Serpantinum** (Quickshell) et enrichie d'outils utilitaires personnalisés.

---

## ⚡ Installation Rapide (En une seule ligne)

Ouvrez un terminal et collez la commande suivante :

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/charles-kamga/charles-kamga/hyprland-config/install.sh)"
```

*Le script détecte automatiquement votre distribution (Arch Linux/EndeavourOS ou Debian/Ubuntu), installe les paquets appropriés (`pacman` ou `apt`), télécharge les outils requis, sauvegarde vos anciennes configurations, et applique le bureau complet en toute sécurité.*

---

## 📦 Installation Manuelle

Si vous préférez cloner le dépôt avant de lancer l'installation :

```bash
git clone -b hyprland-config https://github.com/charles-kamga/charles-kamga.git ~/Kamga-Hyprland
cd ~/Kamga-Hyprland
chmod +x install.sh
./install.sh
```

---

## 🐧 Compatibilité Système

| Distribution | Statut | Gestionnaire de paquets | Notes |
| :--- | :--- | :--- | :--- |
| **Arch Linux / EndeavourOS** | ✅ Support Natif 100% | `pacman` + `yay`/`paru` | Installation instantanée sans étapes manuelles. |
| **Debian (Testing / Sid / 12)** | ✅ Support Automatisé | `apt` + binaires autonomes | Télécharge automatiquement `cliphist` et `matugen` si absents des dépôts Debian. |
| **Ubuntu (24.04 / 24.10)** | ✅ Support Automatisé | `apt` + binaires autonomes | Assurez-vous d'avoir une session Wayland active. |

---

## ✨ Fonctionnalités & Composants Inclus

- **Compositeur Hyprland** avec configuration native Lua modulaire et performante.
- **Serpantinum Desktop Shell** :
  - Barre supérieure modulaire (workspaces animés style pacman, horloge, météo, monitoring CPU/RAM/Disque).
  - Lanceur d'applications rapide et moderne (`Super + D`).
  - Menu de contrôle système, son et réseau.
  - Sélecteur de fond d'écran dynamique (`Super + W`).
- **Terminal Kitty** préconfiguré avec la police *JetBrains Mono* et le thème sombre *Serpantinum*.
- **⚡ QR Studio (`qr-generator`)** :
  - Générateur interactif de codes QR haute définition développé en PyQt6.
  - Design moderne *Bento Grid* avec icônes vectorielles SVG Lucide pures.
  - Détection automatique du presse-papier à l'ouverture.
  - Détection intelligente du contenu (URL Web, Wi-Fi, Email, Texte).
  - Copie directe de l'image PNG dans le presse-papier Wayland (`wl-copy`) pour WhatsApp, Discord, etc.
- **🔍 Scanner de QR Code (`qr-scan`)** :
  - Scan de n'importe quel code QR affiché à l'écran par simple sélection de zone avec la souris (`slurp` + `grim` + `zbar`).
  - Décodage instantané et copie automatique du texte dans le presse-papier.

---

## ⌨️ Raccourcis Clavier Essentiels

| Raccourci | Action |
| :--- | :--- |
| **<kbd>Super</kbd> + <kbd>Entrée</kbd>** | Ouvrir le terminal (**Kitty**) |
| **<kbd>Super</kbd> + <kbd>D</kbd>** | Ouvrir le **Lanceur d'applications** |
| **<kbd>Super</kbd> + <kbd>F</kbd>** | Lancer le navigateur Web (**Firefox**) |
| **<kbd>Super</kbd> + <kbd>Q</kbd>** | Fermer la fenêtre active |
| **<kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>F</kbd>** | Basculer en **Plein écran** (*Maximized*) |
| **<kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>F</kbd>** | Basculer en **Fenêtre flottante** (*Float*) |
| **<kbd>Super</kbd> + <kbd>1</kbd> à <kbd>0</kbd>** | Basculer vers les **Bureaux 1 à 10** |
| **<kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>1</kbd> à <kbd>0</kbd>** | **Déplacer la fenêtre** vers le bureau correspondant |
| **<kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Flèches</kbd>** | Réorganiser la position de la fenêtre sur l'écran |
| **<kbd>Super</kbd> + <kbd>C</kbd>** | Ouvrir l'historique du **Presse-papier** |
| **<kbd>Super</kbd> + <kbd>V</kbd>** | Menu de gestion du **Volume** |
| **<kbd>Super</kbd> + <kbd>W</kbd>** | Sélecteur de **Fonds d'écran** |
| **<kbd>Super</kbd> + <kbd>B</kbd>** | Panneau d'informations système / batterie |
| **<kbd>Super</kbd> + <kbd>L</kbd>** | **Verrouiller l'écran** |
| **<kbd>Super</kbd> + <kbd>Espace</kbd>** | Lecture / Pause multimédia |
| **<kbd>Print</kbd>** | Capture d'écran interactive |

---

## 🛡️ Sauvegardes & Sécurité

L'installateur crée automatiquement une sauvegarde horodatée de vos anciens dossiers de configuration dans `~/.config/dotfiles_backup_<horodatage>/` avant toute modification. Vous pouvez ainsi restaurer votre état précédent à tout moment.
