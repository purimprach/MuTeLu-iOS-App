import Foundation
import SwiftData // 👈 1. เพิ่มบรรทัดนี้

@Model // 👈 2. เพิ่ม Macro @Model เข้าไป
final class Member { // 👈 3. เปลี่ยนจาก struct เป็น final class
    @Attribute(.unique) // 👈 4. บอกว่า email ต้องไม่ซ้ำกัน
    var email: String
    
    var id: UUID
    var password: String
    var fullName: String
    var gender: String
    var birthdate: Date
    var birthTime: String
    var phoneNumber: String
    var houseNumber: String
    var carPlate: String
    var meritPoints: Int
    var role: UserRole
    var status: AccountStatus
    var joinedDate: Date
    
    init(
        id: UUID = UUID(),
        email: String,
        password: String,
        fullName: String,
        gender: String,
        birthdate: Date,
        birthTime: String,
        phoneNumber: String,
        houseNumber: String,
        carPlate: String,
        role: UserRole = .user,
        status: AccountStatus = .active,
        joinedDate: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.password = password
        self.fullName = fullName
        self.gender = gender
        self.birthdate = birthdate
        self.birthTime = birthTime
        self.phoneNumber = phoneNumber
        self.houseNumber = houseNumber
        self.carPlate = carPlate
        self.meritPoints = 0 // แต้มบุญเริ่มต้นที่ 0
        self.role = role
        self.status = status
        self.joinedDate = joinedDate
    }
}
enum UserRole: String, Codable {
    case admin = "Admin"
    case user = "User"
}

enum AccountStatus: String, Codable {
    case active = "Active"
    case suspended = "Suspended"
}
