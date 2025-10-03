import SwiftUI
import CoreLocation
import Combine

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// MARK: - Main View: RecommenderForYouView
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
struct RecommenderForYouView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject private var memberStore: MemberStore
    
    // --- 1. เพิ่ม Stores ที่จำเป็น ---
    @EnvironmentObject private var bookmarkStore: BookmarkStore
    @StateObject private var sacredPlaceViewModel = SacredPlaceViewModel()
    
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    @StateObject private var loc = LocationProvider()
    
    var currentMember: Member? = nil
    private var activeMember: Member? { currentMember ?? memberStore.members.first { $0.email == loggedInEmail } }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // --- Header (เหมือนเดิม) ---
                BackButton()
                HStack {
                    Text(language.localized("สำหรับคุณ", "For You"))
                        .font(.title2.bold())
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // --- Banners (เหมือนเดิม) ---
                BuddhistDayBanner()
                ReligiousHolidayBanner()
                
                // --- 2. เพิ่มการ์ด "สถานที่บันทึกไว้" เข้ามาตรงนี้ ---
                BookmarkedPlacesCard(
                    placesViewModel: sacredPlaceViewModel,
                    bookmarkStore: bookmarkStore,
                    flowManager: flowManager,
                    loggedInEmail: loggedInEmail
                )
                .environmentObject(language) // ส่ง language ต่อไปให้ subview
                
                // --- Hero Cards (เหมือนเดิม) ---
                Group {
                    TempleBannerCard(
                        headingTH: "แนะนำวัดเหมาะกับวันนี้",
                        headingEN: "Today’s Temple",
                        memberOverride: nil,
                        openDetail: { flowManager.currentScreen = .recommendation }
                    )
                    .environmentObject(language)
                    .environmentObject(loc)
                    
                    if let heading = birthdayHeading(for: activeMember) {
                        TempleBannerCard(
                            headingTH: heading.th,
                            headingEN: heading.en,
                            memberOverride: activeMember,
                            openDetail: { flowManager.currentScreen = .recommendation }
                        )
                        .environmentObject(language)
                        .environmentObject(loc)
                    } else {
                        MissingBirthdayCard { flowManager.currentScreen = .editProfile }
                            .environmentObject(language) // ส่ง language ต่อไปให้ subview
                    }
                }
                
                Spacer(minLength: 12)
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
        let i = max(1, min(7, w)) - 1
        return (th[i], en[i])
    }
}


//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// MARK: - Subview: BookmarkedPlacesCard (ส่วนที่เพิ่มใหม่)
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
private struct BookmarkedPlacesCard: View {
    @ObservedObject var placesViewModel: SacredPlaceViewModel
    @ObservedObject var bookmarkStore: BookmarkStore
    var flowManager: MuTeLuFlowManager
    let loggedInEmail: String
    
    @EnvironmentObject var language: AppLanguage
    
    var bookmarkedRecords: [BookmarkRecord] {
        bookmarkStore.getBookmarks(for: loggedInEmail)
    }
    
    var body: some View {
        if !bookmarkedRecords.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                // --- Header ของการ์ด ---
                HStack(spacing: 8) {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.blue)
                    Text(language.localized("รายการที่บันทึกไว้", "Saved Places"))
                    Spacer()
                    Button(language.localized("ดูทั้งหมด", "See All")) {
                        flowManager.currentScreen = .bookmarks
                    }
                    .font(.subheadline)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
                
                // --- Horizontal Scroll View ---
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(bookmarkedRecords) { record in
                            if let place = placesViewModel.places.first(where: { $0.id.uuidString == record.placeID }) {
                                BookmarkItem(place: place)
                                    .onTapGesture {
                                        flowManager.currentScreen = .sacredDetail(place: place)
                                    }
                            }
                        }
                    }
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.secondarySystemBackground)))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.primary.opacity(0.06), lineWidth: 1))
            .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        }
    }
}

// MARK: - Subview: BookmarkItem (ส่วนที่เพิ่มใหม่)
private struct BookmarkItem: View {
    let place: SacredPlace
    @EnvironmentObject var language: AppLanguage
    
    var body: some View {
        VStack(alignment: .leading, spacing:8) {
            Image(place.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 80)
                .cornerRadius(10)
                .clipped()
            
            Text(language.localized(place.nameTH, place.nameEN))
                .font(.system(size: 10, weight: .bold))
                .lineLimit(1)
                .frame(width: 140, alignment: .center)
        }
    }
}


//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// MARK: - Subviews เดิม (ไม่มีการเปลี่ยนแปลง)
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
private struct TempleBannerCard: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var loc: LocationProvider
    var headingTH: String
    var headingEN: String
    var memberOverride: Member?
    var openDetail: () -> Void
    
    var body: some View {
        let temple = getRecommendedTemple(for: memberOverride)
        
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                Text(language.localized(headingTH, headingEN))
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.secondary)
            
            ZStack(alignment: .bottomLeading) {
                bannerImage(named: temple.imageName)
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                LinearGradient(
                    colors: [Color.black.opacity(0.0), Color.black.opacity(0.55)],
                    startPoint: .center, endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .allowsHitTesting(false)
                
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
            .onTapGesture(perform: openDetail)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
    }
    
    @ViewBuilder
    private func bannerImage(named: String) -> some View {
        if UIImage(named: named) != nil {
            Image(named).resizable().scaledToFill()
        } else {
            ZStack {
                LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "photo").font(.largeTitle).foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    private func distanceString(to dest: CLLocation?) -> String? {
        guard let dest, let here = loc.lastLocation else { return nil }
        let m = here.distance(from: dest)
        if m < 1000 { return String(format: "%.0f m", m) }
        return String(format: "%.1f km", m/1000)
    }
}

private struct MissingBirthdayCard: View {
    @EnvironmentObject var language: AppLanguage
    var onEditProfile: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(language.localized("ยังไม่มีวันเกิดในโปรไฟล์", "No birthday in profile"), systemImage: "calendar.badge.exclamationmark")
                .font(.headline)
            Text(language.localized("เพิ่มวันเกิดเพื่อรับคำแนะนำวัดที่ตรงกับวันเกิดของคุณ", "Add your birthday to get temple recommendations tailored to your weekday"))
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
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.separator), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

final class LocationProvider: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var lastLocation: CLLocation?
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }
}
