import Foundation

struct Recipe: Identifiable, Codable {
    let id = UUID()
    let name: String
    let emoji: String
    let ingredients: [String]
    
    static let availableRecipes: [Recipe] = [
        Recipe(name: "Sandwich", emoji: "🥪", ingredients: ["Bread", "Lettuce", "Tomato"]),
        Recipe(name: "Omelette", emoji: "🍳", ingredients: ["Egg", "Cheese", "Mushroom"]),
        Recipe(name: "Burger", emoji: "🍔", ingredients: ["Bread", "Meat", "Lettuce"]),
        Recipe(name: "Salad", emoji: "🥗", ingredients: ["Lettuce", "Tomato", "Onion"]),
        Recipe(name: "Steak", emoji: "🥩", ingredients: ["Meat", "Mushroom", "Onion"]),
        Recipe(name: "Cheese Toast", emoji: "🧀", ingredients: ["Bread", "Cheese"]),
        Recipe(name: "Meat Omelette", emoji: "🥘", ingredients: ["Egg", "Meat", "Onion"]),
    ]
}
