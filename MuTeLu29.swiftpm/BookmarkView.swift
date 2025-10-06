import SwiftUI

struct BookmarkView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var bookmarkStore: BookmarkStore
    @StateObject private var viewModel = SacredPlaceViewModel()
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    
    // ดึงรายการที่บันทึกไว้ของผู้ใช้คนปัจจุบัน
    private var bookmarkedRecords: [BookmarkRecord] {
        bookmarkStore.getBookmarks(for: loggedInEmail)
    }
    
    var body: some View {
        VStack {
            // vvv ส่วนที่แก้ไข vvv
            // --- ลบ Header และปุ่ม "ย้อนกลับ" ที่สร้างเองออกไปจากตรงนี้ ---
            
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
        // vvv ส่วนที่แก้ไข vvv
        // --- ตั้งชื่อหัวข้อของหน้าให้สวยงาม ---
        .navigationTitle("📍 \(language.localized("สถานที่บันทึกไว้", "Bookmarked Places"))")
        .navigationBarTitleDisplayMode(.inline) // ทำให้หัวข้อเล็กลง
    }
}

// --- Subview สำหรับแสดงผล 1 รายการ (ไม่ต้องแก้ไข) ---
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
