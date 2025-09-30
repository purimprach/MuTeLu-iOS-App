import SwiftUI

struct PhoneFortuneView: View {
    @State private var phoneNumber: String = ""
    @State private var resultPairs: [String] = []
    @State private var errorMessage: String?
    @State private var isConfirmed: Bool = false
    @State private var showAlert = false
    
    @EnvironmentObject var language: AppLanguage
    @EnvironmentObject var flow: MuTeLuFlowManager
    
    let buttons = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["⌫", "0", "✓"]
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            BackButton()
            // Title
            Text("📱 " + language.localized("ทำนายเบอร์โทรศัพท์", "Phone Number Fortune"))
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            // Phone display
            Text(formattedPhone())
                .font(.system(size: 28, weight: .medium, design: .monospaced))
                .frame(maxWidth: .infinity, minHeight: 50)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .purple.opacity(0.7), radius: 3, x: 0, y: 2)
                )
                .padding(.horizontal)
            
            // Error
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            // Keypad
            if !isConfirmed {
                VStack(spacing: 15) {
                    ForEach(buttons, id: \.self) { row in
                        HStack(spacing: 20) {
                            ForEach(row, id: \.self) { item in
                                Button(action: {
                                    handleInput(item)
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(.systemGray6))
                                            .frame(width: 65, height: 65)
                                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                        Text(item)
                                            .font(.title2)
                                            .foregroundColor(.purple)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Predict button
                    Button(action: {
                        handleInput("✓")
                    }) {
                        Label(language.localized("ทำนาย", "Predict"), systemImage: "sparkles")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.purple)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .disabled(phoneNumber.count != 10)
                    .opacity(phoneNumber.count == 10 ? 1 : 0.5)
                    .padding(.horizontal)
                }
            }
            
            // Results
            if isConfirmed {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(resultPairs, id: \.self) { pair in
                        Text(pair)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
                .padding(.horizontal)
                
                // Try another number
                Button(action: {
                    phoneNumber = ""
                    resultPairs = []
                    errorMessage = nil
                    isConfirmed = false
                }) {
                    Label(language.localized("ลองเบอร์อื่น", "Try another number"), systemImage: "arrow.clockwise")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.purple)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .alert(language.localized("ไม่สามารถทำนายได้", "Prediction Failed"), isPresented: $showAlert) {
            Button(language.localized("ตกลง", "OK"), role: .cancel) { }
        } message: {
            Text(language.localized("กรุณากรอกเบอร์โทรให้ครบ 10 หลัก", "Please enter a valid 10-digit number"))
        }
    }
    
    func formattedPhone() -> String {
        if phoneNumber.count <= 3 {
            return phoneNumber
        } else {
            let prefix = phoneNumber.prefix(3)
            let suffix = phoneNumber.dropFirst(3)
            return "\(prefix)-\(suffix)"
        }
    }
    
    func handleInput(_ input: String) {
        switch input {
        case "⌫":
            if !phoneNumber.isEmpty {
                phoneNumber.removeLast()
                isConfirmed = false
                errorMessage = nil
                resultPairs = []
            }
        case "✓":
            if phoneNumber.count == 10 {
                let last7 = String(phoneNumber.suffix(7))
                let pairs = zip(last7, last7.dropFirst()).map { String([$0, $1]) }.prefix(6)
                let meanings = NumberMeaningLoader.loadMeanings(language: language.currentLanguage)
                resultPairs = pairs.map {
                    "\($0)  ▶️  \(meanings[$0] ?? language.localized("ไม่พบคำทำนาย", "No prediction found"))"
                }
                errorMessage = nil
                isConfirmed = true
            } else {
                isConfirmed = false
                resultPairs = []
                showAlert = true
            }
        default:
            if phoneNumber.count < 10 {
                phoneNumber.append(input)
                isConfirmed = false
                errorMessage = nil
                resultPairs = []
            }
        }
    }
}
