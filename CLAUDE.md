# Caffeine pour macOS

Petit utilitaire de barre de menus (clone de l'extension « Caffeine » d'Ubuntu) :
une tasse à café dans la barre de menus (en haut à droite).
- **Inactive** = tasse vide, ne fait rien.
- **Active** (au clic) = tasse pleine + empêche la mise en veille automatique du Mac.

Rien de plus. Volontairement minimaliste.

## Contexte utilisateur (IMPORTANT — à lire en priorité)
- L'utilisateur (Baptiste) **ne connaît pas Swift** et **découvre Xcode** (qu'il
  installe exprès pour apprendre). Tout expliquer, en français.
- Avancer **phase par phase**, valider chaque étape avant de passer à la suivante.
- Ton pédagogique : expliquer le code, les concepts Swift/macOS, ET les manipulations
  dans Xcode (chaque écran/menu) au passage.

## Décisions techniques (et pourquoi)
- **Outillage : Xcode** (l'IDE complet d'Apple), choisi pour **apprendre**
  l'environnement standard. Build et lancement depuis Xcode (bouton ▶ / Cmd-R).
- **Langage : Swift** (standard du natif macOS).
- **Framework : AppKit `NSStatusItem`** (et non SwiftUI `MenuBarExtra`) car on veut
  un **clic = bascule directe** (fidèle au Caffeine d'Ubuntu). App AppKit pure,
  démarrée par `main.swift` (voir « Structure » + le piège connu plus bas).
- **Anti-veille : `ProcessInfo.beginActivity`** (API Foundation, simple) avec
  l'option `.idleDisplaySleepDisabled` (garde l'écran allumé, comme l'original).
- **App « agent »** : « Application is agent (UIElement) » = YES dans les réglages
  du target → pas d'icône dans le Dock, juste la barre de menus.
- Icônes : symboles système `cup.and.saucer` (vide) / `cup.and.saucer.fill` (pleine).
  Aucun asset à dessiner.
- Comportement : on/off illimité (pas de minuterie pour l'instant — option Phase 4).

## Prérequis / état de l'environnement
- macOS 26.5, Swift 6.3.2 (Command Line Tools déjà présents).
- **Xcode en cours d'installation** (depuis le Mac App Store).
- Apple ID gratuit suffit. Apple Developer Program (99 €/an) NON requis (usage perso).

## Structure du projet
- `Caffeine/Caffeine.xcodeproj` — le projet Xcode.
- `Caffeine/Caffeine/main.swift` — **point d'entrée** : crée l'app, branche
  `AppDelegate` comme délégué, `setActivationPolicy(.accessory)`, `app.run()`.
  Le tout dans `MainActor.assumeIsolated { }` (sinon warning de concurrence Swift 6
  sur `app.delegate = delegate` ; le projet est en isolation `MainActor` par défaut).
- `Caffeine/Caffeine/AppDelegate.swift` — logique de l'app (la tasse, le menu).
- `ViewController.swift` + `Base.lproj/Main.storyboard` — restes du modèle, **inutilisés**
  (on pourra les supprimer ; ne pas remettre de référence au storyboard).
- Réglages du target (« Application is agent », pas de storyboard) dans le projet.

### ⚠️ Piège connu (déjà rencontré)
Le modèle « Storyboard » fait démarrer `AppDelegate` *via le storyboard*. Comme on a
retiré le storyboard (pour ne pas avoir de fenêtre), `AppDelegate` n'était plus lancé
→ l'app tournait mais `applicationDidFinishLaunching` ne s'exécutait jamais (aucune tasse).
**Solution :** point d'entrée explicite dans `main.swift` (et donc PAS de `@main` sur
`AppDelegate`). Ne pas dépendre du storyboard pour démarrer le délégué.

## Build & lancement
- Dans Xcode : bouton ▶ (Run) ou **Cmd-R** pour compiler + lancer.
- Stopper : bouton ⏹ dans Xcode, ou menu de la tasse → « Quitter ».
- (Optionnel, plus tard) build en ligne de commande : `xcodebuild -scheme Caffeine`.

## Plan de développement (cocher au fur et à mesure)
- [x] **Phase 0** — Créer le projet Xcode (assistant) + réglage « app agent ».
- [x] **Phase 1** — Afficher l'icône « tasse vide » dans la barre de menus + menu « Quitter ».
- [x] **Phase 2** — Clic gauche = bascule vide ↔ pleine (sans logique de veille encore).
- [x] **Phase 3** — Brancher l'anti-veille (`beginActivity`/`endActivity`) sur la bascule.
- [x] **Phase 4** — Menu enrichi, minuterie (30 min/1 h/2 h) + notification de fin
      (logo joint), icône d'app générée, lancement au démarrage (`SMAppService`),
      installation dans /Applications.

## Statut actuel
**Toutes les phases faites** ✅ — app complète, installée dans /Applications :
- clic gauche = bascule veille on/off ; clic droit = menu (Activer/Désactiver,
  durées 30 min/1 h/2 h, Lancer au démarrage, Quitter) ;
- anti-veille via `beginActivity(.idleDisplaySleepDisabled)` ;
- minuterie (`Timer`) + extinction auto + notification de fin, avec le logo joint
  via `UNNotificationAttachment` (`makeLogoFile()` rend la tasse à la volée) ;
- icône d'app « tasse blanche sur carré brun » : PNG dans `AppIcon.appiconset`
  (générés depuis `cup.and.saucer.fill` ; script de génération non versionné) ;
- lancement au démarrage via `SMAppService.mainApp` ;
- app agent, démarrée par `main.swift`, signée ad-hoc, zéro warning.

Restes inutilisés `ViewController.swift` + `Base.lproj/Main.storyboard` (inoffensifs).

### Mettre à jour l'app installée
Recompiler en Release puis recopier dans /Applications :
`xcodebuild -project Caffeine/Caffeine.xcodeproj -scheme Caffeine -configuration Release build`
puis copier le `.app` produit dans /Applications + `lsregister -f`. (Dév courant : Cmd-R dans Xcode.)

### Connu / cosmétique
L'icône À GAUCHE des notifications reste vide tant que le cache d'icônes du démon de
notifs n'est pas rafraîchi (déconnexion/reconnexion). L'icône d'app est valide
(Spotlight l'affiche) ; le logo À DROITE (image jointe) s'affiche, lui, toujours.
NB : le projet est sandboxé (`ENABLE_APP_SANDBOX = YES`) — OK pour `beginActivity`
(Phase 3) ; à surveiller pour le lancement au démarrage (Phase 4).

## Publication (perso)
Usage perso uniquement : **pas de notarisation, pas de compte Apple payant**.
Lancer depuis Xcode suffit ; pour un usage quotidien, on pourra « Archiver » l'app et
copier le `.app` dans /Applications + l'ajouter aux ouvertures au démarrage. Le Apple
Developer Program ne servirait que pour **partager** l'app à d'autres — non requis ici.
