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
  - Timer expiration notification
  - Launch at startup
  - Quit
- **Launch at startup** — option for Caffeine to start automatically with your Mac
- **Notifications** — sound + visual alert when timer expires

## Installation

### Requirements

- **macOS** 10.15 or later
- Xcode (to build the project)

### Build and run

```bash
# Build in Debug mode (development)
cd Caffeine
xcodebuild -scheme Caffeine build

# For daily use: copy to /Applications
cp -r build/Debug/Caffeine.app /Applications/
```

Or simply: open `Caffeine.xcodeproj` in Xcode and press **Cmd-R**.

## Architecture

- **Language**: Swift 6
- **Framework**: AppKit (`NSStatusItem`)
- **Entry point**: `main.swift` — creates the app and launches the `AppDelegate`
- **Logic**: `AppDelegate.swift` — manages the cup, menu, and sleep prevention
- **Sleep prevention**: `ProcessInfo.beginActivity()` with `.idleDisplaySleepDisabled`

### Project structure

```
Caffeine/
├── Caffeine.xcodeproj/    # Xcode project
├── Caffeine/
│   ├── main.swift         # Entry point
│   ├── AppDelegate.swift  # Main logic
│   └── Assets/
└── README.md
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

### Running in development

Open the project in Xcode:
```bash
open Caffeine/Caffeine.xcodeproj
```

Then click the ▶ button (Run) or press **Cmd-R**.

## Technical notes

- **Agent app**: Caffeine appears only in the menu bar, not in the Dock
- **System icons**: uses `cup.and.saucer` (empty) and `cup.and.saucer.fill` (full) from SF Symbols
- **Sandbox**: the app is sandboxed to comply with macOS standards
- **Signing**: ad-hoc signing (no Apple Developer account required for personal use)

## Roadmap

Already complete for daily use. Possible future improvements:

- Sync with system preferences (Do Not Disturb)
- Customizable timer durations
- Usage history
- Adaptive dark mode

## License

Personal use. No Apple notarization required.

---

**Questions?** Make sure Xcode is installed and the project builds in Debug mode.
