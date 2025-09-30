import Foundation

struct NumberMeaning: Codable, Identifiable {
    var id: String { number }
    let number: String
    let meaning: String
}
