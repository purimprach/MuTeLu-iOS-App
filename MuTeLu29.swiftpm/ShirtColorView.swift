import SwiftUI

struct ShirtColorView: View {
    @State private var selectedDate = Date()
    @State private var showCalendar = true
    @State private var showResult = false
    @EnvironmentObject var language: AppLanguage
    
    private let allColors = LuckyColourLoader.loadAllColors()
    
    var selectedDay: Int {
        Calendar.current.component(.day, from: selectedDate)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        formatter.dateStyle = .full
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        Spacer()
        BackButton()
        VStack(spacing: 20) {
            Text("👕 " + language.localized(" สีเสื้อมงคลประจำวัน", "Lucky Shirt Color"))
                .font(.title3)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(Color(.purple).opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.5), lineWidth: 2)
                )
                .cornerRadius(12)
            
            if showCalendar {
                DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .environment(\.locale, Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US"))
                    .labelsHidden()
                    .padding(.horizontal)
                
                Button(action: {
                    showCalendar = false
                    showResult = true
                }) {
                    Text(language.localized("ดูคำทำนาย", "See Prediction"))
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            
            if showResult {
                Text(formattedDate)
                    .font(.headline)
                    .foregroundColor(.gray)
                
                if let color = allColors.first(where: { $0.day == selectedDay }) {
                    VStack(alignment: .leading, spacing: 15) {
                        Divider()
                        ColorRow(label: language.localized("เสริมดวง", "Good Luck"), values: color.shouldWear)
                        Divider()
                        ColorRow(label: language.localized("ไม่ควรใส่", "Avoid"), values: color.shouldAvoid)
                        Divider()
                        ColorRow(label: language.localized("เสริมโชค", "Wealth & Success"), values: color.canWear)
                        Divider()
                    }
                    .padding(.horizontal)
                } else {
                    Text(language.localized("ไม่พบข้อมูลสำหรับวันที่เลือก", "No data for selected day"))
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                Button(action: {
                    showCalendar = true
                    showResult = false
                }) {
                    Text(language.localized("เลือกวันที่อื่นๆ", "Choose Another Date"))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding()
            }
            
            Spacer()
        }
        .padding()
    }
}

struct ColorRow: View {
    let label: String
    let values: [String]
    
    var body: some View {
        let shouldUseBlackText: Set<String> = ["ขาว", "ครีม", "เหลืองอ่อน","เหลืองเข้ม", "เงิน", "ทอง", "เทา","เขียวอ่อน","ส้ม"]
        
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.headline)
            
            HStack(spacing: 10) {
                ForEach(values, id: \.self) { colorName in
                    Text(colorName)
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                        .frame(width:105)
                        .background(colorFromName(colorName))
                        .foregroundColor(shouldUseBlackText.contains(colorName) ? .black : .white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.9), lineWidth: 2)
                        )
                        .cornerRadius(10)
                }
            }
        }
    }
    
    func colorFromName(_ name: String) -> Color {
        switch name {
        case "แดง", "แดงเข้ม": return .red
        case "น้ำเงิน", "น้ำเงินสดใส": return .blue
        case "ฟ้า": return .cyan
        case "เขียวเข้ม": return Color(red: 0.0, green: 0.4, blue: 0.1) 
        case "เขียวอ่อน": return Color(red: 0.5, green: 0.8, blue: 0.2)
        case "เหลืองเข้ม": return Color(red: 1.0, green: 0.8, blue: 0.0) 
        case "เหลืองอ่อน": return Color(red: 1.0, green: 0.9, blue: 0.3) 
        case "ครีม": return Color(red: 0.9, green: 0.9, blue: 0.8) 
        case "เทา": return Color(red: 0.7, green: 0.7, blue: 0.7)  
        case "เงิน": return Color(red: 0.8, green: 0.8, blue: 0.85) 
        case "ม่วงอ่อน", "ม่วงเข้ม": return .purple
        case "น้ำตาล": return .brown
        case "ส้ม": return .orange
        case "ชมพู": return .pink
        case "ดำ": return .black
        case "ขาว": return .white
        case "ทอง": return Color(red: 0.93, green: 0.78, blue: 0.25)
        default: return .gray.opacity(0.3)
        }
    }
}
