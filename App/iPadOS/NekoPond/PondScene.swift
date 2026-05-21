import CoreGraphics
import SceneKit
import UIKit

final class PondScene: SCNScene, SCNSceneRendererDelegate {
    private let maximumDeltaTime: TimeInterval = 1.0 / 30.0
    private let steeringSystem = FishSteeringSystem()
    private weak var view: SCNView?
    private var lastUpdateTime: TimeInterval?
    private var bootstrapped = false
    private var simulationPaused = true
    private var fishEntities: [FishEntity] = []
    private let fishRoot = SCNNode()
    private let effectsRoot = SCNNode()
    private let decorRoot = SCNNode()
    private let waterSurfaceNode = SCNNode()
    private let waterVolumeNode = SCNNode()
    private let floorNode = SCNNode()
    private let cameraNode = SCNNode()
    private let cameraTargetNode = SCNNode()
    private let pondBounds = CGRect(x: -10.0, y: -6.0, width: 20.0, height: 12.0)
    private let waterSurfaceY: Float = 0.0
    private let fishDepthRange: ClosedRange<CGFloat> = -1.8 ... -0.4
    private var activeFishCount = 6
    private var rippleScale: CGFloat = 0.62
    private var interactionSensitivity: CGFloat = 1.0

    func attach(view: SCNView) {
        self.view = view
        syncViewport(to: view.bounds.size)
        installCameraPointOfView(on: view)
    }

    func bootstrap() {
        guard !bootstrapped else { return }
        bootstrapped = true
        background.contents = UIColor(red: 0.006, green: 0.020, blue: 0.035, alpha: 1.0)
        lightingEnvironment.contents = UIColor(red: 0.32, green: 0.48, blue: 0.52, alpha: 1.0)
        lightingEnvironment.intensity = 0.78
        fogStartDistance = 10.0
        fogEndDistance = 38.0
        fogDensityExponent = 1.35
        fogColor = UIColor(red: 0.015, green: 0.055, blue: 0.062, alpha: 1.0)
        PondAssetRegistry.shared.preload([.pondBackgroundDay, .waterVeilDeep, .waterDistortionNoise])
        buildScene()
        spawnInitialFishIfNeeded()
#if DEBUG
        logDebugState(prefix: "bootstrap")
#endif
    }

    func pauseSimulation() {
        simulationPaused = true
        lastUpdateTime = nil
    }

    func resumeSimulation() {
        bootstrap()
        simulationPaused = false
        lastUpdateTime = nil
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard bootstrapped, !simulationPaused else {
            lastUpdateTime = time
            return
        }
        guard let previous = lastUpdateTime else {
            lastUpdateTime = time
            return
        }
        lastUpdateTime = time
        let delta = time - previous
        guard delta.isFinite, delta > 0 else { return }
        step(deltaTime: min(delta, maximumDeltaTime), time: time)
    }


    @MainActor
    func apply(settings: PondSettings) {
        activeFishCount = supportedFishCount(settings.fishCount)
        rippleScale = CGFloat(settings.rippleStrength)
        interactionSensitivity = settings.sensitivity == .low ? 0.72 : (settings.sensitivity == .high ? 1.22 : 1.0)
        simulationPaused = settings.isPaused
        for (index, fish) in fishEntities.enumerated() { fish.rootNode.isHidden = index >= activeFishCount }
        let brightness = CGFloat(settings.nightBrightness)
        lightingEnvironment.intensity = settings.mood == .moonlight ? 0.38 + brightness * 0.32 : 0.62 + brightness * 0.22
        fogDensityExponent = settings.mood == .rain ? 1.55 : 1.35
        switch settings.mood {
        case .dawn:
            background.contents = UIColor(red: 0.006, green: 0.020, blue: 0.035, alpha: 1.0)
            fogColor = UIColor(red: 0.018, green: 0.060, blue: 0.065, alpha: 1.0)
        case .day:
            background.contents = UIColor(red: 0.012, green: 0.050, blue: 0.062, alpha: 1.0)
            fogColor = UIColor(red: 0.025, green: 0.095, blue: 0.090, alpha: 1.0)
        case .rain:
            background.contents = UIColor(red: 0.004, green: 0.018, blue: 0.028, alpha: 1.0)
            fogColor = UIColor(red: 0.040, green: 0.078, blue: 0.082, alpha: 1.0)
        case .moonlight:
            background.contents = UIColor(red: 0.003, green: 0.010, blue: 0.022, alpha: 1.0)
            fogColor = UIColor(red: 0.010, green: 0.030, blue: 0.052, alpha: 1.0)
        case .winter:
            background.contents = UIColor(red: 0.014, green: 0.032, blue: 0.042, alpha: 1.0)
            fogColor = UIColor(red: 0.052, green: 0.082, blue: 0.085, alpha: 1.0)
        }
    }

