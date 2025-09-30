import SwiftUI

struct CarPlateView: View {
    @State private var plate: String = ""
    @State private var result: String?
    
    var body: some View {
        VStack(spacing: 20) {
            BackButton()
            Text("🚗 ทำนายเลขทะเบียนรถ")
                .font(.title2)
                .fontWeight(.bold)
            
            TextField("กรอกเลขทะเบียน", text: $plate)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            Button("ทำนาย") {
                result = "ทะเบียนนี้เสริมพลังด้านการเดินทางปลอดภัย 🛡️ (Demo)"
            }
            .padding()
            .background(.orange)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            if let result = result {
                Text(result)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
}
