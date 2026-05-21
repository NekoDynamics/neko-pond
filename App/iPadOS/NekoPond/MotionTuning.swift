import CoreGraphics
import Foundation
import UIKit

struct FishMotionTuning {
    let initialVelocity: CGVector
    let initialCruiseSpeed: CGFloat
    let initialCuriosityDelay: TimeInterval
    let calmAccelerationLimit: CGFloat
    let minimumLivingSpeed: CGFloat
    let maximumCruiseSpeed: CGFloat
    let velocityResponsiveness: CGFloat
    let velocityBreathingAmount: CGFloat
    let velocityBreathingRate: CGFloat
    let idleDriftAmount: CGFloat
    let idleDriftRate: CGFloat
    let microCurrentStrength: CGVector
    let microCurrentRate: CGVector
    let passiveCurrentStrength: CGVector
    let passiveCurrentRate: CGVector
    let curiousTurnRange: ClosedRange<CGFloat>
    let idleSpeedRange: ClosedRange<CGFloat>
    let cruiseSpeedRange: ClosedRange<CGFloat>
    let idleDurationRange: ClosedRange<TimeInterval>
    let wanderDecisionIntervalRange: ClosedRange<TimeInterval>
    let idleChoiceProbability: CGFloat
    let hesitationChoiceProbability: CGFloat
    let hesitationDurationRange: ClosedRange<TimeInterval>
    let hesitationSlowdown: CGFloat
    let focusChoiceProbability: CGFloat
    let focusDurationRange: ClosedRange<TimeInterval>
    let focusCommitment: CGFloat
    let attentionChoiceProbability: CGFloat
    let attentionDurationRange: ClosedRange<TimeInterval>
    let attentionCommitment: CGFloat
    let attentionDecayRate: CGFloat
    let attentionSlowdown: CGFloat
    let probeChoiceProbability: CGFloat
    let probeTurnRange: ClosedRange<CGFloat>
    let habitChoiceProbability: CGFloat
    let habitDurationRange: ClosedRange<TimeInterval>
    let habitCommitmentRange: ClosedRange<CGFloat>
    let ambivalenceChoiceProbability: CGFloat
    let ambivalenceCommitmentRange: ClosedRange<CGFloat>
    let rhythmDecisionIntervalRange: ClosedRange<TimeInterval>
    let calmWindowChoiceProbability: CGFloat
    let calmWindowDurationRange: ClosedRange<TimeInterval>
    let alertMomentChoiceProbability: CGFloat
    let alertMomentDurationRange: ClosedRange<TimeInterval>
    let behavioralCooldownRange: ClosedRange<TimeInterval>
    let attentionRhythmRange: ClosedRange<CGFloat>
    let curiosityRhythmRange: ClosedRange<CGFloat>
    let energyRhythmRange: ClosedRange<CGFloat>
    let calmAttentionLevel: CGFloat
    let calmCuriosityLevel: CGFloat
    let calmEnergyLevel: CGFloat
    let alertAttentionLevel: CGFloat
    let alertCuriosityLevel: CGFloat
    let alertEnergyLevel: CGFloat
    let rhythmTransitionRate: CGFloat
    let calmMotionIntensity: CGFloat
    let alertMotionIntensity: CGFloat
    let calmExplorationCommitment: CGFloat
    let alertExplorationCommitment: CGFloat
    let calmTurnSoftening: CGFloat
    let alertTurnTightening: CGFloat
    let calmTailEnergy: CGFloat
    let alertTailEnergy: CGFloat
    let boundarySlowdown: CGFloat
    let boundaryCuriosityBlend: CGFloat
    let directionUnderCorrection: CGFloat
    let lowActivitySpeedRange: ClosedRange<CGFloat>

