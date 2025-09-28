import SwiftUI
import CoreLocation

struct SacredPlaceDetailView: View {
    let place: SacredPlace
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var locationManager: LocationManager
    @State private var showDetailSheet = false
    @State private var showContactOptions = false
    @State private var showCheckinAlert = false
    @EnvironmentObject var checkInStore: CheckInStore
    @EnvironmentObject var memberStore: MemberStore
    @AppStorage("loggedInEmail") var loggedInEmail: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // 🔙 ปุ่มย้อนกลับ
                Button(action: {
                    flowManager.currentScreen = .recommendation
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(language.localized("ย้อนกลับ", "Back"))
                    }
                    .font(.body)
                    .foregroundColor(.purple)
                    .padding(.leading)
                    .bold()
                }
                Spacer()
                // ✅ ชื่อสถานที่
                Text(language.localized(place.nameTH, place.nameEN))
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                // ✅ กล่อง description
                ExpandableTextView(
                    fullText: language.localized(place.descriptionTH, place.descriptionEN),
                    lineLimit: 5
                )
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // ✅ รูปภาพ
                Image(place.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                // ✅ ปุ่มกดดูรายละเอียด
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
                
                // ✅ แผนที่
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
                    Spacer()
                    // ✅ ปุ่มนำทาง
                    Button(action: {
                        openInMaps()
                    }) {
                        Label(language.localized("นำทาง", "Get Directions"), systemImage: "map.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    //ปุ่มเช็คอิน
                    VStack {
                        if checkInStore.hasCheckedInToday(email: loggedInEmail, placeID: place.id.uuidString) {
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
                                checkInStore.add(record: newRecord)
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
                    
                    // ✅ ปุ่มติดต่อ
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
                        Button("โทร") {
                            contactPhone()
                        }
                        Button("อีเมล") {
                            contactEmail()
                        }
                        Button("แอดไลน์") {
                            openLine()
                        }
                        Button("ยกเลิก", role: .cancel) {}
                    }
                }
                .padding()
            }
            .padding(.top)
        }
        // ✅ Sheet แสดงข้อมูลรายละเอียด
        .sheet(isPresented: $showDetailSheet) {
            DetailSheetView(details: place.details)
                .environmentObject(language)
        }
        .onAppear {
            locationManager.userLocation = CLLocation(latitude: 13.738444, longitude: 100.531750)
        }
    }
    
    func isUserNearPlace() -> Bool {
        
        guard let userLocation = locationManager.userLocation else {
            print("❌ ไม่พบตำแหน่งผู้ใช้")
            return false
        }
        //print("🔎 ตำแหน่ง user: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
        let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        let distance = userLocation.distance(from: placeLocation)
        //print("📍 ระยะห่างระหว่างคุณกับ \(place.nameTH): \(distance) เมตร")
        
        return distance < 1000
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
