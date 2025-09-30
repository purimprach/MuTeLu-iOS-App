import Foundation

func loadSacredPlaces() -> [SacredPlace] {
    guard let url = Bundle.main.url(forResource: "SacredPlacesDataNew", withExtension: "json") else {
        print("❌ ไม่พบไฟล์ SacredPlacesDataNew.json")
        return []
    }
    
    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode([SacredPlace].self, from: data)
    } catch {
        print("❌ โหลดหรือแปลง JSON ผิดพลาด: \(error)")
        return []
    }
}

