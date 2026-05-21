import SwiftUI

// Recipe Info Component
struct RecipeInfoView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(recipe.name)
                .font(.headline)
                .foregroundColor(.primary)
            Text(recipe.ingredients.joined(separator: " + "))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
