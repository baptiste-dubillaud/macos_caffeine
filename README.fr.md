# ☕ Caffeine pour macOS

**Langue :** [🇫🇷 Français](#caffeine-pour-macos) | [🇬🇧 English](README.md)

Un petit utilitaire minimaliste de barre de menus pour macOS — un clone de l'extension « Caffeine » d'Ubuntu.

## À quoi ça sert ?

Une simple tasse à café dans la barre de menus (en haut à droite) qui empêche votre Mac de se mettre en veille à la demande :

- **Tasse vide** = app inactive, mise en veille normale
- **Tasse pleine** (au clic) = anti-veille activé, votre écran ne s'endormira pas

C'est tout. Volontairement minimaliste.

## Fonctionnalités

- ☕ **Icône de barre de menus** — tasse vide/pleine selon l'état
- **Clic gauche** — bascule rapide veille on/off
- **Clic droit** — menu complet :
  - Activer / Désactiver immédiatement
  - Minuterie : 30 min, 1 h, ou 2 h d'anti-veille puis retour automatique
  - Notification de fin de minuterie
  - Lancer au démarrage du Mac
  - Quitter
- **Lancement au démarrage** — option pour que Caffeine démarre automatiquement avec votre Mac
- **Notifications** — alerte sonore + visuelle quand la minuterie expire

## Installation

### Prérequis

- **macOS** 10.15 ou récent
- Xcode (Command Line Tools ou IDE complet)

### Démarrage rapide (développement)

Ouvrir le projet dans Xcode et appuyer sur **Cmd-R** pour compiler et lancer immédiatement.

### Compiler depuis le code source

```bash
cd Caffeine
xcodebuild -scheme Caffeine -configuration Release build
```

Le binaire est généré à : `build/Release/Caffeine.app`

### Déployer dans `/Applications`

```bash
cp -r Caffeine/build/Release/Caffeine.app /Applications/
# Rafraîchir la base de données du lanceur système
lsregister -f /Applications/Caffeine.app
```

Puis lancer depuis Spotlight (Cmd-Espace, taper « Caffeine ») ou ajouter aux éléments de connexion via Réglages Système > Général > Éléments de connexion.

### Mettre à jour une installation existante

Recompiler et remplacer l'app dans `/Applications` :

```bash
cd Caffeine
xcodebuild -project Caffeine.xcodeproj -scheme Caffeine -configuration Release build -derivedDataPath ../build
rm -rf /Applications/Caffeine.app
cp -r build/Build/Products/Release/Caffeine.app /Applications/
lsregister -f /Applications/Caffeine.app
```

### Gestion du versionning

Les infos de version sont stockées dans Xcode :
- Ouvrir `Caffeine.xcodeproj` → Target **Caffeine** → Build Settings
- **Marketing Version** : version visible à l'utilisateur (ex : `1.0`, `1.1`, `2.0`)
- **Current Project Version** : numéro de build (à incrémenter à chaque compilation)

La version s'affiche dans le menu de l'app (clic droit sur la tasse).

## Architecture

- **Langage** : Swift 6
- **Framework** : AppKit (`NSStatusItem`)
- **Point d'entrée** : `main.swift` — crée l'app et démarre l'`AppDelegate`
- **Logique** : `AppDelegate.swift` — gère la tasse, le menu et l'anti-veille
- **Anti-veille** : `ProcessInfo.beginActivity()` avec `.idleDisplaySleepDisabled`

### Structure du projet

```
Caffeine/
├── Caffeine.xcodeproj/    # Projet Xcode
├── Caffeine/
│   ├── main.swift         # Point d'entrée
│   ├── AppDelegate.swift  # Logique principale
│   └── Assets/
└── README.fr.md
```

## Développement

### Phases achevées

- ✅ Affichage de l'icône dans la barre de menus
- ✅ Bascule vide ↔ pleine au clic
- ✅ Activation/désactivation de l'anti-veille
- ✅ Menu enrichi avec minuterie
- ✅ Notifications de fin
- ✅ Lancement au démarrage
- ✅ Icône d'app

### Lancer en développement

Ouvrir le projet dans Xcode :
```bash
open Caffeine/Caffeine.xcodeproj
```

Puis cliquer sur le bouton ▶ (Run) ou appuyer sur **Cmd-R**.

## Notes techniques

- **App « agent »** : Caffeine n'apparaît que dans la barre de menus, pas dans le Dock
- **Icônes système** : utilise `cup.and.saucer` (vide) et `cup.and.saucer.fill` (pleine) de SF Symbols
- **Sandbox** : l'app est sandboxée pour respecter les normes macOS
- **Signature** : signature ad-hoc (pas de compte Apple Developer requis pour usage personnel)

## Roadmap

Déjà complet pour un usage quotidien. Les évolutions possibles seraient :

- Synchronisation avec préférences système (Do Not Disturb)
- Customisation des durées de minuterie
- Historique d'usage
- Dark mode adapté

## Licence

Usage personnel. Pas de notarisation Apple requise.

---

**Questions ?** Vérifiez que Xcode est installé et que le projet compile en Debug.
