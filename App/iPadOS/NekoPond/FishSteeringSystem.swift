import CoreGraphics
import Foundation

struct FishSteeringSystem {
    private let motionTuning = FishMotionTuning.meditative
    private let rotationTuning = FishRotationTuning.softLag
    private let tailTuning = FishTailTuning.gentlePulse
    private let edgePressure = EdgePressureField(tuning: .ambient)
    private let maximumStableDeltaTime: CGFloat = 1.0 / 30.0
    private let maximumPositionDelta: CGFloat = 6.0
    private let maximumAnimationTime: TimeInterval = 60.0 * 10.0

    func update(component: inout FishMovementComponent, bounds: CGRect, neighbors: [FishMovementComponent], deltaTime: TimeInterval) {
        guard deltaTime.isFinite, deltaTime > 0.0 else { return }

        let step = CGFloat(deltaTime).clamped(to: 0.0...maximumStableDeltaTime)
        sanitize(component: &component, bounds: bounds)

        component.lifeTime = (component.lifeTime + TimeInterval(step)).truncatingRemainder(dividingBy: maximumAnimationTime)
        updateBehaviorRhythm(component: &component, deltaTime: deltaTime)
        chooseWanderIntentIfNeeded(component: &component, bounds: bounds, deltaTime: deltaTime)

        let hesitationScale = component.hesitationTimeRemaining > 0.0 ? motionTuning.hesitationSlowdown : 1.0
        let attentionScale = component.attentionTimeRemaining > 0.0 ? motionTuning.attentionSlowdown : 1.0
        let pressure = edgePressure.sample(
            position: component.position,
            velocity: component.velocity,
            bounds: bounds,
            time: CGFloat(component.lifeTime),
            phase: component.breathingPhase
        )
        let motionIntensity = rhythmMotionIntensity(for: component)
        let breath = sin(CGFloat(component.lifeTime) * motionTuning.velocityBreathingRate * component.energyLevel + component.breathingPhase) * motionTuning.velocityBreathingAmount * motionIntensity
        let smallDrift = sin(CGFloat(component.lifeTime) * motionTuning.idleDriftRate + component.swayPhase) * motionTuning.idleDriftAmount * component.curiosityLevel
        let intentDirection = focusedDirection(for: component)
        let underCorrection = sin(CGFloat(component.lifeTime) * 0.061 + component.underCorrectionPhase) * motionTuning.directionUnderCorrection
        let desiredDirection = intentDirection.rotated(by: smallDrift + underCorrection).normalizedOrFallback(intentDirection)
        let desiredSpeed = (component.targetSpeed * component.energyLevel + breath) * hesitationScale * attentionScale * pressure.speedScale
        let desiredVelocity = desiredDirection.scaled(by: desiredSpeed)
        let driftSteering = desiredVelocity
            .adding(component.velocity.scaled(by: -1.0))
            .scaled(by: motionTuning.velocityResponsiveness * motionIntensity * pressure.commitmentScale)

        let microLift = CGVector(
            dx: cos(CGFloat(component.lifeTime) * motionTuning.microCurrentRate.dx + component.swayPhase) * motionTuning.microCurrentStrength.dx,
            dy: sin(CGFloat(component.lifeTime) * motionTuning.microCurrentRate.dy + component.breathingPhase) * motionTuning.microCurrentStrength.dy
        ).scaled(by: motionIntensity)
        let passiveCurrent = CGVector(
            dx: sin(CGFloat(component.lifeTime) * motionTuning.passiveCurrentRate.dx + component.breathingPhase) * motionTuning.passiveCurrentStrength.dx,
            dy: cos(CGFloat(component.lifeTime) * motionTuning.passiveCurrentRate.dy + component.swayPhase) * motionTuning.passiveCurrentStrength.dy
        ).scaled(by: max(0.22, 1.0 - motionIntensity * 0.34))
        let schooling = separationForce(for: component, neighbors: neighbors)
        let acceleration = driftSteering
            .adding(pressure.steering)
            .adding(microLift)
            .adding(passiveCurrent)
            .adding(schooling)
            .limited(to: motionTuning.calmAccelerationLimit * motionIntensity * max(0.72, pressure.commitmentScale))
        component.velocity = component.velocity.adding(acceleration.scaled(by: step))
        component.velocity = component.velocity.limited(to: motionTuning.maximumCruiseSpeed * max(0.86, component.energyLevel))

        if component.velocity.length < motionTuning.minimumLivingSpeed {
            let fallback = component.wanderDirection.normalizedOrFallback(CGVector(dx: cos(component.heading), dy: sin(component.heading)))
            component.velocity = fallback.scaled(by: motionTuning.minimumLivingSpeed)
        }

        let positionDelta = component.velocity.scaled(by: step).limited(to: maximumPositionDelta)
        component.position = component.position.offset(by: positionDelta)
        keepInsideSoftBounds(component: &component, bounds: bounds)
        updateHeading(component: &component, deltaTime: step)
        updateDepth(component: &component, deltaTime: step)
        updateVisualMotion(component: &component, deltaTime: step)
        updateObservationSample(component: &component, edgeProximity: pressure.proximity)
        sanitize(component: &component, bounds: bounds)
        assertStable(component)
    }


