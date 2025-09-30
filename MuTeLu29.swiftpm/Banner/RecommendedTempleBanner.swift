import SwiftUI

struct RecommendedTempleBanner: View {
    @EnvironmentObject var language: AppLanguage
    var currentMember: Member?
    var onTap: (() -> Void)? = nil   // แตะทั้งใบได้ (ไม่บังคับส่ง)
    
    var body: some View {
        let temple = getRecommendedTemple(for: currentMember)
        
        // Heading
        let headingTH: String
        let headingEN: String
        if let bday = currentMember?.birthdate {
            let (th, en) = weekdayName2(for: bday)
            headingTH = "แนะนำวัดที่เหมาะกับคนเกิดวัน\(th)"
            headingEN = "Recommended temple for \(en)-born"
        } else {
            headingTH = "แนะนำวัดที่เหมาะกับวันนี้"
            headingEN = "Today’s Temple"
        }
        
        return VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(language.localized(headingTH, headingEN))
                    .font(.headline)
            } icon: {
                Image(systemName: "building.columns").foregroundColor(.red)
            }
            
            ZStack(alignment: .bottomLeading) {
                bannerImage(named: temple.imageName)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                LinearGradient(
                    colors: [.clear, .black.opacity(0.55)],
                    startPoint: .center, endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(language.localized(temple.nameTH, temple.nameEN))
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                    
                    Text(language.localized(temple.descTH, temple.descEN))
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.95))
                        .lineLimit(2)
                }
                .padding(14)
            }
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .onTapGesture { onTap?() }
        }
        .padding()
        .frame(maxWidth: 600)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(Color.primary.opacity(0.06), lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
    }
    
    // MARK: helpers
    
    @ViewBuilder
    private func bannerImage(named: String) -> some View {
        if UIImage(named: named) != nil {
            Image(named).resizable().scaledToFill()
        } else {
            ZStack {
                LinearGradient(colors: [.pink, .orange],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "photo")
                    .font(.largeTitle).foregroundColor(.white.opacity(0.85))
            }
            .scaledToFill()
        }
    }
}
/// วันอาทิตย์...เสาร์ / Sunday...Saturday แบบแม่นยำด้วย Calendar
func weekdayName2(for date: Date) -> (th: String, en: String) {
    let w = Calendar(identifier: .gregorian).component(.weekday, from: date) // 1=Sun..7=Sat
    let ths = ["อาทิตย์","จันทร์","อังคาร","พุธ","พฤหัส","ศุกร์","เสาร์"]
    let ens = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    let i = max(1, min(7, w)) - 1
    return (ths[i], ens[i])
}
