import Foundation
import CoreLocation

// --- 1. เพิ่ม Conformance: Identifiable, Codable, Equatable, Hashable ---
struct SacredPlace: Identifiable, Codable, Equatable, Hashable {
    
    var id: UUID
    let nameTH: String
    let nameEN: String
    let descriptionTH: String
    let descriptionEN: String
    let locationTH: String
    let locationEN: String
    let latitude: Double
    let longitude: Double
    let imageName: String
    let tags: [String]
    let rating: Double
    let details: [DetailItem]
    
    // --- 2. เพิ่มฟังก์ชันสำหรับ Equatable ---
    // บอก SwiftUI ว่า SacredPlace 2 อันจะเท่ากันก็ต่อเมื่อ id ของมันเหมือนกัน
    static func == (lhs: SacredPlace, rhs: SacredPlace) -> Bool {
        lhs.id == rhs.id
    }
    
    // --- 3. เพิ่มฟังก์ชันสำหรับ Hashable ---
    // บอก SwiftUI ให้ใช้ id ในการสร้าง "ลายนิ้วมือ" ที่ไม่ซ้ำกัน
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // --- CodingKeys (เหมือนเดิม) ---
    enum CodingKeys: String, CodingKey {
        case nameTH, nameEN, descriptionTH, descriptionEN, locationTH, locationEN,
             latitude, longitude, imageName, tags, rating, details
    }
    
    // --- init(from:) (เหมือนเดิม) ---
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let nameTH = try container.decode(String.self, forKey: .nameTH)
        let nameEN = try container.decode(String.self, forKey: .nameEN)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        
        let uniqueString = "\(nameTH)-\(nameEN)-\(latitude)-\(longitude)"
        self.id = UUID(uuidString: uniqueString.deterministicUUID()) ?? UUID()
        
        self.nameTH = nameTH
        self.nameEN = nameEN
        self.descriptionTH = try container.decode(String.self, forKey: .descriptionTH)
        self.descriptionEN = try container.decode(String.self, forKey: .descriptionEN)
        self.locationTH = try container.decode(String.self, forKey: .locationTH)
        self.locationEN = try container.decode(String.self, forKey: .locationEN)
        self.latitude = latitude
        self.longitude = longitude
        self.imageName = try container.decode(String.self, forKey: .imageName)
        self.tags = try container.decode([String].self, forKey: .tags)
        self.rating = try container.decode(Double.self, forKey: .rating)
        self.details = try container.decode([DetailItem].self, forKey: .details)
    }
}

// Helper extension to create deterministic UUID from string (เหมือนเดิม)
extension String {
    func deterministicUUID() -> String {
        let hash = self.hash
        let uuid = String(format: "%08X-%04X-%04X-%04X-%012X",
                          abs(hash) & 0xFFFFFFFF,
                          abs(hash >> 32) & 0xFFFF,
                          abs(hash >> 48) & 0xFFFF,
                          abs(hash >> 64) & 0xFFFF,
                          abs(hash >> 80) & 0xFFFFFFFFFFFF)
        return uuid
    }
}


// --- Structs และ Extensions ที่เหลือ (มีการเพิ่ม Equatable, Hashable) ---

struct DetailItem: Codable, Identifiable, Equatable, Hashable {
    var id: UUID = UUID()
    let key: LocalizedText
    let value: LocalizedText
    
    enum CodingKeys: String, CodingKey {
        case key, value
    }
    
    // Conformance for Equatable and Hashable
    static func == (lhs: DetailItem, rhs: DetailItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.key = try container.decode(LocalizedText.self, forKey: .key)
        self.value = try container.decode(LocalizedText.self, forKey: .value)
    }
}

struct LocalizedText: Codable, Equatable, Hashable {
    let th: String
    let en: String
}

extension SacredPlace {
    /// คำนวณระยะทางแบบเส้นตรง (เมตร)
    func distanceFrom(_ coord: CLLocationCoordinate2D) -> CLLocationDistance {
        let a = CLLocation(latitude: latitude, longitude: longitude)
        let b = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        return a.distance(from: b)
    }
}