    private func separationForce(for component: FishMovementComponent, neighbors: [FishMovementComponent]) -> CGVector {
        var force = CGVector.zero
        for neighbor in neighbors where neighbor.position != component.position {
            let dx = component.position.x - neighbor.position.x
            let dy = component.position.y - neighbor.position.y
            let distanceSquared = dx * dx + dy * dy
            guard distanceSquared > 0.0001, distanceSquared < 5.0 else { continue }
            let distance = sqrt(distanceSquared)
            let falloff = (1.0 - distance / 2.2).clamped(to: 0.0...1.0)
            force = force.adding(CGVector(dx: dx / distance, dy: dy / distance).scaled(by: falloff * 0.22))
        }
        return force.limited(to: 0.24)
    }

    private func updateDepth(component: inout FishMovementComponent, deltaTime: CGFloat) {
        let targetDepth = -1.1 + sin(CGFloat(component.lifeTime) * 0.22 + component.swayPhase) * 0.45 + cos(CGFloat(component.lifeTime) * 0.17 + component.breathingPhase) * 0.18
        let blend = min(1.0, deltaTime * 0.7)
        component.depth += (targetDepth - component.depth) * blend
        component.depth = component.depth.clamped(to: -1.8 ... -0.4)
    }

    private func chooseWanderIntentIfNeeded(component: inout FishMovementComponent, bounds: CGRect, deltaTime: TimeInterval) {
        guard deltaTime.isFinite, deltaTime > 0.0 else { return }
        component.wanderDecisionTimeRemaining -= deltaTime
        component.idleTimeRemaining = max(0.0, component.idleTimeRemaining - deltaTime)
        component.hesitationTimeRemaining = max(0.0, component.hesitationTimeRemaining - deltaTime)
        component.focusTimeRemaining = max(0.0, component.focusTimeRemaining - deltaTime)
        component.attentionTimeRemaining = max(0.0, component.attentionTimeRemaining - deltaTime)
        component.habitTimeRemaining = max(0.0, component.habitTimeRemaining - deltaTime)
        let attentionDecay = max(0.0, 1.0 - CGFloat(deltaTime) * motionTuning.attentionDecayRate)
        component.attentionStrength *= attentionDecay

        guard component.wanderDecisionTimeRemaining <= 0.0 else { return }

        let currentDirection = component.velocity.normalizedOrFallback(component.wanderDirection)
        let baseAngle = atan2(currentDirection.dy, currentDirection.dx)
        let curiosityScale = max(0.25, component.curiosityLevel)
        var angleOffset = component.randomSource.value(in: motionTuning.curiousTurnRange) * curiosityScale + component.turnBias
        if component.randomSource.chance(motionTuning.probeChoiceProbability * component.attentionLevel) {
            angleOffset += component.randomSource.value(in: motionTuning.probeTurnRange)
        }
        let nextAngle = baseAngle + angleOffset
        let curiousDirection = CGVector(dx: cos(nextAngle), dy: sin(nextAngle)).normalizedOrFallback(currentDirection)
        let explorationCommitment = rhythmExplorationCommitment(for: component)
        var nextDirection = curiousDirection
        if component.habitTimeRemaining > 0.0 {
            nextDirection = curiousDirection
                .scaled(by: 1.0 - component.habitCommitment)
                .adding(component.habitDirection.scaled(by: component.habitCommitment))
                .normalizedOrFallback(curiousDirection)
        }
        if component.randomSource.chance(motionTuning.ambivalenceChoiceProbability / max(0.72, component.energyLevel)) {
            let ambivalence = component.randomSource.value(in: motionTuning.ambivalenceCommitmentRange)
            nextDirection = component.wanderDirection
                .scaled(by: ambivalence)
                .adding(nextDirection.scaled(by: 1.0 - ambivalence))
                .normalizedOrFallback(nextDirection)
        }
        let pressure = edgePressure.sample(
            position: component.position,
            velocity: component.velocity,
            bounds: bounds,
            time: CGFloat(component.lifeTime),
            phase: component.breathingPhase
        )
        if component.focusTimeRemaining > 0.0 {
            component.wanderDirection = component.wanderDirection
                .scaled(by: min(0.94, motionTuning.focusCommitment * explorationCommitment * pressure.commitmentScale))
                .adding(nextDirection.scaled(by: 1.0 - min(0.94, motionTuning.focusCommitment * explorationCommitment * pressure.commitmentScale)))
                .normalizedOrFallback(nextDirection)
        } else {
            let nonEventBlend = component.randomSource.value(in: 0.10...0.36) * (1.0 - pressure.proximity * 0.5)
            component.wanderDirection = component.wanderDirection
                .scaled(by: (explorationCommitment - 1.0).clamped(to: 0.0...0.40))
                .adding(nextDirection.scaled(by: nonEventBlend))
                .normalizedOrFallback(nextDirection)
        }
        if component.habitTimeRemaining <= 0.0 && component.randomSource.chance(motionTuning.habitChoiceProbability / max(0.70, component.attentionLevel)) {
            component.habitTimeRemaining = component.randomSource.timeValue(in: motionTuning.habitDurationRange)
            component.habitDirection = component.wanderDirection
            component.habitCommitment = component.randomSource.value(in: motionTuning.habitCommitmentRange)
        }

        if component.calmTimeRemaining > 0.0 || component.idleTimeRemaining > 0.0 || component.randomSource.chance(motionTuning.idleChoiceProbability / max(0.65, component.energyLevel)) {
            component.idleTimeRemaining = component.randomSource.timeValue(in: motionTuning.idleDurationRange)
            component.targetSpeed = component.randomSource.value(in: motionTuning.idleSpeedRange)
        } else {
            component.targetSpeed = component.randomSource.value(in: motionTuning.cruiseSpeedRange)
        }

        if component.randomSource.chance(motionTuning.hesitationChoiceProbability / max(0.70, component.attentionLevel)) {
            component.hesitationTimeRemaining = component.randomSource.timeValue(in: motionTuning.hesitationDurationRange)
        }

        if component.focusTimeRemaining <= 0.0 && component.randomSource.chance(motionTuning.focusChoiceProbability * component.curiosityLevel) {
            component.focusTimeRemaining = component.randomSource.timeValue(in: motionTuning.focusDurationRange)
        }

        if component.attentionTimeRemaining <= 0.0 && component.randomSource.chance(motionTuning.attentionChoiceProbability * component.attentionLevel) {
            let attentionAngle = baseAngle + component.randomSource.value(in: -0.22...0.22) + component.turnBias
            component.attentionDirection = CGVector(dx: cos(attentionAngle), dy: sin(attentionAngle)).normalizedOrFallback(currentDirection)
            component.attentionTimeRemaining = component.randomSource.timeValue(in: motionTuning.attentionDurationRange)
            component.attentionStrength = component.randomSource.value(in: 0.52...0.86)
            if component.alertTimeRemaining <= 0.0 {
                component.targetSpeed = min(component.targetSpeed, component.randomSource.value(in: motionTuning.idleSpeedRange))
            }
            component.cooldownTimeRemaining = component.randomSource.timeValue(in: motionTuning.behavioralCooldownRange)
        }

        let decisionStretch = (1.0 / max(0.55, component.curiosityLevel)).clamped(to: 1.15...2.45)
        component.wanderDecisionTimeRemaining = component.randomSource.timeValue(in: motionTuning.wanderDecisionIntervalRange) * TimeInterval(decisionStretch)
    }

