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
    
    // State สำหรับส่งข้อมูลให้ MainMenuView
    @State private var nearestWithDistance: [(place: SacredPlace, distance: CLLocationDistance)] = []
    @State private var topRatedPlaces: [SacredPlace] = []
    
    // State สำหรับควบคุมการคำนวณ
    @State private var locationUnavailable = false
    @State private var lastComputedLocation: CLLocation?
    
    private let sacredPlaces = loadSacredPlaces()
    
    private var currentMember: Member? {
        memberStore.members.first { $0.email == loggedInEmail }
    }
    
    // MARK: - Body (ฉบับแก้ไข)
    var body: some View {
        // 👇 **เราจะใช้ TabView เป็น View หลักของหน้านี้เลย**
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
            // ... (โค้ดใน onAppear เหมือนเดิมทุกประการ) ...
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
    }
    
    // MARK: - Functions (เหมือนเดิม)
    func checkProximityToSacredPlaces() {
        Task { await computeRouteNearest() }
    }
    
    private func computeRouteNearest() async {
        guard let userCL = locationManager.userLocation else {
            await MainActor.run { locationUnavailable = true }
            return
        }
        
        // กันคำนวณถี่เกินไป
        if let last = lastComputedLocation {
            let moved = userCL.distance(from: last)
            if moved < 50 { return }
        }
        
        let userCoord = userCL.coordinate
        
        // 1) จัดอันดับระยะ "เส้นตรง" หา top 8 มาก่อน
        let linearRank = sacredPlaces.map { place in
            (place: place,
             d: userCL.distance(from: CLLocation(latitude: place.latitude,
                                                 longitude: place.longitude)))
        }
        let topLinearPlaces = Array(linearRank.sorted { $0.d < $1.d }.prefix(8)).map { $0.place }
        
        // 2) ขอระยะ "จริง" จาก Apple Maps
        let routed = await RouteDistanceService.shared.batchDistances(
            from: userCoord,
            places: topLinearPlaces,
            mode: .driving
        )
        
        // 3) เอาเฉพาะที่มีระยะจริง (meters != nil) แล้วจัดอันดับใกล้สุด
        let nearest3: [(place: SacredPlace, meters: CLLocationDistance)] = Array(
            routed
                .compactMap { r in
                    guard let d = r.meters else { return nil }   // << กรอง nil ออก
                    return (place: r.place, meters: d)           // << d เป็น Double แล้ว
                }
                .sorted { $0.meters < $1.meters }
                .prefix(3)
        )
        
        // 4) รีวิวสูงสุด 3 อันดับ (ไม่เกี่ยวกับ Optional)
        let top3Review = sacredPlaces.sorted { $0.rating > $1.rating }.prefix(3)
        
        // 5) อัปเดต UI
        await MainActor.run {
            self.locationUnavailable = false
            self.lastComputedLocation = userCL
            self.nearestWithDistance = nearest3.map { (place: $0.place, distance: $0.meters) }  // << ไม่ Optional
            self.topRatedPlaces = Array(top3Review)
        }
    }
}

struct NotificationView: View {
    var body: some View { Text("Notification Screen") }
}
