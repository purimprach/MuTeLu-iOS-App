import Foundation
import SwiftData

@Model
final class UserInteraction {
    var id: UUID
    var memberEmail: String
    var placeID: String
    var placeNameTH: String
    var placeNameEN: String
    var tags: [String]
    var interactionType: String // "view", "map_open", "check_in"
    var timestamp: Date
    var weight: Double // check-in=1.0, map=0.5, view=0.3

    init(
        memberEmail: String,
        placeID: String,
        placeNameTH: String,
        placeNameEN: String,
        tags: [String],
        interactionType: String,
        timestamp: Date = Date(),
        weight: Double
    ) {
        self.id = UUID()
        self.memberEmail = memberEmail
        self.placeID = placeID
        self.placeNameTH = placeNameTH
        self.placeNameEN = placeNameEN
        self.tags = tags
        self.interactionType = interactionType
        self.timestamp = timestamp
        self.weight = weight
    }

    /// Helper: สร้าง interaction แบบ view (น้ำหนัก 0.3)
    static func view(memberEmail: String, placeID: String, placeNameTH: String, placeNameEN: String, tags: [String]) -> UserInteraction {
        return UserInteraction(memberEmail: memberEmail, placeID: placeID, placeNameTH: placeNameTH, placeNameEN: placeNameEN, tags: tags, interactionType: "view", weight: 0.3)
    }

    /// Helper: สร้าง interaction แบบ map_open (น้ำหนัก 0.5)
    static func mapOpen(memberEmail: String, placeID: String, placeNameTH: String, placeNameEN: String, tags: [String]) -> UserInteraction {
        return UserInteraction(memberEmail: memberEmail, placeID: placeID, placeNameTH: placeNameTH, placeNameEN: placeNameEN, tags: tags, interactionType: "map_open", weight: 0.5)
    }

    /// Helper: สร้าง interaction แบบ check_in (น้ำหนัก 1.0)
    static func checkIn(memberEmail: String, placeID: String, placeNameTH: String, placeNameEN: String, tags: [String]) -> UserInteraction {
        return UserInteraction(memberEmail: memberEmail, placeID: placeID, placeNameTH: placeNameTH, placeNameEN: placeNameEN, tags: tags, interactionType: "check_in", weight: 1.0)
    }
}
