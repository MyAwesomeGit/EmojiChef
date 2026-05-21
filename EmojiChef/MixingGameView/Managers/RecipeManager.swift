import SwiftUI

// MARK: - Recipe Manager (Single Responsibility)
class RecipeManager: RecipeManageable {
    func canMakeRecipe(_ recipe: Recipe, with ingredients: Set<String>) -> Bool {
        recipe.ingredients.allSatisfy { ingredients.contains($0) }
    }
    
    func isRecipeCreated(_ recipe: Recipe, createdRecipes: Set<String>) -> Bool {
        createdRecipes.contains(recipe.name)
    }
    
    func createRecipe(_ recipe: Recipe, in gameState: GameState) -> String {
        gameState.createdRecipes.insert(recipe.name)
        gameState.saveGame()
        return "You created \(recipe.emoji) \(recipe.name)!"
    }
}
