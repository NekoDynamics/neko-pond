import CoreGraphics
import Foundation

struct FishMovementComponent {
    var position: CGPoint
    var velocity: CGVector
    var heading: CGFloat
    var wanderDirection: CGVector
    var targetSpeed: CGFloat
    var wanderDecisionTimeRemaining: TimeInterval
    var idleTimeRemaining: TimeInterval
    var hesitationTimeRemaining: TimeInterval
    var focusTimeRemaining: TimeInterval
    var attentionTimeRemaining: TimeInterval
    var attentionDirection: CGVector
    var attentionStrength: CGFloat
    var habitTimeRemaining: TimeInterval
    var habitDirection: CGVector
    var habitCommitment: CGFloat
    var rhythmDecisionTimeRemaining: TimeInterval
    var calmTimeRemaining: TimeInterval
    var alertTimeRemaining: TimeInterval
    var cooldownTimeRemaining: TimeInterval
    var attentionLevel: CGFloat
    var targetAttentionLevel: CGFloat
    var curiosityLevel: CGFloat
    var targetCuriosityLevel: CGFloat
    var energyLevel: CGFloat
    var targetEnergyLevel: CGFloat
    var lifeTime: TimeInterval
    var turnVelocity: CGFloat
    var bodySway: CGFloat
    var tailSway: CGFloat
    var fatigueSoftness: CGFloat
    var lowActivityTime: TimeInterval
    var depth: CGFloat
#if DEBUG
    var observationSample: FishObservationSample
#endif
    let breathingPhase: CGFloat
    let swayPhase: CGFloat
    let turnBias: CGFloat
    let asymmetryPhase: CGFloat
    let fatiguePhase: CGFloat
    let underCorrectionPhase: CGFloat
    var randomSource: FishRandomSource

    init(position: CGPoint, seed: UInt64, tuning: FishMotionTuning = .meditative) {
        self.position = position
        self.velocity = tuning.initialVelocity
        self.heading = atan2(velocity.dy, velocity.dx)
        self.wanderDirection = velocity.normalizedOrFallback(CGVector(dx: 1.0, dy: 0.0))
        self.targetSpeed = tuning.initialCruiseSpeed
        self.wanderDecisionTimeRemaining = tuning.initialCuriosityDelay
        self.idleTimeRemaining = 0.0
        self.hesitationTimeRemaining = 0.0
        self.focusTimeRemaining = 0.0
        self.attentionTimeRemaining = 0.0
        self.attentionDirection = self.wanderDirection
        self.attentionStrength = 0.0
        self.habitTimeRemaining = 0.0
        self.habitDirection = self.wanderDirection
        self.habitCommitment = 0.0
        self.rhythmDecisionTimeRemaining = tuning.rhythmDecisionIntervalRange.lowerBound
        self.calmTimeRemaining = tuning.calmWindowDurationRange.lowerBound * 0.65
        self.alertTimeRemaining = 0.0
        self.cooldownTimeRemaining = 0.0
        self.attentionLevel = tuning.calmAttentionLevel
        self.targetAttentionLevel = tuning.calmAttentionLevel
        self.curiosityLevel = tuning.calmCuriosityLevel
        self.targetCuriosityLevel = tuning.calmCuriosityLevel
        self.energyLevel = tuning.calmEnergyLevel
        self.targetEnergyLevel = tuning.calmEnergyLevel
        self.lifeTime = 0.0
        self.turnVelocity = 0.0
        self.bodySway = 0.0
        self.tailSway = 0.0
        self.fatigueSoftness = 0.0
        self.lowActivityTime = 0.0
        self.depth = -1.0
#if DEBUG
        self.observationSample = FishObservationSample()
#endif
        self.breathingPhase = CGFloat((seed >> 8) & 0xFF) / 255.0 * .pi * 2.0
        self.swayPhase = CGFloat((seed >> 20) & 0xFF) / 255.0 * .pi * 2.0
        self.turnBias = (CGFloat((seed >> 32) & 0xFF) / 255.0 - 0.5) * 0.08
        self.asymmetryPhase = CGFloat((seed >> 40) & 0xFF) / 255.0 * .pi * 2.0
        self.fatiguePhase = CGFloat((seed >> 48) & 0xFF) / 255.0 * .pi * 2.0
        self.underCorrectionPhase = CGFloat((seed >> 56) & 0xFF) / 255.0 * .pi * 2.0
        self.randomSource = FishRandomSource(seed: seed)
    }
}

#if DEBUG
struct FishObservationSample {
    var frameCount: Int = 0
    var edgeProximitySum: CGFloat = 0.0
    var peakEdgeProximity: CGFloat = 0.0
    var clampFallbackCount: Int = 0
    var turnCrossingCount: Int = 0
    var previousTurnSign: CGFloat = 0.0
    var speedSum: CGFloat = 0.0
    var speedSquaredSum: CGFloat = 0.0
    var tailSimilaritySum: CGFloat = 0.0
    var previousTailSway: CGFloat = 0.0
    var longestLowActivityWindow: TimeInterval = 0.0

