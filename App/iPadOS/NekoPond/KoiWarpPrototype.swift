import SpriteKit
import simd

final class KoiWarpPrototype: SKNode {
    private enum Constants {
        static let columns = 10
        static let rows = 4
        static let visualSize = CGSize(width: 360, height: 90)
        static let baseSpeed: CGFloat = 58.0
        static let margin: CGFloat = 210.0
    }

    private let sprite: SKSpriteNode
    private let baseGrid: SKWarpGeometryGrid
    private var time: CGFloat = 0.0
    private var swimSpeed: CGFloat = Constants.baseSpeed
    private var heading: CGFloat = 0.0
    private var destinationPositions: [vector_float2]

    init(textureCache: PondTextureCache, sceneSize: CGSize) {
        let assetPath = PondAssetRegistry.path(for: PondAssetRegistry.KoiWarp.kohakuBase)
        let texture = textureCache.texture(for: assetPath) ?? SKTexture()
        texture.filteringMode = .linear

        sprite = SKSpriteNode(texture: texture, color: .clear, size: Constants.visualSize)
        baseGrid = SKWarpGeometryGrid(columns: Constants.columns, rows: Constants.rows)
        destinationPositions = Self.identityPositions()

        super.init()

        isUserInteractionEnabled = false
        zPosition = PondLayerZ.koi + 0.35
        position = CGPoint(x: max(Constants.margin, sceneSize.width * 0.18), y: sceneSize.height * 0.52)
        zRotation = 0.0

        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        sprite.warpGeometry = baseGrid
        sprite.isUserInteractionEnabled = false
        addChild(sprite)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { nil }

    func reset(for sceneSize: CGSize) {
        position = CGPoint(x: max(Constants.margin, sceneSize.width * 0.18), y: sceneSize.height * 0.52)
        heading = 0.0
        zRotation = 0.0
    }

    func update(deltaTime: TimeInterval, sceneSize: CGSize) {
        let dt = CGFloat(deltaTime)
        guard dt.isFinite, dt > 0 else { return }

        time += dt
        let targetHeading = headingTarget(for: sceneSize)
        heading += shortestAngle(from: heading, to: targetHeading) * min(1.0, dt * 1.8)
        zRotation = heading

        swimSpeed = Constants.baseSpeed + 10.0 * sin(time * 0.43)
        position.x += cos(heading) * swimSpeed * dt
        position.y += sin(heading) * swimSpeed * dt
        position.y = min(max(position.y, Constants.margin * 0.55), sceneSize.height - Constants.margin * 0.55)

        if position.x > sceneSize.width + Constants.margin {
            position.x = -Constants.margin
            position.y = sceneSize.height * (0.42 + 0.16 * sin(time * 0.31))
            heading = 0.0
            zRotation = 0.0
        }

        updateWarp()
    }

    private func headingTarget(for sceneSize: CGSize) -> CGFloat {
        let centerY = sceneSize.height * (0.50 + 0.10 * sin(time * 0.18))
        let yError = centerY - position.y
        return atan2(yError * 0.015, 1.0)
    }

    private func shortestAngle(from current: CGFloat, to target: CGFloat) -> CGFloat {
        var delta = target - current
        while delta > .pi { delta -= .pi * 2.0 }
        while delta < -.pi { delta += .pi * 2.0 }
        return delta
    }

    private func updateWarp() {
        let normalizedSpeed = min(1.0, max(0.0, (swimSpeed - 44.0) / 34.0))
        let phase = time * (4.0 + normalizedSpeed * 1.2)
        let amplitude: CGFloat = 0.020 + normalizedSpeed * 0.018
        let waveOffset: CGFloat = .pi * 1.85

        var index = 0
        for row in 0...Constants.rows {
            let y = CGFloat(row) / CGFloat(Constants.rows)
            let edgeDistance = min(y, 1.0 - y) * 2.0
            let centerWeight = pow(max(0.0, edgeDistance), 0.65)

            for column in 0...Constants.columns {
                let x = CGFloat(column) / CGFloat(Constants.columns)
                let tailWeight = pow(1.0 - x, 1.6)
                let lateral = sin(phase + x * waveOffset) * amplitude * tailWeight * centerWeight
                destinationPositions[index] = vector_float2(Float(x), Float(min(1.0, max(0.0, y + lateral))))
                index += 1
            }
        }

        sprite.warpGeometry = baseGrid.replacingByDestinationPositions(positions: destinationPositions)
    }

    private static func identityPositions() -> [vector_float2] {
        (0...Constants.rows).flatMap { row in
            (0...Constants.columns).map { column in
                vector_float2(Float(CGFloat(column) / CGFloat(Constants.columns)), Float(CGFloat(row) / CGFloat(Constants.rows)))
            }
        }
    }
}
