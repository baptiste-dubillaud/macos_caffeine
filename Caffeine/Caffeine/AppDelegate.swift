//
//  AppDelegate.swift
//  Caffeine
//
//  Cœur de l'app : l'état, le cycle de vie et la bascule active/inactive.
//  Le reste est réparti dans des extensions (AppDelegate+*.swift) pour garder
//  chaque fichier court et lisible :
//    • AppDelegate+SleepPrevention — anti-veille + verrouillage/extinction d'écran
//    • AppDelegate+Menu            — le menu (clic droit) et ses actions
//    • AppDelegate+Timer           — minuterie d'extinction auto + notification
//

import Cocoa
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {

    // La « tasse » dans la barre de menus.
    var statusItem: NSStatusItem!

    // L'état de l'app : true = active (tasse pleine), false = inactive (tasse vide).
    var isActive = false

    // Le « jeton » d'anti-veille. Tant qu'on le garde, le Mac ne s'endort pas.
    // nil = pas d'anti-veille en cours (comportement normal).
    var sleepAssertion: NSObjectProtocol?

    // La minuterie d'extinction automatique (mode « activer pour 30 min », etc.).
    // nil = pas de minuterie en cours (activation illimitée).
    var autoOffTimer: Timer?

    // Préférence utilisateur : garder Caffeine actif même quand l'écran se verrouille
    // ou s'éteint. false par défaut → Caffeine se coupe (la veille auto reprend).
    // La valeur est mémorisée entre deux lancements via UserDefaults.
    var keepAliveWhenLocked: Bool {
        get { UserDefaults.standard.bool(forKey: "keepAliveWhenLocked") }
        set { UserDefaults.standard.set(newValue, forKey: "keepAliveWhenLocked") }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.target = self
            button.action = #selector(handleClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        updateIcon()

        // Écouter le verrouillage / l'extinction d'écran (voir AppDelegate+SleepPrevention).
        setupSystemEventListeners()

        // On demande (une seule fois) l'autorisation d'envoyer des notifications.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    deinit {
        // Nettoyer TOUS les observers à la fermeture de l'app (les deux centres où
        // on s'est abonné : le verrouillage d'écran et l'extinction d'écran).
        DistributedNotificationCenter.default().removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    // Aiguillage du clic sur la tasse : droit → menu, gauche → bascule.
    @objc func handleClick(_ sender: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            showMenu()      // clic droit → menu (voir AppDelegate+Menu)
        } else {
            toggle()        // clic gauche → bascule vide ↔ pleine
        }
    }

    // Inverse l'état actif/inactif (clic gauche, ou « Activer/Désactiver »).
    func toggle() {
        setActive(!isActive)
    }

    // Cœur de l'app : fixe l'état, met à jour l'icône et l'anti-veille.
    // En repassant à inactif, on annule aussi une éventuelle minuterie en cours.
    func setActive(_ active: Bool) {
        isActive = active
        updateIcon()
        updateSleepPrevention()
        if !active {
            autoOffTimer?.invalidate()
            autoOffTimer = nil
        }
    }

    // Affiche la tasse pleine ou vide selon l'état.
    func updateIcon() {
        let symbole = isActive ? "cup.and.saucer.fill" : "cup.and.saucer"
        let description = isActive ? L.caffeineActive : L.caffeineInactive
        statusItem.button?.image = NSImage(systemSymbolName: symbole,
                                           accessibilityDescription: description)
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