    mutating func record(edgeProximity: CGFloat, speed: CGFloat, turnVelocity: CGFloat, tailSway: CGFloat, lowActivityTime: TimeInterval) {
        frameCount += 1
        edgeProximitySum += edgeProximity
        peakEdgeProximity = max(peakEdgeProximity, edgeProximity)
        speedSum += speed
        speedSquaredSum += speed * speed
        let turnSign: CGFloat = turnVelocity > 0.015 ? 1.0 : (turnVelocity < -0.015 ? -1.0 : 0.0)
        if turnSign != 0.0, previousTurnSign != 0.0, turnSign != previousTurnSign {
            turnCrossingCount += 1
        }
        if turnSign != 0.0 {
            previousTurnSign = turnSign
        }
        tailSimilaritySum += 1.0 - min(1.0, abs(tailSway - previousTailSway) * 3.0)
        previousTailSway = tailSway
        longestLowActivityWindow = max(longestLowActivityWindow, lowActivityTime)
    }

    mutating func recordClampFallback() {
        clampFallbackCount += 1
    }
}
#endif

struct FishRandomSource {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
    }

    mutating func unitValue() -> CGFloat {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        let value = Double(state >> 11) / Double(UInt64.max >> 11)
        return CGFloat(value)
    }

    mutating func value(in range: ClosedRange<CGFloat>) -> CGFloat {
        range.lowerBound + unitValue() * (range.upperBound - range.lowerBound)
    }

    mutating func timeValue(in range: ClosedRange<TimeInterval>) -> TimeInterval {
        let value = TimeInterval(unitValue())
        return range.lowerBound + value * (range.upperBound - range.lowerBound)
    }

    mutating func chance(_ probability: CGFloat) -> Bool {
        unitValue() < probability
    }
}

extension CGPoint {
    func offset(by vector: CGVector) -> CGPoint {
        CGPoint(x: x + vector.dx, y: y + vector.dy)
    }

    var isFinite: Bool {
        x.isFinite && y.isFinite
    }

    func clamped(to rect: CGRect) -> CGPoint {
        CGPoint(
            x: min(max(x.finiteOrZero, rect.minX), rect.maxX),
            y: min(max(y.finiteOrZero, rect.minY), rect.maxY)
        )
    }
}

extension CGVector {
    static let zero = CGVector(dx: 0.0, dy: 0.0)

    var isFinite: Bool {
        dx.isFinite && dy.isFinite
    }

    var lengthSquared: CGFloat {
        guard isFinite else { return .infinity }
        return dx * dx + dy * dy
    }

    var length: CGFloat {
        sqrt(lengthSquared)
    }

    func normalizedOrFallback(_ fallback: CGVector) -> CGVector {
        guard isFinite else { return fallback.finiteOrZero }
        let currentLength = length
        guard currentLength.isFinite, currentLength > 0.0001 else { return fallback.finiteOrZero }
        return CGVector(dx: dx / currentLength, dy: dy / currentLength)
    }

    func scaled(by scalar: CGFloat) -> CGVector {
        guard isFinite, scalar.isFinite else { return .zero }
        return CGVector(dx: dx * scalar, dy: dy * scalar).finiteOrZero
    }

    func adding(_ other: CGVector) -> CGVector {
        guard isFinite, other.isFinite else { return finiteOrZero.addingFinite(other.finiteOrZero) }
        return addingFinite(other).finiteOrZero
    }

    func limited(to maximumLength: CGFloat) -> CGVector {
        guard isFinite, maximumLength.isFinite, maximumLength > 0.0 else { return .zero }
        let currentLength = length
        guard currentLength.isFinite else { return .zero }
        guard currentLength > maximumLength, currentLength > 0.0001 else { return self }
        return scaled(by: maximumLength / currentLength)
    }

    func rotated(by angle: CGFloat) -> CGVector {
        guard isFinite, angle.isFinite else { return finiteOrZero }
        let sine = sin(angle)
        let cosine = cos(angle)
        return CGVector(dx: dx * cosine - dy * sine, dy: dx * sine + dy * cosine)
    }

    var finiteOrZero: CGVector {
        CGVector(dx: dx.finiteOrZero, dy: dy.finiteOrZero)
    }

    private func addingFinite(_ other: CGVector) -> CGVector {
        CGVector(dx: dx + other.dx, dy: dy + other.dy)
    }
}

extension CGFloat {
    var finiteOrZero: CGFloat {
        isFinite ? self : 0.0
    }

    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(finiteOrZero, range.lowerBound), range.upperBound)
    }
}
