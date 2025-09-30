import SwiftUI

struct OfferingGameView: View {
    @StateObject private var viewModel = OfferingGameViewModel()
    
    var body: some View {
        VStack {
            Text("ด่านที่ \(viewModel.currentOfferingLevel.level)")
                .font(.title2)
                .bold()
            
            Text("งบประมาณ: \(viewModel.currentOfferingLevel.budget) บาท")
            Text("ใช้ไปแล้ว: \(viewModel.usedBudget) บาท")
                .foregroundColor(viewModel.usedBudget > viewModel.currentOfferingLevel.budget ? .red : .primary)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(sampleOfferingItems) { item in
                        VStack {
                            Image(systemName: item.imageName)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            
                            Text(item.name)
                            Text("฿\(item.price)")
                                .font(.caption)
                        }
                        .onTapGesture {
                            viewModel.addItem(item)
                        }
                    }
                }
            }
            .padding()
            
            Divider()
            
            Text("🧺 ตะกร้าสังฆทาน")
                .font(.headline)
            
            ForEach(viewModel.basket) { item in
                HStack {
                    Image(systemName: item.imageName)
                    Text(item.name)
                    Spacer()
                    Text("฿\(item.price)")
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            HStack {
                Button("รีเซ็ต") {
                    viewModel.resetBasket()
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Button("ตรวจสอบ") {
                    if viewModel.checkResult() {
                        viewModel.goToNextLevel()
                    }
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
