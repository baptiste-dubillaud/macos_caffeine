//
//  CaffeineTests.swift
//  CaffeineTests
//
//  Tests de la logique « pure » de l'app (CaffeineLogic) et des titres de durée.
//
//  `@testable import Caffeine` donne au test l'accès aux types internes de l'app.
//  `@MainActor` : le code de l'app est isolé sur le fil principal, donc les tests
//  qui l'appellent le sont aussi.
//

import Testing
@testable import Caffeine

@MainActor
@Suite("Logique pure de Caffeine")
struct CaffeineLogicTests {

    // Décision « couper Caffeine au verrouillage / à l'extinction de l'écran ».
    // On couvre les 4 combinaisons possibles (table de vérité complète) :
    // seule la 1ʳᵉ doit couper (actif ET option décochée).
    @Test("On coupe au verrouillage seulement si actif ET option décochée")
    func lockDecision() {
        #expect(CaffeineLogic.shouldDeactivateOnScreenLock(isActive: true,  keepAliveWhenLocked: false) == true)
        #expect(CaffeineLogic.shouldDeactivateOnScreenLock(isActive: true,  keepAliveWhenLocked: true)  == false)
        #expect(CaffeineLogic.shouldDeactivateOnScreenLock(isActive: false, keepAliveWhenLocked: false) == false)
        #expect(CaffeineLogic.shouldDeactivateOnScreenLock(isActive: false, keepAliveWhenLocked: true)  == false)
    }

    // Conversion minutes → secondes attendue par Timer.
    @Test("Une durée en minutes vaut minutes × 60 secondes")
    func interval() {
        #expect(CaffeineLogic.timerInterval(minutes: 30)  == 1800)
        #expect(CaffeineLogic.timerInterval(minutes: 60)  == 3600)
        #expect(CaffeineLogic.timerInterval(minutes: 120) == 7200)
    }

    // La liste des durées proposées (source unique de vérité du menu).
    @Test("Les durées proposées sont 30, 60 et 120 minutes")
    func durations() {
        #expect(CaffeineLogic.durationMinutes == [30, 60, 120])
    }

    // Chaque durée doit donner un titre non vide et distinct des autres
    // (garde-fou : détecte un copier-coller qui renverrait le même titre partout).
    @Test("Chaque durée a un titre distinct et non vide")
    func durationTitles() {
        let titres = CaffeineLogic.durationMinutes.map { L.activateFor(minutes: $0) }
        #expect(titres.allSatisfy { !$0.isEmpty })   // aucun titre vide
        #expect(Set(titres).count == titres.count)    // tous différents
    }
}
