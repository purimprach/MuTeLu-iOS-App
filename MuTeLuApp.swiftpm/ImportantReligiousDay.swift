import SwiftUI

struct ImportantReligiousDay {
    let date: Date
    let nameTH: String
    let nameEN: String
}

func loadImportantReligiousDays() -> [ImportantReligiousDay] {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.dateFormat = "yyyy-MM-dd"
    
    let rawDays: [(String, String, String)] = [
        ("2025-06-03", "วันเฉลิมพระชนมพรรษาสมเด็จพระนางเจ้าฯ พระบรมราชินี", "HM the Queen’s Birthday"),
        ("2025-07-10", "วันอาสาฬหบูชา", "Asalha Puja Day"),
        ("2025-07-11", "วันเข้าพรรษา", "Buddhist Lent Day"),
        ("2025-07-28", "วันเฉลิมพระชนมพรรษา ร.10", "HM King Rama X’s Birthday"),
        ("2025-08-12", "วันแม่แห่งชาติ", "HM the Queen Mother’s Birthday / Mother’s Day"),
        ("2025-10-07", "วันออกพรรษา", "End of Buddhist Lent"),
        ("2025-10-13", "วันคล้ายวันสวรรคต ร.9", "HM King Rama IX Memorial Day"),
        ("2025-10-23", "วันปิยมหาราช", "King Chulalongkorn Memorial Day"),
        ("2025-12-05", "วันพ่อแห่งชาติ", "Father’s Day / King Rama IX’s Birthday"),
        ("2025-12-10", "วันรัฐธรรมนูญ", "Constitution Day"),
        ("2025-12-31", "วันสิ้นปี", "New Year’s Eve")
    ]
    
    return rawDays.compactMap { (dateStr, nameTH, nameEN) in
        guard let date = formatter.date(from: dateStr) else { return nil }
        return ImportantReligiousDay(
            date: Calendar.current.startOfDay(for: date),
            nameTH: nameTH, nameEN: nameEN
        )
    }
}

struct ReligiousHolidayBanner: View {
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject var language: AppLanguage
    
    private let today = Calendar.current.startOfDay(for: Date())
    private let importantDays = loadImportantReligiousDays()
    
    private var nextImportantDay: ImportantReligiousDay? {
        importantDays.first { $0.date >= today }
    }
    
    private var daysRemaining: Int? {
        guard let next = nextImportantDay else { return nil }
        return Calendar.current.dateComponents([.day], from: today, to: next.date).day
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let next = nextImportantDay, let days = daysRemaining {
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(language.localized("อีก \(days) วันถึง", "\(days) day(s) until"))
                            .font(.headline)
                            .foregroundColor(Color(.label))
                        Text(language.localized(next.nameTH, next.nameEN))
                            .font(.subheadline)
                            .foregroundColor(Color(.label))
                    }
                } icon: {
                    Image(systemName: "sparkles")
                        .foregroundColor(.blue)
                }
                
                Text("📅  \(formattedDate(next.date))")
                    .font(.footnote)
                    .foregroundColor(Color(.secondaryLabel))
            } else {
                Label(language.localized("ไม่พบวันสำคัญถัดไป", "No upcoming important day found"),
                      systemImage: "calendar.badge.exclamationmark")
                .foregroundColor(Color(.label))
            }
        }
        .padding()
        .frame(maxWidth: 600)
        .background(Color(.secondarySystemBackground))        // ✅ การ์ดไดนามิก
        .cornerRadius(16)
        .overlay(                                             // ✅ เส้นขอบบาง ๆ
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .shadow(                                              // ✅ เงาปรับตามโหมด
            color: .black.opacity(scheme == .dark ? 0.15 : 0.25),
            radius: scheme == .dark ? 4 : 8, x: 0, y: 3
        )
        .padding(.horizontal)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

