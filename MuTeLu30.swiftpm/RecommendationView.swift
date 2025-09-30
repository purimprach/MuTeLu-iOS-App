import SwiftUI
import MapKit

struct RecommendationView: View {
    // รับ ViewModel และ Stores เข้ามาเพื่อเข้าถึงข้อมูลทั้งหมด
    @StateObject private var viewModel = SacredPlaceViewModel()
    //@ObservedObject var viewModel: SacredPlaceViewModel
    @EnvironmentObject var checkInStore: CheckInStore
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @AppStorage("loggedInEmail") var loggedInEmail: String = ""
    
    // State สำหรับเก็บผลลัพธ์การแนะนำ
    @State private var recommendedPlaces: [SacredPlace] = []
    @State private var sourcePlaceName: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                BackButton()
                
                Text(language.localized("สถานที่แนะนำ", "Recommended Places"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // ✅ 1. Section ใหม่สำหรับแสดงผลลัพธ์โดยเฉพาะ
                if !recommendedPlaces.isEmpty, let sourceName = sourcePlaceName {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(language.localized("เพราะคุณเพิ่งไป: \(sourceName)", "Because you recently visited: \(sourceName)"))
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(recommendedPlaces) { place in
                            PlaceRow(place: place)
                        }
                    }
                    Divider().padding()
                }
                
                // ✅ 2. Section สำหรับแสดงสถานที่ทั้งหมด (ยังคงมีอยู่)
                VStack(alignment: .leading, spacing: 8) {
                    Text(language.localized("สถานที่ทั้งหมด", "All Places"))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.places) { place in
                        PlaceRow(place: place)
                    }
                }
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground))
        // ✅ 3. เมื่อหน้าจอแสดงผล ให้เริ่มสร้างคำแนะนำ
        .onAppear(perform: generateRecommendations)
    }
    
    // ✅ 4. ฟังก์ชันสำหรับสร้างคำแนะนำ
    private func generateRecommendations() {
        // 4.1 หาประวัติการเช็คอินล่าสุดของผู้ใช้
        guard let latestCheckIn = checkInStore.records(for: loggedInEmail).sorted(by: { $0.date > $1.date }).first,
              let sourcePlace = viewModel.places.first(where: { $0.id.uuidString == latestCheckIn.placeID }) else {
            // ถ้าไม่เคยเช็คอินเลย ให้เคลียร์ค่าทิ้ง
            self.recommendedPlaces = []
            self.sourcePlaceName = nil
            return
        }
        
        // 4.2 สร้าง Engine โดยใช้ข้อมูลสถานที่ทั้งหมดจาก ViewModel
        let engine = RecommendationEngine(places: viewModel.places)
        
        // 4.3 หา ID ของสถานที่ที่เคยไปแล้วทั้งหมด เพื่อไม่ให้แนะนำซ้ำ
        let visitedIDs = checkInStore.records(for: loggedInEmail).map { UUID(uuidString: $0.placeID) }.compactMap { $0 }
        
        // 4.4 สร้างคำแนะนำ!
        self.recommendedPlaces = engine.getRecommendations(basedOn: sourcePlace, excluding: visitedIDs)
        self.sourcePlaceName = language.localized(sourcePlace.nameTH, sourcePlace.nameEN)
    }
}

// MARK: - Subviews (เพื่อให้โค้ด Compile ผ่าน)
struct PlaceRow: View {
    let place: SacredPlace
    private let chulaCoord = CLLocationCoordinate2D(latitude: 13.736717, longitude: 100.532936)
    
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    
    var body: some View {
        Button(action: {
            flowManager.currentScreen = .sacredDetail(place: place)
        }) {
            HStack(spacing: 16) {
                if UIImage(named: place.imageName) != nil {
                    Image(place.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 90, height: 100)
                        .cornerRadius(10)
                        .clipped()
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 90, height: 100)
                        .cornerRadius(10)
                        .clipped()
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(language.localized(place.nameTH, place.nameEN))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Text(language.localized(place.locationTH, place.locationEN))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        let d = place.distanceFrom(chulaCoord)
                        chip(text: String(format: "~ %.1f กม.", d / 1000), icon: "mappin.and.ellipse")
                        chip(text: String(format: "%.1f", place.rating), icon: "star.fill")
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
        }
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
