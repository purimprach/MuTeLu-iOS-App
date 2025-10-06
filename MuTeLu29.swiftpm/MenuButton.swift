import SwiftUI

struct MenuButton: View {
    let titleTH: String
    let titleEN: String
    let image: String
    let screen: MuTeLuScreen
    
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
                flowManager.currentScreen = screen
            }
        }) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 60, height: 60)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    Image(systemName: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.purple)
                }
                Text(language.localized(titleTH, titleEN))
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 150)
            // --- 👇 แก้ไขบรรทัดนี้ ---
            .background(Color(.secondarySystemBackground))
            // --------------------
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
    }
}
