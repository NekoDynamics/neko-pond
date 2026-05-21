import SpriteKit
import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var settings = PondSettings()
    @AppStorage("nekoPond.hasOnboarded") private var hasOnboarded = false
    @State private var hudVisible = true
    @State private var settingsVisible = false
    @State private var hudHideTask: Task<Void, Never>?
    @State private var scene: PondSpriteScene?

    var body: some View {
        ZStack {
            PondSpriteView(scene: $scene, settings: settings, onTapWater: { recallHUD() })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            if hasOnboarded {
                CatPlayHUD(
                    isVisible: hudVisible,
                    onSettings: { settingsVisible = true; recallHUD() }
                )
            }

            if settingsVisible {
                SettingsScreen(settings: settings, onClose: { settingsVisible = false; recallHUD() })
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }

            if !hasOnboarded {
                OnboardingView(onStart: {
                    hasOnboarded = true
                    recallHUD()
                })
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.45), value: hudVisible)
        .animation(.easeInOut(duration: 0.35), value: settingsVisible)
        .animation(.easeInOut(duration: 0.45), value: hasOnboarded)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active: scene?.activate()
            case .inactive, .background: scene?.deactivate()
            @unknown default: scene?.deactivate()
            }
        }
        .onAppear {
            scene?.activate()
            recallHUD()
        }
        .onDisappear {
            scene?.deactivate()
            hudHideTask?.cancel()
        }
    }

    private func recallHUD() {
        hudHideTask?.cancel()
        hudVisible = true
        guard hasOnboarded, !settingsVisible else { return }
        hudHideTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(settings.hideUITimer))
            if !Task.isCancelled { hudVisible = false }
        }
    }
}

@MainActor
final class PondSettings: ObservableObject {
    enum Mood: String, CaseIterable { case dawn = "Dawn", day = "Day", rain = "Rain", moonlight = "Moonlight", winter = "Winter" }
    enum Sensitivity: String, CaseIterable { case low = "Low", medium = "Medium", high = "High" }
    enum Soundscape: String, CaseIterable { case off = "Off", soft = "Soft", natural = "Natural" }

    @Published var mood: Mood = .dawn
    @Published var fishCount = 6
    @Published var sensitivity: Sensitivity = .medium
    @Published var soundscape: Soundscape = .natural
    @Published var rippleStrength: Double = 0.62
    @Published var nightBrightness: Double = 0.58
    @Published var catSafeMode = true
    @Published var hideUITimer: Double = 8.0
    @Published var isPaused = false

    func nextMood() { mood = Mood.allCases[(Mood.allCases.firstIndex(of: mood)! + 1) % Mood.allCases.count] }
    func nextSensitivity() { sensitivity = Sensitivity.allCases[(Sensitivity.allCases.firstIndex(of: sensitivity)! + 1) % Sensitivity.allCases.count] }
    func nextFishCount() { fishCount = fishCount >= 9 ? 3 : fishCount + 1 }
    func reset() {
        mood = .dawn; fishCount = 6; sensitivity = .medium; soundscape = .natural
        rippleStrength = 0.62; nightBrightness = 0.58; catSafeMode = true; hideUITimer = 8.0; isPaused = false
    }
}

private struct PondSpriteView: UIViewRepresentable {
    @Binding var scene: PondSpriteScene?
    @ObservedObject var settings: PondSettings
    var onTapWater: () -> Void

    func makeUIView(context: Context) -> SKView {
        let view = SKView(frame: .zero)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.contentScaleFactor = UIScreen.main.scale
        view.backgroundColor = .black
        view.ignoresSiblingOrder = true
        view.shouldCullNonVisibleNodes = true

        let screenSize = UIScreen.main.bounds.size
        let initialSize = CGSize(width: max(screenSize.width, 1366), height: max(screenSize.height, 1024))
        let newScene = PondSpriteScene(size: initialSize)
        newScene.scaleMode = .resizeFill
        newScene.onTapWater = onTapWater
        view.presentScene(newScene)
        scene = newScene
        newScene.apply(settings: settings)
        newScene.activate()
        return view
    }

    func updateUIView(_ view: SKView, context: Context) {
        scene?.apply(settings: settings)
        scene?.onTapWater = onTapWater
    }
}

private struct CatPlayHUD: View {
    let isVisible: Bool
    let onSettings: () -> Void

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Text("NEKO POND")
                    .font(.system(size: 18, weight: .light, design: .default))
                    .tracking(8)
                    .foregroundStyle(DesignToken.koiWhite.opacity(0.45))
                    .opacity(isVisible ? 1 : 0)
                Spacer()
            }
            Spacer()
        }
        .padding(.horizontal, 34)
        .padding(.top, 26)
        .allowsHitTesting(false)
        .overlay(alignment: .topTrailing) {
            Button(action: onSettings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(DesignToken.warmGold.opacity(0.55))
                    .frame(width: 36, height: 36)
                    .background(DesignToken.darkGlass.opacity(0.4), in: Circle())
            }
            .buttonStyle(.plain)
            .opacity(isVisible ? 0.8 : 0.001)
            .allowsHitTesting(true)
            .padding(.trailing, 34)
            .padding(.top, 26)
        }
    }
}

