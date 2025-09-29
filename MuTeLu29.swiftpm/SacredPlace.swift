import Foundation

// ✅ แก้ไข struct ทั้งหมดให้ตรงกับโครงสร้าง JSON ใหม่ของคุณ
struct SacredPlace: Codable, Identifiable {
    
    var id: UUID = UUID()
    let nameTH: String
    let nameEN: String
    let descriptionTH: String
    let descriptionEN: String
    let locationTH: String
    let locationEN: String
    let latitude: Double
    let longitude: Double
    let imageName: String
    
    // ✅ 1. เปลี่ยนจาก category เป็น tags
    let tags: [String]
    
    let rating: Double
    let details: [DetailItem]
    
    // ✅ 2. เพิ่ม CodingKeys เพื่อบอก Swift ว่า key ใน JSON ชื่ออะไรบ้าง
    enum CodingKeys: String, CodingKey {
        case nameTH, nameEN, descriptionTH, descriptionEN, locationTH, locationEN,
             latitude, longitude, imageName, tags, rating, details
    }
}

struct DetailItem: Codable, Identifiable {
    var id: UUID = UUID()
    let key: LocalizedText
    let value: LocalizedText
    
    enum CodingKeys: String, CodingKey {
        case key, value
    }
}

struct LocalizedText: Codable {
    let th: String
    let en: String
}

// ✅ 3. สร้าง Extension เพื่อจัดการกับการ Decode ข้อมูล
// ส่วนนี้จะทำงานตอนที่แอปอ่านไฟล์ JSON และสร้าง ID ที่ไม่ซ้ำกันให้แต่ละสถานที่
extension SacredPlace {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Read all properties first
        let nameTH = try container.decode(String.self, forKey: .nameTH)
        let nameEN = try container.decode(String.self, forKey: .nameEN)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        
        // Create deterministic UUID based on unique place properties
        let uniqueString = "\(nameTH)-\(nameEN)-\(latitude)-\(longitude)"
        let deterministicUUIDString = uniqueString.deterministicUUID()
        self.id = UUID(uuidString: deterministicUUIDString) ?? UUID()
        
        self.nameTH = nameTH
        self.nameEN = nameEN
        self.descriptionTH = try container.decode(String.self, forKey: .descriptionTH)
        self.descriptionEN = try container.decode(String.self, forKey: .descriptionEN)
        self.locationTH = try container.decode(String.self, forKey: .locationTH)
        self.locationEN = try container.decode(String.self, forKey: .locationEN)
        self.latitude = latitude
        self.longitude = longitude
        self.imageName = try container.decode(String.self, forKey: .imageName)
        self.tags = try container.decode([String].self, forKey: .tags) // ⭐️ อ่าน tags จาก JSON
        self.rating = try container.decode(Double.self, forKey: .rating)
        self.details = try container.decode([DetailItem].self, forKey: .details)
    }
}

// Helper extension to create deterministic UUID from string
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

extension DetailItem {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.key = try container.decode(LocalizedText.self, forKey: .key)
        self.value = try container.decode(LocalizedText.self, forKey: .value)
    }
}
import CoreLocation

extension SacredPlace {
    /// คำนวณระยะทางแบบเส้นตรง (เมตร)
    func distanceFrom(_ coord: CLLocationCoordinate2D) -> CLLocationDistance {
        let a = CLLocation(latitude: latitude, longitude: longitude)
        let b = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        return a.distance(from: b)
    }
}
