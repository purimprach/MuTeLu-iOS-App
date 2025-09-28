import SwiftUI
import CoreLocation
import MapKit    

// MARK: - MainMenuView (Clean)
struct MainMenuView: View {
    // INPUTS
    @Binding var showBanner: Bool
    @EnvironmentObject var language: AppLanguage
    var currentMember: Member?
    var flowManager: MuTeLuFlowManager
    
    /// data ที่คำนวณมาจาก HomeView แล้ว (อย่าให้ MainMenuView คิดเอง จะรก)
    var nearest: [(place: SacredPlace, distance: CLLocationDistance)]
    var topRated: [SacredPlace]
    
    var checkProximityToSacredPlaces: () -> Void
    var locationManager: LocationManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                BannerStack(showBanner: $showBanner, currentMember: currentMember)
                    .environmentObject(language)
                
                // 3) Near you (show 1, see all -> .recommendation)
                MiniSection(
                    title: language.localized("อยู่ใกล้คุณ", "Near You"),
                    icon: "location.fill",
                    seeAllTitle: language.localized("ดูทั้งหมด", "See all"),
                    seeAllAction: { flowManager.currentScreen = .recommendation }
                ) {
                    if let first = nearest.first {
                        PlaceMiniCard(
                            title: language.localized(first.place.nameTH, first.place.nameEN),
                            subtitle: language.localized("ห่าง \(formatDistance(first.distance))","\(formatDistance(first.distance, locale: Locale(identifier: "en_US"))) away"),
                            buttonTitle: language.localized("รายละเอียดสถานที่", "View details"),
                            buttonAction: { flowManager.currentScreen = .sacredDetail(place: first.place) }
                        )
                    }
                }
                
                // 4) Top rated (show 1, see all -> .recommendation)
                MiniSection(
                    title: language.localized("รีวิวเยอะ", "Top Reviews"),
                    icon: "star.fill",
                    seeAllTitle: language.localized("ดูทั้งหมด", "See all"),
                    seeAllAction: { flowManager.currentScreen = .recommendation }
                ) {
                    if let first = topRated.first {
                        Card {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(language.localized(first.nameTH, first.nameEN))
                                    .font(.subheadline).bold()
                                    .foregroundStyle(Color(.label))
                                StarRatingView(rating: first.rating)
                                PrimaryButton(
                                    title: language.localized("รายละเอียดสถานที่", "View details"),
                                    color: .blue
                                ) { flowManager.currentScreen = .sacredDetail(place: first) }
                            }
                        }
                    }
                }
                
                // 5) Quick actions grid (ไว้ท้าย ๆ)
                QuickActionsGrid(flowManager: flowManager)
                    .environmentObject(language)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .onAppear { showBanner = true }
            .onChange(of: locationManager.userLocation, initial: false) { _, _ in
                checkProximityToSacredPlaces()
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    private var header: some View {
        GreetingHeaderCard(
            displayName: currentMember?.fullName,           // 
            displayEmail: currentMember?.email,         
            guestName: language.localized("ผู้ใช้รับเชิญ", "Guest user"),
            subtitle: language.localized("ยินดีต้อนรับกลับ", "Welcome back")
        )
    }
    // helper
    func formatDistance(_ meters: CLLocationDistance, locale: Locale = Locale(identifier: "th_TH")) -> String {
        let f = MKDistanceFormatter()
        f.unitStyle = .abbreviated
        f.locale = locale
        return f.string(fromDistance: meters)
    }
}

// MARK: - Banner stack (รวม 3 แบนเนอร์ให้เรียบร้อย)
private struct BannerStack: View {
    @Binding var showBanner: Bool
    @EnvironmentObject var language: AppLanguage
    var currentMember: Member?
    
    var body: some View {
        VStack(spacing: 12) {
            if showBanner {
                // ใช้ตัวใหม่ที่รองรับ Dark/Light
                DailyBannerView(member: currentMember)
                    .environmentObject(language)
                BuddhistDayBanner()
                    .environmentObject(language)
                ReligiousHolidayBanner()
                    .environmentObject(language)
                RecommendedTempleBanner(currentMember: currentMember) 
                    .environmentObject(language)
            }
        }
    }
}

