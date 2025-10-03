import Foundation

// Struct สำหรับเก็บข้อมูล 1 รายการ
// ว่าใคร (memberEmail) ชอบอะไร (placeID)
struct LikeRecord: Codable, Identifiable {
    var id = UUID()
    let memberEmail: String
    let placeID: String // ใช้ UUID ของ SacredPlace แปลงเป็น String
}

// Class หลักสำหรับจัดการข้อมูล Like ทั้งหมด
class LikeStore: ObservableObject {
    @Published var likes: [LikeRecord] = []
    private let storageKey = "user_likes"
    
    init() {
        loadLikes()
    }
    
    // เช็คว่าสถานที่นี้ถูก Like โดยผู้ใช้คนนี้หรือยัง
    func isLiked(placeID: String, by memberEmail: String) -> Bool {
        likes.contains { $0.placeID == placeID && $0.memberEmail == memberEmail }
    }
    
    // ฟังก์ชันสำหรับกด Like และ Unlike
    func toggleLike(placeID: String, for memberEmail: String) {
        if isLiked(placeID: placeID, by: memberEmail) {
            // ถ้า Like อยู่แล้ว -> ให้ Unlike (ลบออก)
            likes.removeAll { $0.placeID == placeID && $0.memberEmail == memberEmail }
        } else {
            // ถ้ายังไม่ Like -> ให้ Like (เพิ่มเข้าไปใหม่)
            let newLike = LikeRecord(memberEmail: memberEmail, placeID: placeID)
            likes.append(newLike)
        }
        saveLikes()
    }
    
    // บันทึกข้อมูลลงในเครื่อง
    private func saveLikes() {
        if let data = try? JSONEncoder().encode(likes) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    // โหลดข้อมูลที่เคยบันทึกไว้
    private func loadLikes() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let savedLikes = try? JSONDecoder().decode([LikeRecord].self, from: data) {
            self.likes = savedLikes
        }
    }
}
