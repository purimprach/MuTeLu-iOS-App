import SwiftUI
import SwiftData

struct GreetingStartupView: View {
    @Query private var members: [Member]
    
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @AppStorage("loggedInEmail") var loggedInEmail: String = ""
    
    private var currentMember: Member? {
        members.first { $0.email == loggedInEmail }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if let member = currentMember {
                Text(language.localized("สวัสดีครับคุณ \(member.fullName)", "Hello, \(member.fullName)"))
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(language.localized("อย่าลืมเช็กดวงประจำวันนะครับ", "Don't forget to check your daily fortune!"))
                    .font(.body)
                    .foregroundColor(.secondary)
            } else {
                Text(language.localized("ยินดีต้อนรับครับ", "Welcome"))
            }
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                flowManager.currentScreen = .home
            }
        }
    }
}

