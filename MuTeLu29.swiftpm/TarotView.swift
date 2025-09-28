import SwiftUI

struct TarotView: View {
    let tarotCards = ["The Fool", "The Magician", "The Lovers", "The Star", "Death", "Strength", "Wheel of Fortune"]
    @State private var drawnCard: String?
    
    var body: some View {
        VStack(spacing: 20) {
            BackButton()
            Text("🃏 ดูดวงไพ่ทาโร่")
                .font(.title2)
                .fontWeight(.bold)
            
            Button("สุ่มไพ่ 1 ใบ") {
                drawnCard = tarotCards.randomElement()
            }
            .padding()
            .background(.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            if let card = drawnCard {
                Text("คุณได้ไพ่: \(card)")
                    .font(.title3)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
    }
}
