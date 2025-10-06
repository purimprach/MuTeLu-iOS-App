import SwiftUI

struct CategoryResultView: View {
    let selectedTag: String
    let allPlaces: [SacredPlace]
    
    @EnvironmentObject var language: AppLanguage
    
    private var filteredPlaces: [SacredPlace] {
        allPlaces.filter { $0.tags.contains(selectedTag) }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if filteredPlaces.isEmpty {
                    Text(language.localized("ไม่พบสถานที่ในหมวดหมู่นี้", "No places found in this category."))
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredPlaces) { place in
                            PlaceRow(place: place, routeDistance: nil)
                        }
                    }
                    .padding(.top)
                }
            }
        }
        // vvv ส่วนที่แก้ไข vvv
        // เรียกใช้ฟังก์ชันแปลภาษาสำหรับหัวข้อของหน้า
        .navigationTitle(language.localized(selectedTag, translateTag(th: selectedTag)))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
    
    // vvv ส่วนที่เพิ่มเข้ามาใหม่ vvv
    // เพิ่มฟังก์ชันแปลภาษาเข้ามาในไฟล์นี้ด้วย
    private func translateTag(th: String) -> String {
        switch th {
        case "การเรียน/การสอบ": return "Education/Exams"
        case "การงาน/ความสำเร็จ": return "Career/Success"
        case "ขอพร": return "Making a Wish"
        case "การเงิน/โชคลาภ": return "Finance/Luck"
        case "ค้าขาย": return "Business/Trade"
        case "สุขภาพ": return "Health"
        case "ความเจริญรุ่งเรือง": return "Prosperity"
        case "แคล้วคลาดปลอดภัย": return "Safety"
        case "ความรัก/ครอบครัว": return "Love/Family"
        case "เสริมดวง/แก้เคราะห์": return "Fortune Enhancement"
        default: return th
        }
    }
}
