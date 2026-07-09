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

    // Faut-il désactiver Caffeine quand l'écran se verrouille / s'éteint ?
    // Oui uniquement s'il est actif ET que l'utilisateur n'a PAS coché
    // « Rester actif écran verrouillé ».
    static func shouldDeactivateOnScreenLock(isActive: Bool, keepAliveWhenLocked: Bool) -> Bool {
        isActive && !keepAliveWhenLocked
    }
}
