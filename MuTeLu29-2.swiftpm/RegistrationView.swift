import SwiftUI
import CryptoKit
import SwiftData

struct RegistrationView: View {
    // 1. เข้าถึง "ตู้เซฟ" (ฐานข้อมูล) ผ่าน Environment
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    
    // State สำหรับเก็บข้อมูลที่ผู้ใช้กรอก
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
    
    // State สำหรับจัดการ Alert
    @State private var showConfirmAlert = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let genderOptions = ["ชาย", "หญิง", "อื่นๆ"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(language.localized("ลงทะเบียน", "Register"))
                    .font(.largeTitle.bold())
                    .padding(.top)
                
                // --- ส่วนฟอร์ม ---
                RequiredField(title: language.localized("อีเมล", "Email"), text: $email)
                RequiredPasswordField(title: language.localized("รหัสผ่าน", "Password"), text: $password)
                RequiredPasswordField(title: language.localized("ยืนยันรหัสผ่าน", "Confirm Password"), text: $confirmPassword)
                
                Divider().padding(.vertical)
                
                Text(language.localized("ข้อมูลเพิ่มเติม (ไม่จำเป็น)", "Optional Information"))
                    .font(.headline)
                    .padding(.top, 5)
                
                InputField(title: language.localized("ชื่อ-สกุล", "Full Name"), text: $fullName)
                genderPicker
                
                DatePicker(language.localized("วันเดือนปีเกิด", "Birthdate"), selection: $birthdate, displayedComponents: .date)
                    .environment(\.locale, Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US"))
                    .environment(\.calendar, Calendar(identifier: language.currentLanguage == "th" ? .buddhist : .gregorian))
                    .padding(.horizontal)
                
                InputField(title: language.localized("เวลาเกิด", "Birth Time"), text: $birthTime)
                InputField(title: language.localized("เบอร์โทรศัพท์", "Phone Number"), text: $phoneNumber)
                InputField(title: language.localized("เลขที่บ้าน", "House Number"), text: $houseNumber)
                InputField(title: language.localized("ทะเบียนรถ", "Car Plate"), text: $carPlate)
                
                // --- ปุ่มยืนยัน ---
                Button(action: {
                    showConfirmAlert = true
                }) {
                    Text(language.localized("ยืนยันการลงทะเบียน", "Confirm Registration"))
                        .bold().frame(maxWidth: .infinity).padding()
                        .background(Color.purple).foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .confirmationDialog(
                    language.localized("ยืนยันการลงทะเบียน", "Confirm Registration"),
                    isPresented: $showConfirmAlert,
                    titleVisibility: .visible
                ) {
                    Button(language.localized("ยืนยัน", "Confirm")) {
                        handleRegister()
                    }
                    Button(language.localized("ยกเลิก", "Cancel"), role: .cancel) { }
                }
                
                // --- ปุ่มกลับไปหน้า Login ---
                Button(action: {
                    flowManager.isLoggedIn = false
                    flowManager.currentScreen = .login
                }) {
                    Text(language.localized("กลับไปหน้าเข้าสู่ระบบ", "Back to Login"))
                        .font(.footnote).foregroundColor(.blue).underline()
                }
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(language.localized("ข้อผิดพลาด", "Error")),
                  message: Text(alertMessage),
                  dismissButton: .default(Text(language.localized("ตกลง", "OK"))))
        }
    }
    
    var genderPicker: some View {
        VStack(alignment: .leading) {
            Text(language.localized("เพศ", "Gender")).font(.caption).foregroundColor(.gray)
            Picker("", selection: $gender) {
                ForEach(genderOptions, id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
    }
    
    // ฟังก์ชันสำหรับจัดการการลงทะเบียน (อัปเกรดเป็น SwiftData แล้ว)
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
        
        let descriptor = FetchDescriptor<Member>(
            predicate: #Predicate { $0.email == trimmedEmail }
        )
        
        do {
            let existingMembers = try modelContext.fetch(descriptor)
            if !existingMembers.isEmpty {
                alertMessage = language.localized("อีเมลนี้ถูกใช้สมัครไปแล้ว", "This email is already registered")
                showAlert = true
                return
            }
        } catch {
            alertMessage = "Database error: \(error.localizedDescription)"
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
        
        modelContext.insert(newMember)
        
        flowManager.loggedInEmail = trimmedEmail
        flowManager.isLoggedIn = false
        flowManager.currentScreen = .login
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = SHA256.hash(data: data) // แก้ไขจาก SHA26 เป็น SHA256
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - View ย่อยต่างๆ (ไม่ต้องแก้ไข)

struct InputField: View {
    var title: String
    @Binding var text: String
    
    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(width: 110, alignment: .leading)
            
            TextField(title, text: $text)
                .textFieldStyle(.roundedBorder)
        }
        .padding(.horizontal)
    }
}

struct RequiredField: View {
    var title: String
    @Binding var text: String
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("*")
                    .foregroundColor(.red)
            }
            .frame(width: 110, alignment: .leading)
            
            TextField(title, text: $text)
                .textFieldStyle(.roundedBorder)
        }
        .padding(.horizontal)
    }
}

struct RequiredPasswordField: View {
    var title: String
    @Binding var text: String
    @State private var showPassword: Bool = false
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
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
                
                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .textFieldStyle(.roundedBorder)
        }
        .padding(.horizontal)
    }
}
