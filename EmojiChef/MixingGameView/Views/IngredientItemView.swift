import SwiftUI

// Individual Ingredient Item
struct IngredientItemView: View {
    let food: FoodIngredient
    
    var body: some View {
        VStack {
            Text(food.emoji)
                .font(.largeTitle)
            Text(food.name)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
