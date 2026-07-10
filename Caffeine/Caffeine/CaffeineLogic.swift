//
//  CaffeineLogic.swift
//  Caffeine
//
//  La logique « pure » de l'app, isolée de l'interface et du système.
//  Ces fonctions prennent des valeurs et renvoient des valeurs — elles ne
//  touchent NI à la barre de menus, NI à l'anti-veille, NI aux notifications.
//  C'est précisément ce qui les rend faciles à tester (voir CaffeineTests).
//

import Foundation

enum CaffeineLogic {

    // Les durées proposées dans le menu (en minutes) — source unique de vérité :
    // le menu ET les tests s'appuient sur cette même liste.
    static let durationMinutes = [30, 60, 120]

    // Convertit une durée en minutes vers l'intervalle en secondes attendu par Timer.
    static func timerInterval(minutes: Int) -> TimeInterval {
        TimeInterval(minutes) * 60
    }

    // Texte du compte à rebours (utilisé dans l'infobulle au survol), au format
    // « m:ss ». On arrondit à la seconde SUPÉRIEURE pour afficher « 30:00 » au
    // démarrage (et non « 29:59 »), et on ne descend jamais sous « 0:00 ».
    static func countdownLabel(remaining: TimeInterval) -> String {
        let total = max(0, Int(remaining.rounded(.up)))
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    // Fraction de temps restant, entre 0 et 1, pour le niveau de café dans la tasse :
    // 1 au démarrage (tasse pleine), 0 à la fin (tasse vide). Toujours borné à [0, 1].
    static func remainingFraction(remaining: TimeInterval, total: TimeInterval) -> Double {
        guard total > 0 else { return 0 }
        return min(1, max(0, remaining / total))
    }

    // Faut-il désactiver Caffeine quand l'écran se verrouille / s'éteint ?
    // Oui uniquement s'il est actif ET que l'utilisateur n'a PAS coché
    // « Rester actif écran verrouillé ».
    static func shouldDeactivateOnScreenLock(isActive: Bool, keepAliveWhenLocked: Bool) -> Bool {
        isActive && !keepAliveWhenLocked
    }
}
