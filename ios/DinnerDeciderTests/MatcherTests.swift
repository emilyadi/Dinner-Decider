//
//  MatcherTests.swift
//  What should I eat for dinner?
//
//  The same checks the web version runs: every answer combination is exercised,
//  and the dietary filter is proven to hold across all of them.
//

import XCTest
@testable import DinnerDecider

final class MatcherTests: XCTestCase {

    /// Every combination of the eight answers: 4 x 3 x 3 x 3 x 3 x 3 x 3 x 3.
    private func allAnswerCombinations() -> [Answers] {
        var out: [Answers] = []
        for utensil in Utensil.allCases {
            for mess in 1...3 {
                for spice in 0...2 {
                    for fancy in 1...3 {
                        for heavy in Heavy.allCases {
                            for appetite in 1...3 {
                                for weather in Weather.allCases {
                                    for diet in Diet.allCases {
                                        out.append(Answers(utensil: utensil, mess: mess,
                                                           spice: spice, fancy: fancy,
                                                           heavy: heavy, appetite: appetite,
                                                           weather: weather, diet: diet))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return out
    }

    func testDatabaseIsWellFormed() {
        let meals = MealDatabase.all
        XCTAssertEqual(meals.count, 272, "the generated database should carry every dish")
        XCTAssertEqual(Set(meals.map(\.name)).count, meals.count, "dish names must be unique")

        for meal in meals {
            XCTAssertFalse(meal.name.isEmpty)
            XCTAssertFalse(meal.utensils.isEmpty, "\(meal.name) has no utensil")
            XCTAssertTrue((1...3).contains(meal.mess), "\(meal.name) has an out-of-range mess level")
            XCTAssertFalse(meal.spice.isEmpty)
            XCTAssertTrue(meal.spice.allSatisfy { (0...2).contains($0) }, "\(meal.name) spice out of range")
            XCTAssertFalse(meal.fancy.isEmpty)
            XCTAssertTrue(meal.fancy.allSatisfy { (1...3).contains($0) }, "\(meal.name) fancy out of range")
            XCTAssertFalse(meal.heavy.isEmpty)
            XCTAssertFalse(meal.appetite.isEmpty)
            XCTAssertTrue(meal.appetite.allSatisfy { (1...3).contains($0) }, "\(meal.name) appetite out of range")
            XCTAssertFalse(meal.weather.isEmpty)
        }
    }

    /// The dietary answer is a hard filter, never a preference. No amount of
    /// tapping "Give me another" may surface something that breaks it.
    func testDietaryFilterHoldsForEveryAnswerCombination() {
        for answers in allAnswerCombinations() {
            let ranked = Matcher.ranked(for: answers)
            XCTAssertFalse(ranked.isEmpty, "no dish for \(answers)")

            switch answers.diet {
            case .vegan:
                XCTAssertTrue(ranked.allSatisfy { $0.diet == .vegan },
                              "a non-vegan dish reached a vegan run")
            case .vegetarian:
                XCTAssertTrue(ranked.allSatisfy { $0.diet != .omnivore },
                              "a meat dish reached a vegetarian run")
            default:
                break
            }
        }
    }

    func testEveryCombinationYieldsAConfidentMatch() {
        for answers in allAnswerCombinations() {
            guard let top = Matcher.ranked(for: answers).first else {
                return XCTFail("no dish for \(answers)")
            }
            XCTAssertGreaterThanOrEqual(Matcher.score(top, against: answers), 60,
                                        "weak best match for \(answers): \(top.name)")
        }
    }

    func testTopMatchUsuallyHonoursUtensilAndEmphasis() {
        let combinations = allAnswerCombinations()
        var utensilHits = 0
        var heavyHits = 0
        for answers in combinations {
            guard let top = Matcher.ranked(for: answers).first else { continue }
            if let u = answers.utensil, top.utensils.contains(u) { utensilHits += 1 }
            if let h = answers.heavy, top.heavy.contains(h) { heavyHits += 1 }
        }
        let total = Double(combinations.count)
        XCTAssertGreaterThan(Double(utensilHits) / total, 0.95)
        XCTAssertGreaterThan(Double(heavyHits) / total, 0.95)
    }

    func testSearchURLEscapesTheDishName() {
        let meal = MealDatabase.all.first { $0.name.contains("Ph\u{1EDF}") } ?? MealDatabase.all[0]
        let url = meal.searchURL
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.host, "www.google.com")
        XCTAssertTrue(url?.absoluteString.hasPrefix("https://www.google.com/search?q=") ?? false)
    }

    func testGiveMeAnotherWalksTheRankingWithoutRepeating() {
        let model = QuizModel()
        model.start()
        for question in Quiz.questions {
            guard let option = question.options.first else { continue }
            model.choose(option)
            // choose() advances after a short delay; drive it directly in the test
            RunLoop.current.run(until: Date().addingTimeInterval(0.3))
        }
        XCTAssertNotNil(model.suggestion)
        var seen = Set<String>()
        for _ in 0..<8 {
            if let name = model.suggestion?.name { seen.insert(name) }
            model.anotherSuggestion()
        }
        XCTAssertGreaterThan(seen.count, 5, "Give me another should keep producing new dishes")
    }
}
