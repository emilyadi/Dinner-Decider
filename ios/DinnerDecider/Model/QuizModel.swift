//
//  QuizModel.swift
//  What should I eat for dinner?
//

import Foundation
import SwiftUI

enum Screen {
    case start, quiz, result
}

final class QuizModel: ObservableObject {

    @Published private(set) var screen: Screen = .start
    @Published private(set) var index = 0
    @Published private(set) var answers = Answers()
    @Published private(set) var suggestion: Meal?

    private var ranked: [Meal] = []
    private var pick = 0
    /// Blocks the second tap of a double tap so a fast finger cannot skip a question.
    private var advancing = false

    var question: Question { Quiz.questions[index] }
    var questionCount: Int { Quiz.questions.count }
    var progress: Double { Double(index + 1) / Double(questionCount) }

    var selectedValue: AnyHashable? { answers.value(for: question.key) }

    func start() {
        screen = .quiz
    }

    /// Choosing an answer moves to the next question by itself, after a beat
    /// that lets the selection register.
    func choose(_ option: Option) {
        guard !advancing else { return }
        answers.set(option.value, for: question.key)
        advancing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) { [weak self] in
            guard let self else { return }
            self.advancing = false
            self.advance()
        }
    }

    private func advance() {
        if index < questionCount - 1 {
            index += 1
        } else {
            ranked = Matcher.ranked(for: answers)
            pick = 0
            suggestion = ranked.first
            screen = .result
        }
    }

    func back() {
        guard !advancing else { return }
        if index == 0 {
            screen = .start
        } else {
            index -= 1
        }
    }

    func anotherSuggestion() {
        guard !ranked.isEmpty else { return }
        pick += 1
        suggestion = ranked[pick % ranked.count]
    }

    func restart() {
        advancing = false
        answers.clear()
        index = 0
        ranked = []
        pick = 0
        suggestion = nil
        screen = .start
    }
}