    private func updateBehaviorRhythm(component: inout FishMovementComponent, deltaTime: TimeInterval) {
        guard deltaTime.isFinite, deltaTime > 0.0 else { return }
        component.rhythmDecisionTimeRemaining -= deltaTime
        component.calmTimeRemaining = max(0.0, component.calmTimeRemaining - deltaTime)
        component.alertTimeRemaining = max(0.0, component.alertTimeRemaining - deltaTime)
        component.cooldownTimeRemaining = max(0.0, component.cooldownTimeRemaining - deltaTime)

        if component.rhythmDecisionTimeRemaining <= 0.0 {
            chooseRhythmTarget(component: &component)
        } else if component.calmTimeRemaining > 0.0 {
            setRhythmTargets(
                component: &component,
                attention: motionTuning.calmAttentionLevel,
                curiosity: motionTuning.calmCuriosityLevel,
                energy: motionTuning.calmEnergyLevel
            )
        } else if component.alertTimeRemaining > 0.0 {
            setRhythmTargets(
                component: &component,
                attention: motionTuning.alertAttentionLevel,
                curiosity: motionTuning.alertCuriosityLevel,
                energy: motionTuning.alertEnergyLevel
            )
        } else if component.cooldownTimeRemaining > 0.0 {
            setRhythmTargets(
                component: &component,
                attention: 0.76,
                curiosity: 0.68,
                energy: 0.78
            )
        }

        let blend = min(1.0, CGFloat(deltaTime) * motionTuning.rhythmTransitionRate)
        component.attentionLevel += (component.targetAttentionLevel - component.attentionLevel) * blend
        component.curiosityLevel += (component.targetCuriosityLevel - component.curiosityLevel) * blend
        component.energyLevel += (component.targetEnergyLevel - component.energyLevel) * blend
    }

