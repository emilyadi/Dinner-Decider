//
//  StartView.swift
//  What should I eat for dinner?
//

import SwiftUI

struct StartView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            PlateMark()
                .padding(.bottom, 34)

            Text("What should I eat\nfor dinner?")
                .font(.system(size: 52, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.onGround)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 24)
                .padding(.bottom, 44)

            Button("Find my dinner!", action: onStart)
                .buttonStyle(ChunkyButtonStyle(fill: Theme.coral,
                                               ink: Theme.coralInk,
                                               edge: Theme.coralDeep,
                                               horizontal: 46, vertical: 22))

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// The white plate with its yellow rim, bobbing gently.
private struct PlateMark: View {
    @State private var lifted = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.card)
                .overlay(Circle().strokeBorder(Theme.sun, lineWidth: 13))
                .shadow(color: .black.opacity(0.18), radius: 18, y: 10)
            Text("\u{1F374}")
                .font(.system(size: 66))
        }
        .frame(width: 165, height: 165)
        .rotationEffect(.degrees(lifted ? 3 : -3))
        .offset(y: lifted ? -10 : 0)
        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: lifted)
        .onAppear { lifted = true }
        .accessibilityHidden(true)
    }
}
