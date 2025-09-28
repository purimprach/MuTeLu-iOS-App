import Foundation

struct CheckInRecord: Codable, Identifiable {
    var id: UUID = UUID()
    let placeID: String
    let placeNameTH: String
    let placeNameEN: String
    let meritPoints: Int
    let memberEmail: String
    var date: Date  // เปลี่ยนเป็น var เพื่อให้ admin แก้ไขได้
    let latitude: Double
    let longitude: Double
    var isEditedByAdmin: Bool = false  // เพิ่มฟิลด์เพื่อติดตามว่า admin แก้ไขหรือไม่
}

class CheckInStore: ObservableObject {
    @Published var records: [CheckInRecord] = []
    
    init() {
        load()
    }
    
    func add(record: CheckInRecord) {
        records.append(record)
        print("✅ Adding check-in record:")
        print("   PlaceID: \(record.placeID)")
        print("   Email: \(record.memberEmail)")
        print("   Date: \(record.date)")
        print("   Total records now: \(records.count)")
        save()
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: "checkInRecords")
        }
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: "checkInRecords"),
           let saved = try? JSONDecoder().decode([CheckInRecord].self, from: data) {
            records = saved
            print("📂 Loaded \(records.count) check-in records from UserDefaults")
        } else {
            print("📂 No existing check-in records found in UserDefaults")
        }
    }
    
    func records(for email: String) -> [CheckInRecord] {
        records.filter { $0.memberEmail == email }
    }
    
    func removeAll(for email: String) {
        records.removeAll { $0.memberEmail == email }
        save()
    }

    // เปลี่ยนเป็น 1 นาที สำหรับทดสอบ
    func hasCheckedInRecently(email: String, placeID: String) -> Bool {
        let oneMinuteAgo = Date().addingTimeInterval(-1 * 60) // 1 นาทีที่แล้ว
        let recentCheckIn = records.contains {
            $0.memberEmail == email &&
            $0.placeID == placeID &&
            $0.date >= oneMinuteAgo
        }
        
        // Debug logging
        print("🔍 Checking recent check-in:")
        print("   Email: \(email)")
        print("   PlaceID: \(placeID)")
        print("   Total records: \(records.count)")
        print("   Records for this user: \(records.filter { $0.memberEmail == email }.count)")
        print("   Recent check-in exists: \(recentCheckIn)")
        
        if let lastCheckIn = records.filter({ $0.memberEmail == email && $0.placeID == placeID }).max(by: { $0.date < $1.date }) {
            print("   Last check-in date: \(lastCheckIn.date)")
            print("   Time difference: \(Date().timeIntervalSince(lastCheckIn.date)/60) minutes ago")
        }
        
        return recentCheckIn
    }
    
    // เก็บฟังก์ชันเดิมไว้สำหรับ backward compatibility
    func hasCheckedInToday(email: String, placeID: String) -> Bool {
        return hasCheckedInRecently(email: email, placeID: placeID)
    }
    
    // ฟังก์ชันคำนวณเวลาที่เหลือก่อนจะเช็คอินได้อีกครั้ง
    func timeRemainingUntilNextCheckIn(email: String, placeID: String) -> TimeInterval? {
        guard let lastCheckIn = records.filter({ $0.memberEmail == email && $0.placeID == placeID }).max(by: { $0.date < $1.date }) else {
            return nil // ไม่เคยเช็คอิน
        }
        
        let nextAllowedTime = lastCheckIn.date.addingTimeInterval(1 * 60) // 1 นาทีหลังจากเช็คอินครั้งล่าสุด
        let now = Date()
        
        if nextAllowedTime > now {
            return nextAllowedTime.timeIntervalSince(now)
        } else {
            return 0 // เช็คอินได้แล้ว
        }
    }
    
    // ฟังก์ชันสำหรับ admin แก้ไขเวลา check-in
    func updateCheckInDate(recordID: UUID, newDate: Date) {
        if let index = records.firstIndex(where: { $0.id == recordID }) {
            records[index].date = newDate
            records[index].isEditedByAdmin = true
            save()
        }
    }
    
    // ฟังก์ชันหา check-in record ตาม ID
    func getRecord(by id: UUID) -> CheckInRecord? {
        return records.first { $0.id == id }
    }
    
    // ฟังก์ชันลบ check-in record เฉพาะ
    func removeRecord(by id: UUID) {
        records.removeAll { $0.id == id }
        save()
    }
}
