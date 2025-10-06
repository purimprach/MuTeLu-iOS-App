import Foundation

class RecommendationEngine {
    
    private let places: [SacredPlace]
    private let allTags: [String]
    private var placeVectors: [UUID: [Int]] = [:]
    
    init(places: [SacredPlace]) {
        self.places = places
        self.allTags = Array(Set(places.flatMap { $0.tags })).sorted()
        self.vectorizePlaces()
    }
    
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
    
    private func cosineSimilarity(vecA: [Int], vecB: [Int]) -> Double {
        let dotProduct = zip(vecA, vecB).map(*).reduce(0, +)
        let magnitudeA = sqrt(Double(vecA.map({ $0 * $0 }).reduce(0, +)))
        let magnitudeB = sqrt(Double(vecB.map({ $0 * $0 }).reduce(0, +)))
        
        if magnitudeA == 0 || magnitudeB == 0 {
            return 0.0
        }
        
        return Double(dotProduct) / (magnitudeA * magnitudeB)
    }
    
    // --- ฟังก์ชันเก่าสำหรับ Content-based ---
    func getRecommendations(basedOn sourcePlace: SacredPlace, excluding visitedPlaceIDs: [UUID], top: Int = 3) -> [SacredPlace] {
        guard let sourceVector = placeVectors[sourcePlace.id] else { return [] }
        
        var scores: [(place: SacredPlace, score: Double)] = []
        
        for targetPlace in self.places { // <--- ใช้ self.places
            if targetPlace.id == sourcePlace.id || visitedPlaceIDs.contains(targetPlace.id) { continue }
            guard let targetVector = placeVectors[targetPlace.id] else { continue }
            let score = cosineSimilarity(vecA: sourceVector, vecB: targetVector)
            if score > 0 {
                scores.append((targetPlace, score))
            }
        }
        
        return scores.sorted { $0.score > $1.score }.prefix(top).map { $0.place }
    }
    
    // --- ฟังก์ชันใหม่สำหรับ Profile-based ---
    func getRecommendations(for userProfile: [String: Int], excluding visitedPlaceIDs: [UUID], top: Int = 5) -> [SacredPlace] {
        var recommendations: [(place: SacredPlace, score: Int)] = []
        
        for place in self.places { // <--- ใช้ self.places
            if visitedPlaceIDs.contains(place.id) { continue }
            
            var matchScore = 0
            for tag in place.tags {
                matchScore += userProfile[tag, default: 0]
            }
            
            if matchScore > 0 {
                recommendations.append((place, matchScore))
            }
        }
        
        return recommendations.sorted { $0.score > $1.score }.prefix(top).map { $0.place }
    }
}
