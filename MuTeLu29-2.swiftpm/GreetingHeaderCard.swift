import SwiftUI

struct GreetingHeaderCard: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // ส่งเข้ามาเป็น Optional ได้
    let displayName: String?
    let displayEmail: String?
    let guestName: String              // เช่น "ผู้ใช้รับเชิญ"
    let subtitle: String?              // เช่น "ยินดีต้อนรับกลับ" (อยากไม่ใช้ ส่ง nil ได้)
    
    @State private var wave = false
    
    private var isGuest: Bool { (displayEmail ?? "").isEmpty }
    private var effectiveName: String {
        if isGuest { return guestName }
        return (displayName?.isEmpty == false ? displayName! : guestName)
    }
    private var initial: String {
        if isGuest { return "G" } // กรณีผู้ใช้รับเชิญ
        let base = (displayEmail ?? displayName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return base.first.map { String($0).uppercased() } ?? "?"
    }
    
    var body: some View {
        ZStack {
            // glass card + stroke + shadow
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(LinearGradient(
                            colors: scheme == .dark
                            ? [Color.white.opacity(0.12), Color.white.opacity(0.02)]
                            : [Color.black.opacity(0.06), Color.black.opacity(0.02)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ), lineWidth: 1)
                ).frame(maxWidth:600)
                .shadow(color: .black.opacity(scheme == .dark ? 0.24 : 0.14),
                        radius: scheme == .dark ? 12 : 18, x: 0, y: 8)
            
            HStack(spacing: 14) {
                // Avatar = ตัวแรกของอีเมล (หรือ G ถ้า guest)
                Circle()
                    .fill(LinearGradient(colors: [Color.purple, Color.blue],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text(initial)
                            .font(.title2.weight(.bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        // “สวัสดีตอน…นะ [ชื่อ]”
                        Text("\(timeGreeting())")
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundStyle(LinearGradient(colors: [.purple, .pink, .orange],
                                                            startPoint: .leading, endPoint: .trailing))
                        
                        Text("👋")
                            .font(.system(size: 30))
                            .rotationEffect(.degrees(wave ? 18 : -6), anchor: .bottomLeading)
                            .animation(reduceMotion ? nil :
                                    .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                                       value: wave)
                    }
                    
                    // แสดงอีเมลถ้ามี
                        Text("\(effectiveName)")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(LinearGradient(colors: [.blue, .brown],
                                                        startPoint: .leading, endPoint: .trailing))
                    
                    
                    
                    // แสดง subtitle ถ้ามี
                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .onAppear { wave = true }
    }
    
    // MARK: - Helpers
    private func timeGreeting() -> String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12:  return "สวัสดีตอนเช้า"
        case 12..<16: return "สวัสดีตอนบ่าย"
        case 16..<20: return "สวัสดีตอนเย็น"
        default:      return "สวัสดี"
        }
    }
}
