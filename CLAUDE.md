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
- `Caffeine/Caffeine.xcodeproj` — le projet Xcode. **objectVersion 77** avec
  **groupe synchronisé** (`fileSystemSynchronizedGroups`) : tout fichier déposé dans
  `Caffeine/Caffeine/` est automatiquement compilé — **pas besoin de toucher au
  `.pbxproj`** pour ajouter/supprimer un fichier.
- `main.swift` — **point d'entrée** : crée l'app, branche `AppDelegate` comme délégué,
  `setActivationPolicy(.accessory)`, `app.run()`. Le tout dans
  `MainActor.assumeIsolated { }` (sinon warning de concurrence Swift 6 sur
  `app.delegate = delegate` ; le projet est en isolation `MainActor` par défaut).
- `AppDelegate.swift` — **cœur** : état (`isActive`, `sleepAssertion`, `countdownTimer`,
  `autoOffEndDate`, `autoOffDuration`, `keepAliveWhenLocked`), cycle de vie, bascule
  `setActive/toggle`, mise à jour de l'icône (`updateIcon`), `deinit`.
- `AppDelegate+SleepPrevention.swift` — anti-veille (`beginActivity`) + écoute du
  verrouillage/extinction d'écran (`handleScreenLocked`).
- `AppDelegate+Menu.swift` — construction du menu (clic droit) + ses actions.
- `AppDelegate+Timer.swift` — minuterie (compte à rebours) + notification de fin.
- `CaffeineLogic.swift` — `enum` de logique pure (testée) : décision de coupure au
  verrouillage, durées, minutes→secondes, texte du décompte, fraction du remplissage (café).
- `StatusIcon.swift` — dessine l'icône de la barre, toujours en image **« template »** :
  tasse seule sans minuterie, ou tasse remplie de « café » (niveau qui baisse) pendant
  une minuterie. macOS gère la couleur clair/sombre et l'inversion au clic.
- `LogoRenderer.swift` — `enum` sans état : dessine le logo de la notification.
- `Strings.swift` — `enum L` : toutes les chaînes affichées, via `String(localized:)`.
- `Localizable.xcstrings` — catalogue de traductions (voir « Localisation » plus bas).
- (`ViewController.swift` + `Main.storyboard` : **supprimés**, n'existaient déjà plus.)
- Réglages du target (« Application is agent », pas de storyboard) dans le projet.

## Localisation (anglais + français, extensible)
- **Langue source = anglais** (`developmentRegion = en`) ; le **français est fourni**.
  macOS choisit **automatiquement** : français si le Mac est en français, anglais sinon.
- Le code n'écrit **jamais** de texte en dur : il passe par `enum L` (dans
  `Strings.swift`), qui appelle `String(localized: "…")`. La clé anglaise EST le texte
  source ; la traduction française vit dans `Localizable.xcstrings`.
- **Ajouter une langue** (ex. espagnol) : ouvrir `Localizable.xcstrings` dans Xcode,
  bouton « + » → choisir la langue, remplir les cases. Ajouter aussi la région dans
  `knownRegions` du `.pbxproj` (déjà fait pour `fr`). Aucun code à modifier.
- Réglages activés : `LOCALIZATION_PREFERS_STRING_CATALOGS`, `SWIFT_EMIT_LOC_STRINGS`,
  `STRING_CATALOG_GENERATE_SYMBOLS` = YES.

### ⚠️ Piège connu (déjà rencontré)
Le modèle « Storyboard » fait démarrer `AppDelegate` *via le storyboard*. Comme on a
retiré le storyboard (pour ne pas avoir de fenêtre), `AppDelegate` n'était plus lancé
→ l'app tournait mais `applicationDidFinishLaunching` ne s'exécutait jamais (aucune tasse).
**Solution :** point d'entrée explicite dans `main.swift` (et donc PAS de `@main` sur
`AppDelegate`). Ne pas dépendre du storyboard pour démarrer le délégué.

## Tests
- **Cible `CaffeineTests`** (Swift Testing, `import Testing` / `#expect`), hébergée par
  l'app (`TEST_HOST`), groupe synchronisé → déposer un `.swift` dans `Caffeine/CaffeineTests/`
  suffit. Les tests accèdent au code interne via `@testable import Caffeine` et sont
  `@MainActor` (le code de l'app est isolé sur le fil principal).
- **Philosophie** : on ne teste que la **logique pure**, volontairement isolée dans
  `CaffeineLogic.swift` (décision de coupure au verrouillage, durées, minutes→secondes).
  L'UI, l'anti-veille et les notifications (effets de bord) ne sont pas testés.
- Fichiers : `CaffeineTests.swift` (logique + titres de durée) et
  `LogoRendererTests.swift` (le logo est un vrai PNG 256×256).
- **Lancer** : dans Xcode **Cmd-U** (ou ▶ dans la marge d'un test). En ligne de commande :
  `xcodebuild test -project Caffeine/Caffeine.xcodeproj -scheme Caffeine -destination 'platform=macOS'`.

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
  durées 30 min/1 h/2 h, Lancer au démarrage, Rester actif écran verrouillé, Quitter) ;
- **coupure au verrouillage/extinction d'écran** : par défaut, Caffeine se désactive
  quand l'écran se verrouille (`com.apple.screenIsLocked`) ou s'éteint
  (`NSWorkspace.screensDidSleepNotification`) — l'usage voulu (veille auto courte
  empêchée seulement pendant le travail/les réunions). Option **« Rester actif écran
  verrouillé »** (case à cocher, mémorisée dans `UserDefaults` sous la clé
  `keepAliveWhenLocked`) pour l'inverse (garder actif en arrière-plan) ;
- anti-veille via `beginActivity(.idleDisplaySleepDisabled)` ;
- minuterie + extinction auto + notification de fin, avec le logo joint
  via `UNNotificationAttachment` (`LogoRenderer.makeFile()` rend la tasse à la volée) ;
- **indicateur de minuterie** : la tasse se **remplit de « café »** dont le niveau baisse
  avec le temps (l'icône reste la simple tasse, alignée comme les autres). L'icône est
  une image **« template »** (remplissage + contour assemblés en une silhouette) → macOS
  la recolore (clair/sombre) et l'inverse au clic, comme ses propres icônes ;
  temps exact dans l'infobulle au survol. `countdownTimer` répétitif (1×/s) +
  `autoOffEndDate`/`autoOffDuration` ; `tick()` redessine l'icône (`StatusIcon.image`
  avec `CaffeineLogic.remainingFraction`) et coupe quand le temps est écoulé ;
- icône d'app « tasse blanche sur carré brun » : PNG dans `AppIcon.appiconset`
  (générés depuis `cup.and.saucer.fill` ; script de génération non versionné) ;
- lancement au démarrage via `SMAppService.mainApp` ;
- app agent, démarrée par `main.swift`, signée ad-hoc, zéro warning ;
- **bilingue anglais/français** (auto selon la langue du Mac), extensible ;
- code **découpé** en fichiers courts (cœur + extensions `AppDelegate+*`).

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
