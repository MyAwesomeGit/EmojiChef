import SwiftUI

// MARK: - Recipe Management Protocol (Interface Segregation)
protocol RecipeManageable {
    func canMakeRecipe(_ recipe: Recipe, with ingredients: Set<String>) -> Bool
    func isRecipeCreated(_ recipe: Recipe, createdRecipes: Set<String>) -> Bool
    func createRecipe(_ recipe: Recipe, in gameState: GameState) -> String
}
