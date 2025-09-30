import Foundation

class SacredPlaceViewModel: ObservableObject {
    @Published var places: [SacredPlace] = []
    @Published var selectedCategory: String = "การเรียน" // ตอนนี้ยังไม่ใช้
    
    init() {
        loadPlaces()
    }
    
    func loadPlaces() {
        if let url = Bundle.main.url(forResource: "SacredPlacesDataNew", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode([SacredPlace].self, from: data)
                self.places = decoded
                print("✅ โหลดสำเร็จ: \(decoded.count) สถานที่")
            } catch {
                print("❌ JSON Decode Error: \(error.localizedDescription)")
            }
        } else {
            print("❌ ไม่พบไฟล์ SacredPlacesDataNew.json ใน Bundle")
        }
    }
    
    func filteredPlaces() -> [SacredPlace] {
        return places
        // return places.filter { $0.category == selectedCategory }
    }
}
