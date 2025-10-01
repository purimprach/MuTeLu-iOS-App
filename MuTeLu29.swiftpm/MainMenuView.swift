import SwiftUI
import CoreLocation
import MapKit    

// MARK: - MainMenuView
struct MainMenuView: View {
    @Binding var showBanner: Bool
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var checkInStore: CheckInStore
    var currentMember: Member?
    var flowManager: MuTeLuFlowManager
    
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
                
                // 🔄 รวม NearYou + TopReviews
                PlaceSection(nearest: nearest, topRated: topRated, flowManager: flowManager)
                    .environmentObject(language)
                
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
        GreetingHeaderCardPro(
            name: currentMember?.fullName,
            email: currentMember?.email,
            subtitle: language.localized("ยินดีต้อนรับกลับ", "Welcome back"),
            meritPoints: checkInStore.records(for: currentMember?.email ?? "").reduce(0) { $0 + $1.meritPoints },
            onProfile: {}
        )
        .environmentObject(language)
    }
}

// MARK: - GreetingHeaderCardPro
struct GreetingHeaderCardPro: View {
    @EnvironmentObject var language: AppLanguage
    var name: String?
    var email: String?
    var subtitle: String
    var meritPoints: Int = 0
    var onProfile: () -> Void
    
    private var displayName: String {
        name?.isEmpty == false ? name! : language.localized("ผู้ใช้รับเชิญ", "Guest user")
    }
    private var initials: String {
        (email ?? "guest@example.com").emailInitials
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(LinearGradient(colors: [.purple.opacity(0.95), .indigo.opacity(0.9)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
            Circle().fill(Color.white.opacity(0.12))
                .frame(width: 160, height: 160)
                .blur(radius: 20)
                .offset(x: 140, y: -50)
            Circle().fill(Color.black.opacity(0.12))
                .frame(width: 120, height: 120)
                .blur(radius: 18)
                .offset(x: -140, y: 60)
            
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .orange],
                                                 startPoint: .topLeading,
                                                 endPoint: .bottomTrailing))
                        Text(initials)
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                    }
                    .frame(width: 56, height: 56)
                    .overlay(Circle().stroke(.white.opacity(0.8), lineWidth: 2))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(displayName)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 8) {
                    if let email, !email.isEmpty {
                        Pill(icon: "envelope.fill", text: email, bg: .black)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    Pill(icon: "star.fill",
                         text: language.localized("แต้มบุญ", "Merit") + " \(meritPoints)",
                         bg: .orange)
                }
            }
            .padding(16)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 10, y: 6)
    }
}

// MARK: - PlaceSection (รวม NearYou + TopReviews)
private struct PlaceSection: View {
    @EnvironmentObject var language: AppLanguage
    var nearest: [(place: SacredPlace, distance: CLLocationDistance)]
    var topRated: [SacredPlace]
    var flowManager: MuTeLuFlowManager
    
    @State private var selectedTab = 0
    @State private var pageNear = 0
    @State private var pageTop  = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Segmented switcher
            Picker("", selection: $selectedTab) {
                Text(language.localized("อยู่ใกล้คุณ", "Near You")).tag(0)
                Text(language.localized("รีวิวเยอะ", "Top Reviews")).tag(1)
            }
            .pickerStyle(.segmented)
            
