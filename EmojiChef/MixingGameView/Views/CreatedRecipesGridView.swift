import SwiftUI

// Created Recipes Grid Component
struct CreatedRecipesGridView: View {
    let createdRecipes: Set<String>
    
    var body: some View {
        VStack(alignment: .leading) {
            if !createdRecipes.isEmpty {
                Text("Your Dishes:")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                    ForEach(Array(createdRecipes), id: \.self) { recipeName in
                        if let recipe = Recipe.availableRecipes.first(where: { $0.name == recipeName }) {
                            CreatedRecipeItemView(recipe: recipe)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}
