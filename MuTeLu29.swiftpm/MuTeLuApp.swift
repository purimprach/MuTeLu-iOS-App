import SwiftUI

@main
struct MuTeLuApp: App {
    // --- 1. สร้าง @StateObject ทั้งหมดที่นี่ที่เดียว ---
    @StateObject var language = AppLanguage()
    @StateObject var flowManager = MuTeLuFlowManager()
    @StateObject var locationManager = LocationManager()
    @StateObject var memberStore = MemberStore()
    @StateObject var checkInStore = CheckInStore()
    @StateObject var likeStore = LikeStore()
    @StateObject var bookmarkStore = BookmarkStore()
    @StateObject var userActionStore = UserActionStore()
    
    var body: some Scene {
        WindowGroup {
            RootWrapperView()
            // --- 2. ส่งต่อ EnvironmentObject ทั้งหมดให้ครบ ---
                .environmentObject(language)
                .environmentObject(flowManager)
                .environmentObject(locationManager)
                .environmentObject(memberStore)
                .environmentObject(checkInStore)
                .environmentObject(likeStore)
                .environmentObject(bookmarkStore)
                .environmentObject(userActionStore)
        }
    }
}
