import SwiftUI

struct LuckyColour: Codable, Identifiable {
    var id: Int { day }
    let day: Int
    let element: String
    let goodColors: [String]
    let badColors: [String]
    let supportColors: [String]
}