    func handleTouches(phase: TouchPhase, touches: Set<UITouch>, in view: SCNView) {
        for touch in touches {
            let location = touch.location(in: view)
            let fish = fishHit(at: location, in: view)
            let surfacePoint = waterHit(at: location, in: view) ?? .init(x: 0.0, y: 0.0, z: 0.0)
#if DEBUG
            let fishName = fish?.rootNode.name ?? "none"
            print("[PondTouch] phase=\(phase) screen=\(location) fish=\(fishName) world=(\(surfacePoint.x), \(surfacePoint.y), \(surfacePoint.z)) camera=\(cameraNode.position) fishCount=\(fishEntities.count)")
#endif
            switch phase {
            case .began:
                if let fish {
                    fish.respondToTouch(from: CGPoint(x: CGFloat(surfacePoint.x), y: CGFloat(surfacePoint.z)))
                    spawnFishTouchBurst(at: surfacePoint)
                }
                spawnRipple(at: surfacePoint, strong: true)
                respondToWaterTap(at: CGPoint(x: CGFloat(surfacePoint.x), y: CGFloat(surfacePoint.z)))
            case .moved:
                spawnRipple(at: surfacePoint, strong: false)
            case .ended:
                break
            }
        }
    }

    private func buildScene() {
        rootNode.addChildNode(waterVolumeNode)
        rootNode.addChildNode(floorNode)
        rootNode.addChildNode(waterSurfaceNode)
        rootNode.addChildNode(decorRoot)
        rootNode.addChildNode(fishRoot)
        rootNode.addChildNode(effectsRoot)
        cameraTargetNode.position = SCNVector3(0.0, -0.6, 0.0)
        rootNode.addChildNode(cameraTargetNode)
        buildCamera()
        buildLighting()
        buildWater()
        buildDecor()
    }

