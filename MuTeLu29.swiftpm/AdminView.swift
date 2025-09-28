import SwiftUI

struct AdminView: View {
    @EnvironmentObject var memberStore: MemberStore
    @EnvironmentObject var checkInStore: CheckInStore
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    
    @State private var editingMember: Member?
    @State private var showingEditSheet = false
    @State private var memberToDelete: Member?
    @State private var showDeleteConfirm = false
    @State private var showingAddSheet = false
    @State private var selectedTab = 0  // 0: Members, 1: Check-ins
    
    // Check-in management states
    @State private var editingCheckIn: CheckInRecord?
    @State private var showingEditCheckInSheet = false
    @State private var checkInToDelete: CheckInRecord?
    @State private var showDeleteCheckInConfirm = false
    
    // ... (ส่วน body และ toolbar เหมือนเดิม ไม่ต้องแก้)
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Admin Tabs", selection: $selectedTab) {
                    Text(language.localized("สมาชิก", "Members")).tag(0)
                    Text(language.localized("เช็คอิน", "Check-ins")).tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    // Members Tab
                    ScrollView {
                        VStack(alignment: .center, spacing: 20) {
                            Text(language.localized("รายชื่อสมาชิกทั้งหมด", "All Registered Members"))
                                .font(.title2).bold()
                                .padding(.top)
                            
                            ForEach(memberStore.members, id: \.id) { member in
                                memberCard(for: member)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .tag(0)
                    
                    // Check-ins Tab
                    ScrollView {
                        VStack(alignment: .center, spacing: 20) {
                            Text(language.localized("ประวัติเช็คอินทั้งหมด", "All Check-in Records"))
                                .font(.title2).bold()
                                .padding(.top)
                            
                            ForEach(checkInStore.records.sorted(by: { $0.date > $1.date }), id: \.id) { checkIn in
                                checkInCard(for: checkIn)
                            }
                            
                            if checkInStore.records.isEmpty {
                                Text(language.localized("ยังไม่มีการเช็คอิน", "No check-in records yet"))
                                    .foregroundColor(.secondary)
                                    .padding()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle(language.localized("หน้าผู้ดูแลระบบ", "Admin Panel"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        flowManager.currentScreen = .login
                    } label: {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text(language.localized("กลับ", "Back"))
                        }
                    }
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("➕ \(language.localized("เพิ่มสมาชิก", "Add Member"))") {
                        showingAddSheet = true
                    }
                    .fontWeight(.semibold)
                }
            }
            // ... (ส่วน sheet และ alert เหมือนเดิม ไม่ต้องแก้)
            .sheet(isPresented: $showingEditSheet) {
                if let memberToEdit = editingMember {
                    EditMemberView(member: memberToEdit) { updated in
                        if let index = memberStore.members.firstIndex(where: { $0.id == updated.id }) {
                            memberStore.members[index] = updated
                        }
                        showingEditSheet = false
                    }
                }
            }
            .alert(language.localized("ยืนยันการลบ", "Confirm Deletion"),
                   isPresented: $showDeleteConfirm) {
                Button(language.localized("ลบ", "Delete"), role: .destructive) {
                    if let member = memberToDelete {
                        delete(member)
                    }
                }
                Button(language.localized("ยกเลิก", "Cancel"), role: .cancel) {}
            } message: {
                Text(language.localized("คุณแน่ใจว่าต้องการลบสมาชิกนี้หรือไม่", "Are you sure you want to delete this member?"))
            }
            .sheet(isPresented: $showingAddSheet) {
                EditMemberView(member: nil) { newMember in
                    memberStore.members.append(newMember)
                    showingAddSheet = false
                }
            }
            .sheet(isPresented: $showingEditCheckInSheet) {
                if let checkInToEdit = editingCheckIn {
                    EditCheckInView(checkIn: checkInToEdit) { updatedCheckIn in
                        checkInStore.updateCheckInDate(recordID: updatedCheckIn.id, newDate: updatedCheckIn.date)
                        showingEditCheckInSheet = false
                    }
                }
            }
            .alert(language.localized("ยืนยันการลบเช็คอิน", "Confirm Check-in Deletion"),
                   isPresented: $showDeleteCheckInConfirm) {
                Button(language.localized("ลบ", "Delete"), role: .destructive) {
                    if let checkIn = checkInToDelete {
                        checkInStore.removeRecord(by: checkIn.id)
                    }
                }
                Button(language.localized("ยกเลิก", "Cancel"), role: .cancel) {}
            } message: {
                Text(language.localized("คุณแน่ใจว่าต้องการลบการเช็คอินนี้หรือไม่", "Are you sure you want to delete this check-in record?"))
            }
        }
    }
    
    // 👇 [ปรับปรุงตรงนี้] แก้ไข memberCard ให้เข้ากับ struct Member ของคุณ
    @ViewBuilder
    func memberCard(for member: Member) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Header
            Text("👤 \(member.fullName)")
                .font(.headline)
                .fontWeight(.bold)
            
            Divider()
            
            // MARK: - Personal & Contact Info
            VStack(alignment: .leading, spacing: 8) {
                Label(member.email, systemImage: "envelope.fill")
                Label(member.phoneNumber, systemImage: "phone.fill")
            }
            .font(.subheadline)
            
            // MARK: - "Mu-Telu" Specific Info
            VStack(alignment: .leading, spacing: 8) {
                Label("เกิดวันที่: \(formattedDate(member.birthdate)), เวลา \(member.birthTime)", systemImage: "calendar")
                Label("เพศ: \(member.gender)", systemImage: "person.circle")
                Label("บ้านเลขที่: \(member.houseNumber)", systemImage: "house.fill")
                Label("ทะเบียนรถ: \(member.carPlate)", systemImage: "car.fill")
                Label("แต้มบุญ: \(member.meritPoints)", systemImage: "star.fill")
                    .foregroundColor(.yellow)
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 4)
            
            // MARK: - Action Buttons
            HStack {
                Button("✏️ \(language.localized("แก้ไข", "Edit"))") {
                    editingMember = member
                    showingEditSheet = true
                }
                .buttonStyle(.bordered)
                .tint(.purple)
                
                Spacer()
                
                Button("🗑️ \(language.localized("ลบ", "Delete"))") {
                    memberToDelete = member
                    showDeleteConfirm = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
    
    @ViewBuilder
    func checkInCard(for checkIn: CheckInRecord) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Header
            HStack {
                Text("📍 \(checkIn.placeNameTH)")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                if checkIn.isEditedByAdmin {
                    Text("✏️ แก้ไขแล้ว")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                }
            }
            
            Divider()
            
            // MARK: - Check-in Info
            VStack(alignment: .leading, spacing: 8) {
                Label(checkIn.memberEmail, systemImage: "person.fill")
                Label("เช็คอินเมื่อ: \(formattedDateTime(checkIn.date))", systemImage: "clock.fill")
                Label("คะแนนบุญ: \(checkIn.meritPoints)", systemImage: "star.fill")
                    .foregroundColor(.yellow)
                Label("สถานที่: \(checkIn.placeNameEN)", systemImage: "globe")
            }
            .font(.subheadline)
            
            // Time elapsed since check-in
            let timeElapsed = Date().timeIntervalSince(checkIn.date)
            let hoursElapsed = timeElapsed / 3600
            
            HStack {
                if hoursElapsed < 12 {
                    Text("⏱️ เหลือเวลา: \(String(format: "%.1f", 12 - hoursElapsed)) ชั่วโมง")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("✅ สามารถเช็คอินใหม่ได้แล้ว")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .padding(.top, 4)
            
            // MARK: - Action Buttons
            HStack {
                Button("✏️ \(language.localized("แก้ไขเวลา", "Edit Time"))") {
                    editingCheckIn = checkIn
                    showingEditCheckInSheet = true
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                
                Spacer()
                
                Button("🗑️ \(language.localized("ลบ", "Delete"))") {
                    checkInToDelete = checkIn
                    showDeleteCheckInConfirm = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
    
    func delete(_ member: Member) {
        if let index = memberStore.members.firstIndex(where: { $0.id == member.id }) {
            memberStore.members.remove(at: index)
        }
    }
    
    func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        return formatter.string(from: date)
    }
    
    // ปรับปรุง function นี้ให้แสดงแค่วันที่ (เพราะเวลาเกิดแยกไปแล้ว)
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long // แสดงวันที่แบบเต็ม
        formatter.timeStyle = .none // ไม่ต้องแสดงเวลา
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        return formatter.string(from: date)
    }
}
