import Foundation

// MARK: - Enums (เดิม)
enum UserRole: String, Codable {
    case admin = "Admin"
    case user = "User"
}

enum AccountStatus: String, Codable {
    case active = "Active"
    case suspended = "Suspended"
}

// MARK: - Member (เวอร์ชันปรับปรุงสำหรับ Codable)
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
    
    // แต้มรวม (ถ้ามีระบบคิดแต้มจาก CheckInRecord แนะนำให้คำนวณจาก store ภายนอก)
    var meritPoints: Int = 0
    
    // ✅ ใหม่: เก็บเวลาล็อกอินล่าสุด + ประวัติการล็อกอินทุกครั้ง
    var lastLogin: Date?                  // ล่าสุด
    var loginHistory: [Date] = []         // ทุกครั้ง
    
    // ✅ คะแนน tag ของผู้ใช้ (คงไว้ตามของเดิม)
    var tagScores: [String: Int] = [:]
    
    var role: UserRole
    var status: AccountStatus
    var joinedDate: Date
    
    // ใช้แยก key ชัดเจน (ปลอดภัยต่อการเปลี่ยนชื่อฟิลด์)
    private enum CodingKeys: String, CodingKey {
        case id, email, password, fullName, gender, birthdate, birthTime, phoneNumber, houseNumber, carPlate
        case meritPoints
        case lastLogin, loginHistory, tagScores
        case role, status, joinedDate
    }
    
    // MARK: - Init ปกติ (สำหรับสร้างสมาชิกใหม่ในโค้ด)
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
        meritPoints: Int = 0,
        lastLogin: Date? = nil,
        loginHistory: [Date] = [],
        tagScores: [String: Int] = [:]
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
        self.meritPoints = meritPoints
        self.lastLogin = lastLogin
        self.loginHistory = loginHistory
        self.tagScores = tagScores
    }
    
    // MARK: - Codable (Backward-compatible)
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id          = try c.decode(UUID.self, forKey: .id)
        self.email       = try c.decode(String.self, forKey: .email)
        self.password    = try c.decode(String.self, forKey: .password)
        self.fullName    = try c.decode(String.self, forKey: .fullName)
        self.gender      = try c.decode(String.self, forKey: .gender)
        self.birthdate   = try c.decode(Date.self, forKey: .birthdate)
        self.birthTime   = try c.decode(String.self, forKey: .birthTime)
        self.phoneNumber = try c.decode(String.self, forKey: .phoneNumber)
        self.houseNumber = try c.decode(String.self, forKey: .houseNumber)
        self.carPlate    = try c.decode(String.self, forKey: .carPlate)
        
        // ฟิลด์ที่อาจไม่มีในข้อมูลเดิม -> decodeIfPresent + ค่าเริ่มต้น
        self.meritPoints = try c.decodeIfPresent(Int.self, forKey: .meritPoints) ?? 0
        self.lastLogin   = try c.decodeIfPresent(Date.self, forKey: .lastLogin)
        self.loginHistory = try c.decodeIfPresent([Date].self, forKey: .loginHistory) ?? []
        self.tagScores   = try c.decodeIfPresent([String: Int].self, forKey: .tagScores) ?? [:]
        
        self.role        = try c.decode(UserRole.self, forKey: .role)
        self.status      = try c.decode(AccountStatus.self, forKey: .status)
        self.joinedDate  = try c.decode(Date.self, forKey: .joinedDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(email, forKey: .email)
        try c.encode(password, forKey: .password)
        try c.encode(fullName, forKey: .fullName)
        try c.encode(gender, forKey: .gender)
        try c.encode(birthdate, forKey: .birthdate)
        try c.encode(birthTime, forKey: .birthTime)
        try c.encode(phoneNumber, forKey: .phoneNumber)
        try c.encode(houseNumber, forKey: .houseNumber)
        try c.encode(carPlate, forKey: .carPlate)
        try c.encode(meritPoints, forKey: .meritPoints)
        try c.encode(lastLogin, forKey: .lastLogin)
        try c.encode(loginHistory, forKey: .loginHistory)
        try c.encode(tagScores, forKey: .tagScores)
        try c.encode(role, forKey: .role)
        try c.encode(status, forKey: .status)
        try c.encode(joinedDate, forKey: .joinedDate)
    }
    
    // MARK: - Utilities
    /// บันทึกการล็อกอิน: อัปเดตทั้ง lastLogin และเก็บลง loginHistory
    mutating func recordLogin(at date: Date = Date()) {
        lastLogin = date
        loginHistory.append(date)
    }
    
    /// จำนวนครั้งที่ล็อกอินทั้งหมด (ใช้ทำสถิติได้เลย)
    var totalLogins: Int { loginHistory.count }
}
