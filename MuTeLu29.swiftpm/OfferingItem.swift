import Foundation

struct OfferingItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String
    let price: Int
    let isAppropriate: Bool
}

let sampleOfferingItems: [OfferingItem] = [
    OfferingItem(name: "สบู่", imageName: "soap", price: 20, isAppropriate: true),
    OfferingItem(name: "ยาสีฟัน", imageName: "toothpaste", price: 25, isAppropriate: true),
    OfferingItem(name: "บุหรี่", imageName: "cigarette", price: 45, isAppropriate: false),
    OfferingItem(name: "แชมพู", imageName: "shampoo", price: 30, isAppropriate: true),
    OfferingItem(name: "เบียร์", imageName: "beer", price: 60, isAppropriate: false),
    OfferingItem(name: "ผ้าเช็ดตัว", imageName: "towel", price: 50, isAppropriate: true)
]
