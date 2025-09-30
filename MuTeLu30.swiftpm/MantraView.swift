import SwiftUI

struct MantraView: View {
    let mantras = [
        "พุทโธ ธัมโม สังโฆ ✨",
        "นะโม ตัสสะ ภะคะวะโต 🔔",
        "โอม มณี ปัทเม ฮุม 🕉️",
        "นะมะพะทะ เสริมโชคลาภ 💰",
        "อิทธิฤทธิ์ ปาฏิหาริย์ มหาลาภ 🌟"
    ]
    
    @State private var selectedMantra: String?
    
    var body: some View {
        VStack(spacing: 20) {
            BackButton()
            Text("🔮 สุ่มคาถาประจำวัน")
                .font(.title2)
                .fontWeight(.bold)
            
            Button("สุ่มคาถา") {
                selectedMantra = mantras.randomElement()
            }
            .padding()
            .background(.purple)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            if let mantra = selectedMantra {
                Text(mantra)
                    .font(.title3)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
}