            // แสดง TabView เฉพาะแท็บที่เลือก (กัน tag ซ้ำ)
            if selectedTab == 0 {
                if nearest.isEmpty {
                    EmptyStateView(
                        icon: "location.slash.fill",
                        text: language.localized("กำลังค้นหาสถานที่ใกล้คุณ...", "Finding places near you...")
                    )
                    .frame(maxWidth: .infinity, minHeight: 160)
                } else {
                    TabView(selection: $pageNear) {
                        ForEach(Array(nearest.prefix(3).enumerated()), id: \.offset) { idx, item in
                            PlaceCard(
                                title: language.localized(item.place.nameTH, item.place.nameEN),
                                subtitle: language.localized(
                                    "🚙  ห่าง \(formatDistance(item.distance))",
                                    "🚙  \(formatDistance(item.distance, locale: Locale(identifier: "en_US"))) away"
                                ),
                                buttonTitle: language.localized("รายละเอียดสถานที่", "View details"),
                                buttonAction: { flowManager.currentScreen = .sacredDetail(place: item.place) }
                            )
                            .padding(.bottom, 22) // กันจุด indicator ทับปุ่ม
                            .tag(idx)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .frame(height: 190)
                }
            } else {
                if topRated.isEmpty {
                    EmptyStateView(
                        icon: "star.slash.fill",
                        text: language.localized("ไม่พบสถานที่แนะนำ", "No recommended places found")
                    )
                    .frame(maxWidth: .infinity, minHeight: 160)
                } else {
                    TabView(selection: $pageTop) {
                        ForEach(Array(topRated.prefix(3).enumerated()), id: \.offset) { idx, place in
                            PlaceCard(
                                title: language.localized(place.nameTH, place.nameEN),
                                subtitle: String(
                                    format: language.localized("⭐⭐⭐ คะแนน %.1f / 5", "Rating %.1f / 5"),
                                    place.rating
                                ),
                                buttonTitle: language.localized("รายละเอียดสถานที่", "View details"),
                                buttonAction: { flowManager.currentScreen = .sacredDetail(place: place) }
                            )
                            .padding(.bottom, 22) // กันจุด indicator ทับปุ่ม
                            .tag(idx)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .frame(height: 190)
                }
            }
        }
        .animation(.easeInOut, value: selectedTab)
    }
    
    private func formatDistance(_ meters: CLLocationDistance,
                                locale: Locale = Locale(identifier: "th_TH")) -> String {
        let f = MKDistanceFormatter()
        f.unitStyle = .abbreviated
        f.locale = locale
        return f.string(fromDistance: meters)
    }
}

// การ์ดสถานที่ (ใช้ Card/PrimaryButton ที่คุณมีอยู่)
private struct PlaceCard: View {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let buttonAction: () -> Void
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("🕍")
                    Text(title)
                        .font(.subheadline).bold()
                        .foregroundStyle(Color(.label))
                        .lineLimit(2)
                }
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.brown)
                
                PrimaryButton(title: buttonTitle, color: .purple, action: buttonAction)
            }
        }
    }
}

// สถานะว่าง
private struct EmptyStateView: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.secondary)
            Text(text)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Banner stack
private struct BannerStack: View {
    @Binding var showBanner: Bool
    @EnvironmentObject var language: AppLanguage
    var currentMember: Member?
    
    var body: some View {
        VStack(spacing: 12) {
            if showBanner {
                DailyBannerView(member: currentMember)
                    .environmentObject(language)
            }
        }
    }
}

// MARK: - Pill
private struct Pill: View {
    var icon: String
    var text: String
    var bg: Color
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .white.opacity(0.4))
            Text(text).foregroundStyle(.white)
                .font(.footnote.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(bg.opacity(0.25))
        .clipShape(Capsule())
    }
}

// MARK: - Card
struct Card<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) { content }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.separator), lineWidth: 0.5))
            .shadow(color: .black.opacity(scheme == .dark ? 0.15 : 0.25),
                    radius: scheme == .dark ? 4 : 8, x: 0, y: 3)
    }
}

// MARK: - PrimaryButton
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

// MARK: - StarRatingView
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
// MARK: - Quick actions grid (เก็บรวมท้ายหน้า)
private struct QuickActionsGrid: View {
    @EnvironmentObject var language: AppLanguage
    let flowManager: MuTeLuFlowManager
    @State private var showAll = false
    
    private var items: [(th: String, en: String, icon: String, screen: MuTeLuScreen)] {
        [
            ("แนะนำสถานที่ศักดิ์สิทธิ์สำหรับคุณ","Recommended for You","wand.and.stars",.recommenderForYou),
            ("แนะนำสถานที่ศักดิ์สิทธิ์รอบจุฬาฯ","Sacred Places around Chula","building.columns", .recommendation),
            ("ทำนายเบอร์โทร","Phone Fortune","phone.circle", .phoneFortune),
            ("คะแนนแต้มบุญ","Merit Points","star.circle", .meritPoints),
            ("สีเสื้อประจำวัน","Shirt Color","tshirt", .shirtColor),
            ("เลขทะเบียนรถ","Car Plate Number","car", .carPlate),
            ("เลขที่บ้าน","House Number","house", .houseNumber),
            ("ดูดวงไพ่ทาโร่","Tarot Reading","suit.club", .tarot),
            ("เซียมซี","Fortune Sticks","scroll", .seamSi),
            ("คาถาประจำวัน","Daily Mantra","sparkles", .mantra),
            ("เกร็ดความรู้","Knowledge","book.closed", .knowledge)
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
                    MenuButton(
                        titleTH: it.th,
                        titleEN: it.en,
                        image: it.icon,
                        screen: it.screen
                    )
                    .environmentObject(language)
                    .environmentObject(flowManager)
                }
            }
        }
    }
}
