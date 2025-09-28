import SwiftUI

struct AppView: View {
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var memberStore: MemberStore
    @StateObject var checkInStore = CheckInStore()
    @AppStorage("loggedInEmail") private var loggedInEmail = ""
    
    private var activeMember: Member? {
        memberStore.members.first { $0.email == loggedInEmail }
    }
    
    var body: some View {
        // <<< ลบ Group และ AnyView ออกทั้งหมด >>>
        
        switch flowManager.currentScreen {
        case .login:
            LoginView()
            
        case .registration:
            RegistrationView()
            
        case .home:
            HomeView()
                .environmentObject(flowManager)
                .environmentObject(language)
                .environmentObject(memberStore)
                .environmentObject(locationManager)
                .environmentObject(checkInStore)
        case .editProfile:
            if let memberToEdit = activeMember {
                EditProfileView(user: memberToEdit)
                    .environmentObject(flowManager)
                    .environmentObject(language)
                    .environmentObject(memberStore)
                    .environmentObject(locationManager)
                    .environmentObject(checkInStore)
            } else {
                LoginView()
            }
            
        case .recommenderForYou:
            RecommenderForYouView(currentMember: activeMember)
                .environmentObject(language)
                .environmentObject(flowManager)
                .environmentObject(checkInStore)
                .environmentObject(memberStore)
                .environmentObject(locationManager)
            
        case .recommendation:
            RecommendationView()
                .environmentObject(language)
                .environmentObject(flowManager)
                .environmentObject(checkInStore)
                .environmentObject(memberStore)
                .environmentObject(locationManager)
            
        case .sacredDetail(let place):
            SacredPlaceDetailView(place: place)
                .environmentObject(language)
                .environmentObject(flowManager)
                .environmentObject(checkInStore)
                .environmentObject(memberStore)
            
            // ... เคสอื่นๆ ก็เอา AnyView ออกให้หมด ...
            
        case .phoneFortune:
            PhoneFortuneView()
            
        case .shirtColor:
            ShirtColorView()
            
        case .carPlate:
            CarPlateView()
            
        case .houseNumber:
            HouseNumberView()
            
        case .tarot:
            TarotView()
            
        case .mantra:
            MantraView()
            
        case .seamSi:
            SeamSiView()
            
        case .knowledge:
            KnowledgeMenuView()
            
        case .wishDetail:
            WishDetailView()
            
        case .adminLogin:
            AdminLoginView()
            
        case .admin:
            AdminView()
            
        case .gameMenu:
            GameMenuView()
            
        case .meritPoints:
            MeritPointsView()
            
        case .offeringGame:
            OfferingGameView()
                .environmentObject(language)
                .environmentObject(flowManager)
            
        @unknown default:
            Text("Coming soon...")
        }
    }
}
#Preview {
    // 1. สร้าง object จำลองของทุกอย่างที่ AppView ต้องใช้
    //    (ถ้า class ของคุณต้องการค่าเริ่มต้น ก็ต้องใส่ให้ครบ)
    let mockFlowManager = MuTeLuFlowManager()
    let mockLanguage = AppLanguage()
    let mockLocationManager = LocationManager()
    let mockMemberStore = MemberStore()
    
    // ตั้งค่าหน้าจอเริ่มต้นที่อยากจะ Preview (เช่น อยากดูหน้า login)
    // mockFlowManager.currentScreen = .login
    
    // 2. สร้าง AppView แล้ว "ฉีด" object เหล่านี้เข้าไปด้วย .environmentObject()
    return AppView()
        .environmentObject(mockFlowManager)
        .environmentObject(mockLanguage)
        .environmentObject(mockLocationManager)
        .environmentObject(mockMemberStore)
}

