import Foundation

// Struct สำหรับเก็บผลลัพธ์การคำนวณ
struct NILR_Score: Identifiable {
    let id: UUID
    let place: SacredPlace
    let score: Double
}

class NILR_Recommender {
    
    private let members: [Member]
    private let places: [SacredPlace]
    private let activities: [ActivityRecord]
    
    init(members: [Member], places: [SacredPlace], activities: [ActivityRecord]) {
        self.members = members
        self.places = places
        self.activities = activities
    }
    
    // ฟังก์ชันหลักสำหรับเริ่มการคำนวณ
    func calculateScores() -> (isf: [NILR_Score], isp: [NILR_Score]) {
        // 1. สร้าง User-Location Matrix (เมทริกซ์ข้อมูลการเช็คอิน)
        let interactionMatrix = createInteractionMatrix()
        
        // 2. คำนวณคะแนน ISF และ ISP
        let isfScores = calculateISF(matrix: interactionMatrix)
        let ispScores = calculateISP(matrix: interactionMatrix)
        
        return (isf: isfScores, isp: ispScores)
    }
    
    // สร้างเมทริกซ์จำลองการมีอยู่ของข้อมูล (1 คือเคยไป, 0 คือไม่เคย)
    private func createInteractionMatrix() -> [[Double]] {
        var matrix = Array(repeating: Array(repeating: 0.0, count: places.count), count: members.count)
        
        for (userIndex, member) in members.enumerated() {
            for (placeIndex, place) in places.enumerated() {
                // เช็คว่า user คนนี้เคย check-in ที่สถานที่นี้หรือไม่
                let hasCheckedIn = activities.contains {
                    $0.memberEmail.lowercased() == member.email.lowercased() &&
                    $0.placeID == place.id.uuidString &&
                    $0.type == .checkIn
                }
                if hasCheckedIn {
                    matrix[userIndex][placeIndex] = 1.0
                }
            }
        }
        return matrix
    }
    
    // คำนวณ ISF (Iterative Scoring Function - ตามความถี่)
    private func calculateISF(matrix: [[Double]]) -> [NILR_Score] {
        guard !members.isEmpty, !places.isEmpty else { return [] }
        
        var userScores = Array(repeating: 1.0, count: members.count)
        var locationScores = Array(repeating: 0.0, count: places.count)
        
        for _ in 0..<3 { // ทำซ้ำ 3 รอบตามสคริปต์ Python
            // อัปเดตคะแนนสถานที่: l_score = u_score • R
            locationScores = dot(vector: userScores, matrix: matrix)
            
            // Normalize คะแนนสถานที่
            let normL = normalize(vector: locationScores)
            
            // อัปเดตคะแนนผู้ใช้: u_score = R • l_score
            userScores = dot(matrix: matrix, vector: normL)
            
            // Normalize คะแนนผู้ใช้
            userScores = normalize(vector: userScores)
        }
        
        // จัดเรียงผลลัพธ์
        let finalScores = normalize(vector: locationScores)
        var results: [NILR_Score] = []
        for (index, place) in places.enumerated() {
            results.append(NILR_Score(id: place.id, place: place, score: finalScores[index]))
        }
        
        return results.sorted { $0.score > $1.score }
    }
    
    // คำนวณ ISP (Iterative Scoring Preference - ตามความชอบ/กลับมาซ้ำ)
    private func calculateISP(matrix: [[Double]]) -> [NILR_Score] {
        guard !members.isEmpty, !places.isEmpty else { return [] }
        
        // prefU: ความชอบของผู้ใช้ (นับจำนวนสถานที่ที่ไปซ้ำ)
        let prefU = members.map { member in
            Double(Set(activities.filter { $0.memberEmail.lowercased() == member.email.lowercased() && $0.type == .checkIn }.map { $0.placeID }).count)
        }
        
        // prefL: ความนิยมของสถานที่ (นับจำนวนผู้ใช้ที่กลับมาซ้ำ)
        let prefL = places.map { place in
            Double(Set(activities.filter { $0.placeID == place.id.uuidString && $0.type == .checkIn }.map { $0.memberEmail }).count)
        }
        
        var userScores = Array(repeating: 1.0, count: members.count)
        var locationScores = Array(repeating: 0.0, count: places.count)
        
        for _ in 0..<3 {
            let weightedUserScores = zip(userScores, prefU).map(*)
            locationScores = dot(vector: Array(weightedUserScores), matrix: matrix)
            let normL = normalize(vector: locationScores)
            
            let weightedLocationScores = zip(normL, prefL).map(*)
            userScores = dot(matrix: matrix, vector: Array(weightedLocationScores))
            userScores = normalize(vector: userScores)
        }
        
        let finalScores = normalize(vector: locationScores)
        var results: [NILR_Score] = []
        for (index, place) in places.enumerated() {
            results.append(NILR_Score(id: place.id, place: place, score: finalScores[index]))
        }
        
        return results.sorted { $0.score > $1.score }
    }
    
    // --- Helper functions for matrix multiplication ---
    private func dot(vector: [Double], matrix: [[Double]]) -> [Double] {
        var result = Array(repeating: 0.0, count: matrix[0].count)
        for j in 0..<matrix[0].count {
            for i in 0..<vector.count {
                result[j] += vector[i] * matrix[i][j]
            }
        }
        return result
    }
    
    private func dot(matrix: [[Double]], vector: [Double]) -> [Double] {
        var result = Array(repeating: 0.0, count: matrix.count)
        for i in 0..<matrix.count {
            for j in 0..<vector.count {
                result[i] += matrix[i][j] * vector[j]
            }
        }
        return result
    }
    
    private func normalize(vector: [Double]) -> [Double] {
        let norm = sqrt(vector.map { $0 * $0 }.reduce(0, +))
        return norm > 0 ? vector.map { $0 / norm } : vector
    }
}