    private func buildCamera() {
        let camera = SCNCamera()
        camera.usesOrthographicProjection = false
        camera.fieldOfView = 42.0
        camera.zNear = 0.1
        camera.zFar = 120.0
        camera.wantsHDR = true
        camera.wantsDepthOfField = false
        camera.bloomIntensity = 0.12
        camera.bloomThreshold = 0.82
        camera.vignettingIntensity = 0.52
        camera.vignettingPower = 0.62
        camera.colorFringeIntensity = 0.0
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0.0, 13.2, 6.4)
        cameraNode.eulerAngles = SCNVector3(-1.10, 0.0, 0.0)
        let lookAt = SCNLookAtConstraint(target: cameraTargetNode)
        lookAt.isGimbalLockEnabled = true
        cameraNode.constraints = [lookAt]
        rootNode.addChildNode(cameraNode)
        if let view {
            installCameraPointOfView(on: view)
        }
    }

    private func buildLighting() {
        let sun = SCNNode()
        let directional = SCNLight()
        directional.type = .directional
        directional.intensity = 480
        directional.temperature = 6_800
        directional.castsShadow = true
        directional.shadowRadius = 8.0
        directional.shadowSampleCount = 12
        directional.shadowColor = UIColor.black.withAlphaComponent(0.22)
        sun.light = directional
        sun.eulerAngles = SCNVector3(-1.15, -0.30, -0.18)
        rootNode.addChildNode(sun)

        let fill = SCNNode()
        let omni = SCNLight()
        omni.type = .omni
        omni.intensity = 78
        omni.color = UIColor(red: 0.28, green: 0.62, blue: 0.68, alpha: 1.0)
        fill.light = omni
        fill.position = SCNVector3(-5.0, 4.0, 5.0)
        rootNode.addChildNode(fill)

        let ambient = SCNNode()
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 140
        ambientLight.color = UIColor(red: 0.08, green: 0.18, blue: 0.22, alpha: 1.0)
        ambient.light = ambientLight
        rootNode.addChildNode(ambient)
    }

    private func buildWater() {
        let floorPlane = SCNPlane(width: 28.0, height: 20.0)
        let floorMaterial = SCNMaterial()
        floorMaterial.lightingModel = .physicallyBased
        floorMaterial.diffuse.contents = PondAssetRegistry.shared.image(.pondBackgroundDay) ?? pondFloorTexture(size: CGSize(width: 1600, height: 1200))
        floorMaterial.roughness.contents = 0.96
        floorMaterial.metalness.contents = 0.0
        floorMaterial.normal.contents = PondAssetRegistry.shared.image(.waterDistortionNoise) ?? pondNormalTexture(size: CGSize(width: 1024, height: 1024), intensity: 0.18)
        floorPlane.firstMaterial = floorMaterial
        floorNode.geometry = floorPlane
        floorNode.eulerAngles.x = -.pi / 2
        floorNode.position = SCNVector3(0.0, -2.6, 0.0)

        let surface = SCNPlane(width: 30.0, height: 22.0)
        let surfaceMaterial = SCNMaterial()
        surfaceMaterial.lightingModel = .physicallyBased
        surfaceMaterial.diffuse.contents = PondAssetRegistry.shared.image(.waterVeilDeep) ?? waterSurfaceTexture(size: CGSize(width: 1600, height: 1200))
        surfaceMaterial.roughness.contents = 0.16
        surfaceMaterial.metalness.contents = 0.0
        surfaceMaterial.transparency = 0.84
        surfaceMaterial.fresnelExponent = 1.4
        surfaceMaterial.blendMode = .alpha
        surfaceMaterial.isDoubleSided = true
        surfaceMaterial.shaderModifiers = [.surface: """
        float rippleA = sin(_surface.position.x * 0.55 + u_time * 0.28) * cos(_surface.position.y * 0.43 - u_time * 0.21);
        float rippleB = sin(_surface.position.x * 1.10 - u_time * 0.17) * 0.5 + cos(_surface.position.y * 0.86 + u_time * 0.15) * 0.5;
        float caustic = pow(max(0.0, sin(_surface.position.x * 0.95 + u_time * 0.52) * cos(_surface.position.y * 0.82 - u_time * 0.41)), 5.0);
        _surface.normal = normalize(_surface.normal + float3(rippleA * 0.08, rippleB * 0.06, 0.0));
        _surface.emission.rgb += float3(0.01, 0.06, 0.055) + float3(0.20, 0.24, 0.12) * caustic;
        _surface.roughness = 0.12 + abs(rippleA) * 0.06 + abs(rippleB) * 0.04;
        """]
        surface.firstMaterial = surfaceMaterial
        waterSurfaceNode.geometry = surface
        waterSurfaceNode.name = "waterSurface"
        waterSurfaceNode.categoryBitMask = 1
        waterSurfaceNode.eulerAngles.x = -.pi / 2
        waterSurfaceNode.position = SCNVector3(0.0, waterSurfaceY, 0.0)

        let volume = SCNBox(width: 28.0, height: 2.8, length: 20.0, chamferRadius: 0.0)
        let volumeMaterial = SCNMaterial()
        volumeMaterial.lightingModel = .physicallyBased
        volumeMaterial.diffuse.contents = UIColor(red: 0.02, green: 0.10, blue: 0.12, alpha: 0.22)
        volumeMaterial.emission.contents = UIColor(red: 0.008, green: 0.035, blue: 0.04, alpha: 0.18)
        volumeMaterial.transparent.contents = UIColor.white.withAlphaComponent(0.14)
        volumeMaterial.cullMode = .front
        volumeMaterial.blendMode = .alpha
        volume.firstMaterial = volumeMaterial
        waterVolumeNode.geometry = volume
        waterVolumeNode.position = SCNVector3(0.0, -1.3, 0.0)
    }

    private func buildDecor() {
        let stones: [(CGFloat, CGFloat, CGFloat)] = [(-8.9, -4.6, 1.4), (-7.6, 4.8, 1.0), (7.8, 4.1, 1.2), (-1.5, 5.0, 0.8), (8.4, -4.8, 1.35), (5.8, -5.4, 0.9)]
        for stone in stones {
            buildStone(at: CGPoint(x: stone.0, y: stone.1), scale: stone.2)
        }
        let reeds: [(CGFloat, CGFloat, CGFloat)] = [(-9.0, -2.4, 1.0), (9.3, 1.8, 0.9), (-5.8, 5.1, 0.75), (6.8, -3.8, 0.82)]
        for reed in reeds { buildGrass(at: CGPoint(x: reed.0, y: reed.1), scale: reed.2) }
        buildLotus(at: CGPoint(x: -7.7, y: 3.6), flower: true, scale: 1.05)
        buildLotus(at: CGPoint(x: 7.6, y: 4.4), flower: false, scale: 1.15)
        buildLotus(at: CGPoint(x: 8.1, y: -4.2), flower: true, scale: 0.95)
        buildPetals()
    }

    private func spawnInitialFishIfNeeded() {
        guard fishEntities.isEmpty else { return }
        let seeds: [UInt64] = [0x4D314E656B6F506F, 0x706F6E6446697368, 0xBADC0FFEE0DDF00D, 0xC0A57A11D15C0DED, 0x51A7EC0E9A7BEEF0, 0xA11CEB0BA5ED1234, 0xF15ACA7FEE123456, 0xF00DCA7F15A98765, 0xD09ECAFE1234BEEF]
        let visibleFishCount = supportedFishCount(activeFishCount)
        let totalFishCount = max(seeds.count, visibleFishCount)
        for (index, seed) in seeds.enumerated() {
            let position = initialFishPosition(at: index, total: totalFishCount)
            let fish = FishEntity(id: index + 1, position: position, seed: seed)
            let scale = Float(0.082 + CGFloat(index % 3) * 0.006)
            fish.setBaseScale(scale)
            fish.movement.depth = CGFloat.random(in: fishDepthRange)
            fish.rootNode.isHidden = index >= visibleFishCount
            fish.applyVisualState()
            fishEntities.append(fish)
            fishRoot.addChildNode(fish.rootNode)
        }
    }

    private func supportedFishCount(_ count: Int) -> Int {
        min(max(count, 3), 9)
    }

    private func initialFishPosition(at index: Int, total: Int) -> CGPoint {
        let predefinedPositions: [CGPoint] = [
            CGPoint(x: -7.8, y: 2.8),
            CGPoint(x: -3.2, y: -3.4),
            CGPoint(x: 0.8, y: 1.9),
            CGPoint(x: 4.2, y: -1.2),
            CGPoint(x: 7.1, y: 3.3),
            CGPoint(x: -1.4, y: 4.5),
            CGPoint(x: 5.8, y: -4.0)
        ]
        if index < predefinedPositions.count {
            return predefinedPositions[index]
        }

        let safeTotal = max(total, 1)
        let angle = (CGFloat(index) / CGFloat(safeTotal)) * CGFloat.pi * 2.0
        return CGPoint(x: cos(angle) * 6.8, y: sin(angle) * 3.9)
    }

    private func step(deltaTime: TimeInterval, time: TimeInterval) {
        let neighborSnapshot = fishEntities.map(\.movement)
        for index in fishEntities.indices {
            guard !fishEntities[index].rootNode.isHidden else { continue }
            steeringSystem.update(component: &fishEntities[index].movement, bounds: pondBounds, neighbors: neighborSnapshot, deltaTime: deltaTime)
            fishEntities[index].applyVisualState()
        }
        waterSurfaceNode.geometry?.firstMaterial?.setValue(Float(time), forKey: "u_time")
        effectsRoot.childNodes.forEach { node in
            if node.opacity <= 0.01 { node.removeFromParentNode() }
        }
    }

    private func fishHit(at point: CGPoint, in view: SCNView) -> FishEntity? {
        let hits = view.hitTest(point, options: [
            .searchMode: SCNHitTestSearchMode.all.rawValue,
            .boundingBoxOnly: false,
            .ignoreHiddenNodes: true,
            .categoryBitMask: 2
        ])
        for hit in hits {
            var node: SCNNode? = hit.node
            while let current = node {
                if let fish = fishEntities.first(where: { $0.rootNode === current || current.name?.contains("-\($0.id)") == true }) {
                    return fish
                }
                node = current.parent
            }
        }
        return nil
    }

    private func waterHit(at point: CGPoint, in view: SCNView) -> SCNVector3? {
        let hits = view.hitTest(point, options: [
            .searchMode: SCNHitTestSearchMode.closest.rawValue,
            .rootNode: waterSurfaceNode,
            .ignoreHiddenNodes: true,
            .categoryBitMask: 1
        ])
        return hits.first?.worldCoordinates
    }


    private func installCameraPointOfView(on view: SCNView) {
        guard cameraNode.camera != nil, cameraNode.parent != nil else { return }
        if view.pointOfView !== cameraNode {
            view.pointOfView = cameraNode
        }
    }

    private func syncViewport(to size: CGSize) {
        guard size.width > 1.0, size.height > 1.0 else { return }
        cameraNode.camera?.fieldOfView = size.width > size.height ? 42.0 : 50.0
#if DEBUG
        print("[PondViewport] size=\(size) camera=\(cameraNode.position)")
#endif
    }

    private func attractFish(to point: CGPoint, speed: CGFloat) {
        for fish in fishEntities {
            let distance = hypot(point.x - fish.movement.position.x, point.y - fish.movement.position.y)
            let direction = CGVector(dx: point.x - fish.movement.position.x, dy: point.y - fish.movement.position.y)
            fish.movement.attentionDirection = direction.normalizedOrFallback(fish.movement.wanderDirection)
            fish.movement.attentionStrength = max(0.20, 1.0 - distance / 14.0) * interactionSensitivity
            fish.movement.attentionTimeRemaining = 2.8
            fish.movement.focusTimeRemaining = 1.8
            fish.movement.alertTimeRemaining = 0.8
            fish.movement.cooldownTimeRemaining = 1.5
            fish.movement.targetSpeed = speed * interactionSensitivity
        }
    }

    private func spawnRipple(at point: SCNVector3, strong: Bool) {
        let torus = SCNTorus(ringRadius: (strong ? 0.32 : 0.18) * rippleScale, pipeRadius: strong ? 0.008 : 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.68, green: 0.88, blue: 0.82, alpha: strong ? 0.32 : 0.16)
        material.emission.contents = UIColor(red: 0.08, green: 0.20, blue: 0.18, alpha: 0.12)
        material.blendMode = .alpha
        torus.firstMaterial = material
        let node = SCNNode(geometry: torus)
        node.position = SCNVector3(point.x, waterSurfaceY + 0.02, point.z)
        node.eulerAngles.x = -.pi / 2
        effectsRoot.addChildNode(node)
        let duration = strong ? 1.45 : 0.9
        node.runAction(.sequence([.group([.scale(to: (strong ? 7.8 : 4.4) * rippleScale, duration: duration), .fadeOut(duration: duration)]), .removeFromParentNode()]))
    }

    private func spawnFishTouchBurst(at point: SCNVector3) {
        spawnRipple(at: point, strong: true)
        let sphere = SCNSphere(radius: 0.08)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.72, green: 0.88, blue: 0.82, alpha: 0.22)
        material.emission.contents = UIColor(red: 0.12, green: 0.38, blue: 0.28, alpha: 0.18)
        material.blendMode = .alpha
        sphere.firstMaterial = material
        let node = SCNNode(geometry: sphere)
        node.position = SCNVector3(point.x, -0.35, point.z)
        effectsRoot.addChildNode(node)
        node.runAction(.sequence([.group([.scale(to: 7.0, duration: 0.55), .fadeOut(duration: 0.55)]), .removeFromParentNode()]))
    }


    private func respondToWaterTap(at point: CGPoint) {
        for fish in fishEntities where !fish.rootNode.isHidden {
            let distance = hypot(point.x - fish.movement.position.x, point.y - fish.movement.position.y)
            if distance < 3.2 {
                let away = CGVector(dx: fish.movement.position.x - point.x, dy: fish.movement.position.y - point.y)
                fish.movement.attentionDirection = away.normalizedOrFallback(fish.movement.wanderDirection)
                fish.movement.attentionStrength = (1.0 - distance / 3.2) * interactionSensitivity
                fish.movement.alertTimeRemaining = 0.8
                fish.movement.cooldownTimeRemaining = 1.8
                fish.movement.targetSpeed = 1.55 * interactionSensitivity
            } else if distance < 7.5 {
                let direction = CGVector(dx: point.x - fish.movement.position.x, dy: point.y - fish.movement.position.y)
                fish.movement.attentionDirection = direction.normalizedOrFallback(fish.movement.wanderDirection)
                fish.movement.attentionStrength = 0.18 * interactionSensitivity
                fish.movement.attentionTimeRemaining = 1.6
                fish.movement.targetSpeed = 1.05
            }
        }
    }

    private func buildLotus(at point: CGPoint, flower: Bool, scale: CGFloat) {
        let root = SCNNode()
        root.position = SCNVector3(Float(point.x), waterSurfaceY + 0.035, Float(point.y))
        for index in 0..<(flower ? 4 : 5) {
            let leaf = SCNPlane(width: 1.15 * scale, height: 0.90 * scale)
            let mat = SCNMaterial()
            mat.lightingModel = .physicallyBased
            mat.diffuse.contents = UIColor(red: 0.14, green: 0.28, blue: 0.14, alpha: 0.85)
            mat.roughness.contents = 0.9
            mat.emission.contents = UIColor(red: 0.01, green: 0.03, blue: 0.01, alpha: 1.0)
            mat.blendMode = .alpha
            mat.isDoubleSided = true
            leaf.cornerRadius = 0.46 * scale
            leaf.firstMaterial = mat
            let node = SCNNode(geometry: leaf)
            node.eulerAngles.x = -.pi / 2
            node.eulerAngles.y = Float(index) * 0.72
            node.position = SCNVector3(Float(cos(CGFloat(index)) * 0.28 * scale), 0, Float(sin(CGFloat(index)) * 0.22 * scale))
            root.addChildNode(node)
        }
        if flower {
            for index in 0..<10 {
                let petal = SCNPlane(width: 0.18 * scale, height: 0.52 * scale)
                let mat = SCNMaterial()
                mat.lightingModel = .physicallyBased
                mat.diffuse.contents = UIColor(red: 0.82, green: 0.52, blue: 0.52, alpha: 0.88)
                mat.emission.contents = UIColor(red: 0.12, green: 0.04, blue: 0.05, alpha: 0.08)
                mat.roughness.contents = 0.65
                mat.isDoubleSided = true
                mat.blendMode = .alpha
                petal.cornerRadius = 0.09 * scale
                petal.firstMaterial = mat
                let node = SCNNode(geometry: petal)
                node.eulerAngles.x = -.pi / 2
                node.eulerAngles.y = Float(index) * (.pi * 2 / 10)
                node.position = SCNVector3(Float(cos(CGFloat(index) * .pi * 2 / 10) * 0.22 * scale), 0.03, Float(sin(CGFloat(index) * .pi * 2 / 10) * 0.22 * scale))
                root.addChildNode(node)
            }
        }
        decorRoot.addChildNode(root)
    }

    private func buildPetals() {
        for index in 0..<12 {
            let petal = SCNPlane(width: 0.14, height: 0.28)
            let mat = SCNMaterial()
            mat.lightingModel = .physicallyBased
            mat.diffuse.contents = UIColor(red: 0.78, green: 0.48, blue: 0.52, alpha: 0.52)
            mat.emission.contents = UIColor(red: 0.04, green: 0.02, blue: 0.02, alpha: 1.0)
            mat.roughness.contents = 0.7
            mat.blendMode = .alpha
            mat.isDoubleSided = true
            petal.cornerRadius = 0.07
            petal.firstMaterial = mat
            let node = SCNNode(geometry: petal)
            node.eulerAngles.x = -.pi / 2
            node.eulerAngles.y = Float(index) * 0.51
            node.position = SCNVector3(Float(CGFloat.random(in: -5.5...5.8)), waterSurfaceY + 0.04, Float(CGFloat.random(in: -4.6...4.7)))
            decorRoot.addChildNode(node)
        }
    }

    private func spawnFood(at point: SCNVector3, count: Int) {
        guard count > 0 else { return }
        for index in 0..<count {
            let pellet = SCNSphere(radius: 0.028)
            let material = SCNMaterial()
            material.lightingModel = .physicallyBased
            material.diffuse.contents = UIColor(red: 0.48, green: 0.38, blue: 0.22, alpha: 1.0)
            material.roughness.contents = 0.84
            material.emission.contents = UIColor(red: 0.02, green: 0.015, blue: 0.01, alpha: 1.0)
            pellet.firstMaterial = material
            let node = SCNNode(geometry: pellet)
            let spread = Float(index) * 0.04
            node.position = SCNVector3(point.x + sin(Float(index) * 1.7) * spread, 0.20 + Float(index) * 0.01, point.z + cos(Float(index) * 1.3) * spread)
            effectsRoot.addChildNode(node)
            node.runAction(.sequence([.moveBy(x: CGFloat.random(in: -0.10...0.10), y: -1.0, z: CGFloat.random(in: -0.10...0.10), duration: 3.4), .fadeOut(duration: 0.35), .removeFromParentNode()]))
        }
    }

    private func buildGrass(at point: CGPoint, scale: CGFloat) {
        let cluster = SCNNode()
        cluster.position = SCNVector3(Float(point.x), -2.4, Float(point.y))
        for index in 0..<7 {
            let blade = SCNCapsule(capRadius: 0.016 * scale, height: 0.85 * scale)
            let material = SCNMaterial()
            material.lightingModel = .physicallyBased
            material.diffuse.contents = UIColor(red: 0.12, green: 0.24 + CGFloat(index) * 0.02, blue: 0.16, alpha: 1.0)
            material.roughness.contents = 0.92
            material.emission.contents = UIColor(red: 0.008, green: 0.02, blue: 0.01, alpha: 1.0)
            blade.firstMaterial = material
            let bladeNode = SCNNode(geometry: blade)
            bladeNode.position = SCNVector3(Float(CGFloat(index - 3) * 0.08 * scale), Float(0.35 * scale), Float(CGFloat(index % 2) * 0.04))
            bladeNode.eulerAngles.z = Float(CGFloat(index - 3) * 0.08)
            cluster.addChildNode(bladeNode)
        }
        decorRoot.addChildNode(cluster)
    }

    private func buildStone(at point: CGPoint, scale: CGFloat) {
        let stone = SCNSphere(radius: 0.55 * scale)
        stone.segmentCount = 32
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor(red: 0.12, green: 0.14, blue: 0.12, alpha: 1.0)
        material.roughness.contents = 0.97
        material.normal.contents = PondAssetRegistry.shared.image(.waterDistortionNoise) ?? pondNormalTexture(size: CGSize(width: 256, height: 256), intensity: 0.22)
        material.emission.contents = UIColor(red: 0.01, green: 0.02, blue: 0.01, alpha: 1.0)
        stone.firstMaterial = material
        let node = SCNNode(geometry: stone)
        node.position = SCNVector3(Float(point.x), -2.35, Float(point.y))
        node.scale = SCNVector3(Float(1.3 * scale), Float(0.7 * scale), Float(1.0 * scale))
        decorRoot.addChildNode(node)
    }

    private func pondFloorTexture(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cg = context.cgContext
            let colors = [
                UIColor(red: 0.03, green: 0.09, blue: 0.08, alpha: 1.0).cgColor,
                UIColor(red: 0.05, green: 0.14, blue: 0.12, alpha: 1.0).cgColor,
                UIColor(red: 0.08, green: 0.18, blue: 0.14, alpha: 1.0).cgColor
            ] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.0, 0.55, 1.0])!
            cg.drawLinearGradient(gradient, start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: size.width, y: size.height), options: [])
            for index in 0..<180 {
                let noise = CGFloat(index) / 180.0
                let alpha = 0.015 + sin(noise * .pi * 2.0) * 0.01
                cg.setFillColor(UIColor(red: 0.12, green: 0.16, blue: 0.12, alpha: alpha).cgColor)
                let rect = CGRect(x: CGFloat.random(in: 0...size.width), y: CGFloat.random(in: 0...size.height), width: CGFloat.random(in: 30...160), height: CGFloat.random(in: 16...90))
                cg.fillEllipse(in: rect)
            }
        }
    }

    private func waterSurfaceTexture(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cg = context.cgContext
            let colors = [
                UIColor(red: 0.008, green: 0.05, blue: 0.07, alpha: 0.94).cgColor,
                UIColor(red: 0.02, green: 0.12, blue: 0.14, alpha: 0.88).cgColor,
                UIColor(red: 0.06, green: 0.22, blue: 0.20, alpha: 0.72).cgColor
            ] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.0, 0.58, 1.0])!
            cg.drawRadialGradient(gradient, startCenter: CGPoint(x: size.width * 0.52, y: size.height * 0.42), startRadius: 20.0, endCenter: CGPoint(x: size.width * 0.52, y: size.height * 0.42), endRadius: size.width * 0.64, options: [])
            for index in 0..<64 {
                let alpha = 0.02 + CGFloat(index % 5) * 0.004
                cg.setStrokeColor(UIColor(red: 0.62, green: 0.82, blue: 0.72, alpha: alpha).cgColor)
                cg.setLineWidth(CGFloat.random(in: 1.4...3.6))
                let path = UIBezierPath()
                let startX = CGFloat.random(in: -120...size.width + 120)
                let startY = CGFloat.random(in: 0...size.height)
                path.move(to: CGPoint(x: startX, y: startY))
                path.addCurve(to: CGPoint(x: startX + CGFloat.random(in: 180...420), y: startY + CGFloat.random(in: -120...120)), controlPoint1: CGPoint(x: startX + CGFloat.random(in: 40...120), y: startY + CGFloat.random(in: -80...80)), controlPoint2: CGPoint(x: startX + CGFloat.random(in: 120...260), y: startY + CGFloat.random(in: -80...80)))
                cg.addPath(path.cgPath)
                cg.strokePath()
            }
        }
    }

    private func pondNormalTexture(size: CGSize, intensity: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cg = context.cgContext
            cg.setFillColor(UIColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0).cgColor)
            cg.fill(CGRect(origin: .zero, size: size))
            for _ in 0..<120 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let radius = CGFloat.random(in: 12...48)
                let hueShift = CGFloat.random(in: -intensity...intensity)
                cg.setFillColor(UIColor(red: 0.5 + hueShift * 0.2, green: 0.5 - hueShift * 0.2, blue: 1.0, alpha: 0.10).cgColor)
                cg.fillEllipse(in: CGRect(x: x, y: y, width: radius, height: radius))
            }
        }
    }

#if DEBUG
    private func logDebugState(prefix: String) {
        print("[PondDebug] \(prefix) fishCount=\(fishEntities.count) camera=\(cameraNode.position) bounds=\(pondBounds)")
    }
#endif
}
