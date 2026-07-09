//
//  AppDelegate+Menu.swift
//  Caffeine
//
//  Construction du menu (clic droit) et actions déclenchées par ses entrées.
//

import Cocoa
import ServiceManagement

extension AppDelegate {

    // Ouvre le menu (clic droit) : Activer/Désactiver, durées, réglages, Quitter.
    func showMenu() {
        let menu = NSMenu()

        // Activer / Désactiver (illimité) — même effet qu'un clic gauche.
        let bascule = NSMenuItem(title: isActive ? L.deactivate : L.activate,
                                 action: #selector(toggleFromMenu),
                                 keyEquivalent: "")
        bascule.target = self
        menu.addItem(bascule)

        menu.addItem(NSMenuItem.separator())

        // Activer pour une durée, puis extinction automatique.
        // La liste des durées vient de CaffeineLogic (source unique de vérité, testée).
        for minutes in CaffeineLogic.durationMinutes {
            let item = NSMenuItem(title: L.activateFor(minutes: minutes),
                                  action: #selector(activateForDuration(_:)),
                                  keyEquivalent: "")
            item.target = self
            item.tag = minutes   // on range la durée (en minutes) dans le « tag »
            menu.addItem(item)
        }

        menu.addItem(NSMenuItem.separator())

        // Lancer au démarrage (coché si déjà activé).
        let login = NSMenuItem(title: L.launchAtLogin,
                               action: #selector(toggleLaunchAtLogin),
                               keyEquivalent: "")
        login.target = self
        login.state = (SMAppService.mainApp.status == .enabled) ? .on : .off
        menu.addItem(login)

        // Rester actif même quand l'écran se verrouille / s'éteint (coché = oui).
        let keepAlive = NSMenuItem(title: L.stayActiveWhenLocked,
                                   action: #selector(toggleKeepAliveWhenLocked),
                                   keyEquivalent: "")
        keepAlive.target = self
        keepAlive.state = keepAliveWhenLocked ? .on : .off
        menu.addItem(keepAlive)

        menu.addItem(NSMenuItem.separator())

        // Version (info, non cliquable).
        let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let versionItem = NSMenuItem(title: L.version(versionString),
                                     action: nil,
                                     keyEquivalent: "")
        versionItem.isEnabled = false
        menu.addItem(versionItem)

        menu.addItem(NSMenuItem.separator())

        // Quitter.
        menu.addItem(withTitle: L.quit,
                     action: #selector(NSApplication.terminate(_:)),
                     keyEquivalent: "q")

        // On affiche le menu, puis on le détache (pour ne pas transformer le clic
        // gauche en ouverture de menu).
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    // Appelée par l'entrée « Activer / Désactiver » du menu.
    @objc func toggleFromMenu() {
        toggle()
    }

    // Active/désactive le lancement automatique à l'ouverture de session.
    @objc func toggleLaunchAtLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            NSLog("Caffeine: launch at login failed: \(error)")
        }
    }

    // Bascule l'option « rester actif écran verrouillé » (mémorisée dans UserDefaults).
    @objc func toggleKeepAliveWhenLocked() {
        keepAliveWhenLocked.toggle()
    }
}
