import SwiftUI

struct BuddhistDayBanner: View {
    @Environment(\.colorScheme) private var scheme            
    @EnvironmentObject var language: AppLanguage
    
    let today = Calendar.current.startOfDay(for: Date())
    let nextHolyDays: [Date] = loadBuddhistDays()
    
    private var nextHolyDay: Date? {
        nextHolyDays.first { $0 >= today }
    }
    
    private var isTodayBuddhistDay: Bool {
        nextHolyDay.map { Calendar.current.isDate($0, inSameDayAs: today) } ?? false
    }
    
    private var daysRemaining: Int? {
        guard let next = nextHolyDay else { return nil }
        return Calendar.current.dateComponents([.day], from: today, to: next).day
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isTodayBuddhistDay {
                Label {
                    Text(language.localized("วันนี้เป็นวันพระ", "Today is a Buddhist Holy Day"))
                        .font(.title3)
                        .foregroundColor(Color(.label))
                } icon: {
                    Image(systemName: "cloud.sun.fill")
                        .foregroundColor(.red)
                }
                
                Text("🙏  \(language.localized("อย่าลืมสวดมนต์ ทำบุญ หรือเจริญสติ ลองหาซื้อพวงมาลัยหรือดอกไม้ไปไหว้สิ่งศักดิ์สิทธิ์ใกล้ๆ ตัว หิ้งพระที่บ้านก็ได้ เสริมดวงได้ดีเลย", "Don’t forget to pray, make merit, or practice mindfulness. You can also offer garlands or flowers to nearby sacred sites—even your home shrine. It’s a great way to enhance your fortune."))")
                    .font(.footnote)
                    .foregroundColor(Color(.secondaryLabel))
                
            } else if let days = daysRemaining {
                Label {
                    Text(language.localized("อีก \(days) วันจะเป็นวันพระ", "\(days) day(s) until the next Buddhist Holy Day"))
                        .font(.headline)
                        .foregroundColor(Color(.label))
                } icon: {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.red)
                }
                
                if let next = nextHolyDay {
                    Text("📆 \(formattedDate(next))")
                        .font(.footnote)
                        .foregroundColor(Color(.secondaryLabel))
                }
            } else {
                Label(language.localized("ไม่พบข้อมูลวันพระ", "No upcoming Buddhist day found"),
                      systemImage: "exclamationmark.triangle.fill")
                .foregroundColor(Color(.label))
            }
        }
        .padding()
        .frame(maxWidth: 600)
        .background(Color(.secondarySystemBackground))              // ✅ การ์ดไดนามิก
        .cornerRadius(16)
        .overlay(                                                    // ✅ เส้นขอบบาง ๆ
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .shadow(                                                     // ✅ เงาปรับตามโหมด
            color: .black.opacity(scheme == .dark ? 0.15 : 0.25),
            radius: scheme == .dark ? 4 : 8, x: 0, y: 3
        )
        .padding(.horizontal)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

// MARK: - Data

func loadBuddhistDays() -> [Date] {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)   // ใช้ ค.ศ.
    formatter.dateFormat = "yyyy-MM-dd"
    
    return [
        // มิถุนายน 2025
        "2025-06-03","2025-06-10","2025-06-18","2025-06-25",
        // กรกฎาคม 2025
        "2025-07-03","2025-07-10","2025-07-11","2025-07-18","2025-07-25",
        // สิงหาคม 2025
        "2025-08-02","2025-08-09","2025-08-17","2025-08-23","2025-08-31",
        // กันยายน 2025
        "2025-09-07","2025-09-15","2025-09-22","2025-09-30",
        // ตุลาคม 2025  (หมายเหตุ: มีวันที่ 19 และ 21)
        "2025-10-07","2025-10-15","2025-10-19","2025-10-21",
        // พฤศจิกายน 2025
        "2025-11-05","2025-11-13","2025-11-20","2025-11-28",
        // ธันวาคม 2025
        "2025-12-05","2025-12-13","2025-12-19","2025-12-27"
    ]
        .compactMap { formatter.date(from: $0) }
        .map { Calendar.current.startOfDay(for: $0) }
}
