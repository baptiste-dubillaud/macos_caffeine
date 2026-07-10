# ☕ Caffeine for macOS

**Language:** [🇬🇧 English](#caffeine-for-macos) | [🇫🇷 Français](README.fr.md)

A minimal menu bar utility for macOS — a clone of Ubuntu's "Caffeine" extension.

## What is it?

A simple coffee cup in your menu bar (top right) that prevents your Mac from going to sleep on demand:

- **Empty cup** = app inactive, normal sleep behavior
- **Full cup** (on click) = sleep prevention active, your screen won't sleep

That's it. Intentionally minimal.

## Features

- ☕ **Menu bar icon** — empty/full cup depending on state
- **Left click** — quick toggle sleep on/off
- **Right click** — full menu:
  - Enable / Disable immediately
  - Timer: 30 min, 1 h, or 2 h of sleep prevention then auto-return
  - **Stay active when screen locked** (toggle)
  - Launch at startup
  - Quit
- **Timer indicator in the menu bar** — while a timer runs, the cup fills with "coffee" whose level drops as time passes (the icon stays just the cup, aligned like the others, no ticking digits). It's a *template* image, so macOS tints it for the menu bar (light/dark) and inverts it on click, just like its own icons; the exact time is shown in the tooltip on hover
- **Auto-off on lock** — by default Caffeine turns itself off when the screen locks or turns off, so your usual auto-sleep resumes. Flip the **Stay active when screen locked** toggle to keep working in the background instead (downloads, builds…). The choice is remembered.
- **Timer expiration notification** — sound + visual alert, with the Caffeine logo attached
- **Launch at startup** — optional automatic start with your Mac
- **Bilingual** — English and French, chosen automatically from your Mac's language (extensible to more)

## Installation

### Requirements

- **macOS** 13 (Ventura) or later (uses `SMAppService` for launch-at-login)
- **Xcode** 16 or later (Swift Testing + String Catalogs)

### Quick start (development)

Open the project in Xcode and press **Cmd-R** to build and run immediately.

### Build from source

```bash
cd Caffeine
xcodebuild -scheme Caffeine -configuration Release build
```

The app binary is generated at: `build/Release/Caffeine.app`

### Deploy to `/Applications`

```bash
cp -r Caffeine/build/Release/Caffeine.app /Applications/
# Refresh the system launcher database
lsregister -f /Applications/Caffeine.app
```

Then launch from Spotlight (Cmd-Space, type "Caffeine") or add to startup items via System Settings > General > Login Items.

### Update an existing installation

Recompile and replace the app in `/Applications`:

```bash
cd Caffeine
xcodebuild -project Caffeine.xcodeproj -scheme Caffeine -configuration Release build -derivedDataPath ../build
rm -rf /Applications/Caffeine.app
cp -r build/Build/Products/Release/Caffeine.app /Applications/
lsregister -f /Applications/Caffeine.app
```

### Version management

Version info is stored in Xcode:
- Open `Caffeine.xcodeproj` → Target **Caffeine** → Build Settings
- **Marketing Version**: user-facing version (e.g., `1.0`, `1.1`, `2.0`)
- **Current Project Version**: build number (increment each build)

The version is displayed in the app menu (right-click the coffee cup).

## Architecture

- **Language**: Swift (the app module is `MainActor`-isolated by default)
- **Framework**: AppKit (`NSStatusItem`)
- **Entry point**: `main.swift` — creates the app and launches the `AppDelegate`
- **Core + extensions**: `AppDelegate.swift` holds the state and lifecycle; the rest is split into focused extensions (`AppDelegate+Menu`, `AppDelegate+Timer`, `AppDelegate+SleepPrevention`)
- **Pure logic**: `CaffeineLogic.swift` — UI-free, unit-tested decisions (lock behavior, durations, countdown text)
- **Sleep prevention**: `ProcessInfo.beginActivity()` with `.idleDisplaySleepDisabled`
- **Localization**: `Localizable.xcstrings` String Catalog (English source + French); all UI text goes through `Strings.swift` (`enum L`)
- **Launch at login**: `SMAppService.mainApp`

### Project structure

```
Caffeine/
├── Caffeine.xcodeproj/                    # Xcode project (file-system synchronized groups)
├── Caffeine/
│   ├── main.swift                         # Entry point
│   ├── AppDelegate.swift                  # Core: state, lifecycle, toggle, icon
│   ├── AppDelegate+Menu.swift             # Right-click menu + actions
│   ├── AppDelegate+Timer.swift            # Countdown timer + notification
│   ├── AppDelegate+SleepPrevention.swift  # Anti-sleep + lock/screen-off handling
│   ├── CaffeineLogic.swift                # Pure, testable logic
│   ├── StatusIcon.swift                   # Menu bar icon (cup with draining coffee level)
│   ├── LogoRenderer.swift                 # Notification logo drawing
│   ├── Strings.swift                      # UI strings (enum L)
│   ├── Localizable.xcstrings              # Translations (English + French)
│   └── Assets.xcassets/                   # App icon
├── CaffeineTests/                         # Unit tests (Swift Testing)
└── README.md
```

## Tests

Unit tests live in `CaffeineTests/` and use **Swift Testing** (`import Testing`, `#expect`). They deliberately target the *pure* logic isolated in `CaffeineLogic` — lock decision, durations, minutes→seconds, countdown format — plus a check that the notification logo is a real 256×256 PNG. UI, sleep prevention and notifications (side effects) are not unit-tested.

Run them in Xcode with **Cmd-U**, or from the command line:

```bash
xcodebuild test -project Caffeine/Caffeine.xcodeproj -scheme Caffeine -destination 'platform=macOS'
```

## Development

### Completed phases

- ✅ Menu bar icon display
- ✅ Empty ↔ full toggle on click
- ✅ Sleep prevention activation/deactivation
- ✅ Enriched menu with timer
- ✅ Expiration notifications
- ✅ Launch at startup
- ✅ App icon
- ✅ Timer indicator in the menu bar (draining coffee level)
- ✅ Auto-off on screen lock (+ "stay active" toggle)
- ✅ English/French localization
- ✅ Code split into files + unit tests

### Running in development

Open the project in Xcode:
```bash
open Caffeine/Caffeine.xcodeproj
```

Then click the ▶ button (Run) or press **Cmd-R**.

## Technical notes

- **Agent app**: Caffeine appears only in the menu bar, not in the Dock
- **System icons**: uses `cup.and.saucer` (empty) and `cup.and.saucer.fill` (full) from SF Symbols
- **Localization**: uses a String Catalog — add a language in Xcode with zero code changes
- **Sandbox**: the app is sandboxed to comply with macOS standards
- **Signing**: ad-hoc signing (no Apple Developer account required for personal use)

## Roadmap

Already complete for daily use. Possible future improvements:

- Sync with system preferences (Do Not Disturb)
- Customizable timer durations
- Usage history
- More languages

## License

Personal use. No Apple notarization required.

---

**Questions?** Make sure Xcode is installed and the project builds in Debug mode.
