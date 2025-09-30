import Foundation

// Enum ไม่มีการเปลี่ยนแปลง
enum UserRole: String, Codable {
    case admin = "Admin"
    case user = "User"
}

enum AccountStatus: String, Codable {
    case active = "Active"
    case suspended = "Suspended"
}

// แก้ไข struct Member
struct Member: Identifiable, Codable {
    let id: UUID
    var email: String
    var password: String
    var fullName: String
    var gender: String
    var birthdate: Date
    var birthTime: String
    var phoneNumber: String
    var houseNumber: String
    var carPlate: String
    var meritPoints: Int = 0
    
    // 👇 เพิ่ม 2 property นี้เข้าไป
    var lastLogin: Date?                 // เก็บเวลาล็อกอินล่าสุด
    var tagScores: [String: Int] = [:]   // เก็บแต้มของแต่ละ tag
    
    var role: UserRole
    var status: AccountStatus
    var joinedDate: Date
    
    // 👇 แก้ไข init เพิ่มเติม
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
        joinedDate: Date = Date(),
        lastLogin: Date? = nil, // เพิ่ม parameter
        tagScores: [String: Int] = [:] // เพิ่ม parameter
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
        self.role = role
        self.status = status
        self.joinedDate = joinedDate
        
        // 👇 กำหนดค่า
        self.lastLogin = lastLogin
        self.tagScores = tagScores
    }
}
