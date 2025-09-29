import SwiftUI
import MapKit

struct RecommendationView: View {
    @StateObject private var viewModel = SacredPlaceViewModel()
    @EnvironmentObject var checkInStore: CheckInStore
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var locationManager: LocationManager
    @AppStorage("loggedInEmail") var loggedInEmail: String = ""
    
    // State สำหรับเก็บผลลัพธ์การแนะนำ
    @State private var recommendedPlaces: [SacredPlace] = []
    @State private var sourcePlaceName: String? = nil
    
    // State ใหม่สำหรับเก็บ "ระยะทางขับรถจริง" ที่คำนวณแล้ว
    @State private var routeDistances: [UUID: CLLocationDistance] = [:]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BackButton()
                
                Text(language.localized("สถานที่แนะนำ", "Recommended Places"))
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Section "เพราะคุณเพิ่งไป"
                if !recommendedPlaces.isEmpty, let sourceName = sourcePlaceName {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(language.localized("เพราะคุณเพิ่งไป: \(sourceName)", "Because you recently visited: \(sourceName)"))
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(recommendedPlaces) { place in
                            PlaceRow(
                                place: place,
                                routeDistance: routeDistances[place.id]
                            )
                        }
                    }
                    Divider().padding()
                }
                
                // Section "สถานที่ทั้งหมด"
                VStack(alignment: .leading, spacing: 8) {
                    Text(language.localized("สถานที่ทั้งหมด", "All Places"))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.places) { place in
                        PlaceRow(
                            place: place,
                            routeDistance: routeDistances[place.id]
                        )
                    }
                }
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            // MARK: - โค้ดสำหรับทดสอบใน App Preview
            // บรรทัดนี้จะจำลองตำแหน่งเพื่อให้เราเห็นผลลัพธ์ใน Preview
            // (เมื่อรันบนเครื่องจริง ควรลบออกเพื่อให้ใช้ GPS จริง)
            locationManager.userLocation = CLLocation(latitude: 13.738444, longitude: 100.531750)
            
            generateRecommendations()
            // เมื่อหน้าจอแสดง ให้เริ่มคำนวณระยะทางขับรถจริง
            Task { await calculateAllRouteDistances() }
        }
        .onChange(of: locationManager.userLocation) {
            // ถ้าตำแหน่งผู้ใช้อัปเดต ให้คำนวณใหม่
            Task { await calculateAllRouteDistances() }
        }
    }
    
    // ฟังก์ชันสำหรับคำนวณระยะทางขับรถจริง (ทำงานเบื้องหลัง)
    private func calculateAllRouteDistances() async {
        guard let userLocation = locationManager.userLocation else { return }
        
        let results = await RouteDistanceService.shared.batchDistances(
            from: userLocation.coordinate,
            places: viewModel.places,
            mode: .driving
        )
        
        var newDistances: [UUID: CLLocationDistance] = [:]
        for result in results {
            newDistances[result.place.id] = result.meters
        }
        
        self.routeDistances = newDistances
    }
    
    // ฟังก์ชันสร้างคำแนะนำ (เหมือนเดิม)
    private func generateRecommendations() {
        guard let latestCheckIn = checkInStore.records(for: loggedInEmail).sorted(by: { $0.date > $1.date }).first,
              let sourcePlace = viewModel.places.first(where: { $0.id.uuidString == latestCheckIn.placeID }) else {
            self.recommendedPlaces = []
            self.sourcePlaceName = nil
            return
        }
        
        let engine = RecommendationEngine(places: viewModel.places)
        let visitedIDs = checkInStore.records(for: loggedInEmail).map { UUID(uuidString: $0.placeID) }.compactMap { $0 }
        
        self.recommendedPlaces = engine.getRecommendations(basedOn: sourcePlace, excluding: visitedIDs)
        self.sourcePlaceName = language.localized(sourcePlace.nameTH, sourcePlace.nameEN)
    }
}

// MARK: - Subviews (PlaceRow ที่แก้ไขปัญหา infinity แล้ว)

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
                                // กรณีคำนวณสำเร็จ: แสดงระยะทางและรูปรถ
                                chip(text: formatDistance(distance), icon: "car.fill")
                            } else {
                                // กรณีคำนวณล้มเหลว: แสดง N/A และรูป wifi ขาด
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

// chip function (เหมือนเดิม)
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
