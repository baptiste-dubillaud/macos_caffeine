//
//  Strings.swift
//  Caffeine
//
//  Toutes les chaînes affichées à l'utilisateur, regroupées au même endroit.
//
//  `String(localized:)` va chercher la traduction dans le catalogue
//  `Localizable.xcstrings` selon la langue du système : français si le Mac est
//  configuré en français, anglais sinon (l'anglais est la langue « source »).
//  Pour ajouter une langue plus tard : ouvrir Localizable.xcstrings dans Xcode
//  et ajouter la langue — aucune ligne de code à changer ici.
//

import Foundation

enum L {
    // Description d'accessibilité de l'icône (lue par VoiceOver).
    static var caffeineActive: String { String(localized: "Caffeine active") }
    static var caffeineInactive: String { String(localized: "Caffeine inactive") }

    // Entrées du menu (clic droit).
    static var activate: String { String(localized: "Activate") }
    static var deactivate: String { String(localized: "Deactivate") }
    static var activate30min: String { String(localized: "Activate for 30 min") }
    static var activate1hour: String { String(localized: "Activate for 1 hour") }
    static var activate2hours: String { String(localized: "Activate for 2 hours") }

    // Titre « Activer N » choisi selon la durée en minutes (réutilise les clés ci-dessus).
    static func activateFor(minutes: Int) -> String {
        switch minutes {
        case 30:  return activate30min
        case 60:  return activate1hour
        case 120: return activate2hours
        default:  return "\(minutes) min"   // filet de sécurité (durées non prévues)
        }
    }
    static var launchAtLogin: String { String(localized: "Launch at login") }
    static var stayActiveWhenLocked: String { String(localized: "Stay active when screen locked") }
    static var quit: String { String(localized: "Quit Caffeine") }

    // Corps de la notification de fin de minuterie.
    static var timerEndedBody: String { String(localized: "Timer finished — sleep is allowed again.") }

    // Ligne d'info « Caffeine v1.0 » (la marque et le numéro ne se traduisent pas).
    static func version(_ v: String) -> String { "Caffeine v\(v)" }
}
