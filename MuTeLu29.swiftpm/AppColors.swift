import SwiftUI

// โค้ดส่วนนี้เป็น "เครื่องมือ" ที่จะทำให้เราสามารถสร้างสีจากโค้ด Hex (เช่น #6A0DAD) ได้
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// นี่คือ "พจนานุกรมสี" ของแอปเราครับ
struct AppColor {
    // สีหลัก
    static let brandPrimary = DynamicColor(
        light: Color(hex: "6A0DAD"),
        dark: Color(hex: "A955FF")
    )
    
    // สีพื้นหลัง
    static let backgroundPrimary = DynamicColor(
        light: Color(hex: "F7F7F9"),
        dark: Color(hex: "121212")
    )
    
    static let backgroundSecondary = DynamicColor(
        light: Color(hex: "FFFFFF"),
        dark: Color(hex: "1E1E1E")
    )
    
    // สีตัวอักษร
    static let textPrimary = DynamicColor(
        light: Color(hex: "1A1A1A"),
        dark: Color(hex: "F5F5F5")
    )
    
    static let textSecondary = DynamicColor(
        light: Color(hex: "6B6B6B"),
        dark: Color(hex: "A0A0A0")
    )
}

// โค้ดส่วนนี้เอาไว้ช่วยให้เราเรียกใช้สีได้ง่ายๆ
// โดยมันจะดูให้เองว่าตอนนี้เป็น Light Mode หรือ Dark Mode
struct DynamicColor {
    let light: Color
    let dark: Color
    
    var color: Color {
        // ใช้ EnvironmentValues เพื่อเช็ค color scheme ปัจจุบัน
        @Environment(\.colorScheme) var colorScheme
        return colorScheme == .dark ? dark : light
    }
}
