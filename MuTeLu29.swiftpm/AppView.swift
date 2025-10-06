import SwiftUI

struct AppView: View {
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var memberStore: MemberStore
    
    // --- รับ EnvironmentObject ทั้งหมด ไม่สร้างใหม่ ---
    @EnvironmentObject var checkInStore: CheckInStore
    @EnvironmentObject var likeStore: LikeStore
    @EnvironmentObject var userActionStore: UserActionStore
    @EnvironmentObject var bookmarkStore: BookmarkStore
    
    @AppStorage("loggedInEmail") private var loggedInEmail = ""
    
    private var activeMember: Member? {
        memberStore.members.first { $0.email == loggedInEmail }
    }
    
    var body: some View {
        // --- 1. เรียกใช้ @ViewBuilder ---
        makeCurrentView()
        // --- 2. ย้าย .environmentObject ทั้งหมดมาไว้ตรงนี้ ---
            .environmentObject(flowManager)
            .environmentObject(language)
            .environmentObject(locationManager)
            .environmentObject(memberStore)
            .environmentObject(checkInStore)
            .environmentObject(likeStore)
            .environmentObject(userActionStore)
            .environmentObject(bookmarkStore)
    }
    
    // --- 3. สร้างฟังก์ชันใหม่ที่ใช้ @ViewBuilder ---
    @ViewBuilder
    private func makeCurrentView() -> some View {
        switch flowManager.currentScreen {
        case .login:
            LoginView()
        case .registration:
            RegistrationView()
        case .home:
            HomeView()
        case .editProfile:
            if let memberToEdit = activeMember {
                EditProfileView(user: memberToEdit)
            } else {
                LoginView()
            }
        case .recommenderForYou:
            RecommenderForYouView(currentMember: activeMember)
        case .recommendation:
            RecommendationView()
        case .sacredDetail(let place):
            // --- 👇 แก้ไขบรรทัดนี้ ---
            let _ = userActionStore.logAction(type: .viewDetail, placeID: place.id.uuidString, memberEmail: loggedInEmail)
            SacredPlaceDetailView(place: place)
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
        case .bookmarks:
            BookmarkView()
        case .placesMap:
            PlacesMapView()
        @unknown default:
            Text("Coming soon...")
        }
    }
}