    private func chooseRhythmTarget(component: inout FishMovementComponent) {
        component.rhythmDecisionTimeRemaining = component.randomSource.timeValue(in: motionTuning.rhythmDecisionIntervalRange)

        if component.cooldownTimeRemaining <= 0.0 && component.randomSource.chance(motionTuning.alertMomentChoiceProbability) {
            component.alertTimeRemaining = component.randomSource.timeValue(in: motionTuning.alertMomentDurationRange)
            component.calmTimeRemaining = 0.0
            component.cooldownTimeRemaining = component.randomSource.timeValue(in: motionTuning.behavioralCooldownRange)
            setRhythmTargets(
                component: &component,
                attention: motionTuning.alertAttentionLevel,
                curiosity: motionTuning.alertCuriosityLevel,
                energy: motionTuning.alertEnergyLevel
            )
        } else if component.randomSource.chance(motionTuning.calmWindowChoiceProbability) {
            component.calmTimeRemaining = component.randomSource.timeValue(in: motionTuning.calmWindowDurationRange)
            component.alertTimeRemaining = 0.0
            setRhythmTargets(
                component: &component,
                attention: motionTuning.calmAttentionLevel,
                curiosity: motionTuning.calmCuriosityLevel,
                energy: motionTuning.calmEnergyLevel
            )
        } else {
            setRhythmTargets(
                component: &component,
                attention: component.randomSource.value(in: motionTuning.attentionRhythmRange),
                curiosity: component.randomSource.value(in: motionTuning.curiosityRhythmRange),
                energy: component.randomSource.value(in: motionTuning.energyRhythmRange)
            )
        }
    }

