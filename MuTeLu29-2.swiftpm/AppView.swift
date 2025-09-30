import SwiftUI
import SwiftData

struct AppView: View {
    @Query private var members: [Member]
    
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @AppStorage("loggedInEmail") private var loggedInEmail = ""
    
    private var activeMember: Member? {
        members.first { $0.email == loggedInEmail }
    }
    
    var body: some View {
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
            RecommenderForYouView()
        case .recommendation:
            RecommendationView()
        case .sacredDetail(let place):
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
        default:
            HomeView()
        }
    }
}
