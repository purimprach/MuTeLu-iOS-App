import SwiftUI

struct RecommendedTempleBanner: View {
    @EnvironmentObject var language: AppLanguage
    var currentMember: Member?
    
    var body: some View {
        // ใช้ logic เดิม: ถ้าไม่มีวันเกิด -> ใช้ "วันนี้" ถ้ามี -> ใช้วันเกิด
        let temple = getRecommendedTemple(for: currentMember)
        
        // ✅ คำนวณ heading ก่อน แล้วค่อยใช้ใน View
        let headingTH: String
        let headingEN: String
        if let bday = currentMember?.birthdate {
            let (th, en) = weekdayName(for: bday)
            headingTH = "แนะนำวัดที่เหมาะกับคนเกิดวัน\(th)"
            headingEN = "Recommended temple for \(en) birthday"
        } else {
            headingTH = "แนะนำวัดที่เหมาะกับวันนี้"
            headingEN = "Today’s Temple"
        }
        
        // ✅ ค่อยสร้าง View จาก String ที่ได้
        return VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(language.localized(headingTH, headingEN))
                    .font(.headline)
            } icon: {
                Image(systemName: "building.columns")
                    .foregroundColor(.red)
            }
            
            HStack(spacing: 12) {
                Image(temple.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .center, spacing: 4) {
                    Text(language.localized(temple.nameTH, temple.nameEN))
                        .font(.title3).bold()
                        .foregroundColor(.blue)
                    
                    Text(language.localized(temple.descTH, temple.descEN))
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                        .lineLimit(3)
                }
            }
        }
        .padding()
        .frame(maxWidth: 600)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(radius: 6)
    }
}

/// ฟังก์ชันช่วยคืนชื่อวันเป็นไทย/อังกฤษ
func weekdayName(for date: Date) -> (th: String, en: String) {
    let df = DateFormatter()
    
    df.locale = Locale(identifier: "th_TH")
    df.dateFormat = "EEEE"
    let th = df.string(from: date)
    
    df.locale = Locale(identifier: "en_US")
    let en = df.string(from: date)
    
    return (th, en)
}
