import SwiftUI

struct DailyBannerView: View {
    var member: Member?
    @EnvironmentObject var language: AppLanguage
    
    var today: Date { Date() }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: language.currentLanguage == "th" ? "th_TH" : "en_US")
        formatter.dateFormat = language.currentLanguage == "th"
        ? "EEEEที่ d MMMM yyyy"
        : "EEEE, MMM d, yyyy"
        return formatter.string(from: today)
    }
    
    var fortuneText: String {
        language.localized(
            getDailyFortuneTH(for: member),
            getDailyFortuneEN(for: member)
        )
    }
    
    var colorInfo: (good: String, bad: String) {
        let info = getFortuneInfo(for: member)
        return (language.localized(info.goodColorTH, info.goodColorEN),
                language.localized(info.badColorTH, info.badColorEN))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("📅 \(formattedDate)")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("🔮 \(fortuneText)")
                .foregroundColor(.white)
            
            Text("✅ \(language.localized("สีมงคล", "Lucky Color")): \(colorInfo.good)")
                .foregroundColor(.white)
            
            Text("⚠️ \(language.localized("ห้ามใช้สี", "Avoid Color")): \(colorInfo.bad)")
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: 600)
        .background(Color.purple.opacity(0.6))
        .cornerRadius(16)
        .shadow(radius: 6)
        .padding(.horizontal)
    }
}

