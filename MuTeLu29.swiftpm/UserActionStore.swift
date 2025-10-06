import Foundation

// Enum บอกประเภทของ Action
enum UserActionType: Int, Codable {
    case viewDetail = 1
    case bookmark = 2
    case like = 3
    case navigate = 4
    case checkIn = 7
}

// Struct เก็บ 1 เหตุการณ์
struct UserAction: Codable, Identifiable {
    var id = UUID()
    let memberEmail: String
    let placeID: String
    let actionType: UserActionType
    let timestamp: Date
}

// Store กลางสำหรับเก็บทุกอย่าง
class UserActionStore: ObservableObject {
    @Published var actions: [UserAction] = []
    private let storageKey = "user_actions"
    
    init() { loadActions() }
    
    // ฟังก์ชันสำหรับบันทึกพฤติกรรมใหม่
    func logAction(type: UserActionType, placeID: String, memberEmail: String) {
        let newAction = UserAction(memberEmail: memberEmail, placeID: placeID, actionType: type, timestamp: Date())
        actions.append(newAction)
        saveActions()
    }
    
    func getActions(for memberEmail: String) -> [UserAction] {
        actions.filter { $0.memberEmail == memberEmail }
    }
    
    private func saveActions() {
        // 👇 เติมโค้ดในปีกกานี้ให้สมบูรณ์
        if let data = try? JSONEncoder().encode(actions) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func loadActions() {
        // 👇 เติมโค้ดในปีกกานี้ให้สมบูรณ์
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let savedActions = try? JSONDecoder().decode([UserAction].self, from: data) {
            self.actions = savedActions
        }
    }
}
