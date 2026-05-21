import SwiftUI

// Recipe Card Component
struct RecipeCardView: View {
    let recipe: Recipe
    let canMake: Bool
    let alreadyMade: Bool
    let onMake: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: {
            if canMake && !alreadyMade {
                onMake()
            }
        }) {
            RecipeCardContent(
                recipe: recipe,
                canMake: canMake,
                alreadyMade: alreadyMade
            )
            .padding()
            .background(recipeCardBackground)
            .cornerRadius(10)
        }
        .disabled(!canMake || alreadyMade)
    }
    
    private var recipeCardBackground: some View {
        if alreadyMade {
            return Color.green.opacity(0.15)
        } else if canMake {
            return Color.blue.opacity(0.15)
        } else {
            return AppColors.surfaceBackground(for: colorScheme)
        }
    }
}
