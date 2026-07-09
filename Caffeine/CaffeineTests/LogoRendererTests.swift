//
//  LogoRendererTests.swift
//  CaffeineTests
//
//  Vérifie que le logo de la notification est bien un vrai PNG de 256×256.
//

import Testing
import AppKit
@testable import Caffeine

@MainActor
@Suite("Rendu du logo")
struct LogoRendererTests {

    @Test("makeFile() produit un vrai PNG de 256×256, lisible sur le disque")
    func producesValidPNG() throws {
        // On fabrique le logo. `#require` fait échouer proprement le test si c'est nil.
        let url = try #require(LogoRenderer.makeFile())

        // 1) Le fichier existe bien sur le disque.
        #expect(FileManager.default.fileExists(atPath: url.path))

        // 2) Son contenu commence par la « signature » d'un fichier PNG.
        let data = try Data(contentsOf: url)
        #expect(data.starts(with: [0x89, 0x50, 0x4E, 0x47]))   // ‰PNG

        // 3) C'est une image réellement décodable, aux bonnes dimensions en pixels.
        let image = try #require(NSImage(contentsOf: url))
        let rep = try #require(image.representations.first as? NSBitmapImageRep)
        #expect(rep.pixelsWide == 256)
        #expect(rep.pixelsHigh == 256)
    }
}
