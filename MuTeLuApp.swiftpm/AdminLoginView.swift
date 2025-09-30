
import SwiftUI

struct AdminLoginView: View {
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var language: AppLanguage
    
    @State private var username = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showError = false
    @State private var errorText = ""
    
    private let correctUsername = "admin"
    private let correctPassword = "123456"
    
    private var canSubmit: Bool {
        !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.5), Color.blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 🔙 ปุ่มย้อนกลับอยู่ในเนื้อหน้า (ไม่ง้อ Toolbar)
                HStack {
                    Button {
                        flowManager.currentScreen = .login
                    } label: {
                        Label(language.localized("ย้อนกลับ", "Back"), systemImage: "chevron.left")
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.horizontal)
                .padding()
                
                Spacer(minLength: 8)
                
                Text(language.localized("เข้าสู่ระบบผู้ดูแล", "Admin Login"))
                    .font(.title).bold()
                    .padding()
                
                // การ์ดฟอร์ม
                VStack(spacing: 16) {
                    IconTextField(
                        systemImage: "person.crop.circle.fill",
                        placeholder: language.localized("ชื่อผู้ใช้", "Username"),
                        text: $username
                    )
                    .textInputAutocapitalization(.never)
                    .keyboardType(.default)
                    
                    IconSecureField(
                        systemImage: "lock.fill",
                        placeholder: language.localized("รหัสผ่าน", "Password"),
                        text: $password,
                        isRevealed: $showPassword
                    )
                    
                    if showError {
                        Text(errorText)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                            .transition(.opacity)
                    }
                    
                    Button(action: handleLogin) {
                        Text(language.localized("เข้าสู่ระบบ", "Login"))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canSubmit ? Color.purple : Color.gray.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
                    }
                    .disabled(!canSubmit)
                    .padding(.top, 6)
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
                .padding(.horizontal)
                
                Spacer()
                Spacer()
            }
        }
    }
    
    // MARK: - Action
    private func handleLogin() {
        withAnimation { showError = false }
        
        let u = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let p = password
        
        guard u == correctUsername.lowercased(), p == correctPassword else {
            errorText = language.localized("ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง", "Incorrect username or password")
            withAnimation { showError = true }
            return
        }
        
        flowManager.currentScreen = .admin
    }
}

//
// MARK: - Reusable Fields
//

/// TextField + ไอคอนซ้าย (บังคับสีตัวอักษร & สีเคอร์เซอร์)
struct IconTextField: View {
    let systemImage: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundColor(.gray)
                .frame(width: 22)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
            // จากเดิม: .foregroundColor(.primary)
            // แก้เป็น:
                .foregroundColor(.black) // ✅ บังคับเป็นสีดำเสมอ
                .tint(.purple)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }
}


/// SecureField + ไอคอน + ปุ่มโชว์/ซ่อน (บังคับสีตัวอักษร & สีเคอร์เซอร์)
struct IconSecureField: View {
    let systemImage: String
    let placeholder: String
    @Binding var text: String
    @Binding var isRevealed: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundColor(.gray)
                .frame(width: 22)
            
            if isRevealed {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                // แก้ไขจุดที่ 1
                    .foregroundColor(.black) // ✅
                    .tint(.purple)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
            } else {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                // แก้ไขจุดที่ 2
                    .foregroundColor(.black) // ✅
                    .tint(.purple)
            }
            
            Button {
                withAnimation(.easeInOut(duration: 0.15)) { isRevealed.toggle() }
            } label: {
                Image(systemName: isRevealed ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
            .accessibilityLabel(isRevealed ? "Hide Password" : "Show Password")
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }
}


