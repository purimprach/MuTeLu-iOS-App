import SwiftUI
import CoreLocation

struct RecommenderForYouView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    
    // ดึง member ปัจจุบันอัตโนมัติ ถ้าไม่ได้ส่ง currentMember มา
    @EnvironmentObject private var memberStore: MemberStore
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    
    /// ถ้าหน้าอื่นอยากส่ง member มาก็ได้ (จะ override อันอัตโนมัติ
    var currentMember: Member? = nil
    
    // member ที่จะใช้จริง
    private var activeMember: Member? {
        currentMember ?? memberStore.members.first { $0.email == loggedInEmail }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                HStack {
                    Button { flowManager.currentScreen = .home } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .padding(8)
                    }
                    Spacer()
                    Text(language.localized("สำหรับคุณ", "For You"))
                        .font(.title3).bold()
                    Spacer().frame(width: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // การ์ด 1: วันนี้
                TempleBannerCard(
                    headingTH: "แนะนำวัดเหมาะกับวันนี้",
                    headingEN: "Today’s Temple",
                    memberOverride: nil,
                    openDetail: { flowManager.currentScreen = .recommendation }
                )
                .environmentObject(language)
                
                // การ์ด 2: ตามวันเกิด (ถ้ามี)
                if let heading = birthdayHeading(for: activeMember) {
                    TempleBannerCard(
                        headingTH: heading.th,
                        headingEN: heading.en,
                        memberOverride: activeMember,
                        openDetail: { flowManager.currentScreen = .recommendation }
                    )
                    .environmentObject(language)
                } else {
                    MissingBirthdayCard {
                        flowManager.currentScreen = .editProfile
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Helpers
    private func birthdayHeading(for member: Member?) -> (th: String, en: String)? {
        guard let bday = member?.birthdate else { return nil }
        let (th, en) = weekdayName(for: bday)
        return ("แนะนำวัดที่เหมาะกับคนเกิดวัน\(th)", "Recommended Temple for \(en)-born")
    }
    
    private func weekdayName(for date: Date) -> (th: String, en: String) {
        let w = Calendar(identifier: .gregorian).component(.weekday, from: date) // 1=Sun … 7=Sat
        let th = ["อาทิตย์","จันทร์","อังคาร","พุธ","พฤหัส","ศุกร์","เสาร์"]
        let en = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
        let i = max(1, min(7, w)) - 1
        return (th[i], en[i])
    }
}

private struct TempleBannerCard: View {
    @EnvironmentObject var language: AppLanguage
    var headingTH: String
    var headingEN: String
    /// nil = ใช้ตรรกะ “วันนี้”, ไม่ nil = ใช้ตรรกะ “วันเกิด”
    var memberOverride: Member?
    /// แตะปุ่มแล้วทำอะไร
    var openDetail: () -> Void
    
    var body: some View {
        let temple = getRecommendedTemple(for: memberOverride)
        
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(language.localized(headingTH, headingEN)).font(.headline)
            } icon: {
                Image(systemName: "building.columns").foregroundColor(.red)
            }
            
            HStack(spacing: 12) {
                if UIImage(named: temple.imageName) != nil {
                    Image(temple.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    ZStack {
                        Color.secondary.opacity(0.12)
                        Image(systemName: "photo")
                            .font(.title2).foregroundColor(.secondary)
                    }
                    .frame(width: 110, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(language.localized(temple.nameTH, temple.nameEN))
                        .font(.title3).bold()
                        .foregroundColor(.blue)
                    
                    Text(language.localized(temple.descTH, temple.descEN))
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                        .lineLimit(3)
                }
                Spacer(minLength: 0)
            }
            
            Button(action: openDetail) {
                Text(language.localized("รายละเอียดสถานที่", "View Details"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.95))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.separator), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

private struct MissingBirthdayCard: View {
    var onEditProfile: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("ยังไม่มีวันเกิดในโปรไฟล์", systemImage: "calendar.badge.exclamationmark")
                .font(.headline)
            Text("เพิ่มวันเกิดเพื่อรับคำแนะนำวัดที่ตรงกับวันเกิดของคุณ")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button(action: onEditProfile) {
                Text("แก้ไขโปรไฟล์")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.orange.opacity(0.95))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.separator), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}
