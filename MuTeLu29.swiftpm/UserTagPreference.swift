import Foundation
import SwiftData

@Model
final class UserTagPreference {
    var id: UUID
    var memberEmail: String
    var tag: String
    var count: Int
    var lastVisited: Date
    var score: Double

    init(memberEmail: String, tag: String, count: Int = 1, lastVisited: Date = Date()) {
        self.id = UUID()
        self.memberEmail = memberEmail
        self.tag = tag
        self.count = count
        self.lastVisited = lastVisited
        self.score = Double(count)
    }
}
