import Foundation

enum Character: String, Codable, CaseIterable {
    case dog = "Dog"
    case toddler = "Toddler"
    case frog = "Frog"
    
    var emoji: String {
        switch self {
        case .dog: return "🐶"
        case .toddler: return "👶"
        case .frog: return "🐸"
        }
    }
}
