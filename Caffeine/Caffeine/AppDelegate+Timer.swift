//
//  AppDelegate+Timer.swift
//  Caffeine
//
//  Minuterie d'extinction automatique et notification de fin.
//

import Cocoa
import UserNotifications

extension AppDelegate {

    // Active l'app pour une durée (lue dans le « tag » du menu), puis extinction auto.
    @objc func activateForDuration(_ sender: NSMenuItem) {
        let minutes = sender.tag
        setActive(true)

        // Durée totale + date de fin (= maintenant + durée).
        let duree = CaffeineLogic.timerInterval(minutes: minutes)
        autoOffDuration = duree
        autoOffEndDate = Date().addingTimeInterval(duree)

        // Minuterie répétitive : chaque seconde, tick() rafraîchit le décompte et
        // coupe l'app quand le temps est écoulé.
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(timeInterval: 1,
                                              target: self,
                                              selector: #selector(tick),
                                              userInfo: nil,
                                              repeats: true)
        updateIcon()   // affiche « 30:00 » tout de suite, sans attendre la 1ʳᵉ seconde
    }

    // Appelée chaque seconde par countdownTimer.
    @objc func tick() {
        guard let end = autoOffEndDate else { return }
        if end.timeIntervalSinceNow <= 0 {
            autoOff()          // temps écoulé → on coupe
        } else {
            updateIcon()       // sinon, on rafraîchit le décompte affiché
        }
    }

    // Fin de la minuterie : on coupe et on prévient l'utilisateur.
    @objc func autoOff() {
        setActive(false)       // coupe l'anti-veille, arrête la minuterie, efface le décompte
        notifyTimerEnded()
    }

    // Affiche une notification système « minuterie terminée ».
    func notifyTimerEnded() {
        let content = UNMutableNotificationContent()
        content.title = "Caffeine"
        content.body = L.timerEndedBody

        // Pas d'image jointe : macOS affiche déjà l'icône de l'app à gauche de la
        // notification, un logo en pièce jointe serait redondant.

        // trigger: nil = la notification est affichée tout de suite.
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
