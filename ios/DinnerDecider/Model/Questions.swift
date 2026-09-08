//
//  Questions.swift
//  What should I eat for dinner?
//

import Foundation

enum QuestionKey: String, CaseIterable {
    case utensil, mess, spice, fancy, heavy, appetite, weather, diet
}

struct Option: Identifiable {
    let label: String
    let value: AnyHashable
    var id: String { label }
}

struct Question: Identifiable {
    let key: QuestionKey
    let text: String
    let options: [Option]
    var id: String { key.rawValue }
}

enum Quiz {
    static let questions: [Question] = [
        Question(key: .utensil,
                 text: "Pretend you\u{2019}re eating. What utensil are you using?",
                 options: [
                    Option(label: "Hands",      value: Utensil.hand),
                    Option(label: "Fork",       value: Utensil.fork),
                    Option(label: "Spoon",      value: Utensil.spoon),
                    Option(label: "Chopsticks", value: Utensil.chopsticks)
                 ]),

        Question(key: .mess,
                 text: "How messy do you want to be?",
                 options: [
                    Option(label: "Not at all", value: 1),
                    Option(label: "Medium",     value: 2),
                    Option(label: "Messy",      value: 3)
                 ]),

        Question(key: .spice,
                 text: "How much spice are you in the mood for?",
                 options: [
                    Option(label: "Zero-toddler level", value: 0),
                    Option(label: "Medium",             value: 1),
                    Option(label: "Hot like the sun",   value: 2)
                 ]),

        Question(key: .fancy,
                 text: "How fancy are you feeling?",
                 options: [
                    Option(label: "Not at all",                       value: 1),
                    Option(label: "A little fancy",                   value: 2),
                    Option(label: "Very fancy\u{2014}pinkies up!",    value: 3)
                 ]),

        Question(key: .heavy,
                 text: "Heavy on the:",
                 options: [
                    Option(label: "Animal",    value: Heavy.protein),
                    Option(label: "Vegetable", value: Heavy.vegetable),
                    Option(label: "Carbs",     value: Heavy.carbs)
                 ]),

        Question(key: .appetite,
                 text: "What\u{2019}s your appetite?",
                 options: [
                    Option(label: "Not very hungry",       value: 1),
                    Option(label: "I could eat",           value: 2),
                    Option(label: "GIVE ME ALL THE FOOD.", value: 3)
                 ]),

        Question(key: .weather,
                 text: "What\u{2019}s the weather?",
                 options: [
                    Option(label: "Cold and rainy",          value: Weather.cold),
                    Option(label: "Hot and sunny",           value: Weather.hot),
                    Option(label: "It\u{2019}s a beautiful day", value: Weather.mild)
                 ]),

        Question(key: .diet,
                 text: "Any dietary restrictions?",
                 options: [
                    Option(label: "Nope\u{2014}anything goes", value: Diet.omnivore),
                    Option(label: "Vegetarian",                value: Diet.vegetarian),
                    Option(label: "Vegan",                     value: Diet.vegan)
                 ])
    ]
}
