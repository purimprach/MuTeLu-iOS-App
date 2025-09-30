import SwiftUI

// MARK: - DailyBannerView

struct DailyBannerView: View {
    var member: Member? = nil
    @EnvironmentObject var language: AppLanguage
    
    private var today: Date { Date() }
    
    private var formattedDate: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        f.dateFormat = language.currentLanguage == "th" ? "EEEEที่ d MMMM yyyy" : "EEEE, MMM d, yyyy"
        return f.string(from: today)
    }
    
    private var fortuneText: String {
        language.localized(getDailyFortuneTH(for: member), getDailyFortuneEN(for: member))
    }
    
    private var colorInfo: (good: String, bad: String) {
        let info = getFortuneInfo(for: member)
        return (language.localized(info.goodColorTH, info.goodColorEN),
                language.localized(info.badColorTH,  info.badColorEN))
    }
    
    var body: some View {
        let gradient = LinearGradient(colors: [.purple.opacity(0.9), .indigo.opacity(0.9)],
                                      startPoint: .topLeading, endPoint: .bottomTrailing)
        
        VStack(alignment: .leading, spacing: 14) {
            // Header – Date
            HStack(alignment: .center,spacing: 10) {
                Image(systemName: "calendar.badge.clock")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.black, .white.opacity(1))
                    .font(.system(size: 22, weight: .semibold))
                    .padding(8)
                Text(formattedDate)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
            }
            
            // Fortune bubble
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "sparkles")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white.opacity(1))
                    .font(.system(size: 20, weight: .semibold))
                Text(fortuneText)
                    .font(.body)
                    .foregroundStyle(.black.opacity(0.95))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(.white.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            // Lucky / Avoid – Chips (with pretty palette icons)
            HStack(spacing: 10) {
                ColorChip(
                    title: language.localized("สีมงคล", "Lucky Color"),
                    value: colorInfo.good,
                    swatch: swatchColor(from: colorInfo.good) ?? .white,
                    icon: AnyView(
                        Image(systemName: "paintpalette")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .white.opacity(0.35))
                            .font(.system(size: 14, weight: .semibold))
                    )
                )
                ColorChip(
                    title: language.localized("ห้ามใช้สี", "Avoid Color"),
                    value: colorInfo.bad,
                    swatch: swatchColor(from: colorInfo.bad) ?? .white,
                    icon: AnyView(
                        Image(systemName: "exclamationmark.triangle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .yellow.opacity(0.9))
                            .font(.system(size: 14, weight: .semibold))
                    )
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(gradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 10, y: 6)
        .frame(maxWidth:.infinity)
    }
    
    // แปลงชื่อสี -> Color (รองรับไทย/อังกฤษยอดนิยม)
    private func swatchColor(from name: String) -> Color? {
        let n = name.lowercased()
        let map: [(keys: [String], color: Color)] = [
            (["แดง","red"], .red),
            (["ชมพู","pink","rose"], .pink),
            (["ส้ม","orange","amber"], .orange),
            (["เหลือง","yellow","gold"], .yellow),
            (["เขียว","green","mint","emerald"], .green),
            (["ฟ้า","น้ำเงิน","blue","sky","navy"], .blue),
            (["คราม","indigo"], .indigo),
            (["ม่วง","purple","violet","lilac"], .purple),
            (["ขาว","white"], .white),
            (["ดำ","black"], .black),
            (["เทา","grey","gray","silver"], .gray),
            (["น้ำตาล","brown","cocoa","chocolate"], .brown)
        ]
        for entry in map where entry.keys.contains(where: { n.contains($0) }) {
            return entry.color
        }
        return nil
    }
}

// MARK: - ColorChip (icon = AnyView เพื่อใช้ palette/hierarchical ได้)

private struct ColorChip: View {
    let title: String
    let value: String
    let swatch: Color
    let icon: AnyView
    
    var body: some View {
        HStack(spacing: 8) {
            icon
            Text(title)
                .font(.caption.weight(.semibold))
            Circle()
                .fill(swatch)
                .frame(width: 14, height: 14)
                .overlay(Circle().strokeBorder(.white.opacity(0.5), lineWidth: 1))
            Text(value)
                .font(.footnote.weight(.medium))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .foregroundStyle(.white)
        .background(.white.opacity(0.12))
        .clipShape(Capsule())
    }
}
