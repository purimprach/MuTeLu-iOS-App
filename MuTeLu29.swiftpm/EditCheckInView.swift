import SwiftUI

struct EditCheckInView: View {
    @EnvironmentObject var language: AppLanguage
    @Environment(\.dismiss) private var dismiss
    
    let checkIn: CheckInRecord
    let onSave: (CheckInRecord) -> Void
    
    @State private var selectedDate: Date
    @State private var showingSaveConfirmation = false
    
    init(checkIn: CheckInRecord, onSave: @escaping (CheckInRecord) -> Void) {
        self.checkIn = checkIn
        self.onSave = onSave
        self._selectedDate = State(initialValue: checkIn.date)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📍 \(checkIn.placeNameTH)")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(checkIn.placeNameEN)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Label(checkIn.memberEmail, systemImage: "person.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text(language.localized("ข้อมูลการเช็คอิน", "Check-in Information"))
                }
                
                Section {
                    DatePicker(
                        language.localized("เวลาเช็คอิน", "Check-in Time"),
                        selection: $selectedDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .environment(\.locale, Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US"))
                    
                    // Show original vs new time
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(language.localized("เวลาเดิม:", "Original Time:"))
                                .fontWeight(.medium)
                            Spacer()
                            Text(formattedDateTime(checkIn.date))
                                .foregroundColor(.secondary)
                        }
                        
                        if selectedDate != checkIn.date {
                            HStack {
                                Text(language.localized("เวลาใหม่:", "New Time:"))
                                    .fontWeight(.medium)
                                Spacer()
                                Text(formattedDateTime(selectedDate))
                                    .foregroundColor(.blue)
                            }
                            
                            // Time difference
                            let timeDiff = selectedDate.timeIntervalSince(checkIn.date)
                            let hoursDiff = timeDiff / 3600
                            
                            HStack {
                                Text(language.localized("ต่างกัน:", "Difference:"))
                                    .fontWeight(.medium)
                                Spacer()
                                Text(String(format: "%.1f ชั่วโมง", hoursDiff))
                                    .foregroundColor(hoursDiff > 0 ? .green : .red)
                            }
                        }
                    }
                    .font(.caption)
                    .padding(.vertical, 4)
                    
                } header: {
                    Text(language.localized("แก้ไขเวลา", "Edit Time"))
                } footer: {
                    Text(language.localized("Admin สามารถแก้ไขเวลาเช็คอินเพื่อจัดการกรณีพิเศษ", "Admin can edit check-in time for special cases"))
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
                    Button(language.localized("ยกเลิก", "Cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(language.localized("บันทึก", "Save")) {
                        showingSaveConfirmation = true
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedDate == checkIn.date)
                }
            }
            .alert(language.localized("ยืนยันการแก้ไข", "Confirm Changes"), 
                   isPresented: $showingSaveConfirmation) {
                Button(language.localized("บันทึก", "Save")) {
                    var updatedCheckIn = checkIn
                    updatedCheckIn.date = selectedDate
                    onSave(updatedCheckIn)
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

#Preview {
    let sampleCheckIn = CheckInRecord(
        placeID: "wat_phra_kaew",
        placeNameTH: "วัดพระแก้ว",
        placeNameEN: "Temple of the Emerald Buddha",
        meritPoints: 100,
        memberEmail: "admin@example.com",
        date: Date(),
        latitude: 13.7500,
        longitude: 100.4900
    )
    
    return EditCheckInView(checkIn: sampleCheckIn) { _ in }
        .environmentObject(AppLanguage())
}