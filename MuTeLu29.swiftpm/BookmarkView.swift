import SwiftUI

struct BookmarkView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var bookmarkStore: BookmarkStore
    @StateObject private var viewModel = SacredPlaceViewModel() // ใช้เพื่อดึงข้อมูลสถานที่ทั้งหมด
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    
    // ดึงรายการที่บันทึกไว้ของผู้ใช้คนปัจจุบัน
    private var bookmarkedRecords: [BookmarkRecord] {
        bookmarkStore.getBookmarks(for: loggedInEmail)
    }
    
    var body: some View {
        VStack {
            // --- Header ---
            HStack {
                Button(action: {
                    // ใช้ flowManager เพื่อย้อนกลับไปหน้า Home หรือ Profile ก็ได้
                    // ในที่นี้เราจะกลับไป Home ก่อน
                    flowManager.currentScreen = .home
                }) {
                    Label(language.localized("ย้อนกลับ", "Back"), systemImage: "chevron.left")
                }
                Spacer()
            }
            .padding()
            
            Text("📍 \(language.localized("สถานที่ที่บันทึกไว้", "Bookmarked Places"))")
                .font(.title2.bold())
                .padding(.bottom)
            
            // --- List of Bookmarks ---
            if bookmarkedRecords.isEmpty {
                Spacer()
                Text(language.localized("คุณยังไม่ได้บันทึกสถานที่ใดๆ", "You haven't bookmarked any places yet."))
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                List(bookmarkedRecords) { record in
                    // หาข้อมูลสถานที่เต็มๆ จาก ID ที่บันทึกไว้
                    if let place = viewModel.places.first(where: { $0.id.uuidString == record.placeID }) {
                        BookmarkRow(place: place, record: record)
                            .onTapGesture {
                                // เมื่อกดที่รายการ ให้ไปที่หน้ารายละเอียด
                                flowManager.currentScreen = .sacredDetail(place: place)
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

// --- Subview สำหรับแสดงผล 1 รายการ ---
struct BookmarkRow: View {
    let place: SacredPlace
    let record: BookmarkRecord
    @EnvironmentObject var language: AppLanguage
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Image(place.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .cornerRadius(12)
                .clipped()
            
            VStack(alignment: .leading, spacing: 5) {
                Text(language.localized(place.nameTH, place.nameEN))
                    .font(.headline)
                    .lineLimit(2)
                
                Text(language.localized("บันทึกเมื่อ: ", "Saved on: ") + dateFormatter.string(from: record.savedDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(.vertical, 8)
    }
}
