import SwiftUI

struct GameMenuView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    
    var body: some View {
        ScrollView {
            BackButton()
            VStack(spacing: 20) {
                Text(language.localized("เกมส่งเสริมวัฒนธรรม", "Cultural Games"))
                    .font(.title2)
                    .bold()
                    .padding(.top)
                
                // เพิ่มเกมต่างๆ ที่นี่
                GameCard(titleTH: "จัดเครื่องสังฆทาน", titleEN: "Offering Set Arrangement", imageName: "gift.fill") {
                    flowManager.currentScreen = .offeringGame
                }
                
                // เพิ่มเกมอื่นๆ ในอนาคต เช่น...
                // GameCard(titleTH: "จำบทสวดมนต์", titleEN: "Chant Memory Game", imageName: "brain.head.profile") { ... }
            }
            .padding()
        }
    }
}

struct GameCard: View {
    let titleTH: String
    let titleEN: String
    let imageName: String
    let action: () -> Void
    
    @EnvironmentObject var language: AppLanguage
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: imageName)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding()
                
                Text(language.localized(titleTH, titleEN))
                    .font(.headline)
                
                Spacer()
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}

