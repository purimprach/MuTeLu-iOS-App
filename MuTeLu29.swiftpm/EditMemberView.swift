import SwiftUI
import CryptoKit

struct EditMemberView: View {
    var member: Member?
    var onSave: (Member) -> Void
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var language: AppLanguage // 👈 เพิ่มเข้ามาเพื่อใช้ภาษา
    
    // MARK: - State Properties
    @State private var fullName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var birthdate = Date()
    @State private var gender = "ชาย" // 👈 เปลี่ยนค่าเริ่มต้น
    @State private var birthTime = ""
    @State private var houseNumber = ""
    @State private var carPlate = ""
    
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let genderOptions = ["ชาย", "หญิง", "อื่นๆ"] // 👈 ตัวเลือกเพศ
    
    private var navigationTitle: String {
        return member == nil ? "เพิ่มสมาชิก" : "แก้ไขสมาชิก"
    }
    
    var body: some View {
        NavigationView {
            Form {
                // ... ส่วนข้อมูลสมาชิก (ไม่ต้องแก้ไข) ...
                Section(header: Text("ข้อมูลสมาชิก (Member Info)")) {
                    TextField("ชื่อ-นามสกุล (Full Name)", text: $fullName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("เบอร์โทรศัพท์ (Phone)", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    DatePicker("วันเกิด (Birthday)", selection: $birthdate, displayedComponents: .date)
                }
                
                Section(header: Text("ข้อมูลเพิ่มเติม (Additional Info)")) {
                    // 👇 --- **ส่วนที่แก้ไข** ---
                    Picker(language.localized("เพศ", "Gender"), selection: $gender) {
                        ForEach(genderOptions, id: \.self) { option in
                            Text(localizedGender(option)).tag(option)
                        }
                    }
                    // ------------------------
                    
                    TextField("เวลาเกิด (Time of Birth)", text: $birthTime)
                    TextField("บ้านเลขที่ (House Number)", text: $houseNumber)
                    TextField("ทะเบียนรถ (Car Plate)", text: $carPlate)
                }
                
                // ... ส่วนรหัสผ่าน (ไม่ต้องแก้ไข) ...
                Section(header: Text("รหัสผ่าน (Password)")) {
                    let passwordPlaceholder = member == nil ? "รหัสผ่าน" : "ตั้งรหัสผ่านใหม่ (เว้นว่างไว้หากไม่ต้องการเปลี่ยน)"
                    
                    SecureField(passwordPlaceholder, text: $password)
                        .textContentType(.oneTimeCode)
                    SecureField("ยืนยันรหัสผ่าน", text: $confirmPassword)
                        .textContentType(.oneTimeCode)
                }
            }
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("ยกเลิก") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("บันทึก") { saveChanges() }
                }
            }
            .onAppear(perform: loadMemberData)
            .alert("ผิดพลาด", isPresented: $showAlert) {
                Button("ตกลง", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Functions
    
    // 👇 เพิ่มฟังก์ชันแปลภาษาสำหรับเพศ
    private func localizedGender(_ key: String) -> String {
        switch key {
        case "ชาย": return language.localized("ชาย", "Male")
        case "หญิง": return language.localized("หญิง", "Female")
        case "อื่นๆ": return language.localized("อื่นๆ", "Other")
        default: return key
        }
    }
    
    // ... (ฟังก์ชันที่เหลือไม่ต้องแก้ไข) ...
    private func loadMemberData() {
        guard let m = member else { return }
        fullName = m.fullName
        email = m.email
        phoneNumber = m.phoneNumber
        birthdate = m.birthdate
        gender = m.gender
        birthTime = m.birthTime
        houseNumber = m.houseNumber
        carPlate = m.carPlate
    }
    
    private func saveChanges() {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !fullName.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "กรุณากรอกชื่อและอีเมลให้ครบถ้วน"
            showAlert = true
            return
        }
        
        var passwordToSave = member?.password ?? ""
        
        if member == nil {
            if password.isEmpty {
                alertMessage = "กรุณากำหนดรหัสผ่านสำหรับสมาชิกใหม่"
                showAlert = true
                return
            }
            if password != confirmPassword {
                alertMessage = "รหัสผ่านไม่ตรงกัน"
                showAlert = true
                return
            }
            passwordToSave = hashPassword(password)
            
        } else if !password.isEmpty {
            if password != confirmPassword {
                alertMessage = "รหัสผ่านใหม่และการยืนยันไม่ตรงกัน"
                showAlert = true
                return
            }
            passwordToSave = hashPassword(password)
        }
        
        let memberToSave = Member(
            id: member?.id ?? UUID(),
            email: email,
            password: passwordToSave,
            fullName: fullName,
            gender: gender,
            birthdate: birthdate,
            birthTime: birthTime,
            phoneNumber: phoneNumber,
            houseNumber: houseNumber,
            carPlate: carPlate,
            role: member?.role ?? .user,
            status: member?.status ?? .active,
            joinedDate: member?.joinedDate ?? Date()
        )
        
        onSave(memberToSave)
        dismiss()
    }
    
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
