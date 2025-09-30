import Foundation

/// เก็บไว้บน MainActor เพื่อความปลอดภัยกับ UI thread
@MainActor
class MemberStore: ObservableObject {
    @Published var members: [Member] = [] {
        didSet { saveMembers() }
    }
    
    private let key = "saved_members"
    
    // MARK: - Init / Load
    init() {
        loadMembers()
    }
    
    // MARK: - Persistence
    func saveMembers() {
        // ✅ เพื่อความเข้ากันได้ย้อนหลัง: ใช้ JSONEncoder ค่า default (เหมือนของเดิม)
        //  (ถ้าจะย้ายไป ISO8601 ในอนาคต ทำ migration ทีหลังได้)
        do {
            let data = try JSONEncoder().encode(members)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            assertionFailure("Save members failed: \(error)")
        }
    }
    
    func loadMembers() {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            self.members = []
            return
        }
        // 🔁 พยายามถอดรหัส 2 แบบ: ISO8601 -> default (รองรับข้อมูลเก่า/ใหม่)
        if let decoded = decodeMembers(data: data) {
            self.members = decoded
        } else {
            // ถ้า decode ไม่ได้เลย ให้รีเซ็ต (ป้องกันแครช)
            self.members = []
        }
    }
    
    private func decodeMembers(data: Data) -> [Member]? {
        // 1) ลองแบบ ISO8601 (ถ้าในอนาคตคุณเปลี่ยนตัวเข้ารหัสเป็น ISO8601)
        do {
            let dec = JSONDecoder()
            dec.dateDecodingStrategy = .iso8601
            return try dec.decode([Member].self, from: data)
        } catch {
            // fallthrough
        }
        // 2) ลองแบบ default (เหมือนโค้ดเดิม)
        do {
            let dec = JSONDecoder()
            return try dec.decode([Member].self, from: data)
        } catch {
            return nil
        }
    }
    
    // MARK: - CRUD Utilities
    func addMember(_ member: Member) {
        members.append(member)
    }
    
    func deleteMember(id: UUID) {
        if let idx = members.firstIndex(where: { $0.id == id }) {
            members.remove(at: idx)
        }
    }
    
    func member(byEmail email: String) -> Member? {
        members.first { $0.email.caseInsensitiveCompare(email) == .orderedSame }
    }
    
    /// แก้ไข/แทนที่สมาชิกทั้งก้อน (อิงตาม id)
    func updateMember(_ updated: Member) {
        guard let idx = members.firstIndex(where: { $0.id == updated.id }) else { return }
        members[idx] = updated
    }
    
    /// ✅ บันทึกการล็อกอิน: อัปเดตทั้ง lastLogin และ loginHistory
    func recordLogin(email: String, at date: Date = Date()) {
        guard let idx = members.firstIndex(where: { $0.email.caseInsensitiveCompare(email) == .orderedSame }) else { return }
        members[idx].lastLogin = date
        members[idx].loginHistory.append(date)
        // didSet ของ members จะ save ให้เอง
    }
    
    // ตัวช่วยปรับแต้ม tag หากต้องการอัปเดตรสนใจผู้ใช้ในระบบแนะนำ
    func incrementTagScore(email: String, tag: String, by value: Int = 1) {
        guard let idx = members.firstIndex(where: { $0.email.caseInsensitiveCompare(email) == .orderedSame }) else { return }
        var dict = members[idx].tagScores
        dict[tag, default: 0] += value
        members[idx].tagScores = dict
    }
    
    func setTagScores(email: String, scores: [String: Int]) {
        guard let idx = members.firstIndex(where: { $0.email.caseInsensitiveCompare(email) == .orderedSame }) else { return }
        members[idx].tagScores = scores
    }
}