// MARK: - Section with header + trailing action
private struct MiniSection<Content: View>: View {
    let title: String
    let icon: String
    let seeAllTitle: String
    let seeAllAction: () -> Void
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(spacing: 8) {
            SectionHeader(title: title, icon: icon, actionTitle: seeAllTitle, action: seeAllAction)
            content
        }
    }
}

private struct SectionHeader: View {
    let title: String
    let icon: String
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(Color(.label))
            Spacer()
            Button(actionTitle, action: action)
                .font(.subheadline)
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Small place card used in sections
private struct PlaceMiniCard: View {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let buttonAction: () -> Void
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.subheadline).bold()
                    .foregroundStyle(Color(.label))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                PrimaryButton(title: buttonTitle, color: .green, action: buttonAction)
            }
        }
    }
}

// MARK: - Quick actions grid (เก็บรวมท้ายหน้า)
private struct QuickActionsGrid: View {
    @EnvironmentObject var language: AppLanguage   // <-- เปลี่ยนตรงนี้
    let flowManager: MuTeLuFlowManager
    @State private var showAll = false
    
    private var items: [(th: String, en: String, icon: String, screen: MuTeLuScreen)] {
        [   ("แนะนำสถานที่ศักดิ์สิทธิ์สำหรับคุณ","Recommended for You","wand.and.stars",.recommenderForYou),
            ("แนะนำสถานที่ศักดิ์สิทธิ์รอบจุฬาฯ","Sacred Places around Chula","building.columns", .recommendation),
            ("ทำนายเบอร์โทร","Phone Fortune","phone.circle", .phoneFortune),
            ("สีเสื้อประจำวัน","Shirt Color","tshirt", .shirtColor),
            ("เลขทะเบียนรถ","Car Plate Number","car", .carPlate),
            ("เลขที่บ้าน","House Number","house", .houseNumber),
            ("ดูดวงไพ่ทาโร่","Tarot Reading","suit.club", .tarot),
            ("เซียมซี","Fortune Sticks","scroll", .seamSi),
            ("คาถาประจำวัน","Daily Mantra","sparkles", .mantra),
            ("เกร็ดความรู้","Knowledge","book.closed", .knowledge),
            ("คะแนนแต้มบุญ","Merit Points","star.circle", .meritPoints)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(language.localized("เครื่องมือด่วน", "Quick actions"))
                    .font(.headline)
                Spacer()
                Button(showAll ? language.localized("ย่อ", "Collapse")
                       : language.localized("ดูทั้งหมด", "See all")) {
                    withAnimation(.easeInOut) { showAll.toggle() }
                }
                       .font(.subheadline)
            }
            
            let visible = showAll ? items : Array(items.prefix(4))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(visible.indices, id: \.self) { i in
                    let it = visible[i]
                    MenuButton(titleTH: it.th, titleEN: it.en, image: it.icon, screen: it.screen)
                        .environmentObject(language)          // เผื่อให้ปุ่มรีแอคภาษาด้วย
                        .environmentObject(flowManager)
                }
            }
        }
    }
}

// MARK: - Shared UI pieces
struct Card<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
        .padding()
        .frame(maxWidth: .infinity)   // ✅ ทุกการ์ดกว้างเท่ากัน
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16)
            .stroke(Color(.separator), lineWidth: 0.5))
        .shadow(color: .black.opacity(scheme == .dark ? 0.15 : 0.25),
                radius: scheme == .dark ? 4 : 8, x: 0, y: 3)
    }
}

private struct PrimaryButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(color.opacity(0.95))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// (คง StarRatingView ของคุณไว้ใช้ซ้ำได้เลย)
struct StarRatingView: View {
    let rating: Double
    let maxStars: Int = 5
    let showText: Bool = true
    var body: some View {
        HStack(spacing: 6) {
            HStack(spacing: 2) {
                ForEach(0..<maxStars, id: \.self) { i in
                    let threshold = Double(i) + 1
                    if rating >= threshold { Image(systemName: "star.fill") }
                    else if rating >= threshold - 0.5 { Image(systemName: "star.leadinghalf.filled") }
                    else { Image(systemName: "star") }
                }
            }
            .foregroundStyle(.orange)
            .symbolRenderingMode(.hierarchical)
            .font(.caption)
            if showText {
                Text(String(format: "(%.1f / 5)", min(max(rating, 0), 5)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

