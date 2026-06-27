//
//  AppDelegate.swift
//  Caffeine
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    // La « tasse » dans la barre de menus.
    var statusItem: NSStatusItem!

    // L'état de l'app : true = active (tasse pleine), false = inactive (tasse vide).
    var isActive = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // On réserve une place dans la barre de menus.
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // On gère nous-mêmes le clic, pour distinguer gauche et droit.
        if let button = statusItem.button {
            button.target = self                            // « c'est moi qui réagis »
            button.action = #selector(handleClick(_:))      // « appelle cette méthode au clic »
            button.sendAction(on: [.leftMouseUp, .rightMouseUp]) // gauche ET droit
        }

        updateIcon()   // affiche la bonne tasse au démarrage (vide)
    }

    // Appelée à chaque clic sur la tasse.
    @objc func handleClick(_ sender: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            showMenu()      // clic droit → menu (Quitter)
        } else {
            toggle()        // clic gauche → bascule vide ↔ pleine
        }
    }

    // Inverse l'état, puis met l'icône à jour.
    func toggle() {
        isActive.toggle()   // true devient false, et inversement
        updateIcon()
    }

    // Affiche la tasse pleine ou vide selon l'état.
    func updateIcon() {
        let symbole = isActive ? "cup.and.saucer.fill" : "cup.and.saucer"
        let description = isActive ? "Caffeine actif" : "Caffeine inactif"
        statusItem.button?.image = NSImage(systemSymbolName: symbole,
                                           accessibilityDescription: description)
    }

    // Ouvre un petit menu avec « Quitter ».
    func showMenu() {
        let menu = NSMenu()
        menu.addItem(withTitle: "Quitter Caffeine",
                     action: #selector(NSApplication.terminate(_:)),
                     keyEquivalent: "q")

        statusItem.menu = menu                  // 1) on attache le menu...
        statusItem.button?.performClick(nil)    // 2) ...on le fait apparaître...
        statusItem.menu = nil                   // 3) ...puis on le détache (sinon
                                                //    le clic gauche ouvrirait le menu
                                                //    au lieu de basculer la tasse).
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}