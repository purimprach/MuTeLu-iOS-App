import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    
    // --- vvv จุดที่แก้ไข vvv ---
    @EnvironmentObject var activityStore: ActivityStore // ✅ เปลี่ยนมาใช้ ActivityStore
    // --- ^^^ จุดที่แก้ไข ^^^ ---
    
    @AppStorage("loggedInEmail") var loggedInEmail: String = ""
    
    @State private var userRecords: [ActivityRecord] = []
    
    var formatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        f.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        f.calendar = Calendar(identifier: language.currentLanguage == "th" ? .buddhist : .gregorian)
        return f
    }
    
    var body: some View {
        VStack {
            if userRecords.isEmpty {
                Spacer()
                Text(language.localized("ยังไม่มีประวัติการเช็คอิน", "No check-in history yet"))
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                List {
                    ForEach(userRecords) { record in
                        VStack(alignment: .leading) {
                            Text(language.currentLanguage == "th" ? record.placeNameTH : record.placeNameEN)
                                .bold()
                            Text(formatter.string(from: record.date))
                                .font(.caption)
                                .foregroundColor(.gray)
                            // ใช้ optional unwrap สำหรับ meritPoints
                            if let points = record.meritPoints {
                                Text("+\(points) \(language.localized("แต้มบุญ", "merit points"))")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .onAppear {
            // --- vvv จุดที่แก้ไข vvv ---
            // ✅ ดึงข้อมูล check-in จาก ActivityStore
            userRecords = activityStore.checkInRecords(for: loggedInEmail)
                .sorted { $0.date > $1.date }
            // --- ^^^ จุดที่แก้ไข ^^^ ---
        }
    }
}
