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
    
    // กำหนดระยะเวลา Cooldown เป็นวินาที (12 ชั่วโมง * 60 นาที * 60 วินาที)
    private let cooldownInterval: TimeInterval = 12 * 60 * 60
    
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

    func hasCheckedInRecently(email: String, placeID: String) -> Bool {
        // เวลาเมื่อ 12 ชั่วโมงที่แล้ว
        let twelveHoursAgo = Date().addingTimeInterval(-cooldownInterval)
        
        let recentCheckIn = records.contains {
            $0.memberEmail == email &&
            $0.placeID == placeID &&
            $0.date >= twelveHoursAgo
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
        
        // เวลาถัดไปที่สามารถเช็คอินได้ (12 ชั่วโมงหลังจากครั้งล่าสุด)
        let nextAllowedTime = lastCheckIn.date.addingTimeInterval(cooldownInterval)
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
