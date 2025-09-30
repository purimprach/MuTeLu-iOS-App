import SwiftUI
import SwiftData

struct EditCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var language: AppLanguage
    
    // 👇 ใช้ @Bindable เพื่อให้การแก้ไขบันทึกลงฐานข้อมูลอัตโนมัติ
    @Bindable var checkIn: CheckInRecord
    
    // State สำหรับ Alert และการเก็บค่า Date เดิม
    @State private var showingSaveConfirmation = false
    @State private var originalDate: Date
    
    init(checkIn: CheckInRecord) {
        self.checkIn = checkIn
        // เก็บค่าวันที่ดั้งเดิมไว้เปรียบเทียบ
        self._originalDate = State(initialValue: checkIn.date)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📍 \(checkIn.placeNameTH)")
                            .font(.headline.bold())
                        Text(checkIn.placeNameEN)
                            .font(.subheadline).foregroundColor(.secondary)
                        Label(checkIn.memberEmail, systemImage: "person.fill")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text(language.localized("ข้อมูลการเช็คอิน", "Check-in Information"))
                }
                
                Section {
                    DatePicker(
                        language.localized("เวลาเช็คอิน", "Check-in Time"),
                        selection: $checkIn.date, // 👈 ผูกกับข้อมูลโดยตรง
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    
                    if checkIn.date != originalDate {
                        // ... (UI ส่วนแสดงเวลาเดิม/ใหม่ เหมือนเดิม) ...
                    }
                } header: {
                    Text(language.localized("แก้ไขเวลา", "Edit Time"))
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("คะแนนบุญ: \(checkIn.meritPoints)", systemImage: "star.fill")
                            .foregroundColor(.yellow)
                        Label("พิกัด: \(String(format: "%.6f", checkIn.latitude)), \(String(format: "%.6f", checkIn.longitude))", systemImage: "location.fill")
                            .foregroundColor(.blue)
                        if checkIn.isEditedByAdmin {
                            Label(language.localized("เคยแก้ไขโดย Admin แล้ว", "Previously edited by Admin"), systemImage: "pencil.circle.fill")
                                .foregroundColor(.orange)
                        }
                    }
                    .font(.caption)
                } header: {
                    Text(language.localized("รายละเอียดเพิ่มเติม", "Additional Details"))
                }
            }
            .navigationTitle(language.localized("แก้ไขการเช็คอิน", "Edit Check-in"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(language.localized("ยกเลิก", "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(language.localized("บันทึก", "Save")) {
                        showingSaveConfirmation = true
                    }
                    .fontWeight(.semibold)
                    .disabled(checkIn.date == originalDate)
                }
            }
            .alert(language.localized("ยืนยันการแก้ไข", "Confirm Changes"), isPresented: $showingSaveConfirmation) {
                Button(language.localized("บันทึก", "Save")) {
                    // ตั้งค่าว่าข้อมูลนี้ถูกแก้ไขโดย Admin
                    checkIn.isEditedByAdmin = true
                    dismiss() // SwiftData จะบันทึกให้เองเมื่อปิดหน้า
                }
                Button(language.localized("ยกเลิก", "Cancel"), role: .cancel) {}
            } message: {
                Text(language.localized("คุณแน่ใจว่าต้องการแก้ไขเวลาเช็คอินนี้หรือไม่", "Are you sure you want to modify this check-in time?"))
            }
        }
    }
    
    private func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        return formatter.string(from: date)
    }
}
