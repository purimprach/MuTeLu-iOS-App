import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var checkInStore: CheckInStore
    @AppStorage("loggedInEmail") var loggedInEmail: String = ""
    
    @State private var userRecords: [CheckInRecord] = []
    
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
                            Text("+\(record.meritPoints) \(language.localized("แต้มบุญ", "merit points"))")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .onAppear {
            userRecords = checkInStore.records(for: loggedInEmail)
                .sorted { $0.date > $1.date }
        }
    }
}
