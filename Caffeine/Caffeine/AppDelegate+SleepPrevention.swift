//
//  AppDelegate+SleepPrevention.swift
//  Caffeine
//
//  Tout ce qui touche à l'anti-veille et à la réaction au verrouillage / à
//  l'extinction de l'écran.
//

import Cocoa

extension AppDelegate {

    // Configure l'écoute du verrouillage d'écran et de l'extinction d'écran.
    func setupSystemEventListeners() {
        // Quand l'écran se verrouille.
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleScreenLocked),
            name: NSNotification.Name("com.apple.screenIsLocked"),
            object: nil
        )

        // Quand l'écran s'éteint (mise en veille de l'affichage).
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleScreenLocked),
            name: NSWorkspace.screensDidSleepNotification,
            object: nil
        )
    }

    @objc func handleScreenLocked() {
        // Écran verrouillé ou éteint → on coupe l'anti-veille (la veille auto reprend),
        // SAUF si l'utilisateur a coché « Rester actif écran verrouillé ».
        if CaffeineLogic.shouldDeactivateOnScreenLock(isActive: isActive,
                                                      keepAliveWhenLocked: keepAliveWhenLocked) {
            setActive(false)
        }
    }

    // Démarre ou arrête l'anti-veille selon l'état.
    func updateSleepPrevention() {
        if isActive {
            // On demande au système de ne PAS s'endormir (et de garder l'écran
            // allumé) tant qu'on est actif. On garde le jeton renvoyé.
            if sleepAssertion == nil {
                sleepAssertion = ProcessInfo.processInfo.beginActivity(
                    options: [.idleDisplaySleepDisabled],
                    reason: "Caffeine is active")
            }
        } else {
            // On relâche le jeton → la veille automatique normale reprend.
            if let token = sleepAssertion {
                ProcessInfo.processInfo.endActivity(token)
                sleepAssertion = nil
            }
        }
    }
}
