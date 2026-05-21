import SwiftUI

// Recipe Card Content (Separated for clarity)
struct RecipeCardContent: View {
    let recipe: Recipe
    let canMake: Bool
    let alreadyMade: Bool
    
    var body: some View {
        HStack {
            Text(recipe.emoji)
                .font(.largeTitle)
            
            RecipeInfoView(recipe: recipe)
            
            Spacer()
            
            RecipeStatusView(canMake: canMake, alreadyMade: alreadyMade)
        }
    }
}
