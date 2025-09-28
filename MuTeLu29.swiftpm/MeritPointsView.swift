import SwiftUI

struct MeritPointsView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var checkInStore: CheckInStore
    @AppStorage("loggedInEmail") var loggedInEmail: String = ""
    
    @State private var userRecords: [CheckInRecord] = []
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        formatter.calendar = Calendar(identifier: language.currentLanguage == "th" ? .buddhist : .gregorian)
        return formatter
    }
    
    var totalPoints: Int {
        userRecords.map { $0.meritPoints }.reduce(0, +)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            BackButton()
            // 💜 คะแนนรวม
            VStack(spacing: 8) {
                Text(language.localized("คะแนนแต้มบุญทั้งหมด", "Total Merit Points"))
                    .font(.headline)
                
                Text("\(totalPoints) 🟣")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.purple)
            }
            .padding(.top)
            
            // 📋 รายการแต้มบุญ
            if userRecords.isEmpty {
                Spacer()
                Text(language.localized("ยังไม่มีประวัติแต้มบุญ", "No merit history yet"))
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(userRecords) { record in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(language.currentLanguage == "th" ? record.placeNameTH : record.placeNameEN)
                                .font(.headline)
                            Text(dateFormatter.string(from: record.date))
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("+\(record.meritPoints) \(language.localized("แต้ม", "points"))")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
        }
        .padding(.top)
        .onAppear {
            checkInStore.load()
            userRecords = checkInStore.records(for: loggedInEmail).sorted { $0.date > $1.date }
        }
    }
}
