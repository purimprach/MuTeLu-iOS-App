import SwiftUI
import CoreLocation

struct HomeView: View {
    enum HomeTab: Hashable { case home, notifications, history, profile }
    
    @StateObject private var viewModel = SacredPlaceViewModel()
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var memberStore: MemberStore
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var checkInStore: CheckInStore
    
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    
    @State private var selectedTab: HomeTab = .home
    @State private var showBanner = false
    
    // ส่งให้ MainMenuView
    @State private var nearestWithDistance: [(place: SacredPlace, distance: CLLocationDistance)] = []
    @State private var topRatedPlaces: [SacredPlace] = []
    
    // สถานะคุมการคำนวณ
    @State private var locationUnavailable = false
    @State private var lastComputedLocation: CLLocation?
    @State private var lastComputeAt: Date = .distantPast
    
    private let sacredPlaces = loadSacredPlaces()
    private let minMoveMeters: CLLocationDistance = 50
    private let minInterval: TimeInterval = 6
    
    private var currentMember: Member? {
        memberStore.members.first { $0.email == loggedInEmail }
    }
    
    var body: some View {
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
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(.red.opacity(0.12))
                        .clipShape(Capsule())
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .tabItem { Label(language.localized("หน้าหลัก", "Home"), systemImage: "house") }
            .tag(HomeTab.home)
            
            NotificationView()
                .tabItem { Label(language.localized("การแจ้งเตือน", "Notifications"), systemImage: "bell") }
                .tag(HomeTab.notifications)
            
            HistoryView()
                .tabItem { Label(language.localized("ประวัติ", "History"), systemImage: "clock") }
                .tag(HomeTab.history)
            
            NavigationStack { ProfileView() }
                .tabItem { Label(language.localized("ข้อมูลของฉัน", "Profile"), systemImage: "person.circle") }
                .tag(HomeTab.profile)
        }
        .tint(.purple)
        // เรียกครั้งแรกเมื่อหน้าแสดง
        .task {
            await debouncedProximityCompute(force: true)
        }
        // เรียกใหม่เมื่อ location เปลี่ยน (debounce/throttle ภายใน)
        .task(id: locationManager.userLocation) {
            await debouncedProximityCompute()
        }
    }
    
    // MARK: - Public trigger
    func checkProximityToSacredPlaces() {
        Task { await debouncedProximityCompute(force: true) }
    }
    
    // MARK: - Debounce/Throttle wrapper
    private func debouncedProximityCompute(force: Bool = false) async {
        guard let userCL = locationManager.userLocation else {
            await MainActor.run { locationUnavailable = true }
            return
        }
        
        // throttle ระยะ + เวลา
        if !force {
            if let last = lastComputedLocation,
               userCL.distance(from: last) < minMoveMeters,
               Date().timeIntervalSince(lastComputeAt) < minInterval {
                return
            }
        }
        
        let result = await computeNearest(from: userCL)
        await MainActor.run {
            self.locationUnavailable = false
            self.lastComputedLocation = userCL
            self.lastComputeAt = Date()
            self.nearestWithDistance = result.nearest
            self.topRatedPlaces = result.topRated
        }
    }
    
    // MARK: - Core compute returns value (ทดสอบง่าย/อัพเดตรวม)
    private func computeNearest(from userCL: CLLocation) async
    -> (nearest: [(place: SacredPlace, distance: CLLocationDistance)], topRated: [SacredPlace]) {
        
        // 1) ระยะเส้นตรง
        let linearRank = sacredPlaces.map { place in
            (place: place,
             d: userCL.distance(from: CLLocation(latitude: place.latitude,
                                                 longitude: place.longitude)))
        }
        let k = min(8, sacredPlaces.count)
        let topLinearPlaces = Array(linearRank.sorted { $0.d < $1.d }.prefix(k)).map { $0.place }
        
        // 2) ระยะจริงจากเส้นทาง
        let routed = await RouteDistanceService.shared.batchDistances(
            from: userCL.coordinate,
            places: topLinearPlaces,
            mode: .driving
        )
        
        // 3) กรองค่า nil + เรียงสั้นสุด
        let nearest3 = routed
            .compactMap { r -> (SacredPlace, CLLocationDistance)? in
                guard let d = r.meters else { return nil }
                return (r.place, d)
            }
            .sorted { $0.1 < $1.1 }
        let nearest = Array(nearest3.prefix(3)).map { (place: $0.0, distance: $0.1) }
        
        // 4) รีวิวสูงสุด
        let topRated = Array(sacredPlaces.sorted { $0.rating > $1.rating }.prefix(3))
        
        return (nearest, topRated)
    }
}

struct NotificationView: View {
    var body: some View {
        Text("Notification Screen")
            .font(.headline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
    }
}