    private func setRhythmTargets(component: inout FishMovementComponent, attention: CGFloat, curiosity: CGFloat, energy: CGFloat) {
        component.targetAttentionLevel = attention
        component.targetCuriosityLevel = curiosity
        component.targetEnergyLevel = energy
    }

    private func focusedDirection(for component: FishMovementComponent) -> CGVector {
        guard component.attentionTimeRemaining > 0.0, component.attentionStrength > 0.01 else { return component.wanderDirection }

        let commitment = (motionTuning.attentionCommitment * component.attentionLevel * component.attentionStrength).clamped(to: 0.0...0.78)
        return component.wanderDirection
            .scaled(by: 1.0 - commitment)
            .adding(component.attentionDirection.scaled(by: commitment))
            .normalizedOrFallback(component.wanderDirection)
    }

    private func rhythmMotionIntensity(for component: FishMovementComponent) -> CGFloat {
        if component.calmTimeRemaining > 0.0 {
            return motionTuning.calmMotionIntensity
        }
        if component.alertTimeRemaining > 0.0 {
            return motionTuning.alertMotionIntensity
        }
        if component.cooldownTimeRemaining > 0.0 {
            return 0.82
        }
        return component.energyLevel
    }

    private func rhythmExplorationCommitment(for component: FishMovementComponent) -> CGFloat {
        if component.calmTimeRemaining > 0.0 {
            return motionTuning.calmExplorationCommitment
        }
        if component.alertTimeRemaining > 0.0 {
            return motionTuning.alertExplorationCommitment
        }
        return 1.0
    }

    private func keepInsideSoftBounds(component: inout FishMovementComponent, bounds: CGRect) {
        let clampedX = min(max(component.position.x.finiteOrZero, bounds.minX), bounds.maxX)
        let clampedY = min(max(component.position.y.finiteOrZero, bounds.minY), bounds.maxY)
        guard clampedX != component.position.x || clampedY != component.position.y else { return }

        component.position = CGPoint(x: clampedX, y: clampedY)
        component.velocity = component.velocity.scaled(by: motionTuning.boundarySlowdown)
        let drift = component.velocity.normalizedOrFallback(component.wanderDirection).rotated(by: component.turnBias)
        component.wanderDirection = component.wanderDirection
            .scaled(by: 1.0 - motionTuning.boundaryCuriosityBlend)
            .adding(drift.scaled(by: motionTuning.boundaryCuriosityBlend))
            .normalizedOrFallback(drift)
#if DEBUG
        component.observationSample.recordClampFallback()
#endif
    }

    private func updateHeading(component: inout FishMovementComponent, deltaTime: CGFloat) {
        guard deltaTime.isFinite, deltaTime > 0.0, component.velocity.isFinite else { return }
        let targetHeading = atan2(component.velocity.dy, component.velocity.dx)
        let underCorrection = sin(CGFloat(component.lifeTime) * 0.047 + component.underCorrectionPhase) * motionTuning.directionUnderCorrection
        let turn = shortestAngle(from: component.heading, to: targetHeading + underCorrection)
        let turnRhythm = component.calmTimeRemaining > 0.0 ? motionTuning.calmTurnSoftening : (component.alertTimeRemaining > 0.0 ? motionTuning.alertTurnTightening : 1.0)
        component.turnVelocity += turn * rotationTuning.rotationResponsiveness * turnRhythm * deltaTime
        component.turnVelocity *= max(0.0, 1.0 - rotationTuning.waterResistance * deltaTime)
        let maximumTurnMomentum = rotationTuning.maximumTurnMomentum * turnRhythm
        component.turnVelocity = min(max(component.turnVelocity, -maximumTurnMomentum), maximumTurnMomentum)
        component.heading += component.turnVelocity * deltaTime
        component.heading = normalizedAngle(component.heading)
    }

