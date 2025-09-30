import SwiftUI
import CryptoKit
import SwiftData

struct EditMemberView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // รับ Member object มา (ถ้าเป็นการแก้ไข)
    var member: Member?
    
    // State สำหรับเก็บข้อมูลในฟอร์ม
    @State private var fullName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var birthdate = Date()
    @State private var gender = "ไม่ระบุ"
    @State private var birthTime = ""
    @State private var houseNumber = ""
    @State private var carPlate = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    // State สำหรับ Alert
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private var navigationTitle: String {
        return member == nil ? "เพิ่มสมาชิก" : "แก้ไขสมาชิก"
    }
    
    var body: some View {
        NavigationView {
            Form {
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
                
                Section(header: Text("รหัสผ่าน (Password)")) {
                    let passwordPlaceholder = member == nil ? "รหัสผ่าน" : "ตั้งรหัสผ่านใหม่ (เว้นว่างไว้หากไม่ต้องการเปลี่ยน)"
                    SecureField(passwordPlaceholder, text: $password)
                    SecureField("ยืนยันรหัสผ่าน", text: $confirmPassword)
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
    
    private func loadMemberData() {
        guard let member = member else { return }
        // ถ้าเป็นการแก้ไข ให้ดึงข้อมูลเดิมมาใส่ใน State
        fullName = member.fullName
        email = member.email
        phoneNumber = member.phoneNumber
        birthdate = member.birthdate
        gender = member.gender
        birthTime = member.birthTime
        houseNumber = member.houseNumber
        carPlate = member.carPlate
    }
    
    private func saveChanges() {
        // --- การตรวจสอบข้อมูลพื้นฐาน ---
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !fullName.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "กรุณากรอกชื่อและอีเมลให้ครบถ้วน"
            showAlert = true
            return
        }
        
        if let existingMember = member {
            // --- กรณีแก้ไขสมาชิก ---
            existingMember.fullName = fullName
            existingMember.email = email
            existingMember.phoneNumber = phoneNumber
            existingMember.birthdate = birthdate
            existingMember.gender = gender
            existingMember.birthTime = birthTime
            existingMember.houseNumber = houseNumber
            existingMember.carPlate = carPlate
            
            // อัปเดตรหัสผ่าน (ถ้ามีการกรอกใหม่)
            if !password.isEmpty {
                if password != confirmPassword {
                    alertMessage = "รหัสผ่านใหม่และการยืนยันไม่ตรงกัน"
                    showAlert = true
                    return
                }
                existingMember.password = hashPassword(password)
            }
        } else {
            // --- กรณีเพิ่มสมาชิกใหม่ ---
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
            
            let newMember = Member(
                email: email,
                password: hashPassword(password),
                fullName: fullName,
                gender: gender,
                birthdate: birthdate,
                birthTime: birthTime,
                phoneNumber: phoneNumber,
                houseNumber: houseNumber,
                carPlate: carPlate
            )
            modelContext.insert(newMember)
        }
        
        // SwiftData จะบันทึกข้อมูลให้อัตโนมัติ
        dismiss()
    }
    
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
