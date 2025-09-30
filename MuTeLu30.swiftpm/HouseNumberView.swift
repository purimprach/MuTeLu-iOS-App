import SwiftUI

struct HouseNumberView: View {
    @EnvironmentObject var language: AppLanguage
    @State private var houseNumber: String = ""
    @State private var resultTH: String?
    @State private var resultEN: String?
    @State private var goodColor: String = ""
    @State private var badColor: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // ปุ่มกลับ
                BackButton()
                
                // หัวข้อ
                Text(language.localized("🏠 ทำนายเลขที่บ้าน", "🏠 House Number Prediction"))
                    .font(.title2)
                    .fontWeight(.bold)
                
                // ช่องกรอกเลขที่บ้าน
                TextField(language.localized("กรอกเลขที่บ้าน", "Enter your house number"), text: $houseNumber)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
                    .keyboardType(.numbersAndPunctuation)
                
                // ปุ่มทำนาย
                Button(action: {
                    let sum = calculateHouseNumberSum(houseNumber)
                    let prediction = getHouseNumberPrediction(for: sum)
                    resultTH = prediction.th
                    resultEN = prediction.en
                    goodColor = prediction.goodColor
                    badColor = prediction.badColor
                }) {
                    Text(language.localized("ทำนาย", "Predict"))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                // กล่องผลลัพธ์
                if let resultTH = resultTH, let resultEN = resultEN {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(language.localized("ผลทำนาย:", "Prediction:"))
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text(language.localized(resultTH, resultEN))
                                .font(.body)
                            
                            Divider()
                            
                            Text("✅ \(language.localized("สีมงคล", "Lucky Color")): \(goodColor)")
                            Text("⚠️ \(language.localized("ห้ามใช้สี", "Avoid Color")): \(badColor)")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .shadow(radius: 5)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
    
    func calculateHouseNumberSum(_ input: String) -> Int {
        let digits = input.filter { $0.isNumber }.compactMap { Int(String($0)) }
        var total = digits.reduce(0, +)
        while total >= 10 {
            total = String(total).compactMap { Int(String($0)) }.reduce(0, +)
        }
        return total
    }
    
    func getHouseNumberPrediction(for number: Int) -> (th: String, en: String, goodColor: String, badColor: String) {
        switch number {
        case 1:
            return ("ส่งเสริมความเป็นผู้นำ ความมั่นใจ", "Promotes leadership and confidence", "แดง", "น้ำเงินเข้ม")
        case 2:
            return ("อบอุ่น น่าอยู่ เหมาะกับครอบครัว", "Warm and homely, ideal for family life", "เขียวอ่อน", "เทาเข้ม")
        case 3:
            return ("กระตือรือร้น เหมาะกับนักธุรกิจ", "Energetic, great for business owners", "ส้ม", "น้ำตาล")
        case 4:
            return ("เหมาะกับคนทำงานด้านสื่อหรือค้าขาย", "Good for communication or commerce careers", "ฟ้า", "ดำ")
        case 5:
            return ("มั่นคง สมดุล เหมาะกับทุกเพศวัย", "Stable and balanced, suitable for all", "เหลือง", "แดงเข้ม")
        case 6:
            return ("เสริมเรื่องความรัก ความสวยงาม", "Enhances love and aesthetics", "ชมพู", "เขียวเข้ม")
        case 7:
            return ("เงียบสงบ เหมาะกับผู้สูงอายุหรือผู้ปฏิบัติธรรม", "Quiet and peaceful, ideal for elderly or spiritual", "ม่วง", "ส้ม")
        case 8:
            return ("เน้นโชคลาภ การเงิน อำนาจ", "Focuses on wealth and power", "ทอง", "ฟ้าอ่อน")
        case 9:
            return ("เสริมสิริมงคล จิตใจสูงส่ง", "Spiritual and auspicious", "ขาว", "ดำ")
        default:
            return ("ไม่สามารถคำนวณได้", "Unable to predict", "-", "-")
        }
    }
}
