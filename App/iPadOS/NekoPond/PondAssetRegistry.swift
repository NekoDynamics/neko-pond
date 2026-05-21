import Foundation

enum PondAssetRegistry {
    enum PondBackground: CaseIterable {
        case dawn
        case day
        case moonlight
        case rain
        case winter

        var relativePath: String {
            switch self {
            case .dawn: "Pond/pond_background_dawn_2732x2048.png"
            case .day: "Pond/pond_background_day_2732x2048.png"
            case .moonlight: "Pond/pond_background_moonlight_2732x2048.png"
            case .rain: "Pond/pond_background_rain_2732x2048.png"
            case .winter: "Pond/pond_background_winter_2732x2048.png"
            }
        }
    }

    enum WaterOverlay: CaseIterable {
        case causticsLoop01
        case causticsLoop02
        case causticsSoftLarge
        case darkVignette
        case moteSoft
        case moteTiny
        case rainRippleOverlay
        case rippleRing01
        case rippleRing02
        case rippleRingSoftLarge
        case waterDistortionNoise
        case waterVeilDeep
        case waterVeilNear

        var relativePath: String {
            switch self {
            case .causticsLoop01: "Water/caustics_loop_01.png"
            case .causticsLoop02: "Water/caustics_loop_02.png"
            case .causticsSoftLarge: "Water/caustics_soft_large.png"
            case .darkVignette: "Water/dark_edge_vignette.png"
            case .moteSoft: "Water/mote_soft.png"
            case .moteTiny: "Water/mote_tiny.png"
            case .rainRippleOverlay: "Water/rain_ripple_overlay.png"
            case .rippleRing01: "Water/ripple_ring_01.png"
            case .rippleRing02: "Water/ripple_ring_02.png"
            case .rippleRingSoftLarge: "Water/ripple_ring_soft_large.png"
            case .waterDistortionNoise: "Water/water_distortion_noise.png"
            case .waterVeilDeep: "Water/water_veil_deep.png"
            case .waterVeilNear: "Water/water_veil_near.png"
            }
        }
    }

    enum KoiAtlas: CaseIterable {
        case creamRed
        case kohaku
        case sanke
        case shiroUtsuri
        case showa
        case yamabuki

        var relativePath: String {
            switch self {
            case .creamRed: "Koi/koi_cream_red_atlas.png"
            case .kohaku: "Koi/koi_kohaku_atlas.png"
            case .sanke: "Koi/koi_sanke_atlas.png"
            case .shiroUtsuri: "Koi/koi_shiro_utsuri_atlas.png"
            case .showa: "Koi/koi_showa_atlas.png"
            case .yamabuki: "Koi/koi_yamabuki_atlas.png"
            }
        }
    }

    enum EnvironmentAsset: CaseIterable {
        case aquaticGrass01
        case aquaticGrass02
        case lotusBudPink
        case lotusFlowerPink
        case lotusFlowerWhite
        case lotusLeaf01
        case lotusLeaf02
        case lotusLeaf03Small
        case mossStone01
        case mossStone02Flat
        case mossStone03Small
        case petal01
        case petal02
        case petal03Small
        case petal04Pale

        var relativePath: String {
            switch self {
            case .aquaticGrass01: "Environment/aquatic_grass_01.png"
            case .aquaticGrass02: "Environment/aquatic_grass_02.png"
            case .lotusBudPink: "Environment/lotus_bud_pink.png.png"
            case .lotusFlowerPink: "Environment/lotus_flower_pink.png"
            case .lotusFlowerWhite: "Environment/lotus_flower_white.png"
            case .lotusLeaf01: "Environment/lotus_leaf_01.png"
            case .lotusLeaf02: "Environment/lotus_leaf_02.png"
            case .lotusLeaf03Small: "Environment/lotus_leaf_03_small.png"
            case .mossStone01: "Environment/moss_stone_01.png"
            case .mossStone02Flat: "Environment/moss_stone_02_flat.png"
            case .mossStone03Small: "Environment/moss_stone_03_small.png"
            case .petal01: "Environment/petal_01.png"
            case .petal02: "Environment/petal_02.png"
            case .petal03Small: "Environment/petal_03_small.png"
            case .petal04Pale: "Environment/petal_04_pale.png"
            }
        }
    }

    static func path(for asset: PondBackground) -> String { asset.relativePath }
    static func path(for asset: WaterOverlay) -> String { asset.relativePath }
    static func path(for asset: KoiAtlas) -> String { asset.relativePath }
    static func path(for asset: EnvironmentAsset) -> String { asset.relativePath }

    static let allRuntimeAssetPaths: [String] =
        PondBackground.allCases.map(\.relativePath) +
        WaterOverlay.allCases.map(\.relativePath) +
        KoiAtlas.allCases.map(\.relativePath) +
        EnvironmentAsset.allCases.map(\.relativePath)
}
