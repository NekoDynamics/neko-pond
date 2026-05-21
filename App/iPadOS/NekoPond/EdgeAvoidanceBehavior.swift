import CoreGraphics
import Foundation

struct EdgePressureField {
    let tuning: EdgePressureTuning

    func sample(position: CGPoint, velocity: CGVector, bounds: CGRect, time: CGFloat, phase: CGFloat) -> EdgePressureSample {
        guard position.isFinite, velocity.isFinite, bounds.isFinite else {
            return EdgePressureSample(steering: .zero, speedScale: 1.0, commitmentScale: 1.0, proximity: 0.0)
        }

        let projectionTime = CGFloat(tuning.lookAhead).clamped(to: 0.0...2.0)
        let projected = position.offset(by: velocity.scaled(by: projectionTime))
        let left = pressure(distance: projected.x - bounds.minX, softness: tuning.horizontalSoftness)
        let right = pressure(distance: bounds.maxX - projected.x, softness: tuning.horizontalSoftness * tuning.rightSoftnessBias)
        let bottom = pressure(distance: projected.y - bounds.minY, softness: tuning.verticalSoftness * tuning.bottomSoftnessBias)
        let top = pressure(distance: bounds.maxY - projected.y, softness: tuning.verticalSoftness)
        let horizontal = left - right
        let vertical = bottom - top
        let gradient = CGVector(dx: horizontal * tuning.horizontalPressureBias, dy: vertical * tuning.verticalPressureBias)
        let proximity = max(max(left, right), max(bottom, top)).clamped(to: 0.0...1.0)
        let current = slowCurrent(time: time, phase: phase)
        let tangent = CGVector(dx: -gradient.dy, dy: gradient.dx)
            .scaled(by: tangentPolarity(time: time, phase: phase))
            .adding(current.scaled(by: proximity * 0.28))
        let steering = gradient
            .scaled(by: tuning.pressureStrength)
            .adding(tangent.scaled(by: tuning.tangentStrength * proximity))
            .limited(to: tuning.maximumSteering)
        let speedScale = (1.0 - proximity * tuning.speedAttenuation).clamped(to: tuning.minimumSpeedScale...1.0)
        let commitmentScale = (1.0 - proximity * tuning.commitmentLoss).clamped(to: tuning.minimumCommitmentScale...1.0)

        return EdgePressureSample(
            steering: steering,
            speedScale: speedScale,
            commitmentScale: commitmentScale,
            proximity: proximity
        )
    }

    private func pressure(distance: CGFloat, softness: CGFloat) -> CGFloat {
        guard distance.isFinite, softness.isFinite, softness > 0.0 else { return 0.0 }
        let normalized = (1.0 - distance / softness).clamped(to: 0.0...1.0)
        let eased = normalized * normalized * normalized
        return eased * (1.0 - 0.35 * normalized) + normalized * 0.18
    }

    private func tangentPolarity(time: CGFloat, phase: CGFloat) -> CGFloat {
        sin(time * tuning.tangentDriftRate + phase) >= 0.0 ? 1.0 : -1.0
    }

    private func slowCurrent(time: CGFloat, phase: CGFloat) -> CGVector {
        CGVector(
            dx: sin(time * tuning.currentRate.dx + phase) * tuning.currentStrength.dx,
            dy: cos(time * tuning.currentRate.dy + phase * 0.7) * tuning.currentStrength.dy
        )
    }
}

struct EdgePressureSample {
    let steering: CGVector
    let speedScale: CGFloat
    let commitmentScale: CGFloat
    let proximity: CGFloat
}

private extension CGRect {
    var isFinite: Bool {
        origin.isFinite && size.width.isFinite && size.height.isFinite && width > 0.0 && height > 0.0
    }
}
