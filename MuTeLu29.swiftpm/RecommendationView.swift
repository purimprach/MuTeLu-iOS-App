import SwiftUI
import MapKit

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// MARK: - Main View: RecommendationView
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
struct RecommendationView: View {
    // --- 1. Properties ---
    @StateObject private var viewModel = SacredPlaceViewModel()
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var locationManager: LocationManager
    
    // --- vvv จุดที่แก้ไข vvv ---
    @EnvironmentObject var activityStore: ActivityStore // ✅ เปลี่ยนมาใช้ ActivityStore
    // --- ^^^ จุดที่แก้ไข ^^^ ---
    
    @AppStorage("loggedInEmail") var loggedInEmail: String = ""
    
    @State private var recommendedPlaces: [SacredPlace] = []
    @State private var routeDistances: [UUID: CLLocationDistance] = [:]
    
    // --- 2. Body ---
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BackButton()
                
                Text(language.localized("สถานที่แนะนำ", "Recommended Places"))
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if !recommendedPlaces.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(language.localized("แนะนำสำหรับคุณโดยเฉพาะ", "Specially Recommended for You"))
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(recommendedPlaces) { place in
                            PlaceRow(place: place, routeDistance: routeDistances[place.id])
                        }
                    }
                    Divider().padding()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(language.localized("สถานที่ทั้งหมด", "All Places"))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.places) { place in
                        PlaceRow(place: place, routeDistance: routeDistances[place.id])
                    }
                }
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            locationManager.userLocation = CLLocation(latitude: 13.738444, longitude: 100.531750)
            generateRecommendations()
            Task { await calculateAllRouteDistances() }
        }
        .onChange(of: locationManager.userLocation) {
            Task { await calculateAllRouteDistances() }
        }
    }
    
    // --- 3. Functions ---
    
    private func generateRecommendations() {
        var userProfile: [String: Int] = [:]
        
        // --- vvv จุดที่แก้ไข vvv ---
        // ดึงข้อมูลจาก activityStore แทน UserActionStore
        let userActivities = activityStore.activities(for: loggedInEmail)
        
        for activity in userActivities {
            if let place = viewModel.places.first(where: { $0.id.uuidString == activity.placeID }) {
                // กำหนดคะแนนตามประเภทของ Activity
                let score: Int
                switch activity.type {
                case .checkIn:
                    score = 10
                case .bookmarked:
                    score = 5
                case .liked:
                    score = 3
                case .unliked, .unbookmarked:
                    score = -2 // ให้คะแนนติดลบเมื่อไม่ชอบหรือไม่สนใจ
                }
                
                for tag in place.tags {
                    userProfile[tag, default: 0] += score
                }
            }
        }
        // --- ^^^ จุดที่แก้ไข ^^^ ---
        
        let engine = RecommendationEngine(places: viewModel.places)
        let allVisitedIDs = activityStore.checkInRecords(for: loggedInEmail).map { UUID(uuidString: $0.placeID) }.compactMap { $0 }
        
        if !userProfile.isEmpty {
            self.recommendedPlaces = engine.getRecommendations(for: userProfile, excluding: allVisitedIDs, top: 3)
        } else {
            self.recommendedPlaces = Array(viewModel.places.sorted { $0.rating > $1.rating }.prefix(3))
        }
    }
    
    private func calculateAllRouteDistances() async {
        guard let userLocation = locationManager.userLocation else { return }
        
        let placesToCalculate = viewModel.places
        let results = await RouteDistanceService.shared.batchDistances(
            from: userLocation.coordinate,
            places: placesToCalculate,
            mode: .driving
        )
        
        var newDistances: [UUID: CLLocationDistance] = [:]
        for result in results {
            newDistances[result.place.id] = result.meters
        }
        
        self.routeDistances = newDistances
    }
}

// (Subviews: PlaceRow และ chip ไม่มีการเปลี่ยนแปลง)

struct PlaceRow: View {
    let place: SacredPlace
    let routeDistance: CLLocationDistance?
    
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    
    var body: some View {
        Button(action: {
            flowManager.currentScreen = .sacredDetail(place: place)
        }) {
            HStack(spacing: 16) {
                if UIImage(named: place.imageName) != nil {
                    Image(place.imageName)
                        .resizable().scaledToFill()
                        .frame(width: 90, height: 100).cornerRadius(10).clipped()
                } else {
                    Image(systemName: "photo")
                        .resizable().scaledToFill()
                        .frame(width: 90, height: 100).cornerRadius(10).clipped()
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(language.localized(place.nameTH, place.nameEN))
                        .font(.subheadline).foregroundColor(.primary)
                    
                    Text(language.localized(place.locationTH, place.locationEN))
                        .font(.caption).foregroundColor(.gray).lineLimit(2)
                    
                    HStack(spacing: 8) {
                        if let distance = routeDistance {
                            if distance != .infinity {
                                chip(text: formatDistance(distance), icon: "car.fill")
                            } else {
                                chip(text: "N/A", icon: "wifi.slash")
                            }
                        }
                        
                        chip(text: String(format: "%.1f", place.rating), icon: "star.fill")
                    }
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.gray.opacity(0.5))
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
    
    private func formatDistance(_ meters: CLLocationDistance) -> String {
        let formatter = MKDistanceFormatter()
        formatter.unitStyle = .abbreviated
        return formatter.string(fromDistance: meters)
    }
}

private func chip(text: String, icon: String) -> some View {
    HStack(spacing: 4) {
        Image(systemName: icon)
        Text(text)
    }
    .font(.caption).bold()
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(Color(.tertiarySystemBackground))
    .clipShape(Capsule())
    .foregroundColor(.orange)
}
