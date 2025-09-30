import SwiftUI

struct ShirtColor: Codable {
    let day: Int
    let element: String
    let shouldWear: [String]
    let shouldAvoid: [String]
    let canWear: [String]
}
