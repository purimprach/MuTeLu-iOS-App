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
    @EnvironmentObject var likeStore: LikeStore
    @EnvironmentObject var bookmarkStore: BookmarkStore
    @EnvironmentObject var userActionStore: UserActionStore
    
    @AppStorage("loggedInEmail") var loggedInEmail: String = ""
    
    @State private var isLiked: Bool = false
    @State private var isBookmarked: Bool = false
    
    @State private var refreshTrigger = UUID()
    @State private var countdownTimer: Timer?
    @State private var timeRemaining: TimeInterval = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // ปุ่มย้อนกลับ
                Button(action: { flowManager.currentScreen = .recommendation }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(language.localized("ย้อนกลับ", "Back"))
                    }
                    .font(.body).foregroundColor(.purple).padding(.leading).bold()
                }
                
                // MARK: - Header Card
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        Text(language.localized(place.nameTH, place.nameEN))
                            .font(.title2).fontWeight(.bold).multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        // --- กลุ่มปุ่ม Like และ Bookmark ---
                        HStack(spacing: 20) {
                            // ปุ่ม Bookmark
                            Button(action: {
                                bookmarkStore.toggleBookmark(placeID: place.id.uuidString, for: loggedInEmail)
                                userActionStore.logAction(type: .bookmark, placeID: place.id.uuidString, memberEmail: loggedInEmail)
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                                    isBookmarked.toggle()
                                }
                            }) {
                                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                    .font(.title)
                                    .foregroundColor(isBookmarked ? .blue : .gray)
                                    .scaleEffect(isBookmarked ? 1.2 : 1.0)
                            }
                            
                            // ปุ่ม Like
                            Button(action: {
                                likeStore.toggleLike(placeID: place.id.uuidString, for: loggedInEmail)
                                userActionStore.logAction(type: .like, placeID: place.id.uuidString, memberEmail: loggedInEmail)
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                                    isLiked.toggle()
                                }
                            }) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .font(.title)
                                    .foregroundColor(isLiked ? .red : .gray)
                                    .scaleEffect(isLiked ? 1.2 : 1.0)
                            }
                        }
                    }
                    
                    Label(language.currentLanguage == "th" ? place.locationTH : place.locationEN, systemImage: "mappin.and.ellipse")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                .padding().background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
                
                // MARK: - Description
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
                
                // MARK: - Image
                Image(place.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                // MARK: - Buttons
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
                
                // MARK: - Map and Actions
                VStack(alignment: .leading, spacing: 15) {
                    MapSnapshotView(
                        latitude: place.latitude,
                        longitude: place.longitude,
                        placeName: place.nameTH
                    )
                    .frame(height: 180)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
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
                    
                    // Check-in Button Logic
                    VStack {
                        if checkInStore.hasCheckedInRecently(email: loggedInEmail, placeID: place.id.uuidString) {
                            VStack(spacing: 8) {
                                Label(language.localized("เช็คอินแล้ว", "Checked-in"), systemImage: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                
                                if timeRemaining > 0 {
                                    Text(language.localized("เช็คอินครั้งถัดไปได้ในอีก:", "Next check-in in:"))
                                    Text(formatTime(timeRemaining))
                                        .font(.system(.headline, design: .monospaced).bold())
                                        .foregroundColor(.orange)
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
                        } else if isUserNearPlace() {
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
                                    
                                    // (Optional) Update tag scores
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
                        } else {
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
                    
                    // Contact Button
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
            }
            .padding(.top)
        }
        .sheet(isPresented: $showDetailSheet) {
            DetailSheetView(details: place.details)
                .environmentObject(language)
        }
        .onAppear {
            isLiked = likeStore.isLiked(placeID: place.id.uuidString, by: loggedInEmail)
            isBookmarked = bookmarkStore.isBookmarked(placeID: place.id.uuidString, by: loggedInEmail)
            startCountdownTimer()
        }
        .onDisappear {
            stopCountdownTimer()
        }
    }
    
    // MARK: - Functions
    func isUserNearPlace() -> Bool {
        guard let userLocation = locationManager.userLocation else {
            print("❌ ไม่พบตำแหน่งผู้ใช้")
            return false
        }
        let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        let distance = userLocation.distance(from: placeLocation)
        return distance < 50000 // 50 km for testing
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
    
    // MARK: - Timer Functions
    func startCountdownTimer() {
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
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}

// MARK: - ExpandableTextView
struct ExpandableTextView: View {
    let fullText: String
    let lineLimit: Int
    @State private var isExpanded = false
    @EnvironmentObject var language: AppLanguage
    
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
}
