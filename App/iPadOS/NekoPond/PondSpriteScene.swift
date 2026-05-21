import SpriteKit
import UIKit

final class PondSpriteScene: SKScene {
    private let steeringSystem = FishSteeringSystem()
    private let textureCache = PondTextureCache()
    private var fishNodes: [SKSpriteNode] = []
    private var fishShadows: [SKSpriteNode] = []
    private var fishMovements: [FishMovementComponent] = []
    private var fishConfigs: [KoiSpriteConfig] = []
    private var ripplePool: [SKSpriteNode] = []
    private var activeFishCount = 6
    private var rippleStrength: CGFloat = 0.62
    private var interactionSensitivity: CGFloat = 1.0
    private var isSimulating = false
    private var lastUpdateTime: TimeInterval?
    private let maximumDeltaTime: TimeInterval = 1.0 / 30.0
    private let pondBounds = CGRect(x: -10.0, y: -6.0, width: 20.0, height: 12.0)
    private var moteEmitter: SKEmitterNode?
    var onTapWater: (() -> Void)?

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.006, green: 0.020, blue: 0.035, alpha: 1.0)
        anchorPoint = CGPoint(x: 0.0, y: 0.0)
        scaleMode = .resizeFill
        if size.width <= 0 || size.height <= 0 {
            size = fallbackSceneSize(for: view)
        }
        rebuildLayers()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard view != nil, oldSize != size else { return }
        rebuildLayers()
    }

    func activate() {
        guard !isSimulating else { return }
        isSimulating = true
        lastUpdateTime = nil
    }

    func deactivate() {
        isSimulating = false
        lastUpdateTime = nil
    }

    @MainActor
    func apply(settings: PondSettings) {
        activeFishCount = min(max(settings.fishCount, 3), 9)
        rippleStrength = CGFloat(settings.rippleStrength)
        interactionSensitivity = settings.sensitivity == .low ? 0.72 : (settings.sensitivity == .high ? 1.22 : 1.0)

        for (i, node) in fishNodes.enumerated() {
            node.isHidden = i >= activeFishCount
            fishShadows[i].isHidden = i >= activeFishCount
        }

        applyMood(settings.mood, brightness: CGFloat(settings.nightBrightness))
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        guard isSimulating else {
            lastUpdateTime = currentTime
            return
        }
        guard let previous = lastUpdateTime else {
            lastUpdateTime = currentTime
            return
        }
        lastUpdateTime = currentTime
        let delta = currentTime - previous
        guard delta.isFinite, delta > 0 else { return }
        step(deltaTime: min(delta, maximumDeltaTime))
    }

    private func step(deltaTime: TimeInterval) {
        let size = self.size
        let sceneScale = min(size.width, size.height) / 12.0

        for i in fishMovements.indices {
            guard !fishNodes[i].isHidden else { continue }
            let neighbors = fishMovements
            steeringSystem.update(component: &fishMovements[i], bounds: pondBounds, neighbors: neighbors, deltaTime: deltaTime)
            syncFishNode(index: i, sceneScale: sceneScale)
        }

        // Fade expired ripples
        ripplePool.removeAll { node in
            node.alpha <= 0.01
        }
    }

    // MARK: - Layer Construction

    private func rebuildLayers() {
        removeAllChildren()
        removeAllActions()
        fishNodes.removeAll()
        fishShadows.removeAll()
        fishMovements.removeAll()
        fishConfigs.removeAll()
        ripplePool.removeAll()
        moteEmitter = nil
        buildLayers()
    }

    private func fallbackSceneSize(for view: SKView?) -> CGSize {
        let viewSize = view?.bounds.size ?? .zero
        if viewSize.width > 0, viewSize.height > 0 { return viewSize }

        let screenSize = UIScreen.main.bounds.size
        return CGSize(width: max(screenSize.width, 1366), height: max(screenSize.height, 1024))
    }

    private func sceneCenter(for size: CGSize? = nil) -> CGPoint {
        let targetSize = size ?? self.size
        return CGPoint(x: targetSize.width * 0.5, y: targetSize.height * 0.5)
    }

    private func worldToScene(_ point: CGPoint, sceneScale: CGFloat) -> CGPoint {
        let center = sceneCenter()
        return CGPoint(x: center.x + point.x * sceneScale, y: center.y + point.y * sceneScale)
    }

    private func sceneToWorld(_ point: CGPoint, sceneScale: CGFloat) -> CGPoint {
        let center = sceneCenter()
        return CGPoint(x: (point.x - center.x) / sceneScale, y: (point.y - center.y) / sceneScale)
    }

    private func buildLayers() {
        let size = self.size
        let sceneScale = min(size.width, size.height) / 12.0

        // 1. Floor background
        let floor = makePondBackgroundLayer(size: size)
        addChild(floor)

        // 2. Deep teal water gradient
        let deepWater = makeSpriteLayer(
            texture: PondSpriteAssets.deepWaterTexture(size: CGSize(width: 1024, height: 768)),
            size: CGSize(width: size.width * 1.04, height: size.height * 1.04),
            zPosition: PondLayerZ.deepWater
        )
        deepWater.alpha = 0.16
        addChild(deepWater)

        // 3. Caustics overlay
        let caustics = makeSpriteLayer(
            texture: PondSpriteAssets.causticsTexture(size: CGSize(width: 1024, height: 768)),
            size: CGSize(width: size.width * 1.02, height: size.height * 1.02),
            zPosition: PondLayerZ.caustics
        )
        caustics.alpha = 0.42
        caustics.blendMode = .add
        addChild(caustics)
        animateCaustics(caustics)

        // 4. Fog veil
        let fog = makeSpriteLayer(
            texture: PondSpriteAssets.fogTexture(size: CGSize(width: 1024, height: 768)),
            size: CGSize(width: size.width, height: size.height),
            zPosition: PondLayerZ.fogVeil
        )
        fog.alpha = 0.12
        addChild(fog)

        // 5-6. Koi (shadows + bodies)
        buildFish(sceneScale: sceneScale)

        // 7. Environment (lotus, stones)
        buildEnvironment(sceneScale: sceneScale)

        // 8. Petals
        buildPetals(sceneScale: sceneScale)

        // 9. Particles (motes)
        buildMotes()

        // 10. Vignette
        let vignette = makeSpriteLayer(
            texture: PondSpriteAssets.vignetteTexture(size: CGSize(width: 1024, height: 768)),
            size: CGSize(width: size.width, height: size.height),
            zPosition: PondLayerZ.vignette
        )
        vignette.alpha = 0.32
        vignette.isUserInteractionEnabled = false
        addChild(vignette)

        logPondLayerDebug(
            sceneSize: size,
            background: floor,
            deepWater: deepWater,
            caustics: caustics,
            fog: fog,
            vignette: vignette
        )
    }

    private func makeSpriteLayer(texture: UIImage, size: CGSize, zPosition: CGFloat) -> SKSpriteNode {
        let node = SKSpriteNode(texture: SKTexture(image: texture), size: size)
        node.position = .zero
        node.zPosition = zPosition
        node.isUserInteractionEnabled = false
        return node
    }

    private func makePondBackgroundLayer(size: CGSize) -> SKSpriteNode {
        let assetPath = "Pond/pond_background_day_2732x2048.png"
        let texture: SKTexture

        if let frozenTexture = textureCache.texture(for: assetPath) {
            texture = frozenTexture
        } else {
            #if DEBUG
            print("DEBUG PondSpriteScene frozen background failed to load: \(assetPath); using procedural floor fallback.")
            #endif
            texture = SKTexture(image: PondSpriteAssets.floorTexture(size: CGSize(width: 1024, height: 768)))
        }

        let finalSize = aspectFillSize(textureSize: texture.size(), targetSize: size)
        let node = SKSpriteNode(texture: texture)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        node.size = finalSize
        node.zPosition = PondLayerZ.floor
        node.alpha = 1.0
        node.colorBlendFactor = 0.0
        node.isUserInteractionEnabled = false
        return node
    }


    private func logPondLayerDebug(
        sceneSize: CGSize,
        background: SKSpriteNode,
        deepWater: SKSpriteNode,
        caustics: SKSpriteNode,
        fog: SKSpriteNode,
        vignette: SKSpriteNode
    ) {
        #if DEBUG
        let assetPath = "Pond/pond_background_day_2732x2048.png"
        let frozenTexture = textureCache.texture(for: assetPath)
        print("DEBUG PondSpriteScene scene size: \(sceneSize)")
        print("DEBUG PondSpriteScene background found: \(frozenTexture != nil) path: \(assetPath)")
        print("DEBUG PondSpriteScene background texture size: \(background.texture?.size() ?? .zero)")
        print("DEBUG PondSpriteScene background node size: \(background.size)")
        print("DEBUG PondSpriteScene background node position: \(background.position)")
        print("DEBUG PondSpriteScene background zPosition: \(background.zPosition)")
        print("DEBUG PondSpriteScene overlay alphas: deepWater=\(deepWater.alpha), caustics=\(caustics.alpha), fog=\(fog.alpha), vignette=\(vignette.alpha)")
        #endif
    }

    private func aspectFillSize(textureSize: CGSize, targetSize: CGSize) -> CGSize {
        guard textureSize.width > 0, textureSize.height > 0, targetSize.width > 0, targetSize.height > 0 else {
            return targetSize
        }

        let scale = max(targetSize.width / textureSize.width, targetSize.height / textureSize.height)
        return CGSize(width: textureSize.width * scale, height: textureSize.height * scale)
    }

    // MARK: - Caustics Animation

    private func animateCaustics(_ node: SKSpriteNode) {
        let drift = SKAction.sequence([
            SKAction.moveBy(x: 8, y: 5, duration: 3.2),
            SKAction.moveBy(x: -6, y: 3, duration: 2.8),
            SKAction.moveBy(x: -4, y: -6, duration: 3.0),
            SKAction.moveBy(x: 2, y: -2, duration: 2.5)
        ])
        node.run(SKAction.repeatForever(drift))

        let fade = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.45, duration: 4.0),
            SKAction.fadeAlpha(to: 0.65, duration: 3.5)
        ])
        node.run(SKAction.repeatForever(fade))
    }

    // MARK: - Fish

    private func buildFish(sceneScale: CGFloat) {
        let configs = KoiSpriteConfig.configs(for: 9)
        fishConfigs = configs

        for (i, config) in configs.enumerated() {
            // Shadow
            let shadowTex = PondSpriteAssets.koiShadowTexture(bodySize: config.bodySize)
            let shadow = SKSpriteNode(texture: SKTexture(image: shadowTex), size: CGSize(width: config.bodySize.width * 0.9, height: config.bodySize.height * 0.9))
            shadow.zPosition = PondLayerZ.koiShadow
            shadow.alpha = 0.15
            shadow.isHidden = i >= activeFishCount
            shadow.isUserInteractionEnabled = false
            addChild(shadow)
            fishShadows.append(shadow)

            // Body
            let bodyTex = PondSpriteAssets.koiBodyTexture(config: config)
            let body = SKSpriteNode(texture: SKTexture(image: bodyTex), size: CGSize(width: config.bodySize.width * 0.85, height: config.bodySize.height * 0.85))
            body.zPosition = PondLayerZ.koi
            body.isHidden = i >= activeFishCount
            body.isUserInteractionEnabled = false
            addChild(body)
            fishNodes.append(body)

            // Movement component
            let position = initialFishPosition(at: i, total: configs.count)
            var movement = FishMovementComponent(position: position, seed: config.seed)
            movement.depth = CGFloat.random(in: -1.8 ... -0.4)
            fishMovements.append(movement)
        }
    }

    private func initialFishPosition(at index: Int, total: Int) -> CGPoint {
        let predefined: [CGPoint] = [
            CGPoint(x: -7.8, y: 2.8), CGPoint(x: -3.2, y: -3.4),
            CGPoint(x: 0.8, y: 1.9), CGPoint(x: 4.2, y: -1.2),
            CGPoint(x: 7.1, y: 3.3), CGPoint(x: -1.4, y: 4.5),
            CGPoint(x: 5.8, y: -4.0)
        ]
        if index < predefined.count { return predefined[index] }
        let safeTotal = max(total, 1)
        let angle = (CGFloat(index) / CGFloat(safeTotal)) * .pi * 2
        return CGPoint(x: cos(angle) * 6.8, y: sin(angle) * 3.9)
    }

    private func syncFishNode(index: Int, sceneScale: CGFloat) {
        let movement = fishMovements[index]
        let node = fishNodes[index]
        let shadow = fishShadows[index]

        // Map world coords to scene coords
        let scenePoint = worldToScene(movement.position, sceneScale: sceneScale)
        let sceneX = scenePoint.x
        let sceneY = scenePoint.y
        node.position = scenePoint
        node.zRotation = -movement.heading

        // Depth-based scale variation
        let depthScale = 0.85 + (abs(movement.depth) / 1.8) * 0.15
        let bodySway = sin(CGFloat(movement.lifeTime) * 2.15 * Double(movement.energyLevel) + movement.swayPhase) * 0.03
        node.xScale = depthScale
        node.yScale = depthScale + bodySway

        // Shadow offset
        shadow.position = CGPoint(x: sceneX + 3, y: sceneY - 4)
        shadow.zRotation = -movement.heading
        shadow.xScale = depthScale * 1.02
        shadow.yScale = depthScale * 1.02
        shadow.alpha = 0.12 + min(0.10, CGFloat(movement.velocity.length) / 3.0)

        // Slight depth-based z variation
        node.zPosition = PondLayerZ.koi + movement.depth * 0.01
    }

    // MARK: - Environment

    private func buildEnvironment(sceneScale: CGFloat) {
        let lotuses: [(CGFloat, CGFloat, Bool, CGFloat)] = [
            (-7.7, 3.6, true, 1.05), (7.6, 4.4, false, 1.15), (8.1, -4.2, true, 0.95)
        ]
        for (wx, wy, flower, scale) in lotuses {
            let tex = PondSpriteAssets.lotusLeafTexture(size: CGSize(width: 80, height: 64), isFlower: flower)
            let node = SKSpriteNode(texture: SKTexture(image: tex), size: CGSize(width: 80 * scale, height: 64 * scale))
            node.position = worldToScene(CGPoint(x: wx, y: wy), sceneScale: sceneScale)
            node.zPosition = PondLayerZ.environment
            node.isUserInteractionEnabled = false
            addChild(node)
        }

        let stones: [(CGFloat, CGFloat, CGFloat)] = [
            (-8.9, -4.6, 1.4), (-7.6, 4.8, 1.0), (7.8, 4.1, 1.2),
            (-1.5, 5.0, 0.8), (8.4, -4.8, 1.35), (5.8, -5.4, 0.9)
        ]
        for (wx, wy, scale) in stones {
            let tex = PondSpriteAssets.stoneTexture(size: CGSize(width: 48, height: 40))
            let node = SKSpriteNode(texture: SKTexture(image: tex), size: CGSize(width: 48 * scale, height: 40 * scale))
            node.position = worldToScene(CGPoint(x: wx, y: wy), sceneScale: sceneScale)
            node.zPosition = PondLayerZ.environment - 0.1
            node.isUserInteractionEnabled = false
            addChild(node)
        }
    }

    // MARK: - Petals

    private func buildPetals(sceneScale: CGFloat) {
        for i in 0..<12 {
            let tex = PondSpriteAssets.petalTexture(size: CGSize(width: 12, height: 8))
            let node = SKSpriteNode(texture: SKTexture(image: tex), size: CGSize(width: 12, height: 8))
            let wx = CGFloat.random(in: -5.5...5.8)
            let wy = CGFloat.random(in: -4.6...4.7)
            node.position = worldToScene(CGPoint(x: wx, y: wy), sceneScale: sceneScale)
            node.zPosition = PondLayerZ.petals
            node.zRotation = CGFloat(i) * 0.51
            node.alpha = 0.45
            node.isUserInteractionEnabled = false
            addChild(node)

            // Gentle drift
            let drift = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -8...8), y: CGFloat.random(in: -6...6), duration: Double.random(in: 6...12)),
                SKAction.moveBy(x: CGFloat.random(in: -8...8), y: CGFloat.random(in: -6...6), duration: Double.random(in: 6...12))
            ])
            node.run(SKAction.repeatForever(drift))
        }
    }

    // MARK: - Motes

    private func buildMotes() {
        let emitter = SKEmitterNode()
        emitter.particleTexture = SKTexture(image: PondSpriteAssets.moteTexture())
        emitter.particleBirthRate = 6
        emitter.numParticlesToEmit = 0
        emitter.particleLifetime = 12.0
        emitter.particleLifetimeRange = 6.0
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = .pi * 2
        emitter.particleSpeed = 8
        emitter.particleSpeedRange = 5
        emitter.particleAlpha = 0.25
        emitter.particleAlphaRange = 0.15
        emitter.particleAlphaSpeed = -0.01
        emitter.particleScale = 0.8
        emitter.particleScaleRange = 0.4
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColor = UIColor(red: 0.50, green: 0.80, blue: 0.72, alpha: 1.0)
        emitter.particleBlendMode = .add
        emitter.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        emitter.particlePosition = CGPoint.zero
        emitter.particlePositionRange = CGVector(dx: size.width * 0.9, dy: size.height * 0.8)
        emitter.zPosition = PondLayerZ.particles
        addChild(emitter)
        moteEmitter = emitter
    }

    // MARK: - Ripples

    private func spawnRipple(at scenePoint: CGPoint, strong: Bool) {
        let tex = PondSpriteAssets.rippleTexture(size: CGSize(width: 60, height: 60))
        let node = SKSpriteNode(texture: SKTexture(image: tex), size: CGSize(width: 20, height: 20))
        node.position = scenePoint
        node.zPosition = PondLayerZ.ripples
        node.alpha = strong ? 0.7 : 0.45
        node.isUserInteractionEnabled = false
        addChild(node)
        ripplePool.append(node)

        let targetScale: CGFloat = strong ? 3.5 * rippleStrength : 2.0 * rippleStrength
        let duration: TimeInterval = strong ? 1.45 : 0.9

        node.run(SKAction.group([
            SKAction.scale(to: targetScale, duration: duration),
            SKAction.fadeOut(withDuration: duration)
        ])) {
            node.removeFromParent()
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches, phase: .began)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches, phase: .moved)
    }

    private func handleTouches(_ touches: Set<UITouch>, phase: TouchPhase) {
        guard let view = self.view else { return }
        let size = self.size
        let sceneScale = min(size.width, size.height) / 12.0

        for touch in touches {
            let scenePoint = touch.location(in: self)

            // Spawn ripple
            spawnRipple(at: scenePoint, strong: phase == .began)
            onTapWater?()

            // Convert to world coords for fish interaction
            let worldPoint = sceneToWorld(scenePoint, sceneScale: sceneScale)

            // Check fish proximity
            if phase == .began {
                var touchedFish = false
                for (i, movement) in fishMovements.enumerated() {
                    guard !fishNodes[i].isHidden else { continue }
                    let dist = hypot(worldPoint.x - movement.position.x, worldPoint.y - movement.position.y)
                    if dist < 1.5 {
                        touchFish(at: i, from: worldPoint)
                        touchedFish = true
                    }
                }
                if !touchedFish {
                    respondToWaterTap(at: worldPoint)
                }
            }
        }
    }

    private func touchFish(at index: Int, from point: CGPoint) {
        let away = CGVector(
            dx: fishMovements[index].position.x - point.x,
            dy: fishMovements[index].position.y - point.y
        ).normalizedOrFallback(CGVector(dx: cos(fishMovements[index].heading), dy: sin(fishMovements[index].heading)))
        fishMovements[index].attentionDirection = away
        fishMovements[index].attentionStrength = 1.0
        fishMovements[index].attentionTimeRemaining = 1.5
        fishMovements[index].focusTimeRemaining = 1.0
        fishMovements[index].alertTimeRemaining = 1.0
        fishMovements[index].cooldownTimeRemaining = 1.6
        fishMovements[index].targetSpeed = 1.9
    }

    private func respondToWaterTap(at point: CGPoint) {
        for i in fishMovements.indices where !fishNodes[i].isHidden {
            let dist = hypot(point.x - fishMovements[i].position.x, point.y - fishMovements[i].position.y)
            if dist < 3.2 {
                let away = CGVector(
                    dx: fishMovements[i].position.x - point.x,
                    dy: fishMovements[i].position.y - point.y
                )
                fishMovements[i].attentionDirection = away.normalizedOrFallback(fishMovements[i].wanderDirection)
                fishMovements[i].attentionStrength = (1.0 - dist / 3.2) * interactionSensitivity
                fishMovements[i].alertTimeRemaining = 0.8
                fishMovements[i].cooldownTimeRemaining = 1.8
                fishMovements[i].targetSpeed = 1.55 * interactionSensitivity
            } else if dist < 7.5 {
                let toward = CGVector(
                    dx: point.x - fishMovements[i].position.x,
                    dy: point.y - fishMovements[i].position.y
                )
                fishMovements[i].attentionDirection = toward.normalizedOrFallback(fishMovements[i].wanderDirection)
                fishMovements[i].attentionStrength = 0.18 * interactionSensitivity
                fishMovements[i].attentionTimeRemaining = 1.6
                fishMovements[i].targetSpeed = 1.05
            }
        }
    }

    // MARK: - Mood

    private func applyMood(_ mood: PondSettings.Mood, brightness: CGFloat) {
        switch mood {
        case .dawn:
            backgroundColor = UIColor(red: 0.006, green: 0.020, blue: 0.035, alpha: 1.0)
        case .day:
            backgroundColor = UIColor(red: 0.012, green: 0.050, blue: 0.062, alpha: 1.0)
        case .rain:
            backgroundColor = UIColor(red: 0.004, green: 0.018, blue: 0.028, alpha: 1.0)
        case .moonlight:
            backgroundColor = UIColor(red: 0.003, green: 0.010, blue: 0.022, alpha: 1.0)
        case .winter:
            backgroundColor = UIColor(red: 0.014, green: 0.032, blue: 0.042, alpha: 1.0)
        }
    }
}
