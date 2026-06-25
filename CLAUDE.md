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
  un **clic = bascule directe** (fidèle au Caffeine d'Ubuntu). Dans un projet Xcode
  SwiftUI, on branchera un `AppDelegate` via `@NSApplicationDelegateAdaptor`
  (ou app AppKit pure) — à finaliser au moment de créer le projet.
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

## Structure du projet (à venir, créée par l'assistant Xcode)
- `Caffeine.xcodeproj` — le projet Xcode.
- `Caffeine/` — les sources Swift (ex. `AppDelegate.swift`).
- Réglages du target (dont « Application is agent ») dans l'onglet du projet, pas
  dans un Info.plist écrit à la main.

## Build & lancement
- Dans Xcode : bouton ▶ (Run) ou **Cmd-R** pour compiler + lancer.
- Stopper : bouton ⏹ dans Xcode, ou menu de la tasse → « Quitter ».
- (Optionnel, plus tard) build en ligne de commande : `xcodebuild -scheme Caffeine`.

## Plan de développement (cocher au fur et à mesure)
- [ ] **Phase 0** — Créer le projet Xcode (assistant) + réglage « app agent ».
- [ ] **Phase 1** — Afficher l'icône « tasse vide » dans la barre de menus + menu « Quitter ».
- [ ] **Phase 2** — Clic gauche = bascule vide ↔ pleine (sans logique de veille encore).
- [ ] **Phase 3** — Brancher l'anti-veille (`beginActivity`/`endActivity`) sur la bascule.
- [ ] **Phase 4** (optionnel) — Lancer au démarrage (`SMAppService`), minuterie, infobulle.

## Statut actuel
**En attente de la fin de l'installation d'Xcode.** Aucun code écrit pour l'instant.
Dès qu'Xcode est prêt (`xcodebuild -version` fonctionne), prochaine étape : **Phase 0**
— créer le projet Xcode ensemble, en détaillant chaque écran de l'assistant.

## Publication (perso)
Usage perso uniquement : **pas de notarisation, pas de compte Apple payant**.
Lancer depuis Xcode suffit ; pour un usage quotidien, on pourra « Archiver » l'app et
copier le `.app` dans /Applications + l'ajouter aux ouvertures au démarrage. Le Apple
Developer Program ne servirait que pour **partager** l'app à d'autres — non requis ici.