    static let meditative = FishMotionTuning(
        initialVelocity: CGVector(dx: 0.42, dy: 0.08),
        initialCruiseSpeed: 1.05,
        initialCuriosityDelay: 0.2,
        calmAccelerationLimit: 0.95,
        minimumLivingSpeed: 0.34,
        maximumCruiseSpeed: 1.85,
        velocityResponsiveness: 0.31,
        velocityBreathingAmount: 0.06,
        velocityBreathingRate: 0.86,
        idleDriftAmount: 0.09,
        idleDriftRate: 0.31,
        microCurrentStrength: CGVector(dx: 0.05, dy: 0.07),
        microCurrentRate: CGVector(dx: 0.49, dy: 0.41),
        passiveCurrentStrength: CGVector(dx: 0.08, dy: 0.06),
        passiveCurrentRate: CGVector(dx: 0.13, dy: 0.17),
        curiousTurnRange: -0.24...0.25,
        idleSpeedRange: 0.32...0.72,
        cruiseSpeedRange: 0.82...1.45,
        idleDurationRange: 8.0...26.0,
        wanderDecisionIntervalRange: 4.8...12.5,
        idleChoiceProbability: 0.54,
        hesitationChoiceProbability: 0.065,
        hesitationDurationRange: 0.28...0.84,
        hesitationSlowdown: 0.58,
        focusChoiceProbability: 0.045,
        focusDurationRange: 1.10...2.65,
        focusCommitment: 0.46,
        attentionChoiceProbability: 0.018,
        attentionDurationRange: 1.6...3.9,
        attentionCommitment: 0.58,
        attentionDecayRate: 0.46,
        attentionSlowdown: 0.78,
        probeChoiceProbability: 0.025,
        probeTurnRange: -0.10...0.12,
        habitChoiceProbability: 0.20,
        habitDurationRange: 12.0...32.0,
        habitCommitmentRange: 0.12...0.34,
        ambivalenceChoiceProbability: 0.34,
        ambivalenceCommitmentRange: 0.52...0.90,
        rhythmDecisionIntervalRange: 22.0...58.0,
        calmWindowChoiceProbability: 0.78,
        calmWindowDurationRange: 24.0...48.0,
        alertMomentChoiceProbability: 0.018,
        alertMomentDurationRange: 1.2...3.1,
        behavioralCooldownRange: 5.5...14.0,
        attentionRhythmRange: 0.42...0.86,
        curiosityRhythmRange: 0.34...0.84,
        energyRhythmRange: 0.55...0.92,
        calmAttentionLevel: 0.34,
        calmCuriosityLevel: 0.24,
        calmEnergyLevel: 0.54,
        alertAttentionLevel: 0.96,
        alertCuriosityLevel: 0.88,
        alertEnergyLevel: 0.98,
        rhythmTransitionRate: 0.24,
        calmMotionIntensity: 0.56,
        alertMotionIntensity: 0.96,
        calmExplorationCommitment: 0.72,
        alertExplorationCommitment: 1.04,
        calmTurnSoftening: 0.50,
        alertTurnTightening: 0.96,
        calmTailEnergy: 0.58,
        alertTailEnergy: 1.08,
        boundarySlowdown: 0.86,
        boundaryCuriosityBlend: 0.05,
        directionUnderCorrection: 0.08,
        lowActivitySpeedRange: 0.30...0.50
    )
}

struct FishRotationTuning {
    let rotationResponsiveness: CGFloat
    let waterResistance: CGFloat
    let maximumTurnMomentum: CGFloat
    let bodySwayBaseAmount: CGFloat
    let bodySwaySpeedAmount: CGFloat
    let bodySwayRate: CGFloat

    static let softLag = FishRotationTuning(
        rotationResponsiveness: 38.0,
        waterResistance: 8.4,
        maximumTurnMomentum: 2.2,
        bodySwayBaseAmount: 0.025,
        bodySwaySpeedAmount: 0.035,
        bodySwayRate: 2.15
    )
}

struct FishTailTuning {
    let tailSwayBaseAmount: CGFloat
    let tailSwaySpeedAmount: CGFloat
    let tailSwayBaseRate: CGFloat
    let tailSwaySpeedRate: CGFloat
    let phaseDriftAmount: CGFloat
    let phaseDriftRate: CGFloat
    let asymmetryAmount: CGFloat
    let asymmetryRate: CGFloat
    let fatigueSoftnessAmount: CGFloat
    let fatigueSoftnessRate: CGFloat

    static let gentlePulse = FishTailTuning(
        tailSwayBaseAmount: 0.12,
        tailSwaySpeedAmount: 0.20,
        tailSwayBaseRate: 3.4,
        tailSwaySpeedRate: 2.1,
        phaseDriftAmount: 0.42,
        phaseDriftRate: 0.073,
        asymmetryAmount: 0.10,
        asymmetryRate: 0.041,
        fatigueSoftnessAmount: 0.18,
        fatigueSoftnessRate: 0.029
    )
}

struct EdgePressureTuning {
    let horizontalSoftness: CGFloat
    let verticalSoftness: CGFloat
    let rightSoftnessBias: CGFloat
    let bottomSoftnessBias: CGFloat
    let horizontalPressureBias: CGFloat
    let verticalPressureBias: CGFloat
    let lookAhead: TimeInterval
    let pressureStrength: CGFloat
    let tangentStrength: CGFloat
    let speedAttenuation: CGFloat
    let minimumSpeedScale: CGFloat
    let commitmentLoss: CGFloat
    let minimumCommitmentScale: CGFloat
    let maximumSteering: CGFloat
    let tangentDriftRate: CGFloat
    let currentStrength: CGVector
    let currentRate: CGVector

