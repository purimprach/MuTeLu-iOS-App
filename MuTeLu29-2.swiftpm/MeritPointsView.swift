import SwiftUI
import SwiftData

struct MeritPointsView: View {
    @Query(sort: \CheckInRecord.date, order: .reverse) private var allRecords: [CheckInRecord]
    
    @EnvironmentObject var language: AppLanguage
    @AppStorage("loggedInEmail") var loggedInEmail: String = ""
    
    private var userRecords: [CheckInRecord] {
        allRecords.filter { $0.memberEmail.lowercased() == loggedInEmail.lowercased() }
    }
    
    private var totalPoints: Int {
        userRecords.reduce(0) { $0 + $1.meritPoints }
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        return formatter
    }
    
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
    }
}
