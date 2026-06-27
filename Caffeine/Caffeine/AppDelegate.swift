//
//  AppDelegate.swift
//  Caffeine
//

import Cocoa
import UserNotifications
import ServiceManagement

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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.target = self
            button.action = #selector(handleClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        updateIcon()

        // On demande (une seule fois) l'autorisation d'envoyer des notifications.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    @objc func handleClick(_ sender: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            showMenu()      // clic droit → menu (Quitter)
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
        let description = isActive ? "Caffeine actif" : "Caffeine inactif"
        statusItem.button?.image = NSImage(systemSymbolName: symbole,
                                           accessibilityDescription: description)
    }

    // Démarre ou arrête l'anti-veille selon l'état.
    func updateSleepPrevention() {
        if isActive {
            // On demande au système de ne PAS s'endormir (et de garder l'écran
            // allumé) tant qu'on est actif. On garde le jeton renvoyé.
            if sleepAssertion == nil {
                sleepAssertion = ProcessInfo.processInfo.beginActivity(
                    options: [.idleDisplaySleepDisabled],
                    reason: "Caffeine est actif")
            }
        } else {
            // On relâche le jeton → la veille automatique normale reprend.
            if let token = sleepAssertion {
                ProcessInfo.processInfo.endActivity(token)
                sleepAssertion = nil
            }
        }
    }

    // Ouvre le menu (clic droit) : Activer/Désactiver, durées, puis Quitter.
    func showMenu() {
        let menu = NSMenu()

        // Activer / Désactiver (illimité) — même effet qu'un clic gauche.
        let bascule = NSMenuItem(title: isActive ? "Désactiver" : "Activer",
                                 action: #selector(toggleFromMenu),
                                 keyEquivalent: "")
        bascule.target = self
        menu.addItem(bascule)

        menu.addItem(NSMenuItem.separator())

        // Activer pour une durée, puis extinction automatique.
        let durees: [(titre: String, minutes: Int)] = [
            ("Activer 30 min", 30),
            ("Activer 1 h", 60),
            ("Activer 2 h", 120),
        ]
        for duree in durees {
            let item = NSMenuItem(title: duree.titre,
                                  action: #selector(activateForDuration(_:)),
                                  keyEquivalent: "")
            item.target = self
            item.tag = duree.minutes   // on range la durée (en minutes) dans le « tag »
            menu.addItem(item)
        }

        menu.addItem(NSMenuItem.separator())

        // Lancer au démarrage (coché si déjà activé).
        let login = NSMenuItem(title: "Lancer au démarrage",
                               action: #selector(toggleLaunchAtLogin),
                               keyEquivalent: "")
        login.target = self
        login.state = (SMAppService.mainApp.status == .enabled) ? .on : .off
        menu.addItem(login)

        menu.addItem(NSMenuItem.separator())

        // Quitter.
        menu.addItem(withTitle: "Quitter Caffeine",
                     action: #selector(NSApplication.terminate(_:)),
                     keyEquivalent: "q")

        // On affiche le menu, puis on le détache (comme avant).
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
            NSLog("Caffeine : échec lancement au démarrage : \(error)")
        }
    }

    // Active l'app pour une durée (lue dans le « tag » du menu), puis extinction auto.
    @objc func activateForDuration(_ sender: NSMenuItem) {
        let minutes = sender.tag
        setActive(true)

        // (Re)lance la minuterie : à la fin, autoOff() coupera tout.
        autoOffTimer?.invalidate()
        autoOffTimer = Timer.scheduledTimer(timeInterval: Double(minutes) * 60,
                                            target: self,
                                            selector: #selector(autoOff),
                                            userInfo: nil,
                                            repeats: false)
    }

    // Appelée par la minuterie quand le temps est écoulé.
    @objc func autoOff() {
        setActive(false)
        notifyTimerEnded()
    }

    // Affiche une notification système « minuterie terminée ».
    func notifyTimerEnded() {
        let content = UNMutableNotificationContent()
        content.title = "Caffeine"
        content.body = "Minuterie terminée — la mise en veille est de nouveau autorisée."

        // On JOINT notre logo à la notification : contrairement à l'icône de gauche
        // (= icône de l'app, gérée par macOS), cette image fait partie du contenu et
        // s'affiche donc toujours, sans dépendre du cache d'icônes du système.
        if let url = makeLogoFile(),
           let logo = try? UNNotificationAttachment(identifier: "logo", url: url) {
            content.attachments = [logo]
        }

        // trigger: nil = la notification est affichée tout de suite.
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    // Fabrique le logo (tasse blanche sur carré arrondi brun) dans un fichier
    // temporaire et renvoie son URL — pour le joindre à la notification.
    func makeLogoFile() -> URL? {
        let px = 256
        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { return nil }
        rep.size = NSSize(width: px, height: px)

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        let s = CGFloat(px)
        let margin = s * 0.07
        let rect = NSRect(x: margin, y: margin, width: s - 2 * margin, height: s - 2 * margin)
        NSColor(calibratedRed: 0.40, green: 0.26, blue: 0.17, alpha: 1).setFill()
        NSBezierPath(roundedRect: rect, xRadius: s * 0.2235, yRadius: s * 0.2235).fill()
        let config = NSImage.SymbolConfiguration(pointSize: s * 0.46, weight: .regular)
            .applying(NSImage.SymbolConfiguration(paletteColors: [.white]))
        if let sym = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: nil)?
            .withSymbolConfiguration(config) {
            let z = sym.size
            sym.draw(in: NSRect(x: (s - z.width) / 2, y: (s - z.height) / 2, width: z.width, height: z.height))
        }
        NSGraphicsContext.restoreGraphicsState()

        guard let png = rep.representation(using: .png, properties: [:]) else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("caffeine-logo.png")
        do { try png.write(to: url); return url } catch { return nil }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
