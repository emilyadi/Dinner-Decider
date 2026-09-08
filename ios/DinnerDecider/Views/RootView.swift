//
//  RootView.swift
//  What should I eat for dinner?
//

import SwiftUI

struct RootView: View {
    @StateObject private var model = QuizModel()

    var body: some View {
        ZStack {
            Theme.ground.ignoresSafeArea()

            switch model.screen {
            case .start:
                StartView(onStart: model.start)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            case .quiz:
                QuizView(model: model)
                    .transition(.opacity)
            case .result:
                ResultView(model: model)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .animation(.easeOut(duration: 0.28), value: model.screen)
        .animation(.easeOut(duration: 0.2), value: model.index)
        .statusBarHidden(false)
    }
}

#Preview {
    RootView()
}
