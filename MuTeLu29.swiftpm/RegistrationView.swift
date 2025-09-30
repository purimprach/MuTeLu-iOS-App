import SwiftUI
import CryptoKit

struct RegistrationView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var memberStore: MemberStore
    @State private var showConfirmAlert = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""
    @State private var gender = "ชาย"
    @State private var birthdate = Date()
    @State private var birthTime = ""
    @State private var phoneNumber = ""
    @State private var houseNumber = ""
    @State private var carPlate = ""
    
    @State private var activeAlert: AppAlert?
    
    let genderOptions = ["ชาย", "หญิง", "อื่นๆ"]
    
    // MARK: - โค้ดใหม่สำหรับ RegistrationView.swift
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // --- 1. ปรับปรุง Header และพื้นหลัง ---
                Text(language.localized("ลงทะเบียน", "Register"))
                    .font(.largeTitle.bold()) // 👈 ทำให้เด่นขึ้น
                    .foregroundColor(AppColor.textPrimary.color)
                    .padding(.top)
                
                // --- 2. ใช้ Component ที่ปรับปรุงแล้ว ---
                // เราจะปรับปรุง View ย่อยด้านล่างให้ใช้สีใหม่
                RequiredField(title: language.localized("อีเมล", "Email"), text: $email)
                RequiredPasswordField(title: language.localized("รหัสผ่าน", "Password"), text: $password)
                RequiredPasswordField(title: language.localized("ยืนยันรหัสผ่าน", "Confirm Password"), text: $confirmPassword)
                
                Divider().padding(.vertical)
                
                Text(language.localized("ข้อมูลเพิ่มเติม (ไม่จำเป็น)", "Optional Information"))
                    .font(.headline)
                    .foregroundColor(AppColor.textSecondary.color) // 👈 ใช้สีรอง
                    .padding(.top, 5)
                
                InputField(title: language.localized("ชื่อ-สกุล", "Full Name"), text: $fullName)
                genderPicker
                
                DatePicker(language.localized("วันเดือนปีเกิด", "Birthdate"), selection: $birthdate, displayedComponents: .date)
                    .environment(\.locale, Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US"))
                    .environment(\.calendar, Calendar(identifier: language.currentLanguage == "th" ? .buddhist : .gregorian))
                    .tint(AppColor.brandPrimary.color) // 👈 สีของ DatePicker
                    .padding(.horizontal)
                
                InputField(title: language.localized("เวลาเกิด", "Birth Time"), text: $birthTime)
                InputField(title: language.localized("เบอร์โทรศัพท์", "Phone Number"), text: $phoneNumber)
                InputField(title: language.localized("เลขที่บ้าน", "House Number"), text: $houseNumber)
                InputField(title: language.localized("ทะเบียนรถ", "Car Plate"), text: $carPlate)
                
                // --- 3. ปรับปรุงปุ่มหลักและปุ่มรอง ---
                Button(action: {
                    showConfirmAlert = true
                }) {
                    Text(language.localized("ยืนยันการลงทะเบียน", "Confirm Registration"))
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColor.brandPrimary.color) // 👈 ใช้สีหลัก
                        .foregroundColor(.white)
                        .cornerRadius(12) // 👈 ทำให้มุมมนสอดคล้องกัน
                }
                .padding(.horizontal)
                .confirmationDialog(
                    language.localized("ยืนยันการลงทะเบียน", "Confirm Registration"),
                    isPresented: $showConfirmAlert,
                    titleVisibility: .visible
                ) {
                    Button(language.localized("ยืนยัน", "Confirm")) { handleRegister() }
                    Button(language.localized("ยกเลิก", "Cancel"), role: .cancel) { }
                }
                
                Button(action: {
                    flowManager.isLoggedIn = false
                    flowManager.currentScreen = .login
                }) {
                    Text(language.localized("กลับไปหน้าเข้าสู่ระบบ", "Back to Login"))
                        .font(.footnote)
                        .foregroundColor(AppColor.brandPrimary.color) // 👈 ใช้สีหลัก
                        .underline()
                }
            }
            .padding()
        }
        .background(AppColor.backgroundPrimary.color) // 👈 ใช้สีพื้นหลังหลัก
        .alert(isPresented: $showAlert) {
            Alert(title: Text(language.localized("ข้อผิดพลาด", "Error")),
                  message: Text(alertMessage),
                  dismissButton: .default(Text(language.localized("ตกลง", "OK"))))
        }
    }
    
    // MARK: - ปรับปรุง View ย่อยให้ใช้สีใหม่
    
    // ✅ Field ปกติ
    struct InputField: View {
        var title: String
        @Binding var text: String
        
        var body: some View {
            HStack(alignment: .center) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppColor.textSecondary.color) // 👈
                    .frame(width: 110, alignment: .leading)
                
                TextField(title, text: $text)
                    .textFieldStyle(.roundedBorder)
                    .tint(AppColor.brandPrimary.color) // 👈
            }
            .padding(.horizontal)
        }
    }
    
    // ✅ Field แบบจำเป็น (มีดอกจันสีแดง)
    struct RequiredField: View {
        var title: String
        @Binding var text: String
        
        var body: some View {
            HStack(alignment: .center) {
                HStack(spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(AppColor.textSecondary.color) // 👈
                    Text("*")
                        .foregroundColor(.red)
                }
                .frame(width: 110, alignment: .leading)
                
                TextField(title, text: $text)
                    .textFieldStyle(.roundedBorder)
                    .tint(AppColor.brandPrimary.color) // 👈
            }
            .padding(.horizontal)
        }
    }
    
    // 👇 --- **ส่วนที่แก้ไข** ---
    var genderPicker: some View {
        VStack(alignment: .leading) {
            Text(language.localized("เพศ", "Gender")).font(.caption).foregroundColor(.gray)
            Picker("", selection: $gender) {
                ForEach(genderOptions, id: \.self) { option in
                    Text(localizedGender(option)).tag(option)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
    }
    
    // 👇 เพิ่มฟังก์ชันนี้สำหรับแปลภาษาของตัวเลือกเพศ
    private func localizedGender(_ key: String) -> String {
        switch key {
        case "ชาย": return language.localized("ชาย", "Male")
        case "หญิง": return language.localized("หญิง", "Female")
        case "อื่นๆ": return language.localized("อื่นๆ", "Other")
        default: return key
        }
    }
    // --------------------------
    
    func handleRegister() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedEmail.isEmpty && !trimmedPassword.isEmpty && !confirmPassword.isEmpty else {
            alertMessage = language.localized("กรุณากรอกข้อมูลให้ครบถ้วน", "Please fill in all required fields")
            showAlert = true
            return
        }
        
        guard isValidEmail(trimmedEmail) else {
            alertMessage = language.localized("อีเมลไม่ถูกต้อง", "Invalid email format")
            showAlert = true
            return
        }
        
        guard trimmedPassword == confirmPassword else {
            alertMessage = language.localized("รหัสผ่านไม่ตรงกัน", "Passwords do not match")
            showAlert = true
            return
        }
        
        if memberStore.members.contains(where: { $0.email.lowercased() == trimmedEmail.lowercased() }) {
            alertMessage = language.localized("อีเมลนี้ถูกใช้สมัครไปแล้ว", "This email is already registered")
            showAlert = true
            return
        }
        
        let newMember = Member(
            email: trimmedEmail,
            password: hashPassword(trimmedPassword),
            fullName: fullName,
            gender: gender,
            birthdate: birthdate,
            birthTime: birthTime,
            phoneNumber: phoneNumber,
            houseNumber: houseNumber,
            carPlate: carPlate
        )
        
        memberStore.members.append(newMember)
        
        flowManager.loggedInEmail = trimmedEmail
        flowManager.isLoggedIn = false
        flowManager.currentScreen = .login
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    // ฟังก์ชันสำหรับ Hash รหัสผ่าน (ใช้ SHA256)
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
} // <-- ปิดปีกกาของ RegistrationView

// ✅ Field ปกติ (ปรับปรุงแล้ว)
struct InputField: View {
    var title: String
    @Binding var text: String
    
    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(AppColor.textSecondary.color)
                .frame(width: 110, alignment: .leading)
            
            TextField(title, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(10)
                .background(AppColor.backgroundSecondary.color)
                .cornerRadius(8)
                .tint(AppColor.brandPrimary.color)
        }
        .padding(.horizontal)
    }
}

// ✅ Field แบบจำเป็น (ปรับปรุงแล้ว)
struct RequiredField: View {
    var title: String
    @Binding var text: String
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppColor.textSecondary.color)
                Text("*")
                    .foregroundColor(.red)
            }
            .frame(width: 110, alignment: .leading)
            
            TextField(title, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(10)
                .background(AppColor.backgroundSecondary.color)
                .cornerRadius(8)
                .tint(AppColor.brandPrimary.color)
        }
        .padding(.horizontal)
    }
}

// ✅ Password Field (ปรับปรุงแล้ว)
struct RequiredPasswordField: View {
    var title: String
    @Binding var text: String
    @State private var showPassword: Bool = false
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppColor.textSecondary.color)
                Text("*")
                    .foregroundColor(.red)
            }
            .frame(width: 110, alignment: .leading)
            
            HStack {
                if showPassword {
                    TextField(title, text: $text)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textContentType(.oneTimeCode)
                } else {
                    SecureField(title, text: $text)
                        .textContentType(.oneTimeCode)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(AppColor.textSecondary.color)
                }
            }
            .textFieldStyle(PlainTextFieldStyle())
            .padding(10)
            .background(AppColor.backgroundSecondary.color)
            .cornerRadius(8)
            .tint(AppColor.brandPrimary.color)
        }
        .padding(.horizontal)
    }
}


struct AppAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let confirmAction: (() -> Void)?
}
