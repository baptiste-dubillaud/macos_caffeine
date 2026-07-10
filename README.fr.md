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
  - **Rester actif écran verrouillé** (case à cocher)
  - Lancer au démarrage du Mac
  - Quitter
- **Indicateur de minuterie dans la barre de menus** — quand une minuterie tourne, la tasse se remplit de « café » dont le niveau baisse au fil du temps (l'icône reste la simple tasse, alignée comme les autres, aucun chiffre qui défile). C'est une image *template* : macOS la recolore selon la barre (clair/sombre) et l'inverse au clic, comme ses propres icônes ; le temps exact est dans l'infobulle au survol
- **Extinction auto au verrouillage** — par défaut, Caffeine se coupe quand l'écran se verrouille ou s'éteint, pour que votre veille automatique habituelle reprenne. Cochez **Rester actif écran verrouillé** pour au contraire continuer en arrière-plan (téléchargements, compilations…). Le choix est mémorisé.
- **Notification de fin de minuterie** — alerte sonore + visuelle, avec le logo Caffeine joint
- **Lancement au démarrage** — option pour démarrer automatiquement avec votre Mac
- **Bilingue** — anglais et français, choisi automatiquement selon la langue de votre Mac (extensible à d'autres)

## Installation

### Prérequis

- **macOS** 13 (Ventura) ou récent (utilise `SMAppService` pour le lancement au démarrage)
- **Xcode** 16 ou récent (Swift Testing + catalogues de chaînes)

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

- **Langage** : Swift (le module de l'app est isolé sur le `MainActor` par défaut)
- **Framework** : AppKit (`NSStatusItem`)
- **Point d'entrée** : `main.swift` — crée l'app et démarre l'`AppDelegate`
- **Cœur + extensions** : `AppDelegate.swift` porte l'état et le cycle de vie ; le reste est réparti en extensions ciblées (`AppDelegate+Menu`, `AppDelegate+Timer`, `AppDelegate+SleepPrevention`)
- **Logique pure** : `CaffeineLogic.swift` — décisions sans interface, testées unitairement (coupure au verrouillage, durées, texte du compte à rebours)
- **Anti-veille** : `ProcessInfo.beginActivity()` avec `.idleDisplaySleepDisabled`
- **Localisation** : catalogue de chaînes `Localizable.xcstrings` (anglais source + français) ; tout le texte passe par `Strings.swift` (`enum L`)
- **Lancement au démarrage** : `SMAppService.mainApp`

### Structure du projet

```
Caffeine/
├── Caffeine.xcodeproj/                    # Projet Xcode (groupes synchronisés)
├── Caffeine/
│   ├── main.swift                         # Point d'entrée
│   ├── AppDelegate.swift                  # Cœur : état, cycle de vie, bascule, icône
│   ├── AppDelegate+Menu.swift             # Menu (clic droit) + actions
│   ├── AppDelegate+Timer.swift            # Compte à rebours + notification
│   ├── AppDelegate+SleepPrevention.swift  # Anti-veille + verrouillage/extinction
│   ├── CaffeineLogic.swift                # Logique pure, testable
│   ├── StatusIcon.swift                   # Icône de la barre (tasse + niveau de café qui baisse)
│   ├── LogoRenderer.swift                 # Dessin du logo de notification
│   ├── Strings.swift                      # Chaînes de l'UI (enum L)
│   ├── Localizable.xcstrings              # Traductions (anglais + français)
│   └── Assets.xcassets/                   # Icône de l'app
├── CaffeineTests/                         # Tests unitaires (Swift Testing)
└── README.fr.md
```

## Tests

Les tests unitaires sont dans `CaffeineTests/` et utilisent **Swift Testing** (`import Testing`, `#expect`). Ils visent volontairement la logique *pure* isolée dans `CaffeineLogic` — décision de coupure au verrouillage, durées, minutes→secondes, format du compte à rebours — plus une vérification que le logo de notification est un vrai PNG de 256×256. L'UI, l'anti-veille et les notifications (effets de bord) ne sont pas testés unitairement.

Les lancer dans Xcode avec **Cmd-U**, ou en ligne de commande :

```bash
xcodebuild test -project Caffeine/Caffeine.xcodeproj -scheme Caffeine -destination 'platform=macOS'
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
- ✅ Indicateur de minuterie dans la barre de menus (niveau de café qui baisse)
- ✅ Extinction auto au verrouillage (+ option « rester actif »)
- ✅ Localisation anglais/français
- ✅ Découpage du code en fichiers + tests unitaires

### Lancer en développement

Ouvrir le projet dans Xcode :
```bash
open Caffeine/Caffeine.xcodeproj
```

Puis cliquer sur le bouton ▶ (Run) ou appuyer sur **Cmd-R**.

## Notes techniques

- **App « agent »** : Caffeine n'apparaît que dans la barre de menus, pas dans le Dock
- **Icônes système** : utilise `cup.and.saucer` (vide) et `cup.and.saucer.fill` (pleine) de SF Symbols
- **Localisation** : catalogue de chaînes — ajouter une langue dans Xcode sans toucher au code
- **Sandbox** : l'app est sandboxée pour respecter les normes macOS
- **Signature** : signature ad-hoc (pas de compte Apple Developer requis pour usage personnel)

## Roadmap

Déjà complet pour un usage quotidien. Les évolutions possibles seraient :

- Synchronisation avec préférences système (Do Not Disturb)
- Customisation des durées de minuterie
- Historique d'usage
- Plus de langues

## Licence

Usage personnel. Pas de notarisation Apple requise.

---

**Questions ?** Vérifiez que Xcode est installé et que le projet compile en Debug.
