import SwiftUI

struct MeritPointsView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    
    // --- vvv จุดที่แก้ไข vvv ---
    @EnvironmentObject var activityStore: ActivityStore // ✅ เปลี่ยนมาใช้ ActivityStore
    // --- ^^^ จุดที่แก้ไข ^^^ ---
    
    @AppStorage("loggedInEmail") var loggedInEmail: String = ""
    
    // State สำหรับเก็บประวัติ (เปลี่ยนเป็น ActivityRecord)
    @State private var userRecords: [ActivityRecord] = []
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        formatter.calendar = Calendar(identifier: language.currentLanguage == "th" ? .buddhist : .gregorian)
        return formatter
    }
    
    // --- vvv จุดที่แก้ไข vvv ---
    // ✅ คำนวณแต้มบุญทั้งหมดจาก ActivityStore
    var totalPoints: Int {
        activityStore.totalMeritPoints(for: loggedInEmail)
    }
    // --- ^^^ จุดที่แก้ไข ^^^ ---
    
    var body: some View {
        VStack(spacing: 16) {
            BackButton()
            VStack(spacing: 8) {
                Text(language.localized("คะแนนแต้มบุญทั้งหมด", "Total Merit Points"))
                    .font(.headline)
                
                Text("\(totalPoints) 🟣")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.purple)
            }
            .padding(.top)
            
            if userRecords.isEmpty {
                Spacer()
                Text(language.localized("ยังไม่มีประวัติแต้มบุญ", "No merit history yet"))
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    // --- vvv จุดที่แก้ไข vvv ---
                    // ✅ วนลูปจาก userRecords ที่เป็น [ActivityRecord]
                    ForEach(userRecords) { record in
                        // ตรวจสอบว่าเป็น activity ประเภท checkIn เท่านั้น
                        if record.type == .checkIn {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(language.currentLanguage == "th" ? record.placeNameTH : record.placeNameEN)
                                    .font(.headline)
                                Text(dateFormatter.string(from: record.date))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                // ใช้ optional unwrap สำหรับ meritPoints
                                if let points = record.meritPoints {
                                    Text("+\(points) \(language.localized("แต้ม", "points"))")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    // --- ^^^ จุดที่แก้ไข ^^^ ---
                }
            }
        }
        .padding(.top)
        .onAppear {
            // --- vvv จุดที่แก้ไข vvv ---
            // ✅ ดึงข้อมูลจาก ActivityStore
            userRecords = activityStore.checkInRecords(for: loggedInEmail).sorted { $0.date > $1.date }
            // --- ^^^ จุดที่แก้ไข ^^^ ---
        }
    }
}
