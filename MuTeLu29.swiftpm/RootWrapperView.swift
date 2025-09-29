import SwiftUI

struct RootWrapperView: View {
    @EnvironmentObject var language: AppLanguage
    
    var body: some View {
        AppView()
            .preferredColorScheme(language.isDarkMode ? .dark : .light)
    }
}
