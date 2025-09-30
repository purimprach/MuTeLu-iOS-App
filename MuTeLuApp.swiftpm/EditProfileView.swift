import SwiftUI
import SwiftData

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var language: AppLanguage
    
    @Bindable var user: Member
    
    @State private var showConfirm = false
    
    let genderOptions = ["ชาย", "หญิง", "อื่นๆ"]
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text(language.localized("ข้อมูลส่วนตัว", "Personal Info"))) {
                    TextField(language.localized("ชื่อ-สกุล", "Full Name"), text: $user.fullName)
                    Picker(language.localized("เพศ", "Gender"), selection: $user.gender) {
                        ForEach(genderOptions, id: \.self) { Text($0) }
                    }
                    DatePicker(language.localized("วันเดือนปีเกิด", "Birthdate"), selection: $user.birthdate, displayedComponents: .date)
                    TextField(language.localized("เวลาเกิด", "Birth Time"), text: $user.birthTime)
                    TextField(language.localized("เบอร์โทรศัพท์", "Phone Number"), text: $user.phoneNumber)
                    TextField(language.localized("เลขที่บ้าน", "House Number"), text: $user.houseNumber)
                    TextField(language.localized("ทะเบียนรถ", "Car Plate"), text: $user.carPlate)
                }
            }
            // ... (UI ปุ่มและ Alert ไม่ต้องแก้ไข) ...
            Button(action: {
                showConfirm = true
            }) {
                Text(language.localized("ยืนยันการแก้ไข", "Confirm Changes"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
                    .padding([.horizontal, .bottom])
            }
        }
        .navigationTitle(language.localized("แก้ไขข้อมูล", "Edit Info"))
        .alert(language.localized("ยืนยันการแก้ไข", "Confirm Edit"), isPresented: $showConfirm) {
            Button(language.localized("ยืนยัน", "Confirm")) {
                dismiss()
            }
            Button(language.localized("ยกเลิก", "Cancel"), role: .cancel) { }
        }
    }
}

