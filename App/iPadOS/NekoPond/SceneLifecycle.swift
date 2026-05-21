import Foundation
import SceneKit
import UIKit

@MainActor
final class SceneLifecycle: ObservableObject {
    let scene: PondScene

    private var didBootstrap = false

    init(scene: PondScene? = nil) {
        self.scene = scene ?? PondScene()
    }

    func attach(to view: SCNView) {
        bootstrapIfNeeded()
        view.scene = scene
        view.delegate = scene
        view.backgroundColor = .black
        view.isPlaying = true
        view.rendersContinuously = true
        view.preferredFramesPerSecond = 120
        view.antialiasingMode = .multisampling4X
        view.allowsCameraControl = false
        view.autoenablesDefaultLighting = false
        view.contentMode = .scaleToFill
        view.layer.isOpaque = true
        scene.attach(view: view)
    }

    func bootstrapIfNeeded() {
        guard !didBootstrap else { return }
        scene.bootstrap()
        didBootstrap = true
    }

    func pause() {
        scene.pauseSimulation()
    }

    func resume() {
        bootstrapIfNeeded()
        scene.resumeSimulation()
    }
}