    private func updateVisualMotion(component: inout FishMovementComponent, deltaTime: CGFloat) {
        let time = CGFloat(component.lifeTime).finiteOrZero
        let speedRange = max(0.0001, motionTuning.maximumCruiseSpeed - motionTuning.minimumLivingSpeed)
        let speedRatio = ((component.velocity.length - motionTuning.minimumLivingSpeed) / speedRange).clamped(to: 0.0...1.0)
        let visualEnergy = component.calmTimeRemaining > 0.0 ? motionTuning.calmTailEnergy : (component.alertTimeRemaining > 0.0 ? motionTuning.alertTailEnergy : component.energyLevel)
        let fatigueTarget = (0.5 + 0.5 * sin(time * tailTuning.fatigueSoftnessRate + component.fatiguePhase)) * tailTuning.fatigueSoftnessAmount
        component.fatigueSoftness += (fatigueTarget - component.fatigueSoftness) * 0.012
        let phaseDrift = sin(time * tailTuning.phaseDriftRate + component.swayPhase) * tailTuning.phaseDriftAmount
        let asymmetry = sin(time * tailTuning.asymmetryRate + component.asymmetryPhase) * tailTuning.asymmetryAmount
        let softness = (1.0 - component.fatigueSoftness).clamped(to: 0.74...1.0)
        let bodyPhase = time * rotationTuning.bodySwayRate * max(0.72, visualEnergy) + component.swayPhase + phaseDrift * 0.42
        let tailPhase = time * (tailTuning.tailSwayBaseRate + speedRatio * tailTuning.tailSwaySpeedRate) * max(0.70, visualEnergy) + component.breathingPhase + phaseDrift
        let bodyWave = sin(bodyPhase) * (1.0 + asymmetry * 0.28)
        let tailWave = sin(tailPhase)
        let tailSideBias = tailWave >= 0.0 ? 1.0 + asymmetry : 1.0 - asymmetry * 0.72
        component.bodySway = bodyWave * (rotationTuning.bodySwayBaseAmount + speedRatio * rotationTuning.bodySwaySpeedAmount) * visualEnergy * softness
        component.tailSway = tailWave * tailSideBias * (tailTuning.tailSwayBaseAmount + speedRatio * tailTuning.tailSwaySpeedAmount) * visualEnergy * softness
        let lowActivitySpeed = motionTuning.lowActivitySpeedRange.upperBound
        if component.velocity.length <= lowActivitySpeed, abs(component.turnVelocity) < 0.06 {
            component.lowActivityTime += TimeInterval(deltaTime)
        } else {
            component.lowActivityTime = 0.0
        }
    }

    private func shortestAngle(from current: CGFloat, to target: CGFloat) -> CGFloat {
        guard current.isFinite, target.isFinite else { return 0.0 }
        var difference = target - current
        guard difference.isFinite else { return 0.0 }
        difference = difference.truncatingRemainder(dividingBy: .pi * 2.0)
        if difference > .pi { difference -= .pi * 2.0 }
        if difference < -.pi { difference += .pi * 2.0 }
        return difference
    }

    private func normalizedAngle(_ angle: CGFloat) -> CGFloat {
        guard angle.isFinite else { return 0.0 }
        var normalized = angle.truncatingRemainder(dividingBy: .pi * 2.0)
        if normalized > .pi { normalized -= .pi * 2.0 }
        if normalized < -.pi { normalized += .pi * 2.0 }
        return normalized
    }

