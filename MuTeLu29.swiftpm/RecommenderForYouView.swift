import SwiftUI
import CoreLocation
import SwiftData

struct RecommenderForYouView: View {
    // 👇 1. ดึงข้อมูล Member ทั้งหมดจาก SwiftData
    @Query private var members: [Member]
    
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    
    // 👇 2. เปลี่ยนวิธีหา activeMember
    // ค้นหาจาก array 'members' ที่ @Query ดึงมาให้
    private var activeMember: Member? {
        members.first { $0.email == loggedInEmail }
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
                    memberOverride: nil, // ใช้ member ปัจจุบันอัตโนมัติ
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
                    .environmentObject(language) // 👈 เพิ่ม environmentObject
                }
                
                // Banner อื่นๆ
                // DailyBannerView() // อาจจะต้องส่ง activeMember เข้าไป
                // BuddhistDayBanner()
                // ReligiousHolidayBanner()
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Helpers (เหมือนเดิม)
    private func birthdayHeading(for member: Member?) -> (th: String, en: String)? {
        guard let bday = member?.birthdate else { return nil }
        let (th, en) = weekdayName(for: bday)
        return ("แนะนำวัดที่เหมาะกับคนเกิดวัน\(th)", "Recommended Temple for \(en)-born")
    }
    
    private func weekdayName(for date: Date) -> (th: String, en: String) {
        let w = Calendar(identifier: .gregorian).component(.weekday, from: date)
        let th = ["อาทิตย์","จันทร์","อังคาร","พุธ","พฤหัส","ศุกร์","เสาร์"]
        let en = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
        let i = max(0, min(6, w - 1))
        return (th[i], en[i])
    }
}

// TempleBannerCard และ MissingBirthdayCard ไม่ต้องแก้ไข
// ... (โค้ดส่วนที่เหลือของไฟล์เหมือนเดิม) ...
private struct TempleBannerCard: View {
    @EnvironmentObject var language: AppLanguage
    var headingTH: String
    var headingEN: String
    var memberOverride: Member?
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
                        .resizable().scaledToFill()
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
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.separator), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

private struct MissingBirthdayCard: View {
    @EnvironmentObject var language: AppLanguage
    var onEditProfile: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(language.localized("ยังไม่มีวันเกิดในโปรไฟล์", "No birthday in profile"), systemImage: "calendar.badge.exclamationmark")
                .font(.headline)
            
            Text(language.localized("เพิ่มวันเกิดเพื่อรับคำแนะนำวัดที่ตรงกับวันเกิดของคุณ", "Add your birthday to get temple recommendations tailored to you"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button(action: onEditProfile) {
                Text(language.localized("แก้ไขโปรไฟล์", "Edit Profile"))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.orange.opacity(0.95))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.separator), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}
