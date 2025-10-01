import Foundation
import SwiftData

/// Service สำหรับ track user interactions และอัพเดท tag preferences
@MainActor
class InteractionTracker: ObservableObject {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Track Interactions

    /// Track when user views place detail
    func trackView(
        placeID: String,
        placeNameTH: String,
        placeNameEN: String,
        tags: [String],
        memberEmail: String
    ) {
        let interaction = UserInteraction.view(
            memberEmail: memberEmail,
            placeID: placeID,
            placeNameTH: placeNameTH,
            placeNameEN: placeNameEN,
            tags: tags
        )

        modelContext.insert(interaction)
        try? modelContext.save()

        // Update tag preferences with weight 0.3
        updateTagPreferences(
            memberEmail: memberEmail,
            tags: tags,
            weight: 0.3
        )
    }

    /// Track when user opens map for navigation
    func trackMapOpen(
        placeID: String,
        placeNameTH: String,
        placeNameEN: String,
        tags: [String],
        memberEmail: String
    ) {
        let interaction = UserInteraction.mapOpen(
            memberEmail: memberEmail,
            placeID: placeID,
            placeNameTH: placeNameTH,
            placeNameEN: placeNameEN,
            tags: tags
        )

        modelContext.insert(interaction)
        try? modelContext.save()

        // Update tag preferences with weight 0.5
        updateTagPreferences(
            memberEmail: memberEmail,
            tags: tags,
            weight: 0.5
        )
    }

    /// Track check-in (highest weight)
    func trackCheckIn(
        placeID: String,
        placeNameTH: String,
        placeNameEN: String,
        tags: [String],
        memberEmail: String
    ) {
        let interaction = UserInteraction.checkIn(
            memberEmail: memberEmail,
            placeID: placeID,
            placeNameTH: placeNameTH,
            placeNameEN: placeNameEN,
            tags: tags
        )

        modelContext.insert(interaction)
        try? modelContext.save()

        // Update tag preferences with weight 1.0
        updateTagPreferences(
            memberEmail: memberEmail,
            tags: tags,
            weight: 1.0
        )
    }

    // MARK: - Update Tag Preferences

    private func updateTagPreferences(
        memberEmail: String,
        tags: [String],
        weight: Double
    ) {
        for tag in tags {
            // ค้นหา existing preference
            let descriptor = FetchDescriptor<UserTagPreference>(
                predicate: #Predicate { pref in
                    pref.memberEmail == memberEmail && pref.tag == tag
                }
            )

            if let existing = try? modelContext.fetch(descriptor).first {
                // เพิ่มคะแนนด้วย weighted increment (scale ×10 เพื่อให้เป็น integer)
                existing.count += Int(weight * 10)
                existing.lastVisited = Date()
                existing.score = Double(existing.count)
            } else {
                // สร้างใหม่
                let newPref = UserTagPreference(
                    memberEmail: memberEmail,
                    tag: tag,
                    count: Int(weight * 10),
                    lastVisited: Date()
                )
                modelContext.insert(newPref)
            }
        }

        try? modelContext.save()
    }

    // MARK: - Cleanup Old Data (90 days policy)

    /// ลบ interactions ที่เก่ากว่า 90 วัน
    func cleanupOldInteractions() {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()

        let descriptor = FetchDescriptor<UserInteraction>(
            predicate: #Predicate { interaction in
                interaction.timestamp < cutoffDate
            }
        )

        if let oldInteractions = try? modelContext.fetch(descriptor) {
            for interaction in oldInteractions {
                modelContext.delete(interaction)
            }
            try? modelContext.save()
            print("🗑️ Cleaned up \(oldInteractions.count) old interactions")
        }
    }
}
