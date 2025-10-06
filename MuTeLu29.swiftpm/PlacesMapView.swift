import SwiftUI
import MapKit

struct PlacesMapView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var locationManager: LocationManager
    
    @StateObject private var viewModel = SacredPlaceViewModel()
    @State private var selectedPlace: SacredPlace?
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack(alignment: .bottom) {
            MapReader { proxy in
                Map(selection: $selectedPlace) {
                    
                    // --- 👇 แทนที่ UserAnnotation() เดิมด้วยโค้ดนี้ ---
                    // 1. เช็คว่ามีตำแหน่งผู้ใช้หรือไม่
                    if let userCoordinate = locationManager.userLocation?.coordinate {
                        // 2. สร้าง Annotation สำหรับตำแหน่งผู้ใช้
                        Annotation("ตำแหน่งของคุณ", coordinate: userCoordinate) {
                            // 3. สร้าง View ของหมุด (จุดสีฟ้า) ขึ้นมาเอง
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 44, height: 44) // วงแหวนโปร่งแสง
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 20, height: 20) // วงแหวนสีขาว
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 12, height: 12) // จุดสีฟ้าตรงกลาง
                            }
                        }
                    }
                    // -----------------------------------------
                    
                    ForEach(viewModel.places) { place in
                        Marker(
                            language.localized(place.nameTH, place.nameEN),
                            systemImage: "building.columns.fill",
                            coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
                        )
                        .tint(.purple)
                        .tag(place)
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .onTapGesture {
                    selectedPlace = nil // เมื่อแตะที่แผนที่ ให้ยกเลิกการเลือก
                }

                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
            }
            .overlay(alignment: .top) {
                // ปุ่มย้อนกลับ (เหมือนเดิม)
                HStack {
                    Button(action: { flowManager.currentScreen = .home }) {
                        Label(language.localized("ย้อนกลับ", "Back"), systemImage: "chevron.left")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(.thinMaterial)
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                    }
                    Spacer()
                }
                .padding()
            }
            
            // การ์ดข้อมูล (เหมือนเดิม)
            if let place = selectedPlace {
                MapDetailCard(place: place)
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: selectedPlace)
        .onAppear(perform: setupInitialCamera)
        .onChange(of: selectedPlace) {
            if let place = selectedPlace {
                withAnimation(.easeInOut(duration: 0.5)) {
                    position = .camera(MapCamera(
                        centerCoordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude),
                        distance: 2000
                    ))
                }
            }
        }
    }
    
    private func setupInitialCamera() {
        if let userCoord = locationManager.userLocation?.coordinate {
            position = .camera(MapCamera(centerCoordinate: userCoord, distance: 10000))
        } else {
            let bangkokCoordinate = CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018)
            position = .camera(MapCamera(centerCoordinate: bangkokCoordinate, distance: 30000))
        }
    }
}

// (Struct MapDetailCard ไม่มีการแก้ไข)
struct MapDetailCard: View {
    let place: SacredPlace
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    
    var body: some View {
        VStack(spacing: 0) {
            Image(place.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(language.localized(place.nameTH, place.nameEN))
                    .font(.headline)
                
                Text(language.localized(place.locationTH, place.locationEN))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Button(action: {
                    flowManager.currentScreen = .sacredDetail(place: place)
                }) {
                    Text(language.localized("ดูรายละเอียด", "View Details"))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 10)
    }
}
