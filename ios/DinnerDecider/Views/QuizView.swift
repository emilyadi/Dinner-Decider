//
//  QuizView.swift
//  What should I eat for dinner?
//

import SwiftUI

struct QuizView: View {
    @ObservedObject var model: QuizModel
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var columns: [GridItem] {
        let count = model.question.options.count
        // Cards are capped rather than stretched: on a full screen a four-option
        // row of one-word answers otherwise balloons to several hundred points wide.
        let cap: CGFloat = count == 4 ? 240 : 340
        let across = sizeClass == .compact ? 1 : count
        return Array(repeating: GridItem(.flexible(minimum: 0, maximum: cap), spacing: 18),
                     count: across)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer(minLength: 12)

            Text(model.question.text)
                .font(.system(size: 42, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.onGround)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.55)
                .frame(maxWidth: 620)
                .padding(.horizontal, 24)
                .padding(.bottom, 34)

            LazyVGrid(columns: columns, spacing: 18) {
                ForEach(model.question.options) { option in
                    OptionCard(option: option,
                               isSelected: model.selectedValue == option.value) {
                        model.choose(option)
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 12)
            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                Text("QUESTION \(model.index + 1) OF \(model.questionCount)")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .kerning(0.8)
                    .foregroundStyle(Theme.sunInk)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Theme.sun))
                Spacer()
                Text("What should I eat for dinner?")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.onGround.opacity(0.5))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.onGround.opacity(0.26))
                    Capsule().fill(Theme.coral)
                        .frame(width: geo.size.width * model.progress)
                }
            }
            .frame(height: 12)
        }
        .padding(.horizontal, 26)
        .padding(.top, 8)
    }

    private var footer: some View {
        HStack {
            Button(action: model.back) {
                Label("Back", systemImage: "chevron.left")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(ChunkyButtonStyle(fill: Theme.sun,
                                           ink: Theme.sunInk,
                                           edge: Theme.sunDeep,
                                           horizontal: 30, vertical: 16))
            Spacer()
        }
        .padding(.horizontal, 26)
        .padding(.bottom, 10)
    }
}

private struct OptionCard: View {
    let option: Option
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(option.label)
                    .font(.system(size: 23, weight: .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? Theme.coralInk : Theme.ink)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 34)
                    .frame(maxWidth: .infinity)

                if isSelected {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Theme.coral))
                    }
                    .padding(.trailing, 14)
                }
            }
            .frame(minHeight: 96)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                    .fill(isSelected ? Color(hex: 0xFFF3EC) : Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                    .strokeBorder(isSelected ? Theme.coral : .clear, lineWidth: 4)
            )
            .shadow(color: .black.opacity(0.16), radius: 14, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}
