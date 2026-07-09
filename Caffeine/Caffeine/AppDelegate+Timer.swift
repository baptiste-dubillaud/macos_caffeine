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

        // (Re)lance la minuterie : à la fin, autoOff() coupera tout.
        autoOffTimer?.invalidate()
        autoOffTimer = Timer.scheduledTimer(timeInterval: CaffeineLogic.timerInterval(minutes: minutes),
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
        content.body = L.timerEndedBody

        // On JOINT notre logo à la notification : contrairement à l'icône de gauche
        // (= icône de l'app, gérée par macOS), cette image fait partie du contenu et
        // s'affiche donc toujours, sans dépendre du cache d'icônes du système.
        if let url = LogoRenderer.makeFile(),
           let logo = try? UNNotificationAttachment(identifier: "logo", url: url) {
            content.attachments = [logo]
        }

        // trigger: nil = la notification est affichée tout de suite.
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
