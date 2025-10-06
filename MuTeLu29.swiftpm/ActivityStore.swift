import Foundation

// 1. Enum เพื่อจำแนกประเภทของกิจกรรม
enum ActivityType: String, Codable, Hashable {
    case checkIn = "check_in"
    case liked = "liked"
    case unliked = "unliked"
    case bookmarked = "bookmarked"
    case unbookmarked = "unbookmarked"
}

// 2. Struct กลางสำหรับเก็บประวัติกิจกรรมทุกอย่าง
struct ActivityRecord: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    let type: ActivityType
    let placeID: String
    let placeNameTH: String
    let placeNameEN: String
    let memberEmail: String
    let date: Date
    let meritPoints: Int? // เป็น Optional เพราะการไลค์/บุ๊คมาร์คอาจไม่ให้แต้ม
}

// 3. Store ใหม่สำหรับจัดการกิจกรรมทั้งหมด
@MainActor
class ActivityStore: ObservableObject {
    @Published var activities: [ActivityRecord] = [] {
        didSet { saveActivities() }
    }
    
    private let cooldownInterval: TimeInterval = 12 * 60 * 60 // 12 ชั่วโมง
    
    init() {
        loadActivities()
    }
    
    func addActivity(_ activity: ActivityRecord) {
        // เพิ่มกิจกรรมล่าสุดไว้บนสุดเสมอ
        activities.insert(activity, at: 0)
    }
    
    func saveActivities() {
        if let data = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(data, forKey: "userActivities_v1")
        }
    }
    
    func loadActivities() {
        if let data = UserDefaults.standard.data(forKey: "userActivities_v1"),
           let saved = try? JSONDecoder().decode([ActivityRecord].self, from: data) {
            activities = saved
        }
    }
    
    /// คืนค่ากิจกรรมทั้งหมดของผู้ใช้คนนั้นๆ
    func activities(for email: String) -> [ActivityRecord] {
        activities.filter { $0.memberEmail.lowercased() == email.lowercased() }
    }
    
    /// คืนค่าเฉพาะประวัติการเช็คอิน
    func checkInRecords(for email: String) -> [ActivityRecord] {
        activities.filter { $0.memberEmail.lowercased() == email.lowercased() && $0.type == .checkIn }
    }
    
    /// คำนวณแต้มบุญทั้งหมด
    func totalMeritPoints(for email: String) -> Int {
        activities(for: email).compactMap { $0.meritPoints }.reduce(0, +)
    }
    
    // --- โลจิก Cooldown (เหมือนเดิม) ---
    
    func hasCheckedInRecently(email: String, placeID: String) -> Bool {
        let cooldownAgo = Date().addingTimeInterval(-cooldownInterval)
        return activities.contains {
            $0.type == .checkIn &&
            $0.memberEmail.lowercased() == email.lowercased() &&
            $0.placeID == placeID &&
            $0.date >= cooldownAgo
        }
    }
    
    func timeRemainingUntilNextCheckIn(email: String, placeID: String) -> TimeInterval? {
        guard let lastCheckIn = checkInRecords(for: email)
            .filter({ $0.placeID == placeID })
            .max(by: { $0.date < $1.date }) else {
            return nil
        }
        
        let nextAllowedTime = lastCheckIn.date.addingTimeInterval(cooldownInterval)
        let now = Date()
        
        return nextAllowedTime > now ? nextAllowedTime.timeIntervalSince(now) : 0
    }
}
