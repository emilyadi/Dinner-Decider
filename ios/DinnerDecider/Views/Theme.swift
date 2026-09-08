//
//  Theme.swift
//  What should I eat for dinner?
//
//  Palette: green ground, coral action, yellow accent, deep coral for the dish.
//  Nothing is written in white or yellow on the green — those sit at 1.9:1 and
//  1.3:1. Text on the ground uses `onGround`, a darkened form of it, at 6.6:1.
//

import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8)  & 0xFF) / 255,
            blue:  Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

enum Theme {
    static let ground    = Color(hex: 0x06D6A0)   // app background
    static let onGround  = Color(hex: 0x073B32)   // 6.6:1 on the ground
    static let coral     = Color(hex: 0xFF7F50)   // actions
    static let coralDeep = Color(hex: 0xA63A12)   // button edge, and the dish name
    static let coralInk  = Color(hex: 0x4A1C08)   // 5.75:1 on coral
    static let sun       = Color(hex: 0xFFD166)   // badge, Back, Restart, card cap
    static let sunDeep   = Color(hex: 0xD9A227)
    static let sunInk    = Color(hex: 0x4A3405)   // 8.16:1 on the yellow
    static let card      = Color.white
    static let ink       = Color(hex: 0x22302C)   // text on white
    static let inkSoft   = Color(hex: 0x5A6B65)

    static let cardRadius: CGFloat = 26
    static let bigRadius: CGFloat  = 34
}

/// The app's button look: a solid fill over a darker bottom edge that presses
/// down when tapped.
struct ChunkyButtonStyle: ButtonStyle {
    var fill: Color
    var ink: Color
    var edge: Color
    var horizontal: CGFloat = 40
    var vertical: CGFloat = 20

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .foregroundStyle(ink)
            .padding(.horizontal, horizontal)
            .padding(.vertical, vertical)
            .background(
                ZStack(alignment: .bottom) {
                    Capsule().fill(edge)
                    Capsule().fill(fill).padding(.bottom, configuration.isPressed ? 0 : 5)
                }
            )
            .offset(y: configuration.isPressed ? 3 : 0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
