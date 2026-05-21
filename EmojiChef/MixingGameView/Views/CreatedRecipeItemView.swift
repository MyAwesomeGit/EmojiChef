import SwiftUI

// Individual Created Recipe Item
struct CreatedRecipeItemView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack {
            Text(recipe.emoji)
                .font(.largeTitle)
            Text(recipe.name)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.green.opacity(0.15))
        .cornerRadius(10)
    }
}
