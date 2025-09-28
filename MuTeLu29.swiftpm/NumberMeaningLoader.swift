import Foundation
import SwiftUI

struct NumberMeaningLoader {
    static func loadMeanings(language: String) -> [String: String] {
        guard let url = Bundle.main.url(forResource: "numberMeaning", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONDecoder().decode([String: [String: String]].self, from: data)
        else {
            return [:]
        }
        return json.mapValues { $0[language] ?? $0["th"] ?? "ไม่พบคำทำนาย" }
    }
}
