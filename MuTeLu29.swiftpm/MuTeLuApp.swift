import SwiftUI
import SwiftData // 👈 1. เพิ่มบรรทัดนี้

@main
struct MuTeLuApp: App {
    @StateObject var language = AppLanguage()
    @StateObject var flowManager = MuTeLuFlowManager()
    @StateObject var locationManager = LocationManager()
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Member.self, CheckInRecord.self)
        } catch {
            fatalError("Could not initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootWrapperView()
                .environmentObject(language)
                .environmentObject(flowManager)
                .environmentObject(locationManager)
        }
        .modelContainer(modelContainer)
    }
}
