import SwiftUI

// Ingredient Grid Component
struct IngredientGridView: View {
    let ingredients: Set<String>
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Your Ingredients: (\(ingredients.count)/8)")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(Array(ingredients), id: \.self) { ingredient in
                    if let food = FoodIngredient.allIngredients.first(where: { $0.name == ingredient }) {
                        IngredientItemView(food: food)
                    }
                }
            }
        }
        .padding()
        .background(AppColors.surfaceBackground(for: colorScheme))
        .cornerRadius(10)
    }
}
