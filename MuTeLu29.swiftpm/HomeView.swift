import SwiftUI
import CoreLocation

struct HomeView: View {
    @StateObject private var viewModel = SacredPlaceViewModel()
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var memberStore: MemberStore
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var checkInStore: CheckInStore
    
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    
    @State private var selectedTab = 0
    @State private var showBanner = false
    
    // ใช้ส่งให้ MainMenuView
    @State private var nearestWithDistance: [(place: SacredPlace, distance: CLLocationDistance)] = []
    @State private var topRatedPlaces: [SacredPlace] = []
    
    // คุมความถี่การคำนวณ
    @State private var locationUnavailable = false
    @State private var lastComputedLocation: CLLocation?
    
    private let sacredPlaces = loadSacredPlaces()
    
    // MARK: - Helpers
    private func formatDistance(_ meters: CLLocationDistance) -> String {
        let m = Measurement(value: meters, unit: UnitLength.meters)
        let f = MeasurementFormatter()
        f.unitOptions = .naturalScale
        f.numberFormatter.maximumFractionDigits = 1
        return f.string(from: m)
    }
    
    // ให้ MainMenuView เรียก
    func checkProximityToSacredPlaces() {
        Task { await computeRouteNearest() }
    }
    
    /// ❗️เหลือฟังก์ชันนี้ “อันเดียว” เท่านั้น
    private func computeRouteNearest() async {
        guard let userCL = locationManager.userLocation else {
            await MainActor.run { locationUnavailable = true }
            return
        }
        
        // ลดถี่: ถ้าขยับน้อยกว่า 50m ไม่ต้องคำนวณใหม่
        if let last = lastComputedLocation {
            let moved: CLLocationDistance = userCL.distance(from: last)  // <-- ไม่ใช้ if let
            if moved < 50 { return }
        }
        
        let userCoord = userCL.coordinate
        
        // 1) เลือก 8 แห่งที่ “เส้นตรง” ใกล้สุดก่อน
        let linearRank: [(place: SacredPlace, d: CLLocationDistance)] = sacredPlaces.compactMap { place in
            let lat = place.latitude
            let lon = place.longitude
            let d = userCL.distance(from: CLLocation(latitude: lat, longitude: lon))
            return (place, d)
        }
        let topLinearPlaces = Array(linearRank.sorted { $0.d < $1.d }.prefix(8)).map { $0.place }
        
        // 2) ขอระยะจริงจาก Apple Maps (ดู RouteDistanceService.swift)
        let routed = await RouteDistanceService.shared.batchDistances(
            from: userCoord,
            places: topLinearPlaces,
            mode: .driving
        )
        
        // 3) 3 อันดับระยะจริงใกล้สุด
        let nearest3 = Array(routed.sorted { $0.meters < $1.meters }.prefix(3))
        
        // 4) รีวิวสูงสุด 3 อันดับ
        let top3Review = sacredPlaces.sorted { $0.rating > $1.rating }.prefix(3)

        
        // 5) อัปเดต UI
        await MainActor.run {
            self.locationUnavailable = false
            self.lastComputedLocation = userCL
            self.nearestWithDistance = nearest3.map { (place: $0.place, distance: $0.meters) }
            self.topRatedPlaces = Array(top3Review)
        }
    }
    
    private var currentMember: Member? {
        memberStore.members.first { $0.email == loggedInEmail }
    }
    
    var body: some View {
        ZStack {
            if case .home = flowManager.currentScreen {
                TabView(selection: $selectedTab) {
                    MainMenuView(
                        showBanner: $showBanner,
                        currentMember: currentMember,
                        flowManager: flowManager,
                        nearest: nearestWithDistance,
                        topRated: topRatedPlaces,
                        checkProximityToSacredPlaces: checkProximityToSacredPlaces,
                        locationManager: locationManager
                    )
                    .environmentObject(language)
                    .overlay(alignment: .top) {
                        if locationUnavailable {
                            Text(language.localized("ไม่พบตำแหน่งที่ตั้ง", "Location unavailable"))
                                .font(.footnote)
                                .padding(8)
                                .background(Color.red.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.top, 8)
                        }
                    }
                    .tabItem { Label(language.localized("หน้าหลัก", "Home"), systemImage: "house") }
                    .tag(0)
                    
                    NotificationView()
                        .tabItem { Label(language.localized("การแจ้งเตือน", "Notifications"), systemImage: "bell") }
                        .tag(1)
                    
                    HistoryView()
                        .tabItem { Label(language.localized("ประวัติ", "History"), systemImage: "clock") }
                        .tag(2)
                    
                    NavigationStack { ProfileView() }
                        .tabItem { Label(language.localized("ข้อมูลของฉัน", "Profile"), systemImage: "person.circle") }
                        .tag(3)
                }
                .tint(.purple)
                .onAppear {
                    let appearance = UITabBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = UIColor.systemBackground
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                    
                    checkProximityToSacredPlaces()
                }
                .onChange(of: locationManager.userLocation) {
                    checkProximityToSacredPlaces()
                }

                
            } else {
                switch flowManager.currentScreen {
                case .recommenderForYou : RecommenderForYouView() 
                case .recommendation: RecommendationView()
                case .phoneFortune: PhoneFortuneView()
                case .shirtColor: ShirtColorView()
                case .carPlate: CarPlateView()
                case .houseNumber: HouseNumberView()
                case .tarot: TarotView()
                case .seamSi: SeamSiView()
                case .mantra: MantraView()
                case .sacredDetail: EmptyView()
                case .knowledge: KnowledgeMenuView()
                case .adminLogin: AdminLoginView()
                case .admin: AdminView()
                default: EmptyView()
                }
            }
        }
    }
}

struct NotificationView: View {
    var body: some View { Text("Notification Screen") }
}
