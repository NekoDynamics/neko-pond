import CoreGraphics
import UIKit

enum PondSpriteAssets {

    // MARK: - Pond Floor

    static func floorTexture(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            let colors = [
                UIColor(red: 0.025, green: 0.07, blue: 0.065, alpha: 1.0).cgColor,
                UIColor(red: 0.04, green: 0.11, blue: 0.09, alpha: 1.0).cgColor,
                UIColor(red: 0.06, green: 0.14, blue: 0.11, alpha: 1.0).cgColor
            ] as CFArray
            let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.55, 1])!
            cg.drawLinearGradient(grad, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
            for i in 0..<160 {
                let noise = CGFloat(i) / 160.0
                let alpha = 0.012 + sin(noise * .pi * 2) * 0.008
                cg.setFillColor(UIColor(red: 0.10, green: 0.14, blue: 0.10, alpha: alpha).cgColor)
                let rect = CGRect(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height),
                    width: CGFloat.random(in: 30...140),
                    height: CGFloat.random(in: 14...80)
                )
                cg.fillEllipse(in: rect)
            }
        }
    }

    // MARK: - Deep Water Gradient

    static func deepWaterTexture(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            let colors = [
                UIColor(red: 0.008, green: 0.04, blue: 0.06, alpha: 0.92).cgColor,
                UIColor(red: 0.018, green: 0.09, blue: 0.11, alpha: 0.86).cgColor,
                UIColor(red: 0.04, green: 0.16, blue: 0.15, alpha: 0.70).cgColor
            ] as CFArray
            let center = CGPoint(x: size.width * 0.52, y: size.height * 0.42)
            let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.58, 1])!
            cg.drawRadialGradient(grad, startCenter: center, startRadius: 20, endCenter: center, endRadius: size.width * 0.64, options: [])
        }
    }

    // MARK: - Caustics Overlay

    static func causticsTexture(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            cg.setFillColor(UIColor.clear.cgColor)
            cg.fill(CGRect(origin: .zero, size: size))
            for i in 0..<48 {
                let alpha = 0.015 + CGFloat(i % 5) * 0.004
                let hue = CGFloat(i) / 48.0
                cg.setStrokeColor(UIColor(red: 0.45 + hue * 0.15, green: 0.72, blue: 0.62, alpha: alpha).cgColor)
                cg.setLineWidth(CGFloat.random(in: 1.2...3.0))
                let path = UIBezierPath()
                let sx = CGFloat.random(in: -80...size.width + 80)
                let sy = CGFloat.random(in: 0...size.height)
                path.move(to: CGPoint(x: sx, y: sy))
                path.addCurve(
                    to: CGPoint(x: sx + CGFloat.random(in: 140...360), y: sy + CGFloat.random(in: -100...100)),
                    controlPoint1: CGPoint(x: sx + CGFloat.random(in: 30...100), y: sy + CGFloat.random(in: -60...60)),
                    controlPoint2: CGPoint(x: sx + CGFloat.random(in: 100...220), y: sy + CGFloat.random(in: -60...60))
                )
                cg.addPath(path.cgPath)
                cg.strokePath()
            }
            for i in 0..<24 {
                let cx = CGFloat.random(in: 0...size.width)
                let cy = CGFloat.random(in: 0...size.height)
                let r = CGFloat.random(in: 20...80)
                cg.setFillColor(UIColor(red: 0.30, green: 0.55, blue: 0.48, alpha: 0.018).cgColor)
                cg.fillEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
            }
        }
    }

    // MARK: - Fog Veil

    static func fogTexture(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            let colors = [
                UIColor(red: 0.02, green: 0.06, blue: 0.07, alpha: 0.0).cgColor,
                UIColor(red: 0.02, green: 0.06, blue: 0.07, alpha: 0.22).cgColor,
                UIColor(red: 0.015, green: 0.05, blue: 0.06, alpha: 0.28).cgColor,
                UIColor(red: 0.02, green: 0.06, blue: 0.07, alpha: 0.0).cgColor
            ] as CFArray
            let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.3, 0.7, 1])!
            cg.drawLinearGradient(grad, start: CGPoint(x: 0, y: size.height * 0.3), end: CGPoint(x: 0, y: size.height * 0.75), options: [])
        }
    }

    // MARK: - Vignette

    static func vignetteTexture(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
            let colors = [
                UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0).cgColor,
                UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0).cgColor,
                UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.45).cgColor,
                UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.62).cgColor
            ] as CFArray
            let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.35, 0.7, 1])!
            cg.drawRadialGradient(grad, startCenter: center, startRadius: 0, endCenter: center, endRadius: max(size.width, size.height) * 0.72, options: [])
        }
    }

    // MARK: - Koi Body Texture (top-view silhouette, transparent)

    static func koiBodyTexture(config: KoiSpriteConfig) -> UIImage {
        let size = config.bodySize
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext

            // Body silhouette (top-down elongated ellipse)
            let bodyPath = UIBezierPath()
            let cx = size.width * 0.5
            let cy = size.height * 0.5
            bodyPath.move(to: CGPoint(x: size.width * 0.06, y: cy))
            bodyPath.addCurve(
                to: CGPoint(x: size.width * 0.94, y: cy),
                controlPoint1: CGPoint(x: size.width * 0.28, y: size.height * 0.06),
                controlPoint2: CGPoint(x: size.width * 0.72, y: size.height * 0.06)
            )
            bodyPath.addCurve(
                to: CGPoint(x: size.width * 0.06, y: cy),
                controlPoint1: CGPoint(x: size.width * 0.72, y: size.height * 0.94),
                controlPoint2: CGPoint(x: size.width * 0.28, y: size.height * 0.94)
            )
            bodyPath.close()

            // Clip to body
            cg.addPath(bodyPath.cgPath)
            cg.clip()

            // Base fill
            cg.setFillColor(config.variant.baseColor.cgColor)
            cg.fill(CGRect(origin: .zero, size: size))

            // Pattern spots
            let patternCount = 3 + Int(config.seed % 3)
            var rng = FishRandomSource(seed: config.seed)
            for i in 0..<patternCount {
                let px = size.width * (0.18 + CGFloat(i) * 0.20 + rng.unitValue() * 0.08)
                let py = size.height * (0.25 + rng.unitValue() * 0.50)
                let rx = CGFloat.random(in: 10...22, using: &rng)
                let ry = CGFloat.random(in: 8...16, using: &rng)
                let color = i % 2 == 0 ? config.variant.patternColor : config.variant.accentColor
                cg.setFillColor(color.cgColor)
                cg.fillEllipse(in: CGRect(x: px - rx, y: py - ry, width: rx * 2, height: ry * 2))
            }

            // Tail fork
            let tailColor = config.variant.patternColor.withAlphaComponent(0.38)
            cg.setFillColor(tailColor.cgColor)
            let tailX = size.width * 0.02
            let tailPath = UIBezierPath()
            tailPath.move(to: CGPoint(x: tailX + 8, y: cy))
            tailPath.addLine(to: CGPoint(x: tailX, y: cy - 14))
            tailPath.addLine(to: CGPoint(x: tailX - 4, y: cy - 10))
            tailPath.addLine(to: CGPoint(x: tailX + 2, y: cy))
            tailPath.addLine(to: CGPoint(x: tailX - 4, y: cy + 10))
            tailPath.addLine(to: CGPoint(x: tailX, y: cy + 14))
            tailPath.close()
            cg.addPath(tailPath.cgPath)
            cg.fillPath()

            // Dorsal fin hint
            let finColor = config.variant.accentColor.withAlphaComponent(0.22)
            cg.setFillColor(finColor.cgColor)
            let dorsalPath = UIBezierPath()
            dorsalPath.move(to: CGPoint(x: size.width * 0.45, y: cy - 2))
            dorsalPath.addCurve(
                to: CGPoint(x: size.width * 0.55, y: cy - 2),
                controlPoint1: CGPoint(x: size.width * 0.48, y: -2),
                controlPoint2: CGPoint(x: size.width * 0.52, y: -2)
            )
            dorsalPath.close()
            cg.addPath(dorsalPath.cgPath)
            cg.fillPath()

            // Pectoral fins
            let pectoralColor = config.variant.accentColor.withAlphaComponent(0.18)
            cg.setFillColor(pectoralColor.cgColor)
            for side: CGFloat in [-1, 1] {
                let finPath = UIBezierPath()
                let fx = size.width * 0.62
                let fy = cy + side * (size.height * 0.22)
                finPath.move(to: CGPoint(x: fx, y: fy))
                finPath.addCurve(
                    to: CGPoint(x: fx + 10, y: fy + side * 12),
                    controlPoint1: CGPoint(x: fx + 4, y: fy + side * 2),
                    controlPoint2: CGPoint(x: fx + 8, y: fy + side * 8)
                )
                finPath.addCurve(
                    to: CGPoint(x: fx, y: fy + side * 4),
                    controlPoint1: CGPoint(x: fx + 6, y: fy + side * 10),
                    controlPoint2: CGPoint(x: fx + 2, y: fy + side * 6)
                )
                finPath.close()
                cg.addPath(finPath.cgPath)
                cg.fillPath()
            }

            // Eyes
            let eyeColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
            cg.setFillColor(eyeColor.cgColor)
            for side: CGFloat in [-1, 1] {
                let ex = size.width * 0.78
                let ey = cy + side * (size.height * 0.16)
                cg.fillEllipse(in: CGRect(x: ex - 2.5, y: ey - 2.5, width: 5, height: 5))
            }

            // Eye highlights
            cg.setFillColor(UIColor.white.withAlphaComponent(0.7).cgColor)
            for side: CGFloat in [-1, 1] {
                let ex = size.width * 0.78 + 1
                let ey = cy + side * (size.height * 0.16) - 1
                cg.fillEllipse(in: CGRect(x: ex - 1, y: ey - 1, width: 2, height: 2))
            }
        }
    }

    // MARK: - Koi Shadow

    static func koiShadowTexture(bodySize: CGSize) -> UIImage {
        let size = CGSize(width: bodySize.width * 1.05, height: bodySize.height * 1.1)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            cg.setFillColor(UIColor.black.withAlphaComponent(0.18).cgColor)
            let cx = size.width * 0.5
            let cy = size.height * 0.5
            let bodyPath = UIBezierPath()
            bodyPath.move(to: CGPoint(x: size.width * 0.08, y: cy))
            bodyPath.addCurve(
                to: CGPoint(x: size.width * 0.92, y: cy),
                controlPoint1: CGPoint(x: size.width * 0.30, y: size.height * 0.08),
                controlPoint2: CGPoint(x: size.width * 0.70, y: size.height * 0.08)
            )
            bodyPath.addCurve(
                to: CGPoint(x: size.width * 0.08, y: cy),
                controlPoint1: CGPoint(x: size.width * 0.70, y: size.height * 0.92),
                controlPoint2: CGPoint(x: size.width * 0.30, y: size.height * 0.92)
            )
            bodyPath.close()
            cg.addPath(bodyPath.cgPath)
            cg.fillPath()
        }
    }

    // MARK: - Lotus Leaf

    static func lotusLeafTexture(size: CGSize, isFlower: Bool) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            // Leaf base
            cg.setFillColor(UIColor(red: 0.12, green: 0.24, blue: 0.12, alpha: 0.82).cgColor)
            let leafPath = UIBezierPath(ovalIn: CGRect(x: 2, y: 4, width: size.width - 4, height: size.height - 8))
            cg.addPath(leafPath.cgPath)
            cg.fillPath()
            // Vein
            cg.setStrokeColor(UIColor(red: 0.08, green: 0.18, blue: 0.08, alpha: 0.4).cgColor)
            cg.setLineWidth(1.0)
            cg.move(to: CGPoint(x: size.width * 0.5, y: 6))
            cg.addLine(to: CGPoint(x: size.width * 0.5, y: size.height - 6))
            cg.strokePath()

            if isFlower {
                // Pink petals in center
                let petalCount = 8
                let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
                for i in 0..<petalCount {
                    let angle = CGFloat(i) / CGFloat(petalCount) * .pi * 2
                    let px = center.x + cos(angle) * 8
                    let py = center.y + sin(angle) * 6
                    cg.setFillColor(UIColor(red: 0.85, green: 0.48, blue: 0.50, alpha: 0.85).cgColor)
                    cg.fillEllipse(in: CGRect(x: px - 5, y: py - 4, width: 10, height: 8))
                }
                // Center
                cg.setFillColor(UIColor(red: 0.92, green: 0.78, blue: 0.22, alpha: 0.9).cgColor)
                cg.fillEllipse(in: CGRect(x: center.x - 4, y: center.y - 3, width: 8, height: 6))
            }
        }
    }

    // MARK: - Stone

    static func stoneTexture(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            let colors = [
                UIColor(red: 0.14, green: 0.16, blue: 0.14, alpha: 1.0).cgColor,
                UIColor(red: 0.10, green: 0.12, blue: 0.10, alpha: 1.0).cgColor
            ] as CFArray
            let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
            cg.drawRadialGradient(grad, startCenter: CGPoint(x: size.width * 0.45, y: size.height * 0.4), startRadius: 2, endCenter: CGPoint(x: size.width * 0.5, y: size.height * 0.5), endRadius: size.width * 0.48, options: [])
        }
    }

    // MARK: - Petal

    static func petalTexture(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            cg.setFillColor(UIColor(red: 0.80, green: 0.48, blue: 0.52, alpha: 0.50).cgColor)
            let petalPath = UIBezierPath(ovalIn: CGRect(x: 1, y: 1, width: size.width - 2, height: size.height - 2))
            cg.addPath(petalPath.cgPath)
            cg.fillPath()
        }
    }

    // MARK: - Ripple

    static func rippleTexture(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
            let radius = min(size.width, size.height) * 0.45
            cg.setStrokeColor(UIColor(red: 0.62, green: 0.85, blue: 0.78, alpha: 0.55).cgColor)
            cg.setLineWidth(1.5)
            cg.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            cg.strokePath()
            cg.setStrokeColor(UIColor(red: 0.62, green: 0.85, blue: 0.78, alpha: 0.25).cgColor)
            cg.setLineWidth(1.0)
            cg.addArc(center: center, radius: radius * 0.7, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            cg.strokePath()
        }
    }

    // MARK: - Mote Particle

    static func moteTexture(size: CGSize = CGSize(width: 6, height: 6)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
            let colors = [
                UIColor(red: 0.55, green: 0.82, blue: 0.75, alpha: 0.35).cgColor,
                UIColor(red: 0.55, green: 0.82, blue: 0.75, alpha: 0.0).cgColor
            ] as CFArray
            let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
            cg.drawRadialGradient(grad, startCenter: center, startRadius: 0, endCenter: center, endRadius: size.width * 0.5, options: [])
        }
    }
}

private extension CGFloat {
    static func random(in range: ClosedRange<CGFloat>, using rng: inout FishRandomSource) -> CGFloat {
        range.lowerBound + rng.unitValue() * (range.upperBound - range.lowerBound)
    }
}
