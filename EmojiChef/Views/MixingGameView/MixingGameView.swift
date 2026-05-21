import SwiftUI
internal import UniformTypeIdentifiers

struct MixingGameView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingRecipeAlert = false
    @State private var recipeMessage = ""
    @State private var bowlIngredients: Set<String> = []
    @State private var dragOverBowl = false
    @State private var draggedIngredient: String? = nil
    @State private var showInvalidFeedback = false
    @State private var invalidMessage = ""
    
    private let recipeManager: RecipeManageable
    
    init(recipeManager: RecipeManageable = RecipeManager()) {
        self.recipeManager = recipeManager
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                headerView
                ingredientGrid
                mixingBowl
                createdRecipesSection
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .recipeAlert(isPresented: $showingRecipeAlert, message: recipeMessage)
        .alert("No Recipe Found", isPresented: $showInvalidFeedback) {
            Button("OK") {}
        } message: {
            Text(invalidMessage)
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        Text("Mix Your Ingredients!")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.primary)
    }
    
    // MARK: - Ingredient Grid (Draggable)
    private var ingredientGrid: some View {
        VStack(alignment: .leading) {
            Text("Your Ingredients: (\(gameState.collectedIngredients.count)/8)")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(Array(gameState.collectedIngredients), id: \.self) { ingredient in
                    if let food = FoodIngredient.allIngredients.first(where: { $0.name == ingredient }) {
                        IngredientItemView(food: food)
                            .onDrag {
                                self.draggedIngredient = ingredient
                                return NSItemProvider(object: ingredient as NSString)
                            }
                    }
                }
            }
        }
        .padding()
        .background(AppColors.surfaceBackground(for: colorScheme))
        .cornerRadius(10)
    }
    
    // MARK: - Mixing Bowl (Drop Target)
    private var mixingBowl: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mixing Bowl")
                .font(.headline)
                .foregroundColor(.primary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(dragOverBowl ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(dragOverBowl ? Color.blue : Color.gray.opacity(0.5), lineWidth: 2)
                    )
                    .frame(minHeight: 120)
                    .onDrop(of: [UTType.plainText.identifier], isTargeted: $dragOverBowl) { providers in
                        handleDrop(providers: providers)
                        return true
                    }
                
                if bowlIngredients.isEmpty {
                    Text("Drag ingredients here to combine")
                        .foregroundColor(.secondary)
                } else {
                    VStack(spacing: 8) {
                        HStack(spacing: 12) {
                            ForEach(Array(bowlIngredients), id: \.self) { ingredient in
                                if let food = FoodIngredient.allIngredients.first(where: { $0.name == ingredient }) {
                                    VStack {
                                        Text(food.emoji)
                                            .font(.title)
                                        Text(food.name)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(6)
                                    .background(Color.white.opacity(0.6))
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        bowlIngredients.remove(ingredient)
                                    }
                                }
                            }
                        }
                        Text("Tap an ingredient to remove it")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            
            HStack {
                Button("Clear Bowl") {
                    bowlIngredients.removeAll()
                }
                .buttonStyle(.bordered)
                .disabled(bowlIngredients.isEmpty)
                
                Spacer()
                
                Text("\(bowlIngredients.count) ingredient(s)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(AppColors.surfaceBackground(for: colorScheme))
        .cornerRadius(10)
    }
    
    // MARK: - Created Recipes
    private var createdRecipesSection: some View {
        CreatedRecipesGridView(createdRecipes: gameState.createdRecipes)
    }
    
    // MARK: - Drop Handling
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            // Use explicit UTType for plain text
            provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { (item, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Drop error: \(error.localizedDescription)")
                        return
                    }
                    
                    // Try to get string from Data or directly
                    if let data = item as? Data,
                       let ingredient = String(data: data, encoding: .utf8) {
                        self.addIngredientToBowl(ingredient)
                    } else if let string = item as? String {
                        self.addIngredientToBowl(string)
                    } else {
                        // Fallback: try to get from item as NSString
                        if let nsString = item as? NSString {
                            self.addIngredientToBowl(nsString as String)
                        }
                    }
                }
            }
        }
    }
    
    private func addIngredientToBowl(_ ingredient: String) {
        guard gameState.collectedIngredients.contains(ingredient) else { return }
        guard !bowlIngredients.contains(ingredient) else { return }
        
        bowlIngredients.insert(ingredient)
        
        // Check if bowl contents match a recipe exactly
        if let recipe = recipeManager.findRecipe(for: bowlIngredients) {
            // Recipe found – create it
            let message = recipeManager.createRecipe(recipe, in: gameState)
            recipeMessage = message
            showingRecipeAlert = true
            bowlIngredients.removeAll()
            return
        }
        
        // Check if current ingredients are a subset of any recipe
        let isSubsetOfAnyRecipe = Recipe.availableRecipes.contains { recipe in
            bowlIngredients.allSatisfy { recipe.ingredients.contains($0) }
        }
        
        if isSubsetOfAnyRecipe {
            // Still possible to complete a recipe – do nothing, let player continue
            return
        }
        
        // No recipe uses these ingredients together – show feedback
        if bowlIngredients.count >= 2 {
            if bowlIngredients.count >= 3 {
                invalidMessage = "No recipe found with these ingredients. Try a different combination (max 3 ingredients)."
            } else {
                invalidMessage = "No recipe found with these ingredients. Keep experimenting!"
            }
            showInvalidFeedback = true
        }
    }
}