private struct HUDGlyph: View {
    let systemName: String
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 18, weight: .light))
            .foregroundStyle(DesignToken.warmGold.opacity(0.9))
            .frame(width: 48, height: 48)
            .background(DesignToken.darkGlass, in: Circle())
            .overlay(Circle().stroke(DesignToken.warmGold.opacity(0.24), lineWidth: 1))
    }
}

private struct SettingsScreen: View {
    @ObservedObject var settings: PondSettings
    let onClose: () -> Void

    var body: some View {
        ZStack {
            DesignToken.deepTeal.opacity(0.55).ignoresSafeArea()
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 14) { HUDGlyph(systemName: "cat"); Text("NEKO POND").tracking(8) }
                        .font(.system(size: 14, weight: .light))
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Settings").font(.system(size: 30, weight: .regular))
                        Text("Human controls for your pond").font(.system(size: 15, weight: .light)).opacity(0.68)
                    }
                    VStack(spacing: 0) {
                        SettingsNavRow(icon: "water.waves", title: "Pond", selected: true)
                        SettingsNavRow(icon: "fish", title: "Fish")
                        SettingsNavRow(icon: "scope", title: "Interaction")
                        SettingsNavRow(icon: "speaker.wave.1", title: "Audio")
                        SettingsNavRow(icon: "sun.max", title: "Display")
                        SettingsNavRow(icon: "shield", title: "Safety")
                    }
                    Spacer()
                }
                .foregroundStyle(DesignToken.koiWhite)
                .frame(width: 260)
                .padding(24)
                .background(DesignToken.darkGlass, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(DesignToken.warmGold.opacity(0.18), lineWidth: 1))

                VStack(spacing: 0) {
                    SettingsHeader(onClose: onClose)
                    SettingsRow(icon: "sun.max", title: "Pond Mood", subtitle: "Set the overall look and ambiance.") {
                        Picker("", selection: $settings.mood) { ForEach(PondSettings.Mood.allCases, id: \.self) { Text($0.rawValue).tag($0) } }.pickerStyle(.segmented)
                    }
                    SettingsRow(icon: "fish", title: "Fish Count", subtitle: "Choose how many koi swim in the pond.") {
                        Stepper("\(settings.fishCount)", value: $settings.fishCount, in: 3...9)
                    }
                    SettingsRow(icon: "hand.tap", title: "Interaction Sensitivity", subtitle: "Adjust how koi respond to touches.") {
                        Picker("", selection: $settings.sensitivity) { ForEach(PondSettings.Sensitivity.allCases, id: \.self) { Text($0.rawValue).tag($0) } }.pickerStyle(.segmented)
                    }
                    SettingsRow(icon: "music.note", title: "Soundscape", subtitle: "Set the pond's ambient sound.") {
                        Picker("", selection: $settings.soundscape) { ForEach(PondSettings.Soundscape.allCases, id: \.self) { Text($0.rawValue).tag($0) } }.pickerStyle(.segmented)
                    }
                    SettingsRow(icon: "smallcircle.filled.circle", title: "Touch Ripple Strength", subtitle: "Control touch ripple size.") { Slider(value: $settings.rippleStrength, in: 0.3...1.0) }
                    SettingsRow(icon: "moon", title: "Night Brightness", subtitle: "Adjust brightness in dark environments.") { Slider(value: $settings.nightBrightness, in: 0.25...0.9) }
                    SettingsRow(icon: "pawprint", title: "Cat Safe Mode", subtitle: "Disables intense visuals and sudden changes.") { Toggle("", isOn: $settings.catSafeMode).labelsHidden() }
                    SettingsRow(icon: "eye.slash", title: "Hide UI Timer", subtitle: "Automatically hide controls.") { Stepper("\(Int(settings.hideUITimer)) Seconds", value: $settings.hideUITimer, in: 4...14, step: 1) }
                    Button("Reset Pond", role: .destructive) { settings.reset() }
                        .font(.system(size: 16, weight: .regular)).padding(.top, 12)
                }
                .padding(24)
                .foregroundStyle(DesignToken.koiWhite)
                .frame(maxWidth: .infinity)
                .background(DesignToken.darkGlass, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(DesignToken.warmGold.opacity(0.18), lineWidth: 1))
            }
            .padding(36)
        }
    }
}

