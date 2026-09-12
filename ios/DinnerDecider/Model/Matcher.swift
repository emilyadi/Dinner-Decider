//
//  Matcher.swift
//  What should I eat for dinner?
//
//  A direct port of scoreMeal() in js/app.js. Weights and thresholds are
//  identical, so the app and the web version rank dishes the same way.
//

import Foundation

struct ScoredMeal {
    let meal: Meal
    let score: Int
}

enum Matcher {

    /// Distance from `value` to the nearest level a dish suits.
    private static func nearest(_ levels: Set<Int>, _ value: Int) -> Int {
        levels.map { abs($0 - value) }.min() ?? 0
    }

    static func score(_ meal: Meal, against a: Answers) -> Int {
        var score = 0

        // utensil — the strongest single signal
        if let utensil = a.utensil, meal.utensils.contains(utensil) { score += 30 }

        // heavy on
        if let heavy = a.heavy, meal.heavy.contains(heavy) { score += 26 }

        // an "animal" answer with no dietary restriction prefers actual meat or fish
        if a.heavy == .protein, a.diet == .omnivore, meal.diet == .omnivore { score += 6 }

        // "I like toddler food" asks for plain, familiar food, which the fancy
        // level alone does not capture — a crab boil and a crumbed cutlet are
        // both level 1. This leans the ranking onto the dishes tagged basic.
        if a.fancy == 1, meal.isBasic { score += 28 }

        // the ordinal traits score by how far the dish sits from what was asked for
        if let mess = a.mess         { score += max(0, 22 - 11 * abs(meal.mess - mess)) }
        if let spice = a.spice       { score += max(0, 20 - 12 * nearest(meal.spice, spice)) }
        if let fancy = a.fancy       { score += max(0, 18 -  8 * nearest(meal.fancy, fancy)) }
        if let appetite = a.appetite { score += max(0, 16 -  9 * nearest(meal.appetite, appetite)) }

        // weather
        if let weather = a.weather {
            if meal.weather.contains(weather) { score += 14 }
            else if meal.weather.contains(.mild) || weather == .mild { score += 5 }
        }

        return score
    }

    /// Dishes the dietary answer allows. This is a hard filter applied before
    /// scoring, never a preference — no amount of "Give me another" can surface
    /// something that breaks it.
    static func eligible(for diet: Diet?) -> [Meal] {
        switch diet {
        case .vegan:      return MealDatabase.all.filter { $0.diet == .vegan }
        case .vegetarian: return MealDatabase.all.filter { $0.diet != .omnivore }
        default:          return MealDatabase.all
        }
    }

    /// Every eligible dish, best match first. Ties are shuffled so the same
    /// answers can surface a different dish on another run.
    static func ranked(for answers: Answers) -> [Meal] {
        let scored = eligible(for: answers.diet).map {
            (meal: $0, score: score($0, against: answers), jitter: Double.random(in: 0..<1))
        }
        return scored
            .sorted { lhs, rhs in
                lhs.score != rhs.score ? lhs.score > rhs.score : lhs.jitter > rhs.jitter
            }
            .map(\.meal)
    }
}
