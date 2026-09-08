//
//  ResultView.swift
//  What should I eat for dinner?
//

import SwiftUI

struct ResultView: View {
    @ObservedObject var model: QuizModel

    var body: some View {
        VStack(spacing: 30) {
            Spacer(minLength: 0)

            VStack(spacing: 0) {
                Rectangle()
                    .fill(Theme.sun)
                    .frame(height: 14)

                VStack(spacing: 22) {
                    Text("TONIGHT, YOU SHOULD EAT")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .kerning(1.6)
                        .foregroundStyle(Theme.inkSoft)

                    if let meal = model.suggestion {
                        dishName(for: meal)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 46)
                .frame(maxWidth: .infinity)
                .background(Theme.card)
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.bigRadius, style: .continuous))
            .shadow(color: .black.opacity(0.2), radius: 22, y: 12)
            .frame(maxWidth: 760)
            .padding(.horizontal, 24)

            HStack(spacing: 18) {
                Button("Give me another", action: model.anotherSuggestion)
                    .buttonStyle(ChunkyButtonStyle(fill: Theme.coral,
                                                   ink: Theme.coralInk,
                                                   edge: Theme.coralDeep,
                                                   horizontal: 34, vertical: 18))
                Button("Restart", action: model.restart)
                    .buttonStyle(ChunkyButtonStyle(fill: Theme.sun,
                                                   ink: Theme.sunInk,
                                                   edge: Theme.sunDeep,
                                                   horizontal: 34, vertical: 18))
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// The dish name is a link: tapping it searches Google for it.
    @ViewBuilder
    private func dishName(for meal: Meal) -> some View {
        let title = Text(meal.name)
            .font(.system(size: 46, weight: .heavy, design: .rounded))
            .foregroundStyle(Theme.coralDeep)

        if let url = meal.searchURL {
            Link(destination: url) {
                HStack(spacing: 14) {
                    title
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Theme.coralDeep.opacity(0.6))
                }
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Theme.coralDeep.opacity(0.28))
                        .frame(height: 6)
                        .offset(y: 8)
                }
            }
            .accessibilityLabel("\(meal.name). Search Google for this dish.")
        } else {
            title
        }
    }
}
