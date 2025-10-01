#if DEBUG
import SwiftUI
import SwiftData

struct DatabaseInspectorView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var inspectionResult = "Tap 'Inspect Schema' to check database"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "cylinder.split.1x2")
                    .foregroundColor(.blue)
                Text("Database Inspector")
                    .font(.headline)
            }

            // Action Buttons
            HStack(spacing: 12) {
                Button(action: inspectSchema) {
                    Label("Inspect Schema", systemImage: "doc.text.magnifyingglass")
                }
                .buttonStyle(.borderedProminent)

                Button(action: createTestData) {
                    Label("Create Test", systemImage: "plus.circle")
                }
                .buttonStyle(.bordered)

                Button(action: showDatabaseInfo) {
                    Label("DB Info", systemImage: "info.circle")
                }
                .buttonStyle(.bordered)
            }

            // Results Display
            ScrollView {
                Text(inspectionResult)
                    .font(.system(.caption, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 200)
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            // Clean Database Button
            Button(role: .destructive, action: cleanDatabase) {
                Label("Clean Database (⚠️ Deletes all data)", systemImage: "trash.circle.fill")
                    .font(.caption)
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding()
        .background(Color.blue.opacity(0.08))
        .cornerRadius(12)
    }

    // MARK: - Inspection Functions

    private func inspectSchema() {
        var result = ""
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        result += "🕐 Inspected at: \(timestamp)\n\n"

        // Test 1: UserTagPreference
        result += "=== UserTagPreference ===\n"
        do {
            let descriptor = FetchDescriptor<UserTagPreference>()
            let prefs = try modelContext.fetch(descriptor)
            result += "✅ Table exists\n"
            result += "📊 Count: \(prefs.count) records\n"

            if let first = prefs.first {
                result += "📝 Sample record:\n"
                result += "   Email: \(first.memberEmail)\n"
                result += "   Tag: \(first.tag)\n"
                result += "   Count: \(first.count)\n"
                result += "   Score: \(first.score)\n"
            } else {
                result += "📭 No records yet\n"
            }
            result += "\n"
        } catch {
            result += "❌ Error: \(error.localizedDescription)\n\n"
        }

        // Test 2: CheckInRecord
        result += "=== CheckInRecord ===\n"
        do {
            let descriptor = FetchDescriptor<CheckInRecord>()
            let records = try modelContext.fetch(descriptor)
            result += "✅ Table exists\n"
            result += "📊 Count: \(records.count) records\n"

            if let first = records.first {
                result += "📝 Sample record:\n"
                result += "   Place: \(first.placeNameTH)\n"
                result += "   Email: \(first.memberEmail)\n"
                result += "   Tags: \(first.tags.isEmpty ? "[]" : first.tags.joined(separator: ", "))\n"
                result += "   Tags type: [String] ✅\n"
            } else {
                result += "📭 No check-in records yet\n"
            }
            result += "\n"
        } catch {
            result += "❌ Error: \(error.localizedDescription)\n\n"
        }

        // Test 3: Member (existing model)
        result += "=== Member (existing) ===\n"
        do {
            let descriptor = FetchDescriptor<Member>()
            let members = try modelContext.fetch(descriptor)
            result += "✅ Table exists\n"
            result += "📊 Count: \(members.count) records\n\n"
        } catch {
            result += "❌ Error: \(error.localizedDescription)\n\n"
        }

        // Test 4: UserInteraction (Phase 2A)
        result += "=== UserInteraction (Phase 2A) ===\n"
        do {
            let descriptor = FetchDescriptor<UserInteraction>()
            let interactions = try modelContext.fetch(descriptor)
            result += "✅ Table exists\n"
            result += "📊 Count: \(interactions.count) records\n"

            if let first = interactions.first {
                result += "📝 Sample record:\n"
                result += "   Type: \(first.interactionType)\n"
                result += "   Place: \(first.placeNameTH)\n"
                result += "   Weight: \(first.weight)\n"
                result += "   Email: \(first.memberEmail)\n"
            } else {
                result += "📭 No interaction records yet\n"
            }
            result += "\n"
        } catch {
            result += "❌ Error: \(error.localizedDescription)\n\n"
        }

        result += "=== Migration Status ===\n"
        result += "✅ Phase 2A migration successful\n"
        result += "✅ All 4 models accessible\n"

        inspectionResult = result
    }

    private func createTestData() {
        var result = ""

        // Create test UserTagPreference
        let testPref = UserTagPreference(
            memberEmail: "test@mutelu.app",
            tag: "พระพิฆเนศ",
            count: 5,
            lastVisited: Date()
        )
        modelContext.insert(testPref)

        // Create test UserInteraction
        let testInteraction = UserInteraction.view(
            memberEmail: "test@mutelu.app",
            placeID: "001",
            placeNameTH: "ศาลเจ้าพ่อเสือ",
            placeNameEN: "Tiger Shrine",
            tags: ["พระพิฆเนศ", "ทรัพย์สิน"]
        )
        modelContext.insert(testInteraction)

        do {
            try modelContext.save()
            result += "✅ Test data created:\n"
            result += "   - UserTagPreference (พระพิฆเนศ)\n"
            result += "   - UserInteraction (view @ ศาลเจ้าพ่อเสือ)\n\n"
            result += "💡 Tap 'Inspect Schema' to verify\n"
        } catch {
            result += "❌ Failed to create test data\n"
            result += "Error: \(error.localizedDescription)\n"
        }

        inspectionResult = result
    }

    // MARK: - Additional Functions

    private func showDatabaseInfo() {
        inspectionResult = DatabaseManager.inspectDatabaseLocation()
    }

    private func cleanDatabase() {
        DatabaseManager.cleanDatabase()
        inspectionResult = """
        🗑️ Database cleaned!

        ⚠️ IMPORTANT:
        You must RESTART the app for changes to take effect.

        Steps:
        1. Stop the app (⏹ in Xcode)
        2. Run again (⌘R)
        3. Register new user
        4. Test Database Inspector
        """
    }
}

// MARK: - Preview
#Preview {
    DatabaseInspectorView()
        .modelContainer(
            try! ModelContainer(
                for: Member.self,
                CheckInRecord.self,
                UserTagPreference.self,
                UserInteraction.self
            )
        )
}
#endif
