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
            // 1. สร้าง Schema อย่างชัดเจน
            let schema = Schema([
                Member.self,
                CheckInRecord.self,
                UserTagPreference.self,
                UserInteraction.self
            ])

            // 2. กำหนด ModelConfiguration
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )

            // 3. สร้าง ModelContainer ด้วย explicit configuration
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            // 4. Debug logging
            #if DEBUG
            print("✅ ModelContainer initialized successfully")
            if let storeURL = modelContainer.configurations.first?.url {
                print("📂 SwiftData store: \(storeURL.path)")
            }
            #endif

        } catch {
            // 5. ปรับปรุง error message
            #if DEBUG
            print("❌ ModelContainer initialization failed")
            print("Error: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("Domain: \(nsError.domain)")
                print("Code: \(nsError.code)")
                print("UserInfo: \(nsError.userInfo)")
            }
            #endif

            fatalError("Could not initialize ModelContainer: \(error.localizedDescription)")
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
