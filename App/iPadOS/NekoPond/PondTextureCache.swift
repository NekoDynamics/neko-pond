import Foundation
import SpriteKit

final class PondTextureCache {
    private var texturesByPath: [String: SKTexture] = [:]
    private let bundle: Bundle
    private let fileManager: FileManager

    init(bundle: Bundle = .main, fileManager: FileManager = .default) {
        self.bundle = bundle
        self.fileManager = fileManager
    }

    func texture(for assetPath: String) -> SKTexture? {
        if let texture = texturesByPath[assetPath] {
            return texture
        }

        guard let url = url(for: assetPath) else {
            debugLogMissing(assetPath)
            return nil
        }

        let texture = SKTexture(imageNamed: url.path)
        texturesByPath[assetPath] = texture
        return texture
    }

    func validateAssets(_ paths: [String]) -> [String] {
        paths.filter { url(for: $0) == nil }
    }

    func preload(_ paths: [String]) {
        let textures = paths.compactMap { texture(for: $0) }
        guard !textures.isEmpty else { return }

        SKTexture.preload(textures) {}
    }

    private func url(for assetPath: String) -> URL? {
        guard !assetPath.isEmpty, !assetPath.contains("..") else {
            return nil
        }

        let url = bundle.bundleURL.appendingPathComponent(assetPath, isDirectory: false)
        return fileManager.fileExists(atPath: url.path) ? url : nil
    }

    private func debugLogMissing(_ assetPath: String) {
        #if DEBUG
        print("PondTextureCache missing asset: \(assetPath)")
        #endif
    }
}
