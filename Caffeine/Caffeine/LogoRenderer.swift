//
//  LogoRenderer.swift
//  Caffeine
//
//  Fabrique le logo (tasse blanche sur carré arrondi brun) dans un fichier
//  temporaire — pour le joindre aux notifications.
//
//  Note : on le régénère à chaque fois, car UNNotificationAttachment « déplace »
//  le fichier joint (le mettre en cache casserait la 2ᵉ notification).
//

import Cocoa

enum LogoRenderer {

    // Dessine le logo et l'écrit en PNG dans un fichier temporaire ; renvoie son URL.
    static func makeFile() -> URL? {
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
}
