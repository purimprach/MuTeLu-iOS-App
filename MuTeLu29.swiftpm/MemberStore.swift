import Foundation

class MemberStore: ObservableObject {
    @Published var members: [Member] = [] {
        didSet {
            saveMembers()
        }
    }
    
    private let key = "saved_members"
    
    init() {
        loadMembers()
    }
    
    func saveMembers() {
        if let data = try? JSONEncoder().encode(members) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func loadMembers() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([Member].self, from: data) {
            self.members = saved
        }
    }
}
