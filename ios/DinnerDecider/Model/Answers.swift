//
//  Answers.swift
//  What should I eat for dinner?
//

import Foundation

/// What the person picked. Every field is optional until answered.
struct Answers {
    var utensil: Utensil?
    var mess: Int?
    var spice: Int?
    var fancy: Int?
    var heavy: Heavy?
    var appetite: Int?
    var weather: Weather?
    var diet: Diet?          // .omnivore here means "no restriction"

    mutating func clear() { self = Answers() }

    /// The value chosen for a given question, used to restore the selection
    /// when someone taps Back.
    func value(for key: QuestionKey) -> AnyHashable? {
        switch key {
        case .utensil:  return utensil
        case .mess:     return mess
        case .spice:    return spice
        case .fancy:    return fancy
        case .heavy:    return heavy
        case .appetite: return appetite
        case .weather:  return weather
        case .diet:     return diet
        }
    }

    mutating func set(_ value: AnyHashable, for key: QuestionKey) {
        switch key {
        case .utensil:  utensil  = value as? Utensil
        case .mess:     mess     = value as? Int
        case .spice:    spice    = value as? Int
        case .fancy:    fancy    = value as? Int
        case .heavy:    heavy    = value as? Heavy
        case .appetite: appetite = value as? Int
        case .weather:  weather  = value as? Weather
        case .diet:     diet     = value as? Diet
        }
    }
}
