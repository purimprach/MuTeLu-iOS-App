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
    @State private var refreshTrigger = UUID()
    @State private var countdownTimer: Timer?
    @State private var timeRemaining: TimeInterval = 0
    
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
                    
                    // 👇 --- **ส่วน UI ที่แก้ไข** ---
                    VStack {
                        // 1. เช็คว่าเคยเช็คอินที่นี่เมื่อไม่นานมานี้หรือไม่
                        if checkInStore.hasCheckedInRecently(email: loggedInEmail, placeID: place.id.uuidString) {
                            VStack(spacing: 8) {
                                Label(language.localized("เช็คอินแล้ว", "Checked-in"), systemImage: "checkmark.seal.fill")
                                    .foregroundColor(.purple)
                                
                                // 2. แสดงเวลาที่เหลือ
                                if timeRemaining > 0 {
                                    Text(language.localized("เช็คอินครั้งถัดไปได้ในอีก:", "Next check-in in:"))
                                    Text(formatTime(timeRemaining))
                                        .font(.system(.headline, design: .monospaced).bold())
                                        .foregroundColor(.red)
                                } else {
                                    Text(language.localized("สามารถเช็คอินใหม่ได้แล้ว", "Ready to check-in again"))
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                        }
                        // 3. เช็คว่าอยู่ในระยะที่เช็คอินได้หรือไม่
                        else if isUserNearPlace() {
                            Button(action: {
                                if !checkInStore.hasCheckedInRecently(email: loggedInEmail, placeID: place.id.uuidString) {
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
                                    
                                    // อัปเดตคะแนน Tag
                                    if let userIndex = memberStore.members.firstIndex(where: { $0.email == loggedInEmail }) {
                                        for tag in place.tags {
                                            memberStore.members[userIndex].tagScores[tag, default: 0] += 1
                                        }
                                    }
                                    
                                    refreshTrigger = UUID()
                                    showCheckinAlert = true
                                }
                            }) {
                                Label(language.localized("เช็คอินเพื่อรับแต้ม", "Check-in to earn points"), systemImage: "checkmark.seal.fill")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .cornerRadius(12)
                            }
                            .alert(isPresented: $showCheckinAlert) {
                                Alert(
                                    title: Text("✅ \(language.localized("สำเร็จ", "Success"))"),
                                    message: Text(language.localized("คุณได้เช็คอินเรียบร้อยแล้ว! รับ 15 แต้ม", "You have checked in! Received 15 points")),
                                    dismissButton: .default(Text(language.localized("ตกลง", "OK")))
                                )
                            }
                        }
                        // 4. กรณีที่อยู่นอกระยะ
                        else {
                            Text("📍 \(language.localized("คุณยังอยู่ไกลเกินกว่าจะเช็คอินได้", "You are too far to check-in"))")
                                .foregroundColor(.gray)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .id(refreshTrigger)
                    // -----------------------------
                    
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
                        Button("โทร") { contactPhone() }
                        Button("อีเมล") { contactEmail() }
                        Button("แอดไลน์") { openLine() }
                        Button("ยกเลิก", role: .cancel) {}
                    }
                }
                .padding()
            }
            .padding(.top)
        }
        .sheet(isPresented: $showDetailSheet) {
            DetailSheetView(details: place.details)
                .environmentObject(language)
        }
        .onAppear(perform: startCountdownTimer) // 👈 เรียก Timer เมื่อหน้าจอแสดง
        .onDisappear(perform: stopCountdownTimer) // 👈 หยุด Timer เมื่อออกจากหน้า
    }
    
    func isUserNearPlace() -> Bool {
        guard let userLocation = locationManager.userLocation else {
            print("❌ ไม่พบตำแหน่งผู้ใช้")
            return false
        }
        let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        let distance = userLocation.distance(from: placeLocation)
        
        return distance < 50000 // 50 km
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
    
    func startCountdownTimer() {
        stopCountdownTimer() // หยุด Timer เก่าก่อนเริ่มใหม่
        updateTimeRemaining()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimeRemaining()
        }
    }
    
    func stopCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    func updateTimeRemaining() {
        if let remaining = checkInStore.timeRemainingUntilNextCheckIn(email: loggedInEmail, placeID: place.id.uuidString) {
            timeRemaining = remaining
            if remaining <= 0 {
                stopCountdownTimer()
                refreshTrigger = UUID()
            }
        } else {
            timeRemaining = 0
        }
    }
    
    // 👇 --- **แก้ไขฟังก์ชันนี้** ---
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        
        // จัดรูปแบบเป็น HH:MM:SS
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
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
                Text(isExpanded ? language.localized("แสดงน้อยลง", "Show Less") : language.localized("อ่านเพิ่มเติม", "Read More"))
                    .font(.subheadline)
                    .foregroundColor(.purple)
            }
        }
    }
    
    // เพิ่ม EnvironmentObject เพื่อให้ View ย่อยนี้รู้จักภาษาที่เลือก
    @EnvironmentObject var language: AppLanguage
}
