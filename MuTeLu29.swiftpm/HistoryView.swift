import SwiftUI
import SwiftData

struct HistoryView: View {
    // 1. ดึงข้อมูล CheckInRecord ทั้งหมด และเรียงตามวันที่ล่าสุด
    @Query(sort: \CheckInRecord.date, order: .reverse) private var allRecords: [CheckInRecord]
    
    @EnvironmentObject var language: AppLanguage
    @AppStorage("loggedInEmail") var loggedInEmail: String = ""
    
    // 2. กรองข้อมูลเฉพาะของ User ที่ Login อยู่
    private var userRecords: [CheckInRecord] {
        allRecords.filter { $0.memberEmail.lowercased() == loggedInEmail.lowercased() }
    }
    
    var formatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        f.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        return f
    }
    
    var body: some View {
        VStack {
            if userRecords.isEmpty {
                Spacer()
                Text(language.localized("ยังไม่มีประวัติการเช็คอิน", "No check-in history yet"))
                    .foregroundColor(.gray)
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
                            Text("+\(record.meritPoints) \(language.localized("แต้มบุญ", "merit points"))")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}
