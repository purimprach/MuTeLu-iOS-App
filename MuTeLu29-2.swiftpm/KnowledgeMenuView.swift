import SwiftUI 

struct KnowledgeMenuView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flow: MuTeLuFlowManager
    
    var body: some View {
        VStack(spacing: 20) {
            BackButton()
            
            Text(language.localized("เกร็ดความรู้", "Knowledge"))
                .font(.title2)
                .fontWeight(.bold)
            
            Button(action: {
                flow.currentScreen = .wishDetail
            }) {
                Label(language.localized("หลักการขอพร", "Principles of Making a Wish"), systemImage: "sparkles")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding()
    }
}
