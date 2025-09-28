import Foundation

class RecommendationEngine {
    
    private let places: [SacredPlace]
    private let allTags: [String]
    private var placeVectors: [UUID: [Int]] = [:]
    
    // 1. รับข้อมูลสถานที่ทั้งหมดเข้ามาตอนเริ่มต้น
    init(places: [SacredPlace]) {
        self.places = places
        
        // 2. สร้าง "จักรวาลของ Tags" ทั้งหมดที่มีในระบบ
        self.allTags = Array(Set(places.flatMap { $0.tags })).sorted()
        
        // 3. แปลงสถานที่แต่ละแห่งให้เป็น "เวกเตอร์"
        self.vectorizePlaces()
    }
    
    // ฟังก์ชันแปลงสถานที่ให้เป็นเวกเตอร์
    private func vectorizePlaces() {
        for place in places {
            var vector = [Int](repeating: 0, count: allTags.count)
            for (index, tag) in allTags.enumerated() {
                if place.tags.contains(tag) {
                    vector[index] = 1
                }
            }
            placeVectors[place.id] = vector
        }
    }
    
    // 4. หัวใจของการคำนวณ: ฟังก์ชัน Cosine Similarity
    private func cosineSimilarity(vecA: [Int], vecB: [Int]) -> Double {
        let dotProduct = zip(vecA, vecB).map(*).reduce(0, +)
        let magnitudeA = sqrt(Double(vecA.map({ $0 * $0 }).reduce(0, +)))
        let magnitudeB = sqrt(Double(vecB.map({ $0 * $0 }).reduce(0, +)))
        
        if magnitudeA == 0 || magnitudeB == 0 {
            return 0.0
        }
        
        return Double(dotProduct) / (magnitudeA * magnitudeB)
    }
    
    // 5. ฟังก์ชันหลักสำหรับ "สร้างคำแนะนำ"
    func getRecommendations(basedOn sourcePlace: SacredPlace, excluding visitedPlaceIDs: [UUID], top: Int = 3) -> [SacredPlace] {
        guard let sourceVector = placeVectors[sourcePlace.id] else {
            print("⚠️ ไม่พบเวกเตอร์สำหรับสถานที่ต้นทาง: \(sourcePlace.nameTH)")
            return []
        }
        
        var scores: [(place: SacredPlace, score: Double)] = []
        
        for targetPlace in places {
            if targetPlace.id == sourcePlace.id || visitedPlaceIDs.contains(targetPlace.id) {
                continue
            }
            
            guard let targetVector = placeVectors[targetPlace.id] else { continue }
            
            let score = cosineSimilarity(vecA: sourceVector, vecB: targetVector)
            
            if score > 0 {
                scores.append((targetPlace, score))
            }
        }
        
        let recommendations = scores.sorted { $0.score > $1.score }.prefix(top).map { $0.place }
        
        print("--- Recommendation Results ---")
        print("Based on: \(sourcePlace.nameTH)")
        print("Found \(recommendations.count) recommendations.")
        for rec in recommendations {
            print("- \(rec.nameTH)")
        }
        print("--------------------------")
        
        return recommendations
    }
}
