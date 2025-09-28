import Foundation

class MuTeLuFlowManager: ObservableObject {
    @Published var currentScreen: MuTeLuScreen = .home
    @Published var isLoggedIn: Bool = false
    @Published var members: [Member] = []
    @Published var loggedInEmail: String = ""
}

enum MuTeLuScreen {
    case home
    case login
    case registration
    case editProfile   
    case recommenderForYou 
    case recommendation
    case sacredDetail(place: SacredPlace)
    case phoneFortune
    case shirtColor
    case carPlate
    case houseNumber
    case tarot
    case mantra
    case seamSi
    case knowledge
    case wishDetail
    case adminLogin
    case admin
    case gameMenu
    case meritPoints
    case offeringGame
}