    private func sanitize(component: inout FishMovementComponent, bounds: CGRect) {
        component.position = component.position.isFinite ? component.position.clamped(to: bounds) : CGPoint(x: bounds.midX, y: bounds.midY)
        component.velocity = component.velocity.finiteOrZero.limited(to: motionTuning.maximumCruiseSpeed)
        component.heading = normalizedAngle(component.heading)
        component.turnVelocity = component.turnVelocity.clamped(to: -rotationTuning.maximumTurnMomentum...rotationTuning.maximumTurnMomentum)
        component.wanderDirection = component.wanderDirection.normalizedOrFallback(CGVector(dx: cos(component.heading), dy: sin(component.heading)))
        component.attentionDirection = component.attentionDirection.normalizedOrFallback(component.wanderDirection)
        component.habitDirection = component.habitDirection.normalizedOrFallback(component.wanderDirection)
        component.targetSpeed = component.targetSpeed.clamped(to: motionTuning.minimumLivingSpeed...motionTuning.maximumCruiseSpeed)
        component.hesitationTimeRemaining = component.hesitationTimeRemaining.isFinite ? max(0.0, component.hesitationTimeRemaining) : 0.0
        component.focusTimeRemaining = component.focusTimeRemaining.isFinite ? max(0.0, component.focusTimeRemaining) : 0.0
        component.attentionTimeRemaining = component.attentionTimeRemaining.isFinite ? max(0.0, component.attentionTimeRemaining) : 0.0
        component.attentionStrength = component.attentionStrength.clamped(to: 0.0...1.0)
        component.habitTimeRemaining = component.habitTimeRemaining.isFinite ? max(0.0, component.habitTimeRemaining) : 0.0
        component.habitCommitment = component.habitCommitment.clamped(to: 0.0...0.60)
        component.rhythmDecisionTimeRemaining = component.rhythmDecisionTimeRemaining.isFinite ? component.rhythmDecisionTimeRemaining : motionTuning.rhythmDecisionIntervalRange.lowerBound
        component.calmTimeRemaining = component.calmTimeRemaining.isFinite ? max(0.0, component.calmTimeRemaining) : 0.0
        component.alertTimeRemaining = component.alertTimeRemaining.isFinite ? max(0.0, component.alertTimeRemaining) : 0.0
        component.cooldownTimeRemaining = component.cooldownTimeRemaining.isFinite ? max(0.0, component.cooldownTimeRemaining) : 0.0
        component.attentionLevel = component.attentionLevel.clamped(to: 0.25...1.45)
        component.targetAttentionLevel = component.targetAttentionLevel.clamped(to: 0.25...1.45)
        component.curiosityLevel = component.curiosityLevel.clamped(to: 0.25...1.35)
        component.targetCuriosityLevel = component.targetCuriosityLevel.clamped(to: 0.25...1.35)
        component.energyLevel = component.energyLevel.clamped(to: 0.45...1.25)
        component.targetEnergyLevel = component.targetEnergyLevel.clamped(to: 0.45...1.25)
        component.bodySway = component.bodySway.finiteOrZero
        component.tailSway = component.tailSway.finiteOrZero
        component.fatigueSoftness = component.fatigueSoftness.clamped(to: 0.0...0.40)
        component.lowActivityTime = component.lowActivityTime.isFinite ? max(0.0, component.lowActivityTime) : 0.0
        if !component.lifeTime.isFinite || component.lifeTime < 0.0 {
            component.lifeTime = 0.0
        }
    }

    private func updateObservationSample(component: inout FishMovementComponent, edgeProximity: CGFloat) {
#if DEBUG
        component.observationSample.record(
            edgeProximity: edgeProximity,
            speed: component.velocity.length,
            turnVelocity: component.turnVelocity,
            tailSway: component.tailSway,
            lowActivityTime: component.lowActivityTime
        )
#endif
    }

    private func assertStable(_ component: FishMovementComponent) {
        assert(component.position.isFinite, "Fish position became non-finite")
        assert(component.velocity.isFinite, "Fish velocity became non-finite")
        assert(component.heading.isFinite, "Fish heading became non-finite")
        assert(component.turnVelocity.isFinite, "Fish turn velocity became non-finite")
        assert(component.bodySway.isFinite, "Fish body sway became non-finite")
        assert(component.tailSway.isFinite, "Fish tail sway became non-finite")
    }
}