private struct SettingsHeader: View {
    let onClose: () -> Void
    var body: some View {
        HStack { Text("Pond").font(.system(size: 24, weight: .regular)); Spacer(); Button(action: onClose) { HUDGlyph(systemName: "xmark") }.buttonStyle(.plain) }
            .padding(.bottom, 10)
    }
}

private struct SettingsNavRow: View {
    let icon: String; let title: String; var selected = false
    var body: some View {
        HStack { Image(systemName: icon).frame(width: 34); Text(title); Spacer(); Image(systemName: "chevron.right") }
            .font(.system(size: 18, weight: .light))
            .padding(.vertical, 18).padding(.horizontal, 14)
            .background(selected ? DesignToken.jadeGreen.opacity(0.34) : .clear, in: RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .bottom) { Rectangle().fill(DesignToken.warmGold.opacity(0.12)).frame(height: 1) }
    }
}

private struct SettingsRow<Control: View>: View {
    let icon: String; let title: String; let subtitle: String; @ViewBuilder let control: Control
    var body: some View {
        HStack(spacing: 18) {
            Image(systemName: icon).font(.system(size: 24, weight: .light)).foregroundStyle(DesignToken.warmGold).frame(width: 34)
            VStack(alignment: .leading, spacing: 4) { Text(title).font(.system(size: 18, weight: .regular)); Text(subtitle).font(.system(size: 13, weight: .light)).opacity(0.66) }
            Spacer(); control.frame(width: 330)
        }
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) { Rectangle().fill(DesignToken.warmGold.opacity(0.12)).frame(height: 1) }
    }
}

private struct OnboardingView: View {
    let onStart: () -> Void
    @State private var page = 0
    private let pages: [(String, String, String)] = [
        ("Welcome to\nNEKO POND", "A quiet koi pond\nfor your cat.", "cat"),
        ("Place iPad safely", "Use a flat, stable surface.\nKeep the iPad secure.\nYour cat's safety comes first.", "ipad.landscape"),
        ("Let your cat explore", "Gentle touches create ripples.\nKoi respond with calm curiosity.\nRelax and enjoy the moment.", "drop"),
        ("Start Pond", "Enter full-screen cat mode.\nThe interface will vanish\nso your cat can play.", "cat")
    ]
    var body: some View {
        ZStack {
            DesignToken.darkWaterBlack.opacity(0.76).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 30) {
                HStack { Text("NEKO POND").tracking(9).opacity(0.6); Spacer(); Text("\(page + 1)").frame(width: 42, height: 42).overlay(Circle().stroke(DesignToken.warmGold.opacity(0.45))) }
                Spacer()
                Image(systemName: pages[page].2).font(.system(size: 34, weight: .light)).frame(width: 74, height: 74).overlay(Circle().stroke(DesignToken.warmGold.opacity(0.45)))
                Text(pages[page].0).font(.system(size: 46, weight: .regular)).lineSpacing(4)
                Rectangle().fill(DesignToken.jadeGreen.opacity(0.45)).frame(width: 108, height: 1)
                Text(pages[page].1).font(.system(size: 20, weight: .light)).lineSpacing(8).opacity(0.86)
                Spacer()
                HStack(spacing: 12) { ForEach(0..<4) { Circle().fill($0 == page ? DesignToken.koiWhite : .clear).frame(width: 8, height: 8).overlay(Circle().stroke(DesignToken.koiWhite.opacity(0.5))) }; Spacer() }
                Button(page == 3 ? "Start Pond" : "Continue") { page == 3 ? onStart() : (page += 1) }
                    .font(.system(size: 19, weight: .regular))
                    .frame(width: 280, height: 56)
                    .background(DesignToken.jadeGreen.opacity(0.82), in: RoundedRectangle(cornerRadius: 10))
            }
            .foregroundStyle(DesignToken.koiWhite)
            .padding(44)
            .frame(width: 640, height: 520, alignment: .leading)
            .background(DesignToken.darkGlass, in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(DesignToken.warmGold.opacity(0.25)))
        }
    }
}

enum TouchPhase { case began, moved, ended }

private enum DesignToken {
    static let deepTeal = Color(red: 0.05, green: 0.17, blue: 0.19)
    static let jadeGreen = Color(red: 0.18, green: 0.36, blue: 0.31)
    static let darkWaterBlack = Color(red: 0.03, green: 0.04, blue: 0.09)
    static let koiWhite = Color(red: 0.95, green: 0.91, blue: 0.84)
    static let warmGold = Color(red: 0.85, green: 0.58, blue: 0.29)
    static let darkGlass = Color(red: 0.02, green: 0.10, blue: 0.11).opacity(0.68)
}

#Preview { ContentView() }
