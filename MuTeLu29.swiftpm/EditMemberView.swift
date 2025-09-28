import SwiftUI
import CryptoKit

struct EditMemberView: View {
    var member: Member?
    var onSave: (Member) -> Void
    @Environment(\.dismiss) var dismiss
    
    // MARK: - State Properties
    @State private var fullName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var birthdate = Date()
    @State private var gender = "ไม่ระบุ"
    @State private var birthTime = ""
    @State private var houseNumber = ""
    @State private var carPlate = ""
    
    // ✅ เปลี่ยนชื่อให้ชัดเจนขึ้น
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private var navigationTitle: String {
        return member == nil ? "เพิ่มสมาชิก" : "แก้ไขสมาชิก"
    }
    
    var body: some View {
        NavigationView {
            Form {
                // ... ส่วนข้อมูลสมาชิก และ ข้อมูลเพิ่มเติม ...
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
                    TextField("เพศ (Gender)", text: $gender)
                    TextField("เวลาเกิด (Time of Birth)", text: $birthTime)
                    TextField("บ้านเลขที่ (House Number)", text: $houseNumber)
                    TextField("ทะเบียนรถ (Car Plate)", text: $carPlate)
                }
                
                // MARK: - ส่วนรหัสผ่าน (แสดงผลตลอด)
                // ✅ [แก้ไขจุดที่ 1] - เอา if member != nil ออก และเปลี่ยนชื่อ Header
                Section(header: Text("รหัสผ่าน (Password)")) {
                    // ถ้าเป็นการเพิ่มใหม่ จะขึ้นว่า "รหัสผ่าน"
                    // ถ้าเป็นการแก้ไข จะขึ้นว่า "ตั้งรหัสผ่านใหม่ (เว้นว่างไว้หากไม่ต้องการเปลี่ยน)"
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
        // ไม่ต้องโหลดรหัสผ่านเก่ามาแสดง
    }
    
    // ✅ [แก้ไขจุดที่ 2] - ปรับปรุง Logic การบันทึกทั้งหมด
    private func saveChanges() {
        // --- การตรวจสอบข้อมูลพื้นฐาน ---
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !fullName.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "กรุณากรอกชื่อและอีเมลให้ครบถ้วน"
            showAlert = true
            return
        }
        
        // --- การตรวจสอบรหัสผ่าน ---
        var passwordToSave = member?.password ?? "" // ถ้าเป็นการแก้ไข ให้ใช้รหัสผ่านเดิมเป็นค่าเริ่มต้น
        
        if member == nil { // --- กรณีเพิ่มสมาชิกใหม่ ---
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
            passwordToSave = hashPassword(password) // Hash รหัสผ่านใหม่
            
        } else if !password.isEmpty { // --- กรณีแก้ไข และมีการกรอกรหัสผ่านใหม่ ---
            if password != confirmPassword {
                alertMessage = "รหัสผ่านใหม่และการยืนยันไม่ตรงกัน"
                showAlert = true
                return
            }
            passwordToSave = hashPassword(password) // Hash รหัสผ่านใหม่
        }
        
        // --- สร้างข้อมูลสมาชิกเพื่อบันทึก ---
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

