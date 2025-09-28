import Foundation

struct CheckInRecord: Codable, Identifiable {
    var id: UUID = UUID()
    let placeID: String
    let placeNameTH: String
    let placeNameEN: String
    let meritPoints: Int
    let memberEmail: String
    let date: Date
    let latitude: Double
    let longitude: Double
}

class CheckInStore: ObservableObject {
    @Published var records: [CheckInRecord] = []
    
    init() {
        load()
    }
    
    func add(record: CheckInRecord) {
        records.append(record)
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
        }
    }
    
    func records(for email: String) -> [CheckInRecord] {
        records.filter { $0.memberEmail == email }
    }
    
    func removeAll(for email: String) {
        records.removeAll { $0.memberEmail == email }
        save()
    }

    func hasCheckedInToday(email: String, placeID: String) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return records.contains {
            $0.memberEmail == email &&
            $0.placeID == placeID &&
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }
    }
}
