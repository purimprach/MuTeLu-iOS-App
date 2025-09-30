import Foundation

// สร้าง Enum ไว้ข้างนอก struct เพื่อให้เรียกใช้ง่าย
enum UserRole: String, Codable {
    case admin = "Admin"
    case user = "User"
}

enum AccountStatus: String, Codable {
    case active = "Active"
    case suspended = "Suspended"
}

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
    
    // 👇 เพิ่ม 3 บรรทัดนี้เข้าไป
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
        // 👇 เพิ่ม Parameter เหล่านี้เข้าไป
        role: UserRole = .user, // กำหนดค่าเริ่มต้นเป็น user
        status: AccountStatus = .active, // กำหนดค่าเริ่มต้นเป็น active
        joinedDate: Date = Date() // กำหนดค่าเริ่มต้นเป็นวันปัจจุบัน
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
        
        // 👇 เพิ่มการกำหนดค่าให้ property ใหม่
        self.role = role
        self.status = status
        self.joinedDate = joinedDate
    }
}
