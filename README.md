# 🚀 Kamga's Hyprland Desktop Environment

Configuration moderne, fluide et élégante pour **Hyprland** sur **Arch Linux** & **EndeavourOS**, propulsée par le shell **Serpantinum** (Quickshell) et enrichie d'outils utilitaires personnalisés.

---

## ⚡ Installation Rapide (En une seule ligne)

Ouvrez un terminal et collez la commande suivante :

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/charles-kamga/charles-kamga/hyprland-config/install.sh)"
```

*Le script vérifie automatiquement les dépendances, installe les paquets manquants via `pacman` et `yay`, sauvegarde vos anciennes configurations, et applique le bureau complet en toute sécurité.*

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

## 🛠️ Outils en ligne de commande

```bash
# Lancer le générateur QR en interface graphique :
qr-generator
# ou son alias court :
qr-gen

# Générer expressément le QR du presse-papier sans ouvrir la fenêtre :
qr-generator --clip

# Scanner un code QR affiché à l'écran :
qr-scan

# Scanner un code QR depuis la webcam :
qr-scan --cam
```

---

## 🛡️ Sauvegardes & Sécurité

L'installateur crée automatiquement une sauvegarde horodatée de vos anciens dossiers de configuration dans `~/.config/dotfiles_backup_<horodatage>/` avant toute modification. Vous pouvez ainsi restaurer votre état précédent à tout moment.
