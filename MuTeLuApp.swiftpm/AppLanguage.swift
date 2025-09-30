import Foundation

class AppLanguage: ObservableObject {
    @Published var currentLanguage: String = "th"
    @Published var isDarkMode: Bool = false
    
    func toggleLanguage() {
        currentLanguage = (currentLanguage == "th") ? "en" : "th"
    }
    
    func localized(_ th: String, _ en: String) -> String {
        return currentLanguage == "th" ? th : en
    }
}

