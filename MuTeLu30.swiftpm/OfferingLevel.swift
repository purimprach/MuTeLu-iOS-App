import Foundation

struct OfferingLevel {
    let level: Int
    let budget: Int
    let minAppropriateCount: Int
}

let offeringLevels: [OfferingLevel] = [
    OfferingLevel(level: 1, budget: 100, minAppropriateCount: 2),
    OfferingLevel(level: 2, budget: 150, minAppropriateCount: 3)
]
