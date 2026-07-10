//
//  StatusIcon.swift
//  Caffeine
//
//  Dessine l'icône de la barre de menus.
//
//  L'icône est TOUJOURS la simple tasse, à la taille naturelle du symbole : elle
//  s'aligne comme les autres icônes de la barre, sans décalage. Et dans les deux
//  cas c'est une image « template » (monochrome) : c'est macOS qui la recolore selon
//  la barre de menus (clair/sombre) et qui l'inverse au clic — comme ses propres icônes.
//    • sans minuterie : la simple tasse ;
//    • avec minuterie : la même tasse remplie de « café » dont le niveau BAISSE avec
//      le temps. On assemble le remplissage (silhouette pleine découpée à la bonne
//      hauteur) + le contour de la tasse en une seule silhouette.
//

import Cocoa

enum StatusIcon {

    private static let cupPointSize: CGFloat = 15   // taille de la tasse (identique partout)

    // `progress` : fraction restante 0…1 (niveau de café), ou nil = pas de minuterie.
    static func image(active: Bool, progress: Double?) -> NSImage {
        let cfg = NSImage.SymbolConfiguration(pointSize: cupPointSize, weight: .regular)

        // Sans minuterie → simple tasse.
        guard let progress else {
            let name = active ? "cup.and.saucer.fill" : "cup.and.saucer"
            let img = NSImage(systemSymbolName: name, accessibilityDescription: nil)?
                .withSymbolConfiguration(cfg) ?? NSImage()
            img.isTemplate = true
            return img
        }

        // Avec minuterie → contour de tasse + « café » (remplissage) dont le niveau baisse.
        let outline = NSImage(systemSymbolName: "cup.and.saucer", accessibilityDescription: nil)?
            .withSymbolConfiguration(cfg)
        let fill = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: nil)?
            .withSymbolConfiguration(cfg)
        let size = outline?.size ?? NSSize(width: 18, height: 15)

        let img = NSImage(size: size, flipped: false) { rect in
            // Le café : silhouette pleine, limitée à la hauteur restante (par le bas).
            let level = rect.height * CGFloat(progress)
            NSGraphicsContext.saveGraphicsState()
            NSRect(x: rect.minX, y: rect.minY, width: rect.width, height: level).clip()
            fill?.draw(in: rect)
            NSGraphicsContext.restoreGraphicsState()

            // Le contour complet de la tasse par-dessus.
            outline?.draw(in: rect)
            return true
        }
        // Monochrome → seule la silhouette (l'alpha) compte : macOS gère la couleur
        // (blanc sur barre sombre, foncé sur barre claire) ET l'inversion au clic.
        img.isTemplate = true
        return img
    }
}
