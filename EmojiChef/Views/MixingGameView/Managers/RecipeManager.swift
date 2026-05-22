import SwiftUI

class RecipeManager: RecipeManageable {
    func findRecipe(for ingredients: Set<String>) -> Recipe? {
        Recipe.availableRecipes.first { recipe in
            recipe.ingredients.count == ingredients.count &&
            recipe.ingredients.allSatisfy { ingredients.contains($0) }
        }
    }
    
    func createRecipe(_ recipe: Recipe, in gameState: GameState) -> String {
        // Prevent duplicate recipe creation
        guard !gameState.createdRecipes.contains(recipe.name) else {
            return "You already made \(recipe.emoji) \(recipe.name)!"
        }
        
        gameState.createdRecipes.insert(recipe.name)
        gameState.saveGame()
        return "You created \(recipe.emoji) \(recipe.name)!"
    }
    
    func canLeadToRecipe(_ ingredients: Set<String>) -> Bool {
        // Check if current ingredients can lead to any recipe
        Recipe.availableRecipes.contains { recipe in
            ingredients.allSatisfy { recipe.ingredients.contains($0) }
        }
    }
    
    func isRecipeCreated(_ recipe: Recipe, createdRecipes: Set<String>) -> Bool {
        createdRecipes.contains(recipe.name)
    }
}
