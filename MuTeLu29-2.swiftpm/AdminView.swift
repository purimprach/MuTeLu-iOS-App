import SwiftUI
import CryptoKit
import SwiftData

// MARK: - 1. หน้าจอหลักของผู้ดูแล (Dashboard)
struct AdminView: View {
    @EnvironmentObject var language: AppLanguage
    @State private var selectedTab: AdminTab = .members
    
    enum AdminTab {
        case members
        case checkIns
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // -- แท็บที่ 1: จัดการสมาชิก --
            MemberManagementView()
                .tabItem {
                    Label(language.localized("สมาชิก", "Members"), systemImage: "person.3.fill")
                }
                .tag(AdminTab.members)
            
            // -- แท็บที่ 2: ประวัติการเช็คอิน --
            CheckinHistoryView()
                .tabItem {
                    Label(language.localized("ประวัติเช็คอิน", "Check-ins"), systemImage: "mappin.and.ellipse")
                }
                .tag(AdminTab.checkIns)
        }
    }
}


// MARK: - 2. หน้าจอสำหรับจัดการสมาชิก (ฉบับสมบูรณ์)
struct MemberManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Member.fullName) private var members: [Member]
    
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    
    @State private var editingMember: Member?
    @State private var showingEditSheet = false
    @State private var memberToDelete: Member?
    @State private var showDeleteConfirm = false
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    ForEach(members) { member in
                        memberCard(for: member)
                    }
                }
                .padding()
            }
            .navigationTitle(language.localized("จัดการสมาชิก", "Member Management"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        flowManager.currentScreen = .home
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
            .sheet(isPresented: $showingEditSheet) {
                if let memberToEdit = editingMember {
                    EditMemberView(member: memberToEdit)
                }
            }
            .alert(language.localized("ยืนยันการลบ", "Confirm Deletion"), isPresented: $showDeleteConfirm) {
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
                EditMemberView(member: nil)
            }
        }
    }
    
    @ViewBuilder
    func memberCard(for member: Member) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("👤 \(member.fullName)")
                .font(.headline)
                .fontWeight(.bold)
            Divider()
            VStack(alignment: .leading, spacing: 8) {
                Label(member.email, systemImage: "envelope.fill")
                Label(member.phoneNumber, systemImage: "phone.fill")
            }
            .font(.subheadline)
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
        .background(Material.regular)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
    
    func delete(_ member: Member) {
        modelContext.delete(member)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        return formatter.string(from: date)
    }
}


// MARK: - 3. หน้าจอประวัติเช็คอิน (ฉบับสมบูรณ์)
struct CheckinHistoryView: View {
    @Query(sort: \CheckInRecord.date, order: .reverse) private var records: [CheckInRecord]
    @Query(sort: \Member.fullName) private var members: [Member]
    @EnvironmentObject var language: AppLanguage
    
    @State private var searchText = ""
    @State private var selectedUserEmail: String? = nil
    @State private var selectedPlaceID: String? = nil
    
    private var filteredRecords: [CheckInRecord] {
        var filtered = records
        
        if let email = selectedUserEmail {
            filtered = filtered.filter { $0.memberEmail == email }
        }
        
        if let placeID = selectedPlaceID {
            filtered = filtered.filter { $0.placeID == placeID }
        }
        
        if !searchText.isEmpty {
            let searchOptions: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
            filtered = filtered.filter { record in
                if record.placeNameTH.range(of: searchText, options: searchOptions) != nil { return true }
                if record.placeNameEN.range(of: searchText, options: searchOptions) != nil { return true }
                if record.memberEmail.range(of: searchText, options: searchOptions) != nil { return true }
                if let member = findMember(by: record.memberEmail) {
                    if member.fullName.range(of: searchText, options: searchOptions) != nil { return true }
                }
                return false
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationStack {
            List(filteredRecords) { record in
                CheckInRow(record: record)
            }
            .listStyle(.insetGrouped)
            .navigationTitle(language.localized("ประวัติเช็คอินทั้งหมด", "All Check-in History"))
            .searchable(text: $searchText, prompt: Text(language.localized("ค้นหาด้วยชื่อ, อีเมล, สถานที่...", "Search by name, email, place...")))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Section {
                            Picker("กรองตามสมาชิก", selection: $selectedUserEmail) {
                                Text("สมาชิกทั้งหมด").tag(String?.none)
                                ForEach(members) { member in
                                    Text(member.fullName).tag(String?(member.email))
                                }
                            }
                            
                            Picker("กรองตามสถานที่", selection: $selectedPlaceID) {
                                Text("สถานที่ทั้งหมด").tag(String?.none)
                                let uniquePlaces = Dictionary(grouping: records, by: { $0.placeID })
                                    .compactMap { $0.value.first }
                                    .sorted { $0.placeNameTH < $1.placeNameTH }
                                
                                ForEach(uniquePlaces, id: \.placeID) { record in
                                    Text(record.placeNameTH).tag(String?(record.placeID))
                                }
                            }
                        }
                        
                        if selectedUserEmail != nil || selectedPlaceID != nil {
                            Section {
                                Button(role: .destructive) {
                                    selectedUserEmail = nil
                                    selectedPlaceID = nil
                                } label: {
                                    Label("ล้างการกรอง", systemImage: "xmark.circle")
                                }
                            }
                        }
                    } label: {
                        Image(systemName: (selectedUserEmail != nil || selectedPlaceID != nil) ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .imageScale(.large)
                    }
                }
            }
        }
    }
    
    private func findMember(by email: String) -> Member? {
        return members.first { $0.email.caseInsensitiveCompare(email) == .orderedSame }
    }
}


// MARK: - 4. UI สำหรับแสดงผลแต่ละแถวในหน้าประวัติเช็คอิน
struct CheckInRow: View {
    let record: CheckInRecord
    @Query private var members: [Member]
    @EnvironmentObject var language: AppLanguage
    
    private var memberName: String {
        members.first { $0.email.caseInsensitiveCompare(record.memberEmail) == .orderedSame }?.fullName ?? "Unknown User"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(language.localized(record.placeNameTH, record.placeNameEN))
                .font(.headline)
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label(memberName, systemImage: "person.fill")
                    Label(record.memberEmail, systemImage: "envelope.fill")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(record.date, style: .date)
                    Text(record.date, style: .time)
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            
            Text("+\(record.meritPoints) แต้มบุญ")
                .font(.footnote.bold())
                .foregroundColor(.green)
                .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}
