import SwiftUI

import Foundation
import SwiftData

@Model
final class CheckInRecord {
    var id: UUID
    var placeID: String
    var placeNameTH: String
    var placeNameEN: String
    var meritPoints: Int
    var memberEmail: String
    var date: Date
    var latitude: Double
    var longitude: Double
    var isEditedByAdmin: Bool
    
    init(id: UUID = UUID(), placeID: String, placeNameTH: String, placeNameEN: String, meritPoints: Int, memberEmail: String, date: Date, latitude: Double, longitude: Double, isEditedByAdmin: Bool = false) {
        self.id = id
        self.placeID = placeID
        self.placeNameTH = placeNameTH
        self.placeNameEN = placeNameEN
        self.meritPoints = meritPoints
        self.memberEmail = memberEmail
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
        self.isEditedByAdmin = isEditedByAdmin
    }
}
