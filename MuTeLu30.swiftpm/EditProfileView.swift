import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var memberStore: MemberStore
    @Environment(\.dismiss) var dismiss
    
    var user: Member
    @State private var fullName: String
    @State private var gender: String
    @State private var birthdate: Date
    @State private var birthTime: String
    @State private var phoneNumber: String
    @State private var houseNumber: String
    @State private var carPlate: String
    @State private var showConfirm = false
    
    let genderOptions = ["ชาย", "หญิง", "อื่นๆ"]
    
    init(user: Member) {
        self.user = user
        _fullName = State(initialValue: user.fullName)
        _gender = State(initialValue: user.gender)
        _birthdate = State(initialValue: user.birthdate)
        _birthTime = State(initialValue: user.birthTime)
        _phoneNumber = State(initialValue: user.phoneNumber)
        _houseNumber = State(initialValue: user.houseNumber)
        _carPlate = State(initialValue: user.carPlate)
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text(language.localized("ข้อมูลส่วนตัว", "Personal Info"))) {
                    TextField(language.localized("ชื่อ-สกุล", "Full Name"), text: $fullName)
                    Picker(language.localized("เพศ", "Gender"), selection: $gender) {
                        ForEach(genderOptions, id: \.self) { Text($0) }
                    }
                    DatePicker(language.localized("วันเดือนปีเกิด", "Birthdate"), selection: $birthdate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US"))
                    TextField(language.localized("เวลาเกิด", "Birth Time"), text: $birthTime)
                    TextField(language.localized("เบอร์โทรศัพท์", "Phone Number"), text: $phoneNumber)
                    TextField(language.localized("เลขที่บ้าน", "House Number"), text: $houseNumber)
                    TextField(language.localized("ทะเบียนรถ", "Car Plate"), text: $carPlate)
                }
            }
            
            // ✅ ปุ่มยืนยันแบบสวยงาม
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
                if let index = memberStore.members.firstIndex(where: { $0.email == user.email }) {
                    memberStore.members[index].fullName = fullName
                    memberStore.members[index].gender = gender
                    memberStore.members[index].birthdate = birthdate
                    memberStore.members[index].birthTime = birthTime
                    memberStore.members[index].phoneNumber = phoneNumber
                    memberStore.members[index].houseNumber = houseNumber
                    memberStore.members[index].carPlate = carPlate
                }
                dismiss()
            }
            Button(language.localized("ยกเลิก", "Cancel"), role: .cancel) { }
        }
    }
}
