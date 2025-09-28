import SwiftUI

struct RootWrapperView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var checkInStore: CheckInStore 
    
    var body: some View {
        AppView()
            .onAppear {
                checkInStore.load()
            }
            .preferredColorScheme(language.isDarkMode ? .dark : .light)
            //.id("theme-\(language.isDarkMode)") // ✅ รีเฟรชเฉพาะ Theme
    }
}
