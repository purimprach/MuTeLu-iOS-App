import SwiftUI

struct BackButton: View {
    @EnvironmentObject var flow: MuTeLuFlowManager
    @EnvironmentObject var language: AppLanguage
    
    var body: some View {
        HStack {
            Button(action: {
                flow.currentScreen = .home
            }) {
                Label(language.localized("ย้อนกลับ", "Back"), systemImage: "chevron.left")
                    .font(.headline)
                    .padding(.bottom, -5)
            }
            .padding(.top)
            Spacer()
        }
        .padding(.horizontal)
    }
}
