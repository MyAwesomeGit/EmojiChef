import SwiftUI

// MARK: - Refactored MixingGameView (Open/Closed Principle)
struct MixingGameView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingRecipeAlert = false
    @State private var recipeMessage = ""
    
    // Dependency Injection (Dependency Inversion)
    private let recipeManager: RecipeManageable
    
    init(recipeManager: RecipeManageable = RecipeManager()) {
        self.recipeManager = recipeManager
    }
    
    // Computed properties for cleaner logic
    private var availableRecipes: [Recipe] {
        Recipe.availableRecipes.filter { recipe in
            recipeManager.canMakeRecipe(recipe, with: gameState.collectedIngredients)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                ingredientSection
                recipeSection
                createdRecipesSection
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .recipeAlert(isPresented: $showingRecipeAlert, message: recipeMessage)
    }
    
    // MARK: - View Components (Single Responsibility for each)
    
    private var headerView: some View {
        Text("Mix Your Ingredients!")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.primary)
    }
    
    private var ingredientSection: some View {
        IngredientGridView(ingredients: gameState.collectedIngredients)
    }
    
    private var recipeSection: some View {
        VStack(alignment: .leading) {
            Text("Available Recipes:")
                .font(.headline)
                .foregroundColor(.primary)
            
            ForEach(Recipe.availableRecipes) { recipe in
                RecipeCardView(
                    recipe: recipe,
                    canMake: recipeManager.canMakeRecipe(recipe, with: gameState.collectedIngredients),
                    alreadyMade: recipeManager.isRecipeCreated(recipe, createdRecipes: gameState.createdRecipes),
                    onMake: { makeRecipe(recipe) }
                )
            }
        }
    }
    
    private var createdRecipesSection: some View {
        CreatedRecipesGridView(createdRecipes: gameState.createdRecipes)
    }
    
    // MARK: - Actions
    private func makeRecipe(_ recipe: Recipe) {
        let message = recipeManager.createRecipe(recipe, in: gameState)
        recipeMessage = message
        showingRecipeAlert = true
    }
}
