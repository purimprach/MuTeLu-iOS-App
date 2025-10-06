import SwiftUI

struct AppView: View {
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    
    var body: some View {
        if !flowManager.isLoggedIn {
            LoginView()
        } else {
            // NavigationStack จะเป็นตัวควบคุมหลัก
            NavigationStack(path: $flowManager.path) {
                // หน้าแรกสุดใน Stack คือ HomeView
                HomeView()
                // .navigationDestination คือตัวบอกว่าถ้าเจอข้อมูลประเภทไหนใน path ให้ไปที่หน้าอะไร
                    .navigationDestination(for: MuTeLuScreen.self) { screen in
                        // เรานำ switch-case เดิมมาไว้ตรงนี้แทน
                        switch screen {
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
                        case .gameMenu:
                            GameMenuView()
                        case .meritPoints:
                            MeritPointsView()
                        case .offeringGame:
                            OfferingGameView()
                        case .bookmarks:
                            BookmarkView()
                        case .categorySearch:
                            CategorySearchView()
                            // case ที่ไม่ต้องจัดการในนี้ (เช่น home, login) ให้ใส่ default ไป
                        default:
                            Text("Invalid Screen")
                        }
                    }
            }
        }
    }
}
