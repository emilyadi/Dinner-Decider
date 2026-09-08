//
//  Meal.swift
//  What should I eat for dinner?
//

import Foundation

enum Utensil: String, CaseIterable, Hashable {
    case hand, fork, spoon, chopsticks
}

enum Heavy: String, CaseIterable, Hashable {
    case protein, vegetable, carbs
}

enum Weather: String, CaseIterable, Hashable {
    case cold, hot, mild
}

enum Diet: String, CaseIterable, Hashable {
    case omnivore     // contains meat or fish
    case vegetarian   // no meat, may contain dairy or egg
    case vegan        // no animal products at all
}

/// One dish, tagged against all eight questions.
struct Meal: Identifiable, Hashable {
    let name: String
    let emoji: String
    let origin: String
    let blurb: String

    let utensils: Set<Utensil>
    let mess: Int             // 1 not at all … 3 messy
    let spice: Set<Int>       // levels it suits, 0 … 2
    let fancy: Set<Int>       // levels it fits, 1 … 3
    let heavy: Set<Heavy>
    let appetite: Set<Int>    // sizes it suits, 1 … 3
    let weather: Set<Weather>
    let diet: Diet

    var id: String { name }

    /// Arrays in, sets out: the generated database stays readable and the
    /// literals stay trivial for the type checker.
    init(_ name: String, _ emoji: String, _ origin: String, _ blurb: String,
         u: [Utensil], m: Int, s: [Int], f: [Int],
         h: [Heavy], a: [Int], w: [Weather], d: Diet) {
        self.name = name
        self.emoji = emoji
        self.origin = origin
        self.blurb = blurb
        self.utensils = Set(u)
        self.mess = m
        self.spice = Set(s)
        self.fancy = Set(f)
        self.heavy = Set(h)
        self.appetite = Set(a)
        self.weather = Set(w)
        self.diet = d
    }

    /// Google search for the dish, opened from the result screen.
    var searchURL: URL? {
        var components = URLComponents(string: "https://www.google.com/search")
        components?.queryItems = [URLQueryItem(name: "q", value: name)]
        return components?.url
    }
}
