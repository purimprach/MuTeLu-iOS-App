import SwiftUI

// MARK: - Shared Routers / Stores

final class CheckinFilterStore: ObservableObject {
    @Published var selectedUserEmail: String? = nil
    @Published var selectedPlaceID: String? = nil
    func clear() { selectedUserEmail = nil; selectedPlaceID = nil }
}

final class AdminTabRouter: ObservableObject {
    enum Tab { case members, checkIns }
    @Published var selected: Tab = .members
}

// MARK: - Helpers & Extensions

extension Color {
    static let surfaceOverlay = Color.primary.opacity(0.06)
}

extension String {
    /// อักษร 2 ตัวจาก local-part ของอีเมล
    var emailInitials: String {
        let local = self.split(separator: "@").first.map(String.init) ?? self
        let letters = local
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: ".", with: " ")
            .split(separator: " ")
        let first  = letters.first?.first.map { String($0) } ?? (local.first.map { String($0) } ?? "")
        let second = letters.dropFirst().first?.first.map { String($0) } ?? (local.dropFirst().first.map { String($0) } ?? "")
        return (first + second).uppercased()
    }
}
extension Member { var emailInitials: String { email.emailInitials } }

extension View {
    func cardContainer(gradient: LinearGradient? = nil) -> some View {
        self.padding(14)
            .background(
                ZStack {
                    if let g = gradient { g }
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    }
}

struct AccentPalette {
    static let pairs: [(Color, Color)] = [
        (.pink, .orange), (.purple, .blue), (.mint, .teal), (.indigo, .purple),
        (.yellow, .orange), (.green, .teal), (.cyan, .blue), (.red, .pink)
    ]
    static func pair(for key: String) -> (Color, Color) {
        let idx = abs(key.hashValue) % pairs.count
        return pairs[idx]
    }
}

// MARK: - AdminView

struct AdminView: View {
    @EnvironmentObject var language: AppLanguage
    @StateObject private var tabRouter = AdminTabRouter()
    @StateObject private var filterStore = CheckinFilterStore()
    
    var body: some View {
        TabView(selection: Binding(
            get: { tabRouter.selected == .members ? 0 : 1 },
            set: { tabRouter.selected = ($0 == 0) ? .members : .checkIns }
        )) {
            MemberManagementView()
                .tabItem { Label(language.localized("สมาชิก", "Members"), systemImage: "person.3.fill") }
                .tag(0)
                .environmentObject(tabRouter)
                .environmentObject(filterStore)
            
            CheckinHistoryView()
                .tabItem { Label(language.localized("ประวัติเช็คอิน", "Check-ins"), systemImage: "mappin.and.ellipse") }
                .tag(1)
                .environmentObject(tabRouter)
                .environmentObject(filterStore)
        }
    }
}

// MARK: - MemberManagementView

struct MemberManagementView: View {
    @EnvironmentObject var memberStore: MemberStore
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flowManager: MuTeLuFlowManager
    @EnvironmentObject var checkInStore: CheckInStore
    @EnvironmentObject var tabRouter: AdminTabRouter
    @EnvironmentObject var filterStore: CheckinFilterStore
    
    @State private var editingMember: Member?
    @State private var memberToDelete: Member?
    @State private var showDeleteConfirm = false
    @State private var showingAddSheet = false
    @State private var sortOption: SortOption = .nameAZ
    @State private var searchText = ""
    @State private var showLogoutConfirm = false // 👈 **เพิ่ม State สำหรับ Alert**
    
    enum SortOption: String, CaseIterable, Identifiable {
        case nameAZ, nameZA, meritHigh, recentLogin
        var id: String { rawValue }
    }
    
    private func label(_ opt: SortOption) -> String {
        switch opt {
        case .nameAZ:     return language.localized("ชื่อ A→Z", "Name A→Z")
        case .nameZA:     return language.localized("ชื่อ Z→A", "Name Z→A")
        case .meritHigh:  return language.localized("แต้มบุญมาก→น้อย", "Merit High→Low")
        case .recentLogin:return language.localized("เข้าระบบล่าสุด", "Recent Login")
        }
    }
    private func meritPoints(for m: Member) -> Int {
        checkInStore.records(for: m.email).reduce(0) { $0 + $1.meritPoints }
    }
    private var filteredMembers: [Member] {
        var list = memberStore.members
        if !searchText.isEmpty {
            let key = searchText.lowercased()
            list = list.filter {
                $0.fullName.lowercased().contains(key) ||
                $0.email.lowercased().contains(key) ||
                $0.phoneNumber.lowercased().contains(key)
            }
        }
        switch sortOption {
        case .nameAZ:     list.sort { $0.fullName.localizedCompare($1.fullName) == .orderedAscending }
        case .nameZA:     list.sort { $0.fullName.localizedCompare($1.fullName) == .orderedDescending }
        case .meritHigh:  list.sort { meritPoints(for: $0) > meritPoints(for: $1) }
        case .recentLogin:list.sort { ($0.lastLogin ?? .distantPast) > ($1.lastLogin ?? .distantPast) }
        }
        return list
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(filteredMembers, id: \.id) { member in
                        MemberCard(member: member,
                                   language: language,
                                   onEdit: { editingMember = member },
                                   onDelete: { memberToDelete = member; showDeleteConfirm = true })
                        .environmentObject(checkInStore)
                        .environmentObject(tabRouter)
                        .environmentObject(filterStore)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .navigationTitle(language.localized("จัดการสมาชิก", "Member Management"))
            .searchable(text: $searchText, prompt: Text(language.localized("ค้นหาชื่อ / อีเมล / โทรศัพท์", "Search name / email / phone")))
            .toolbar {
                // 👇 --- **ส่วนที่แก้ไข** ---
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .destructive) {
                        showLogoutConfirm = true // แสดง Alert ยืนยัน
                    } label: {
                        Label(language.localized("ออกจากระบบ", "Logout"), systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
                // -------------------------
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker(selection: $sortOption) {
                            ForEach(SortOption.allCases) { Text(label($0)).tag($0) }
                        } label: {
                            Label(language.localized("เรียงลำดับ", "Sort"), systemImage: "arrow.up.arrow.down")
                        }
                        Divider()
                        Button { showingAddSheet = true } label: {
                            Label(language.localized("เพิ่มสมาชิกใหม่", "Add Member"), systemImage: "person.badge.plus")
                        }
                    } label: { Image(systemName: "ellipsis.circle").imageScale(.large) }
                }
            }
            .sheet(item: $editingMember) { memberToEdit in
                EditMemberView(member: memberToEdit) { updated in
                    if let index = memberStore.members.firstIndex(where: { $0.id == updated.id }) {
                        memberStore.members[index] = updated
                    }
                    editingMember = nil
                }
            }
            .alert(language.localized("ยืนยันการลบ", "Confirm Deletion"), isPresented: $showDeleteConfirm) {
                Button(language.localized("ลบ", "Delete"), role: .destructive) {
                    if let m = memberToDelete,
                       let i = memberStore.members.firstIndex(where: { $0.id == m.id }) {
                        memberStore.members.remove(at: i)
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
            // 👇 **เพิ่ม Alert สำหรับยืนยันการ Logout**
            .alert(language.localized("ยืนยันการออกจากระบบ", "Confirm Logout"), isPresented: $showLogoutConfirm) {
                Button(language.localized("ออกจากระบบ", "Logout"), role: .destructive) {
                    flowManager.isLoggedIn = false
                    flowManager.currentScreen = .login
                }
                Button(language.localized("ยกเลิก", "Cancel"), role: .cancel) {}
            } message: {
                Text(language.localized("คุณต้องการออกจากระบบผู้ดูแลหรือไม่?", "Are you sure you want to log out from the admin system?"))
            }
        }
    }
}

// MARK: - MemberCard (Top 7 วัดเท่านั้น)

struct MemberCard: View {
    let member: Member
    let language: AppLanguage
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    @EnvironmentObject var checkInStore: CheckInStore
    @EnvironmentObject var tabRouter: AdminTabRouter
    @EnvironmentObject var filterStore: CheckinFilterStore
    
    private var meritPoints: Int {
        checkInStore.records(for: member.email).reduce(0) { $0 + $1.meritPoints }
    }
    private var latestCheckinText: String {
        let rs = checkInStore.records(for: member.email)
        guard let d = rs.max(by: { $0.date < $1.date })?.date else {
            return language.localized("ยังไม่เคยเช็คอิน", "No check-ins yet")
        }
        return formattedDateTime(d)
    }
    
    /// คืน Top N วัดของ user นี้ (เร็วกว่าแสดงทั้งหมด)
    private func topCheckins(limit: Int = 7) -> [(placeID: String, name: String, count: Int)] {
        let records = checkInStore.records(for: member.email)
        guard !records.isEmpty else { return [] }
        let isTH = (language.currentLanguage == "th")
        
        let grouped = Dictionary(grouping: records, by: { $0.placeID })
            .map { (pid: $0.key,
                    nameTH: $0.value.first?.placeNameTH ?? "-",
                    nameEN: $0.value.first?.placeNameEN ?? "-",
                    count: $0.value.count) }
            .sorted { l, r in
                if l.count != r.count { return l.count > r.count }           // มาก→น้อย
                let ln = isTH ? l.nameTH : l.nameEN
                let rn = isTH ? r.nameTH : r.nameEN
                return ln.localizedCompare(rn) == .orderedAscending
            }
            .prefix(limit)
        
        return grouped.map { (placeID: $0.pid, name: isTH ? $0.nameTH : $0.nameEN, count: $0.count) }
    }
    
    private var gradient: LinearGradient {
        let (c1, c2) = AccentPalette.pair(for: member.email)
        return LinearGradient(colors: [c1.opacity(0.38), c2.opacity(0.38)],
                              startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    let (c1, c2) = AccentPalette.pair(for: member.email)
                    Circle().fill(LinearGradient(colors: [c1, c2], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 54, height: 54)
                        .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 2))
                        .shadow(color: c2.opacity(0.35), radius: 8, y: 3)
                    Text(member.emailInitials).font(.headline.weight(.bold)).foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(member.fullName).font(.headline).lineLimit(1)
                }
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "star.fill").foregroundColor(.orange)
                    Text("\(meritPoints)").font(.subheadline.bold()).foregroundStyle(.primary)
                }
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(.thinMaterial)
                .clipShape(Capsule())
            }
            
            Divider().opacity(0.2)
            
            // Body
            VStack(alignment: .leading, spacing: 8) {
                infoRow(icon: "envelope.fill", text: member.email, tint: .blue)
                infoRow(icon: "phone.fill", text: member.phoneNumber, tint: .green)
                infoRow(icon: "calendar",
                        text: language.localized("เกิดวันที่: \(formattedDate(member.birthdate)), เวลา \(member.birthTime)",
                                                 "Birth: \(formattedDate(member.birthdate)), \(member.birthTime)"),
                        tint: .indigo)
                infoRow(icon: "person.circle",
                        text: language.localized("เพศ: \(member.gender)", "Gender: \(member.gender)"),
                        tint: .purple)
                HStack(spacing: 12) {
                    infoRow(icon: "house.fill", text: member.houseNumber, tint: .teal)
                    infoRow(icon: "car.fill", text: member.carPlate, tint: .orange)
                }
                
                // Last login
                if let lastLogin = member.lastLogin {
                    infoRow(icon: "clock.arrow.circlepath",
                            text: language.localized("เข้าระบบล่าสุด: \(formattedDateTime(lastLogin))",
                                                     "Last login: \(formattedDateTime(lastLogin))"),
                            tint: .pink)
                } else {
                    infoRow(icon: "clock.arrow.circlepath",
                            text: language.localized("ยังไม่เคยเข้าระบบ", "Never logged in"),
                            tint: .gray)
                }
                
                // Interests (always show)
                let interests: String = {
                    if member.tagScores.isEmpty { return "-" }
                    let sorted = member.tagScores.sorted { $0.value > $1.value }
                    return sorted.map { "\($0.key): \($0.value)" }.joined(separator: "   ")
                }()
                infoRow(icon: "tag.fill",
                        text: language.localized("ความสนใจ : \(interests)", "Interests : \(interests)"),
                        tint: .red)
                .fixedSize(horizontal: false, vertical: true)
                
                // Latest check-in
                infoRow(icon: "clock.badge.checkmark",
                        text: language.localized("เช็คอินล่าสุด: \(latestCheckinText)",
                                                 "Latest check-in: \(latestCheckinText)"),
                        tint: .blue)
                
                // ✅ Top 7 วัด (ชิปกดได้)
                let top7 = topCheckins(limit: 7)
                if !top7.isEmpty {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "building.columns.circle.fill")
                            .foregroundColor(.red)
                            .frame(width: 16)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(top7, id: \.placeID) { item in
                                    Button {
                                        filterStore.selectedUserEmail = member.email
                                        filterStore.selectedPlaceID  = item.placeID
                                        tabRouter.selected = .checkIns
                                    } label: {
                                        HStack(spacing: 6) {
                                            Text(item.name).lineLimit(1)
                                            Text("• \(item.count)")
                                                .font(.subheadline.weight(.semibold))
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .foregroundColor(.white)
                                        .background(
                                            Capsule().fill(
                                                LinearGradient(colors: [Color.red, Color.pink],
                                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                                            )
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                } else {
                    infoRow(icon: "building.columns.circle.fill",
                            text: language.localized("วัดที่เคยเช็คอิน: ยังไม่เคยเช็คอิน", "Visited shrines: No check-ins yet"),
                            tint: .red)
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            // Actions
            HStack {
                Button { onEdit() } label: { Label(language.localized("แก้ไข", "Edit"), systemImage: "pencil") }
                    .buttonStyle(.bordered)
                Spacer()
                Button(role: .destructive) { onDelete() } label: { Label(language.localized("ลบ", "Delete"), systemImage: "trash") }
                    .buttonStyle(.borderedProminent)
            }
            .padding(.top, 2)
        }
        .cardContainer(gradient: gradient)
    }
    
    private func infoRow(icon: String, text: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).imageScale(.small).foregroundColor(tint).frame(width: 16)
            Text(text).foregroundColor(.secondary)
        }
    }
    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter(); f.dateStyle = .long; f.timeStyle = .none
        f.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        return f.string(from: date)
    }
    private func formattedDateTime(_ date: Date) -> String {
        let f = DateFormatter(); f.dateStyle = .medium; f.timeStyle = .short
        f.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        return f.string(from: date)
    }
}

// MARK: - CheckinHistoryView

struct CheckinHistoryView: View {
    @EnvironmentObject var checkInStore: CheckInStore
    @EnvironmentObject var memberStore: MemberStore
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var filterStore: CheckinFilterStore
    
    @State private var searchText = ""
    @State private var sortNewestFirst = true
    
    private var filteredRecords: [CheckInRecord] {
        var records = checkInStore.records
        if let email = filterStore.selectedUserEmail {
            records = records.filter { $0.memberEmail.caseInsensitiveCompare(email) == .orderedSame }
        }
        if let placeID = filterStore.selectedPlaceID {
            records = records.filter { $0.placeID == placeID }
        }
        if !searchText.isEmpty {
            let opt: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
            records = records.filter { r in
                if r.placeNameTH.range(of: searchText, options: opt) != nil { return true }
                if r.placeNameEN.range(of: searchText, options: opt) != nil { return true }
                if r.memberEmail.range(of: searchText, options: opt) != nil { return true }
                if let m = memberStore.members.first(where: { $0.email.caseInsensitiveCompare(r.memberEmail) == .orderedSame }),
                   m.fullName.range(of: searchText, options: opt) != nil { return true }
                return false
            }
        }
        records.sort { sortNewestFirst ? ($0.date > $1.date) : ($0.date < $1.date) }
        return records
    }
    
    var body: some View {
        NavigationStack {
            List {
                if filterStore.selectedUserEmail != nil || filterStore.selectedPlaceID != nil {
                    Section {
                        HStack {
                            if let email = filterStore.selectedUserEmail {
                                Label(email, systemImage: "person.crop.circle.fill")
                            }
                            if let pid = filterStore.selectedPlaceID,
                               let sample = checkInStore.records.first(where: { $0.placeID == pid }) {
                                Label(sample.placeNameTH, systemImage: "building.columns.fill")
                            }
                            Spacer()
                            Button(role: .destructive) {
                                filterStore.clear()
                            } label: {
                                Label(language.localized("ล้างตัวกรอง", "Clear filters"), systemImage: "xmark.circle")
                            }
                            .buttonStyle(.bordered)
                        }
                        .font(.subheadline)
                    }
                }
                
                ForEach(groupedByDay(filteredRecords), id: \.key) { day, items in
                    Section(header: Text(dayHeader(day))) {
                        ForEach(items) { record in
                            CheckInRow(record: record)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14))
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(language.localized("ประวัติเช็คอินทั้งหมด", "All Check-in History"))
            .searchable(text: $searchText, prompt: Text(language.localized("ค้นหาด้วยชื่อ, อีเมล, สถานที่...", "Search by name, email, place...")))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Toggle(language.localized("ใหม่สุดอยู่บน", "Newest first"), isOn: $sortNewestFirst)
                        if filterStore.selectedUserEmail != nil || filterStore.selectedPlaceID != nil || !searchText.isEmpty {
                            Divider()
                            Button(role: .destructive) {
                                filterStore.clear(); searchText = ""
                            } label: {
                                Label(language.localized("ล้างตัวกรองทั้งหมด", "Clear all filters"), systemImage: "xmark.circle")
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle" +
                              ((filterStore.selectedUserEmail != nil || filterStore.selectedPlaceID != nil || !searchText.isEmpty) ? ".fill" : ""))
                        .imageScale(.large)
                    }
                }
            }
        }
    }
    
    private func groupedByDay(_ records: [CheckInRecord]) -> [(key: Date, value: [CheckInRecord])] {
        let cal = Calendar.current
        let groups = Dictionary(grouping: records) { cal.startOfDay(for: $0.date) }
        return groups.keys.sorted(by: >).map { ($0, groups[$0]!.sorted { $0.date > $1.date }) }
    }
    private func dayHeader(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .full; f.timeStyle = .none
        f.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        return f.string(from: date)
    }
}

// MARK: - CheckInRow

struct CheckInRow: View {
    let record: CheckInRecord
    @EnvironmentObject var memberStore: MemberStore
    @EnvironmentObject var language: AppLanguage
    
    private var memberName: String {
        memberStore.members.first { $0.email.caseInsensitiveCompare(record.memberEmail) == .orderedSame }?.fullName ?? "Unknown User"
    }
    
    var body: some View {
        let (c1, c2) = AccentPalette.pair(for: record.placeID)
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "mappin.circle.fill").foregroundColor(c1)
                Text(language.localized(record.placeNameTH, record.placeNameEN))
                    .font(.headline).foregroundColor(.primary)
                Spacer()
                Label("+\(record.meritPoints)", systemImage: "star.fill")
                    .font(.subheadline.bold()).foregroundColor(.orange)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(.thinMaterial).clipShape(Capsule())
            }
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Label(memberName, systemImage: "person.fill")
                    Label(record.memberEmail, systemImage: "envelope.fill")
                }
                .font(.subheadline).foregroundColor(.secondary)
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(record.date, style: .date)
                    Text(record.date, style: .time)
                }
                .font(.subheadline).foregroundColor(.secondary)
            }
        }
        .cardContainer(gradient: LinearGradient(colors: [c1.opacity(0.25), c2.opacity(0.25)],
                                                startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}
