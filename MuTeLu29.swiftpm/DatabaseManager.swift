#if DEBUG
import Foundation

/// Database management utilities (DEBUG only)
class DatabaseManager {

    /// ลบ SwiftData database files ทั้งหมด
    /// ⚠️ ใช้เฉพาะตอน debug เท่านั้น!
    static func cleanDatabase() {
        let fileManager = FileManager.default

        // หา application support directory
        guard let appSupport = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            print("❌ Cannot find application support directory")
            return
        }

        print("🔍 Searching for database files in: \(appSupport.path)")

        do {
            let contents = try fileManager.contentsOfDirectory(
                at: appSupport,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )

            var deletedCount = 0

            for url in contents {
                let ext = url.pathExtension.lowercased()

                // ลบไฟล์ที่เกี่ยวกับ SQLite
                if ext == "sqlite" ||
                   ext == "sqlite-shm" ||
                   ext == "sqlite-wal" ||
                   url.lastPathComponent.contains("default.store") {

                    do {
                        try fileManager.removeItem(at: url)
                        print("🗑️ Deleted: \(url.lastPathComponent)")
                        deletedCount += 1
                    } catch {
                        print("⚠️ Could not delete \(url.lastPathComponent): \(error)")
                    }
                }
            }

            if deletedCount > 0 {
                print("✅ Cleaned \(deletedCount) database file(s)")
            } else {
                print("ℹ️ No database files found to clean")
            }

        } catch {
            print("❌ Error scanning directory: \(error.localizedDescription)")
        }
    }

    /// แสดงข้อมูล database location และขนาด
    static func inspectDatabaseLocation() -> String {
        let fileManager = FileManager.default
        var result = ""

        guard let appSupport = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            return "❌ Cannot find directory"
        }

        result += "📂 Database Location:\n"
        result += "   \(appSupport.path)\n\n"

        do {
            let contents = try fileManager.contentsOfDirectory(
                at: appSupport,
                includingPropertiesForKeys: [.fileSizeKey],
                options: []
            )

            result += "📊 Database Files:\n"

            var foundFiles = false

            for url in contents {
                let ext = url.pathExtension.lowercased()
                if ext == "sqlite" || ext == "sqlite-shm" || ext == "sqlite-wal" || url.lastPathComponent.contains("default.store") {
                    foundFiles = true
                    let attrs = try? fileManager.attributesOfItem(atPath: url.path)
                    let size = attrs?[.size] as? Int64 ?? 0
                    let sizeKB = Double(size) / 1024.0
                    result += "   • \(url.lastPathComponent) (\(String(format: "%.1f", sizeKB)) KB)\n"
                }
            }

            if !foundFiles {
                result += "   (No database files found)\n"
            }

        } catch {
            result += "❌ Error: \(error.localizedDescription)\n"
        }

        return result
    }
}
#endif
