import CoreGraphics
import UIKit

enum KoiVariant: Int, CaseIterable {
    case kohaku = 0       // red-white
    case sanke = 1        // red-white-black
    case showa = 2        // orange-black-white
    case yamabuki = 3     // gold
    case shiroUtsuri = 4  // black-white
    case creamRed = 5     // cream-red

    var baseColor: UIColor {
        switch self {
        case .kohaku:     return UIColor(red: 0.96, green: 0.94, blue: 0.88, alpha: 1.0)
        case .sanke:      return UIColor(red: 0.96, green: 0.94, blue: 0.88, alpha: 1.0)
        case .showa:      return UIColor(red: 0.96, green: 0.94, blue: 0.88, alpha: 1.0)
        case .yamabuki:   return UIColor(red: 0.92, green: 0.72, blue: 0.18, alpha: 1.0)
        case .shiroUtsuri: return UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
        case .creamRed:   return UIColor(red: 0.96, green: 0.92, blue: 0.84, alpha: 1.0)
        }
    }

    var patternColor: UIColor {
        switch self {
        case .kohaku:     return UIColor(red: 0.88, green: 0.18, blue: 0.08, alpha: 0.92)
        case .sanke:      return UIColor(red: 0.88, green: 0.18, blue: 0.08, alpha: 0.92)
        case .showa:      return UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 0.88)
        case .yamabuki:   return UIColor(red: 0.88, green: 0.62, blue: 0.12, alpha: 0.92)
        case .shiroUtsuri: return UIColor(red: 0.96, green: 0.94, blue: 0.88, alpha: 0.92)
        case .creamRed:   return UIColor(red: 0.82, green: 0.22, blue: 0.12, alpha: 0.88)
        }
    }

    var accentColor: UIColor {
        switch self {
        case .kohaku:     return UIColor(red: 0.92, green: 0.28, blue: 0.12, alpha: 0.88)
        case .sanke:      return UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 0.82)
        case .showa:      return UIColor(red: 0.88, green: 0.42, blue: 0.08, alpha: 0.85)
        case .yamabuki:   return UIColor(red: 0.96, green: 0.82, blue: 0.28, alpha: 0.88)
        case .shiroUtsuri: return UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 0.82)
        case .creamRed:   return UIColor(red: 0.90, green: 0.32, blue: 0.18, alpha: 0.82)
        }
    }
}

struct KoiSpriteConfig {
    let variant: KoiVariant
    let bodySize: CGSize
    let seed: UInt64

    static func configs(for count: Int) -> [KoiSpriteConfig] {
        let seeds: [UInt64] = [
            0x4D314E656B6F506F, 0x706F6E6446697368, 0xBADC0FFEE0DDF00D,
            0xC0A57A11D15C0DED, 0x51A7EC0E9A7BEEF0, 0xA11CEB0BA5ED1234,
            0xF15ACA7FEE123456, 0xF00DCA7F15A98765, 0xD09ECAFE1234BEEF
        ]
        return (0..<count).map { i in
            KoiSpriteConfig(
                variant: KoiVariant.allCases[i % KoiVariant.allCases.count],
                bodySize: CGSize(width: 120, height: 56),
                seed: seeds[i % seeds.count]
            )
        }
    }
}

struct PondLayerZ {
    static let floor: CGFloat      = 0
    static let deepWater: CGFloat  = 1
    static let caustics: CGFloat   = 2
    static let fogVeil: CGFloat    = 3
    static let koiShadow: CGFloat  = 4
    static let koi: CGFloat        = 5
    static let environment: CGFloat = 6
    static let petals: CGFloat     = 7
    static let ripples: CGFloat    = 8
    static let particles: CGFloat  = 9
    static let vignette: CGFloat   = 10
}
