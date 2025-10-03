import Foundation

// Struct สำหรับเก็บข้อมูล 1 รายการ
// ว่าใคร (memberEmail) บันทึกอะไร (placeID) เมื่อไหร่ (savedDate)
struct BookmarkRecord: Codable, Identifiable {
    var id = UUID()
    let memberEmail: String
    let placeID: String
    let savedDate: Date
}

// Class หลักสำหรับจัดการข้อมูล Bookmark ทั้งหมด
class BookmarkStore: ObservableObject {
    @Published var bookmarks: [BookmarkRecord] = []
    private let storageKey = "user_bookmarks"
    
    init() {
        loadBookmarks()
    }
    
    // เช็คว่าสถานที่นี้ถูก Bookmark โดยผู้ใช้คนนี้หรือยัง
    func isBookmarked(placeID: String, by memberEmail: String) -> Bool {
        bookmarks.contains { $0.placeID == placeID && $0.memberEmail == memberEmail }
    }
    
    // ดึงรายการ Bookmark ทั้งหมดสำหรับผู้ใช้คนเดียว
    func getBookmarks(for memberEmail: String) -> [BookmarkRecord] {
        return bookmarks
            .filter { $0.memberEmail == memberEmail }
            .sorted { $0.savedDate > $1.savedDate } // เรียงตามวันที่บันทึกล่าสุดก่อน
    }
    
    // ฟังก์ชันสำหรับกด Bookmark และยกเลิก
    func toggleBookmark(placeID: String, for memberEmail: String) {
        if isBookmarked(placeID: placeID, by: memberEmail) {
            // ถ้า Bookmark อยู่แล้ว -> ให้ยกเลิก (ลบออก)
            bookmarks.removeAll { $0.placeID == placeID && $0.memberEmail == memberEmail }
        } else {
            // ถ้ายังไม่ Bookmark -> ให้ Bookmark (เพิ่มเข้าไปใหม่)
            let newBookmark = BookmarkRecord(memberEmail: memberEmail, placeID: placeID, savedDate: Date())
            bookmarks.append(newBookmark)
        }
        saveBookmarks()
    }
    
    // บันทึกข้อมูลลงในเครื่อง
    private func saveBookmarks() {
        if let data = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    // โหลดข้อมูลที่เคยบันทึกไว้
    private func loadBookmarks() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let savedBookmarks = try? JSONDecoder().decode([BookmarkRecord].self, from: data) {
            self.bookmarks = savedBookmarks
        }
    }
}
