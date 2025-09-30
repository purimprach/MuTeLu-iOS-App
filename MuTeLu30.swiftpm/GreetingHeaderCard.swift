import SwiftUI

struct GreetingHeaderCard: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject var language: AppLanguage      // <-- ย้ายขึ้นบนชัดเจน
    
    let displayName: String?
    let displayEmail: String?
    let guestName: String
    let subtitle: String?
    
    @State private var wave = false
    
    // ผู้ใช้ guest ถ้า email ว่าง
    private var isGuest: Bool { (displayEmail ?? "").isEmpty }
    
    // ชื่อที่จะแสดง
    private var effectiveName: String {
        if isGuest { return guestName }
        return (displayName?.isEmpty == false ? displayName! : guestName)
    }
    
    // อักษรแรกในวงกลม (Guest = G)
    private var initial: String {
        if isGuest { return "G" }
        let base = (displayEmail ?? displayName ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return base.first.map { String($0).uppercased() } ?? "?"
    }
    
    var body: some View {
        ZStack {
            // glass card + stroke + shadow
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: scheme == .dark
                                ? [Color.white.opacity(0.12), Color.white.opacity(0.02)]
                                : [Color.black.opacity(0.06), Color.black.opacity(0.02)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(scheme == .dark ? 0.24 : 0.14),
                        radius: scheme == .dark ? 12 : 18, x: 0, y: 8)
            
            HStack(spacing: 14) {
                // Avatar
                Circle()
                    .fill(
                        LinearGradient(colors: [Color.purple, Color.blue],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(initial)
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(.white)
                    )
                    .padding()
                
                VStack(alignment: .leading, spacing: 6) {
                    // Heading + 👋
                    HStack(spacing: 12) {
                        Text(timeGreeting())
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.purple, .pink, .orange],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                        Text("👋")
                            .font(.system(size: 30))
                            .rotationEffect(.degrees(wave ? 18 : -6), anchor: .bottomLeading)
                            .animation(
                                reduceMotion ? nil :
                                        .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                                value: wave
                            )
                        Spacer(minLength: 0)
                    }
                    
                    // ชื่อ
                    Text(effectiveName)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.blue, .brown],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                    
                    // subtitle (ถ้ามี)
                    if let subtitle = subtitle {
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
    
    // MARK: - Helpers (ใช้ localized แทน isThai)
    private func timeGreeting() -> String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12:
            return language.localized("สวัสดีตอนเช้า", "Good morning")
        case 12..<16:
            return language.localized("สวัสดีตอนบ่าย", "Good afternoon")
        case 16..<20:
            return language.localized("สวัสดีตอนเย็น", "Good evening")
        default:
            return language.localized("สวัสดี", "Hello")
        }
    }
}
