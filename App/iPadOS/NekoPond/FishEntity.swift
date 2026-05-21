import CoreGraphics
import SceneKit
import UIKit

final class FishEntity {
    let id: Int
    let rootNode = SCNNode()
    var movement: FishMovementComponent
    private let bodyRoot = SCNNode()
    private let tailRoot = SCNNode()
    private var leftFin = SCNNode()
    private var rightFin = SCNNode()
    private var dorsalFin = SCNNode()
    private let shadowNode = SCNNode()
    private var touchPulse: CGFloat = 0.0
    private var baseScale = SCNVector3(1.0, 1.0, 1.0)

    init(id: Int, position: CGPoint, seed: UInt64) {
        self.id = id
        self.movement = FishMovementComponent(position: position, seed: seed)
        rootNode.name = "fish-\(id)"
        rootNode.categoryBitMask = 2
        buildVisual(seed: seed)
    }

    func applyVisualState() {
        rootNode.position = SCNVector3(Float(movement.position.x), Float(movement.depth), Float(movement.position.y))
        rootNode.eulerAngles.y = Float(-movement.heading)
        let time = CGFloat(movement.lifeTime)
        let energy = 0.75 + movement.energyLevel * 0.55
        bodyRoot.eulerAngles.z = Float(movement.bodySway * 0.30)
        bodyRoot.eulerAngles.x = Float(sin(time * 1.20 + movement.breathingPhase) * 0.030)
        tailRoot.eulerAngles.z = Float(movement.tailSway * 1.35)
        leftFin.eulerAngles.z = Float(-0.58 + sin(time * 3.0) * 0.12 * energy)
        rightFin.eulerAngles.z = Float(0.58 - sin(time * 3.0 + 0.4) * 0.12 * energy)
        dorsalFin.eulerAngles.x = Float(-0.40 + sin(time * 1.4) * 0.04)
        shadowNode.opacity = 0.15 + min(0.12, CGFloat(movement.velocity.length) / 2.8)
        shadowNode.position.y = Float(-abs(movement.depth) - 0.18)
        let pulseScale = 1.0 + Float(touchPulse) * 0.08
        if touchPulse > 0.0 {
            touchPulse = max(0.0, touchPulse - 0.028)
        }
        rootNode.scale = SCNVector3(baseScale.x * pulseScale, baseScale.y * pulseScale, baseScale.z * pulseScale)
    }

    func respondToTouch(from point: CGPoint) {
        touchPulse = 1.0
        let away = CGVector(dx: movement.position.x - point.x, dy: movement.position.y - point.y)
            .normalizedOrFallback(CGVector(dx: cos(movement.heading), dy: sin(movement.heading)))
        movement.attentionDirection = away
        movement.attentionStrength = 1.0
        movement.attentionTimeRemaining = 1.5
        movement.focusTimeRemaining = 1.0
        movement.alertTimeRemaining = 1.0
        movement.cooldownTimeRemaining = 1.6
        movement.targetSpeed = 1.9
    }

    private func buildVisual(seed: UInt64) {
        rootNode.addChildNode(shadow())
        bodyRoot.name = "fishBody-\(id)"
        rootNode.addChildNode(bodyRoot)

        let variant = Int(seed % 6)
        let palette = koiPalette(for: variant)

        let bodyTexture = koiBodyTexture(size: CGSize(width: 512, height: 256), palette: palette, variant: variant)
        let bodyPlane = SCNPlane(width: 36.0, height: 16.0)
        let bodyMaterial = SCNMaterial()
        bodyMaterial.lightingModel = .physicallyBased
        bodyMaterial.diffuse.contents = bodyTexture
        bodyMaterial.roughness.contents = 0.55
        bodyMaterial.metalness.contents = 0.0
        bodyMaterial.emission.contents = bodyTexture
        bodyMaterial.emission.intensity = 0.08
        bodyMaterial.isDoubleSided = true
        bodyMaterial.blendMode = .alpha
        bodyPlane.firstMaterial = bodyMaterial
        let bodyNode = SCNNode(geometry: bodyPlane)
        bodyNode.name = "fishBodyPlane-\(id)"
        bodyNode.categoryBitMask = 2
        bodyNode.eulerAngles.x = -.pi / 2
        bodyRoot.addChildNode(bodyNode)

        addEyes()
        addFins(palette: palette)
    }