    static let ambient = EdgePressureTuning(
        horizontalSoftness: 236.0,
        verticalSoftness: 188.0,
        rightSoftnessBias: 0.92,
        bottomSoftnessBias: 1.12,
        horizontalPressureBias: 0.74,
        verticalPressureBias: 0.58,
        lookAhead: 0.82,
        pressureStrength: 18.0,
        tangentStrength: 9.5,
        speedAttenuation: 0.34,
        minimumSpeedScale: 0.66,
        commitmentLoss: 0.42,
        minimumCommitmentScale: 0.58,
        maximumSteering: 22.0,
        tangentDriftRate: 0.037,
        currentStrength: CGVector(dx: 1.8, dy: 1.2),
        currentRate: CGVector(dx: 0.033, dy: 0.027)
    )
}

struct FishVisualTuning {
    let glowColor: UIColor
    let bodyColor: UIColor
    let bodyStrokeColor: UIColor
    let tailColor: UIColor
    let tailStrokeColor: UIColor
    let bellyColor: UIColor
    let highlightColor: UIColor
    let finColor: UIColor
    let glowSoftness: CGFloat
    let bodySoftness: CGFloat
    let bodyOutlineWeight: CGFloat
    let tailOutlineWeight: CGFloat

    static let restrainedKoi = FishVisualTuning(
        glowColor: UIColor(red: 0.52, green: 0.92, blue: 0.96, alpha: 0.16),
        bodyColor: UIColor(red: 0.50, green: 0.78, blue: 0.80, alpha: 0.94),
        bodyStrokeColor: UIColor(red: 0.86, green: 1.0, blue: 0.98, alpha: 0.28),
        tailColor: UIColor(red: 0.35, green: 0.66, blue: 0.72, alpha: 0.74),
        tailStrokeColor: UIColor(red: 0.80, green: 1.0, blue: 0.98, alpha: 0.20),
        bellyColor: UIColor(red: 0.78, green: 0.95, blue: 0.90, alpha: 0.34),
        highlightColor: UIColor(red: 0.94, green: 1.0, blue: 0.96, alpha: 0.28),
        finColor: UIColor(red: 0.62, green: 0.90, blue: 0.92, alpha: 0.34),
        glowSoftness: 15.0,
        bodySoftness: 2.8,
        bodyOutlineWeight: 1.0,
        tailOutlineWeight: 0.8
    )
}

struct PondVisualTuning {
    let backgroundColor: UIColor
    let deepWaterColor: UIColor
    let centerDepthColor: UIColor
    let upperAmbientColor: UIColor
    let slowShadeColor: UIColor
    let backgroundOverscan: CGFloat
    let centerDepthScale: CGSize
    let centerDepthOffset: CGPoint
    let centerDepthSoftness: CGFloat
    let upperAmbientScale: CGSize
    let upperAmbientOffset: CGPoint
    let upperAmbientSoftness: CGFloat
    let slowShadeScale: CGSize
    let slowShadeOffset: CGPoint
    let slowShadeSoftness: CGFloat
    let lightBreathingBaseAlpha: CGFloat
    let lightBreathingAmount: CGFloat
    let lightBreathingRate: CGFloat
    let lightDriftAmount: CGVector
    let lightDriftRate: CGVector

    static let deepCalm = PondVisualTuning(
        backgroundColor: UIColor(red: 0.03, green: 0.08, blue: 0.11, alpha: 1.0),
        deepWaterColor: UIColor(red: 0.025, green: 0.070, blue: 0.090, alpha: 1.0),
        centerDepthColor: UIColor(red: 0.012, green: 0.038, blue: 0.052, alpha: 0.34),
        upperAmbientColor: UIColor(red: 0.10, green: 0.20, blue: 0.20, alpha: 0.10),
        slowShadeColor: UIColor(red: 0.0, green: 0.018, blue: 0.030, alpha: 0.16),
        backgroundOverscan: 1.04,
        centerDepthScale: CGSize(width: 1.05, height: 0.82),
        centerDepthOffset: CGPoint(x: 0.0, y: -0.08),
        centerDepthSoftness: 42.0,
        upperAmbientScale: CGSize(width: 0.92, height: 0.38),
        upperAmbientOffset: CGPoint(x: -0.10, y: 0.26),
        upperAmbientSoftness: 38.0,
        slowShadeScale: CGSize(width: 0.62, height: 0.50),
        slowShadeOffset: CGPoint(x: 0.20, y: -0.10),
        slowShadeSoftness: 58.0,
        lightBreathingBaseAlpha: 0.86,
        lightBreathingAmount: 0.05,
        lightBreathingRate: 0.12,
        lightDriftAmount: CGVector(dx: 8.0, dy: 5.0),
        lightDriftRate: CGVector(dx: 0.05, dy: 0.04)
    )
}
