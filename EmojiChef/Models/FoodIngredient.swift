import Foundation

// MARK: - Data Models
struct FoodIngredient: Identifiable, Codable, Hashable {
    let id = UUID()
    let emoji: String
    let name: String
    
    static let allIngredients: [FoodIngredient] = [
        FoodIngredient(emoji: "🍅", name: "Tomato"),
        FoodIngredient(emoji: "🧀", name: "Cheese"),
        FoodIngredient(emoji: "🥬", name: "Lettuce"),
        FoodIngredient(emoji: "🍞", name: "Bread"),
        FoodIngredient(emoji: "🥩", name: "Meat"),
        FoodIngredient(emoji: "🍄", name: "Mushroom"),
        FoodIngredient(emoji: "🧅", name: "Onion"),
        FoodIngredient(emoji: "🥚", name: "Egg")
    ]
}
