import SwiftUI

class LuckyColourLoader {
    static func loadAllColors() -> [ShirtColor] {
        guard let url = Bundle.main.url(forResource: "LuckyColour", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([ShirtColor].self, from: data) else {
            print("❌ Failed to load LuckyColour.json")
            return []
        }
        return decoded
    }
}
