import SwiftUI
import CryptoKit // ✅ 1. เพิ่มบรรทัดนี้

struct LoginView: View {
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var memberStore: MemberStore
    @AppStorage("loggedInEmail") private var loggedInEmail: String = ""
    @AppStorage("currentUserEmail") var currentUserEmail = ""
    
    @State private var username = ""
    @State private var password = ""
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    @State private var showGreetingPopup = false
    @State private var greetingName = ""
    @State private var randomGreetingMessage = ""
    
    let greetings = [
        "ขอให้วันนี้เต็มไปด้วยพลังบวกและความสำเร็จ",
        "ขอให้คุณพบแต่สิ่งดี ๆ เข้ามาในชีวิต",
        "วันนี้จะเป็นวันที่ยอดเยี่ยมสำหรับคุณ",
        "ขอให้สมหวังในสิ่งที่ตั้งใจ",
        "วันนี้คุณจะโชคดีเกินคาด!"
    ]
    
    var body: some View {
        // ... ส่วน body ของคุณไม่ต้องแก้ไข ...
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.7),
                                            Color(red: 0.1, green: 0, blue: 0.3)]),
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 15) {
                // Language Picker
                HStack {
                    Spacer()
                    Picker("", selection: $language.currentLanguage) {
                        Text("TH").tag("th")
                        Text("EN").tag("en")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 120)
                }
                .padding(.top)
                .padding(.trailing)
                
                Spacer()
                
                Image("LogoMuTeLu")
                    .resizable().scaledToFill()
                    .frame(width: 130, height: 130)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 3))
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
                
                Text("Mu Te Lu")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
                
                Text(language.localized("แอปสายมูสำหรับคุณ", "A spiritual guide for you"))
                    .font(.headline).foregroundColor(.white.opacity(0.85))
                
                // Email
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                    TextField(language.localized("อีเมล", "Email"), text: $username)
                        .textFieldStyle(.plain)
                        .autocapitalization(.none)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 1)
                .padding(.horizontal)
                
                // Password
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                    SecureField(language.localized("รหัสผ่าน", "Password"), text: $password)
                        .textFieldStyle(.plain)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 1)
                .padding(.horizontal)
                
                // Login Button
                Button(action: handleLogin) {
                    Label(language.localized("เข้าสู่ระบบ", "Login"), systemImage: "arrow.right.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Register Button
                Button {
                    flowManager.currentScreen = .registration
                    flowManager.isLoggedIn = true
                } label: {
                    Text(language.localized("ยังไม่ได้เป็นสมาชิก กดที่นี่", "Not a member yet? Tap here."))
                        .font(.footnote)
                        .foregroundColor(.white)
                        .underline()
                }
                Button(language.localized("< ระบบผู้ดูแล >", "< Admin > Login")) {
                    flowManager.currentScreen = .adminLogin
                }
                .font(.caption)
                .foregroundColor(.white)
                
                Spacer()
            }
            .blur(radius: showGreetingPopup ? 3 : 0)
            
            // Greeting Popup
            if showGreetingPopup {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        Text("🎉")
                            .font(.system(size: 50))
                        
                        Text(language.localized("สวัสดีครับคุณ\n\(greetingName)", "Hello, \(greetingName)"))
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(language.localized(randomGreetingMessage, randomGreetingMessage))
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            withAnimation {
                                showGreetingPopup = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                flowManager.isLoggedIn = true
                                flowManager.currentScreen = .home
                            }
                        }) {
                            Text(language.localized("ตกลง", "OK"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            withAnimation {
                                showGreetingPopup = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                flowManager.isLoggedIn = true
                                flowManager.currentScreen = .tarot
                            }
                        }) {
                            Text(language.localized("ไปดูดวงเลย 🔮", "Check Your Fortune 🔮"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .frame(minWidth: 280, maxWidth: 400)
                    .background(.ultraThinMaterial)
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(2)
                }
            }
        }
        .animation(.spring(), value: showGreetingPopup)
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text(language.localized("เกิดข้อผิดพลาด", "Error")),
                message: Text(errorMessage),
                dismissButton: .default(Text(language.localized("ตกลง", "OK")))
            )
        }
    }
    
    // ✅ 3. แก้ไขฟังก์ชัน handleLogin ทั้งหมด
    func handleLogin() {
        let trimmedEmail = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // ค้นหาสมาชิกด้วยอีเมล
        if let matched = memberStore.members.first(where: { $0.email.lowercased() == trimmedEmail }) {
            // นำรหัสผ่านที่กรอกไป Hash แล้วเปรียบเทียบกับรหัสที่เก็บไว้
            if matched.password == hashPassword(trimmedPassword) {
                // --- Login สำเร็จ ---
                currentUserEmail = matched.email
                loggedInEmail = matched.email
                greetingName = matched.fullName
                randomGreetingMessage = greetings.randomElement() ?? ""
                
                withAnimation {
                    showGreetingPopup = true
                }
            } else {
                // --- รหัสผ่านผิด ---
                errorMessage = language.localized("อีเมลหรือรหัสผ่านไม่ถูกต้อง", "Incorrect email or password")
                showErrorAlert = true
            }
        } else {
            // --- ไม่พบอีเมล ---
            errorMessage = language.localized("อีเมลหรือรหัสผ่านไม่ถูกต้อง", "Incorrect email or password")
            showErrorAlert = true
        }
    }
    
    // ✅ 2. เพิ่มฟังก์ชัน hashPassword
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

