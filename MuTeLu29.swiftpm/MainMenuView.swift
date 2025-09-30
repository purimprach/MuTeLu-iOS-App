import SwiftUI
import CoreLocation
import MapKit    

// MARK: - MainMenuView (Clean)
struct MainMenuView: View {
    // INPUTS
    @Binding var showBanner: Bool
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var checkInStore: CheckInStore         // ✅ ใช้คำนวณแต้มบุญ
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
                            subtitle: language.localized("ห่าง \(formatDistance(first.distance))",
                                                         "\(formatDistance(first.distance, locale: Locale(identifier: "en_US"))) away"),
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
    
    // MARK: Header
    private var header: some View {
        GreetingHeaderCardPro(
            name: currentMember?.fullName,
            email: currentMember?.email,
            subtitle: language.localized("ยินดีต้อนรับกลับ", "Welcome back"),
            meritPoints: checkInStore.records(for: currentMember?.email ?? "").reduce(0) { $0 + $1.meritPoints },
            onProfile: { /* TODO: ใส่จอโปรไฟล์จริงเมื่อพร้อม */ },
            onScan:    { /* TODO: ใส่จอสแกนจริงเมื่อพร้อม */ },
            onMap:     { flowManager.currentScreen = .recommendation }
        )
        .environmentObject(language)
    }
    
    // helper
    func formatDistance(_ meters: CLLocationDistance, locale: Locale = Locale(identifier: "th_TH")) -> String {
        let f = MKDistanceFormatter()
        f.unitStyle = .abbreviated
        f.locale = locale
        return f.string(fromDistance: meters)
    }
}

// MARK: - Greeting Header (Pro)
struct GreetingHeaderCardPro: View {
    @EnvironmentObject var language: AppLanguage
    
    var name: String?
    var email: String?
    var subtitle: String
    var meritPoints: Int = 0
    
    var onProfile: () -> Void
    var onScan: () -> Void
    var onMap: () -> Void
    
    private var displayName: String {
        name?.isEmpty == false ? name! : language.localized("ผู้ใช้รับเชิญ", "Guest user")
    }
    private var initials: String {
        (email ?? "guest@example.com").emailInitials
    }
    
    var body: some View {
        ZStack {
            // gradient + soft blobs
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(colors: [.purple.opacity(0.95), .indigo.opacity(0.9)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            Circle().fill(Color.white.opacity(0.12))
                .frame(width: 160, height: 160)
                .blur(radius: 20)
                .offset(x: 140, y: -50)
            Circle().fill(Color.black.opacity(0.12))
                .frame(width: 120, height: 120)
                .blur(radius: 18)
                .offset(x: -140, y: 60)
            
            // content
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    // Avatar with initials from email
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.pink, .orange],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                        Text(initials)
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                    }
                    .frame(width: 56, height: 56)
                    .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 2))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(displayName)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Notification / Profile button
                    HStack(spacing: 8) {
                        IconCapsule(system: "bell.fill")
                        IconCapsule(system: "person.crop.circle.fill", action: onProfile)
                    }
                }
                
                // pills: points + email (ถ้ามี)
                HStack(spacing: 8) {
                    Pill(
                        icon: "star.fill",
                        text: language.localized("แต้มบุญ", "Merit") + " \(meritPoints)",
                        bg: .orange
                    )
                    if let email, !email.isEmpty {
                        Pill(icon: "envelope.fill", text: email, bg: .blue)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                
                // quick actions
                HStack(spacing: 10) {
                    QuickButton(title: language.localized("สแกนเช็คอิน", "Scan Check-in"),
                                system: "qrcode.viewfinder",
                                color: .green,
                                action: onScan)
                    QuickButton(title: language.localized("แผนที่สถานที่", "Nearby Map"),
                                system: "map.fill",
                                color: .cyan,
                                action: onMap)
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

// MARK: - Small building blocks
private struct IconCapsule: View {
    var system: String
    var action: (() -> Void)? = nil
    var body: some View {
        Button(action: { action?() }) {
            Image(systemName: system)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .white.opacity(0.55))
                .padding(8)
                .background(.white.opacity(0.12))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

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

private struct QuickButton: View {
    var title: String
    var system: String
    var color: Color
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: system)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .white.opacity(0.5))
                Text(title).foregroundStyle(.white)
                    .font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(color.opacity(0.28))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
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
                DailyBannerView(member: currentMember)
                    .environmentObject(language)
                // เพิ่ม/เปิดตัวอื่น ๆ ได้ภายหลัง
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
    @ViewBuilder let content: () -> Content   // ✅ ใส่ @ViewBuilder
    
    var body: some View {
        VStack(spacing: 8) {
            SectionHeader(title: title, icon: icon, actionTitle: seeAllTitle, action: seeAllAction)
            content()  // ✅ เรียก closure
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
    @EnvironmentObject var language: AppLanguage
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
                        .environmentObject(language)
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
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
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

