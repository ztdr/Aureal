import Foundation

enum AuraEffect: Int, CaseIterable {
    case off = 0
    case `static` = 1
    case breathing = 2
    case flashing = 3
    case spectrumCycle = 4
    case rainbow = 5
    case spectrumCycleBreathing = 6
    case chaseFade = 7
    case spectrumCycleChaseFade = 8
    case chase = 9
    case spectrumCycleChase = 10
    case spectrumCycleWave = 11
    case chaseRainbowPulse = 12
    case starryNight = 13
    case music = 14
    case direct = 0xff

    var isColorable: Bool {
        switch self {
        case .off: return false
        case .static: return true
        case .breathing: return true
        case .flashing: return true
        case .spectrumCycle: return false
        case .rainbow: return false
        case .spectrumCycleBreathing: return false
        case .chaseFade: return true
        case .spectrumCycleChaseFade: return false
        case .chase: return true
        case .spectrumCycleChase: return false
        case .spectrumCycleWave: return false
        case .chaseRainbowPulse: return false
        case .starryNight: return false
        case .music: return false
        case .direct: return false
        }
    }

    var name: String {
        switch self {
        case .off: return "Off"
        case .static: return "Static"
        case .breathing: return "Breathing"
        case .flashing: return "Flashing"
        case .spectrumCycle: return "Spectrum Cycle"
        case .rainbow: return "Rainbow"
        case .spectrumCycleBreathing: return "Spectrum Cycle Breathing"
        case .chaseFade: return "Chase Fade"
        case .spectrumCycleChaseFade: return "Spectrum Cycle Chase Fade"
        case .chase: return "Chase"
        case .spectrumCycleChase: return "Spectrum Cycle Chase"
        case .spectrumCycleWave: return "Spectrum Cycle Wave"
        case .chaseRainbowPulse: return "Chase Rainbow Pulse"
        case .starryNight: return "Starry Night"
        case .music: return "Music"
        case .direct: return "(direct)"
        }
    }

    static var effects: [Self] {
        let hiddenEffects = [
            Self.direct,
        ]

        return Self.allCases.filter { effect -> Bool in
            !hiddenEffects.contains(effect)
        }
    }
}

enum AuraControlMode: UInt8 {
    case effect = 0x3b
    case direct = 0x40
}

let AuraCommandLength = 65

let AsusUSBVendorID = 0x0b05

/*
 https://stackoverflow.com/questions/22042661/mac-osx-get-usb-vendor-id-and-product-id
 #!/bin/sh

 system_profiler SPUSBDataType \
     | awk '
       /Product ID:/{p=$3}
       /Vendor ID:/{v=$3}
       /Manufacturer:/{sub(/.*: /,""); m=$0}
       /Location ID:/{sub(/.*: /,""); printf("%s:%s %s (%s)\n", v, p, $0, m);}
     '
 */
let AuraProductIDs = [
    0x18f3,
    0x1872,
    0x1867,
    0x1889,
    0x19af,
    // potentially: 0x1939,
]

let AuraCommand: UInt8 = 0xec
