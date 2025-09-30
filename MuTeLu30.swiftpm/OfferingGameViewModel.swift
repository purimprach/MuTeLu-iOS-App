import Foundation
import SwiftUI

class OfferingGameViewModel: ObservableObject {
    @Published var basket: [OfferingItem] = []
    @Published var currentLevel = 0
    
    var currentOfferingLevel: OfferingLevel {
        offeringLevels[currentLevel]
    }
    
    var usedBudget: Int {
        basket.reduce(0) { $0 + $1.price }
    }
    
    var remainingBudget: Int {
        currentOfferingLevel.budget - usedBudget
    }
    
    func addItem(_ item: OfferingItem) {
        if usedBudget + item.price <= currentOfferingLevel.budget {
            basket.append(item)
        }
    }
    
    func resetBasket() {
        basket.removeAll()
    }
    
    func checkResult() -> Bool {
        let appropriateCount = basket.filter { $0.isAppropriate }.count
        return appropriateCount >= currentOfferingLevel.minAppropriateCount
    }
    
    func goToNextLevel() {
        if currentLevel + 1 < offeringLevels.count {
            currentLevel += 1
            resetBasket()
        }
    }
}
