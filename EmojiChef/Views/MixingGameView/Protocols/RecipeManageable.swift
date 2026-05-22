import SwiftUI

// MARK: - Recipe Management Protocol (Interface Segregation)
protocol RecipeManageable {
    func findRecipe(for ingredients: Set<String>) -> Recipe?
    func createRecipe(_ recipe: Recipe, in gameState: GameState) -> String
    func canLeadToRecipe(_ ingredients: Set<String>) -> Bool
    func isRecipeCreated(_ recipe: Recipe, createdRecipes: Set<String>) -> Bool
}
