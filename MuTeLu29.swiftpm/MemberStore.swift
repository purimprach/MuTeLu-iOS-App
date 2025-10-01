import Foundation

@MainActor
class MemberStore: ObservableObject {
    @Published var members: [Member] = [] {
        didSet { saveMembers() }
    }
    
    private let key = "saved_members"
    init() {
        loadMembers()
    }
    
    func saveMembers() {
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
        if let decoded = decodeMembers(data: data) {
            self.members = decoded
        } else {
            self.members = []
        }
    }
    
    private func decodeMembers(data: Data) -> [Member]? {
        do {
            let dec = JSONDecoder()
            dec.dateDecodingStrategy = .iso8601
            return try dec.decode([Member].self, from: data)
        } catch {
        }
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
    
    /// จัดการการกดไลค์สถานที่
    func toggleLike(for memberEmail: String, place: SacredPlace) {
        guard let index = members.firstIndex(where: { $0.email.lowercased() == memberEmail.lowercased() }) else { return }
        if members[index].likedPlaceIDs.contains(place.id) {
            members[index].likedPlaceIDs.remove(place.id)
            for tag in place.tags {
                members[index].tagScores[tag, default: 0] -= 1
            }
        } else {
            members[index].likedPlaceIDs.insert(place.id)
            for tag in place.tags {
                members[index].tagScores[tag, default: 0] += 1
            }
        }
    }
    func isLiked(by memberEmail: String, placeID: UUID) -> Bool {
        guard let member = members.first(where: { $0.email.lowercased() == memberEmail.lowercased() }) 
        else {
            return false
        }
        return member.likedPlaceIDs.contains(placeID)
    }
}