    private func koiPalette(for variant: Int) -> (base: UIColor, pattern: UIColor, accent: UIColor) {
        switch variant {
        case 0:
            return (
                UIColor(red: 0.96, green: 0.94, blue: 0.88, alpha: 1.0),
                UIColor(red: 0.88, green: 0.18, blue: 0.08, alpha: 0.92),
                UIColor(red: 0.92, green: 0.28, blue: 0.12, alpha: 0.88)
            )
        case 1:
            return (
                UIColor(red: 0.96, green: 0.94, blue: 0.88, alpha: 1.0),
                UIColor(red: 0.88, green: 0.18, blue: 0.08, alpha: 0.92),
                UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 0.82)
            )
        case 2:
            return (
                UIColor(red: 0.96, green: 0.94, blue: 0.88, alpha: 1.0),
                UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 0.82),
                UIColor(red: 0.88, green: 0.18, blue: 0.08, alpha: 0.92)
            )
        case 3:
            return (
                UIColor(red: 0.92, green: 0.72, blue: 0.18, alpha: 1.0),
                UIColor(red: 0.88, green: 0.62, blue: 0.12, alpha: 0.92),
                UIColor(red: 0.96, green: 0.82, blue: 0.28, alpha: 0.88)
            )
        case 4:
            return (
                UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0),
                UIColor(red: 0.96, green: 0.94, blue: 0.88, alpha: 0.92),
                UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 0.82)
            )
        default:
            return (
                UIColor(red: 0.96, green: 0.94, blue: 0.88, alpha: 1.0),
                UIColor(red: 0.88, green: 0.18, blue: 0.08, alpha: 0.92),
                UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 0.82)
            )
        }
    }

    private func koiBodyTexture(size: CGSize, palette: (base: UIColor, pattern: UIColor, accent: UIColor), variant: Int) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cg = context.cgContext

            cg.setFillColor(palette.base.cgColor)
            cg.fill(CGRect(origin: .zero, size: size))

            let bodyPath = UIBezierPath()
            bodyPath.move(to: CGPoint(x: size.width * 0.08, y: size.height * 0.5))
            bodyPath.addCurve(
                to: CGPoint(x: size.width * 0.92, y: size.height * 0.5),
                controlPoint1: CGPoint(x: size.width * 0.3, y: size.height * 0.08),
                controlPoint2: CGPoint(x: size.width * 0.7, y: size.height * 0.08)
            )
            bodyPath.addCurve(
                to: CGPoint(x: size.width * 0.08, y: size.height * 0.5),
                controlPoint1: CGPoint(x: size.width * 0.7, y: size.height * 0.92),
                controlPoint2: CGPoint(x: size.width * 0.3, y: size.height * 0.92)
            )
            cg.addPath(bodyPath.cgPath)
            cg.clip()

            let patternCount = 3 + variant % 3
            for i in 0..<patternCount {
                let cx = size.width * (0.2 + CGFloat(i) * 0.22)
                let cy = size.height * (0.3 + CGFloat(i % 2) * 0.4)
                let rx = CGFloat.random(in: 28...52)
                let ry = CGFloat.random(in: 20...38)
                let color = i % 2 == 0 ? palette.pattern : palette.accent
                cg.setFillColor(color.cgColor)
                cg.fillEllipse(in: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
            }

            cg.setStrokeColor(palette.accent.cgColor)
            cg.setLineWidth(1.5)
            for i in 0..<6 {
                let y = size.height * (0.25 + CGFloat(i) * 0.1)
                let path = UIBezierPath()
                path.move(to: CGPoint(x: size.width * 0.15, y: y))
                path.addCurve(
                    to: CGPoint(x: size.width * 0.85, y: y + CGFloat.random(in: -12...12)),
                    controlPoint1: CGPoint(x: size.width * 0.35, y: y + CGFloat.random(in: -18...18)),
                    controlPoint2: CGPoint(x: size.width * 0.65, y: y + CGFloat.random(in: -18...18))
                )
                cg.addPath(path.cgPath)
                cg.strokePath()
            }
        }
    }

    private func shadow() -> SCNNode {
        let plane = SCNPlane(width: 38.0, height: 18.0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black.withAlphaComponent(0.18)
        material.isDoubleSided = true
        material.blendMode = .alpha
        plane.firstMaterial = material
        shadowNode.geometry = plane
        shadowNode.name = "fishShadow-\(id)"
        shadowNode.eulerAngles.x = -.pi / 2
        shadowNode.position = SCNVector3(0, -1.2, 0)
        return shadowNode
    }

    private func addEyes() {
        for y in [-4.4, 4.4] as [Float] {
            let eye = sphere(name: "fishEye-\(id)", radius: 1.2, scale: SCNVector3(1, 1, 1), color: UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0), position: SCNVector3(15.0, y, 0.2))
            bodyRoot.addChildNode(eye)
            let pupil = sphere(name: "fishPupil-\(id)", radius: 0.6, scale: SCNVector3(1, 1, 1), color: UIColor(red: 0.92, green: 0.88, blue: 0.78, alpha: 1.0), position: SCNVector3(15.6, y, 0.4))
            bodyRoot.addChildNode(pupil)
        }
    }

    private func addFins(palette: (base: UIColor, pattern: UIColor, accent: UIColor)) {
        tailRoot.position = SCNVector3(-18.0, 0.0, 0.0)
        bodyRoot.addChildNode(tailRoot)

        let tailColor = palette.pattern.withAlphaComponent(0.42)
        tailRoot.addChildNode(fin(name: "fishTail-\(id)", width: 18.0, height: 14.0, position: SCNVector3(-6.0, 4.0, 0), rotationZ: 0.30, color: tailColor))
        tailRoot.addChildNode(fin(name: "fishTail-\(id)", width: 18.0, height: 14.0, position: SCNVector3(-6.0, -4.0, 0), rotationZ: -0.30, color: tailColor))

        let finColor = palette.accent.withAlphaComponent(0.28)
        leftFin = fin(name: "fishFin-\(id)", width: 12.0, height: 8.0, position: SCNVector3(3.0, 8.0, -0.4), rotationZ: -0.52, color: finColor)
        rightFin = fin(name: "fishFin-\(id)", width: 12.0, height: 8.0, position: SCNVector3(3.0, -8.0, -0.4), rotationZ: 0.52, color: finColor)
        dorsalFin = fin(name: "fishFin-\(id)", width: 14.0, height: 5.0, position: SCNVector3(-1.0, 0.0, 0.6), rotationZ: .pi / 2, color: finColor)
        dorsalFin.eulerAngles.x = -0.35
        bodyRoot.addChildNode(leftFin)
        bodyRoot.addChildNode(rightFin)
        bodyRoot.addChildNode(dorsalFin)
    }

    private func sphere(name: String, radius: CGFloat, scale: SCNVector3, color: UIColor, position: SCNVector3) -> SCNNode {
        let geometry = SCNSphere(radius: radius)
        geometry.segmentCount = 48
        geometry.firstMaterial = material(color: color, roughness: 0.52, metalness: 0.0, normalScale: 0.06)
        let node = SCNNode(geometry: geometry)
        node.name = name
        node.categoryBitMask = 2
        node.scale = scale
        node.position = position
        return node
    }

    private func fin(name: String, width: CGFloat, height: CGFloat, position: SCNVector3, rotationZ: Float, color: UIColor) -> SCNNode {
        let vertices = [
            SCNVector3(0, 0, 0),
            SCNVector3(Float(-width), Float(height * 0.55), 1.2),
            SCNVector3(Float(-width * 0.88), Float(-height * 0.45), -0.8),
            SCNVector3(Float(-width * 0.32), 0, 0.3)
        ]
        let source = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: [Int32(0), 1, 3, 0, 3, 2], primitiveType: .triangles)
        let geometry = SCNGeometry(sources: [source], elements: [element])
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = color
        material.roughness.contents = 0.62
        material.metalness.contents = 0.0
        material.emission.contents = color.withAlphaComponent(0.04)
        material.blendMode = .alpha
        material.isDoubleSided = true
        material.transparency = 0.78
        geometry.firstMaterial = material
        let node = SCNNode(geometry: geometry)
        node.name = name
        node.categoryBitMask = 2
        node.position = position
        node.eulerAngles.z = rotationZ
        return node
    }

    private func material(color: UIColor, roughness: CGFloat, metalness: CGFloat, normalScale: CGFloat) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = color
        material.roughness.contents = roughness
        material.metalness.contents = metalness
        material.specular.contents = UIColor(red: 0.86, green: 0.90, blue: 0.82, alpha: 1.0)
        material.emission.contents = color.withAlphaComponent(0.035)
        if normalScale > 0.0 {
            material.normal.contents = UIImage(systemName: "circle.hexagongrid.fill")
            material.normal.intensity = normalScale
        }
        return material
    }
}

private extension SCNVector3 {
    init(repeating value: Float) {
        self.init(value, value, value)
    }
}

extension FishEntity {
    func setBaseScale(_ scale: Float) {
        baseScale = SCNVector3(scale, scale, scale)
        rootNode.scale = baseScale
    }
}
