import SwiftUI
import CoreLocation
import SwiftData

struct SacredPlaceDetailView: View {
    // 1. เข้าถึง "ตู้เซฟ" และดึงข้อมูล
    @Environment(\.modelContext) private var modelContext
    @Query private var checkInRecords: [CheckInRecord]
    
    let place: SacredPlace
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var locationManager: LocationManager
    
    @AppStorage("loggedInEmail") var loggedInEmail: String = ""
    
    @State private var showDetailSheet = false
    @State private var showContactOptions = false
    @State private var showCheckinAlert = false
    
    // ฟังก์ชันตรวจสอบการเช็คอิน (ทำงานกับ SwiftData)
    private func hasCheckedInToday() -> Bool {
        let today = Calendar.current.startOfDay(for: .now)
        return checkInRecords.contains { record in
            record.memberEmail.lowercased() == loggedInEmail.lowercased() &&
            record.placeID == place.id.uuidString &&
            Calendar.current.isDate(record.date, inSameDayAs: today)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Top Section (Navigation & Place Info)
                Button(action: {
                    flowManager.currentScreen = .recommendation
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(language.localized("ย้อนกลับ", "Back"))
                    }
                    .font(.body.bold())
                    .foregroundColor(.purple)
                    .padding(.leading)
                }
                
                Text(language.localized(place.nameTH, place.nameEN))
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                ExpandableTextView(
                    fullText: language.localized(place.descriptionTH, place.descriptionEN),
                    lineLimit: 5
                )
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Image(place.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                Button(action: {
                    showDetailSheet.toggle()
                }) {
                    Text(language.localized("ดูรายละเอียด", "View Details"))
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // MARK: - Map & Actions Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("📍 \(language.currentLanguage == "th" ? place.locationTH : place.locationEN)")
                        .font(.subheadline)
                        .padding(.horizontal)
                    
                    MapSnapshotView(
                        latitude: place.latitude,
                        longitude: place.longitude,
                        placeName: place.nameTH
                    )
                    .frame(height: 180)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Button(action: openInMaps) {
                        Label(language.localized("นำทาง", "Get Directions"), systemImage: "map.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // -- ปุ่มเช็คอิน (อัปเกรดแล้ว) --
                    VStack {
                        if hasCheckedInToday() {
                            Label("✅ คุณเช็คอินแล้ววันนี้", systemImage: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                        } else if isUserNearPlace() {
                            Button(action: {
                                let newRecord = CheckInRecord(
                                    placeID: place.id.uuidString,
                                    placeNameTH: place.nameTH,
                                    placeNameEN: place.nameEN,
                                    meritPoints: 15,
                                    memberEmail: loggedInEmail,
                                    date: Date(),
                                    latitude: place.latitude,
                                    longitude: place.longitude
                                )
                                modelContext.insert(newRecord)
                                showCheckinAlert = true
                            }) {
                                Label("เช็คอินเพื่อรับแต้ม", systemImage: "checkmark.seal.fill")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .cornerRadius(12)
                            }
                            .alert(isPresented: $showCheckinAlert) {
                                Alert(
                                    title: Text("✅ สำเร็จ"),
                                    message: Text("คุณได้เช็คอินเรียบร้อยแล้ว! รับ 15 แต้ม"),
                                    dismissButton: .default(Text("ตกลง"))
                                )
                            }
                        } else {
                            Text("📍 คุณยังอยู่ไกลเกินกว่าจะเช็คอินได้")
                                .foregroundColor(.gray)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // -- ปุ่มติดต่อ --
                    Button(action: {
                        showContactOptions = true
                    }) {
                        Text("📞 ติดต่อสถานที่")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .confirmationDialog("ติดต่อสถานที่", isPresented: $showContactOptions, titleVisibility: .visible) {
                        Button("โทร") { contactPhone() }
                        Button("อีเมล") { contactEmail() }
                        Button("แอดไลน์") { openLine() }
                        Button("ยกเลิก", role: .cancel) {}
                    }
                }
                .padding(.bottom) // เพิ่ม padding ด้านล่าง
            }
            .padding(.top)
        }
        .sheet(isPresented: $showDetailSheet) {
            DetailSheetView(details: place.details)
                .environmentObject(language)
        }
    }
    
    // MARK: - Helper Functions
    
    func isUserNearPlace() -> Bool {
        guard let userLocation = locationManager.userLocation else {
            return false
        }
        let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        let distance = userLocation.distance(from: placeLocation)
        return distance < 50000 // ระยะ 50 กม. สำหรับการทดสอบ
    }
    
    func openInMaps() {
        let latitude = place.latitude
        let longitude = place.longitude
        if let url = URL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=d") {
            UIApplication.shared.open(url)
        }
    }
    
    func contactPhone() {
        if let url = URL(string: "tel://022183365"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func contactEmail() {
        if let url = URL(string: "mailto:pr@chula.ac.th"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func openLine() {
        if let url = URL(string: "https://page.line.me/chulalongkornu"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

struct ExpandableTextView: View {
    let fullText: String
    let lineLimit: Int
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(fullText)
                .lineLimit(isExpanded ? nil : lineLimit)
                .animation(.easeInOut, value: isExpanded)
            
            Button(action: {
                isExpanded.toggle()
            }) {
                Text(isExpanded ? "แสดงน้อยลง" : "อ่านเพิ่มเติม")
                    .font(.subheadline)
                    .foregroundColor(.purple)
            }
        }
    }
}
