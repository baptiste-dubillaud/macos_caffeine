//
//  main.swift
//  Caffeine
//
//  Point d'entrée du programme. On construit l'app « à la main », sans
//  storyboard : c'est ce qui convient à un utilitaire de barre de menus.
//

import Cocoa

// Le démarrage a lieu sur le « fil principal » (le main actor). On le confirme
// à Swift avec MainActor.assumeIsolated { ... } — sans ça, il met un avertissement
// de prudence (concurrence) sur la ligne « app.delegate = delegate ».
MainActor.assumeIsolated {
    // 1) L'unique objet application.
    let app = NSApplication.shared

    // 2) Notre « chef d'orchestre » : on le crée et on le branche comme délégué.
    //    C'est lui qui, au démarrage, créera la tasse (voir AppDelegate.swift).
    let delegate = AppDelegate()
    app.delegate = delegate

    // 3) App « agent » : vit dans la barre de menus, pas dans le Dock.
    app.setActivationPolicy(.accessory)

    // 4) On démarre la boucle d'événements (l'app tourne jusqu'à ce qu'on quitte).
    app.run()
}
