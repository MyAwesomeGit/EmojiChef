import SwiftUI
internal import UniformTypeIdentifiers
import Combine

// MARK: - ViewModel for Mixing Game Logic
class MixingGameViewModel: ObservableObject {
    
    // MARK: - Types
    enum AlertType {
        case recipeSuccess(message: String)
        case recipeError(message: String)
        
        var title: String {
            switch self {
            case .recipeSuccess: return "Cooking Result"
            case .recipeError: return "No Recipe Found"
            }
        }
        
        var message: String {
            switch self {
            case .recipeSuccess(let msg), .recipeError(let msg): return msg
            }
        }
    }
    
    // MARK: - Published Properties (UI State)
    @Published private(set) var bowlIngredients: Set<String> = []
    @Published var isAlertPresented: Bool = false
    @Published private(set) var alertType: AlertType?
    @Published private(set) var canClearBowl: Bool = false
    @Published private(set) var ingredientCount: Int = 0
    
    // MARK: - Dependencies
    private let gameState: GameState
    private let recipeManager: RecipeManageable
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(
        gameState: GameState,
        recipeManager: RecipeManageable = RecipeManager()
    ) {
        self.gameState = gameState
        self.recipeManager = recipeManager
        
        // Observe ingredient count for UI updates
        $bowlIngredients
            .map { $0.count }
            .assign(to: \.ingredientCount, on: self)
            .store(in: &cancellables)
        
        $bowlIngredients
            .map { !$0.isEmpty }
            .assign(to: \.canClearBowl, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Actions
    
    /// Adds an ingredient to the bowl if valid
    func addIngredient(_ ingredient: String) {
        guard gameState.collectedIngredients.contains(ingredient) else { return }
        guard !bowlIngredients.contains(ingredient) else { return }
        
        bowlIngredients.insert(ingredient)
        validateBowlContents()
    }
    
    /// Removes an ingredient from the bowl
    func removeIngredient(_ ingredient: String) {
        bowlIngredients.remove(ingredient)
    }
    
    /// Clears all ingredients from the bowl
    func clearBowl() {
        bowlIngredients.removeAll()
    }
    
    /// Handles drop from drag-and-drop interaction
    func handleDrop(_ providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] (item, error) in
                guard let self = self, error == nil else { return }
                
                DispatchQueue.main.async {
                    let ingredient: String? = {
                        if let data = item as? Data {
                            return String(data: data, encoding: .utf8)
                        } else if let string = item as? String {
                            return string
                        } else if let nsString = item as? NSString {
                            return nsString as String
                        }
                        return nil
                    }()
                    
                    if let ingredient = ingredient {
                        self.addIngredient(ingredient)
                    }
                }
            }
        }
    }
    
    // MARK: - Private Logic
    
    private func validateBowlContents() {
        if let recipe = recipeManager.findRecipe(for: bowlIngredients) {
            handleRecipeMatch(recipe)
            return
        }
        
        if recipeManager.canLeadToRecipe(bowlIngredients) {
            return
        }
        
        if bowlIngredients.count >= 2 {
            let message = bowlIngredients.count >= 3
                ? "No recipe found with these ingredients. Try a different combination (max 3 ingredients)."
                : "No recipe found with these ingredients. Keep experimenting!"
            
            showAlert(.recipeError(message: message))
        }
    }
    
    private func handleRecipeMatch(_ recipe: Recipe) {
        if recipeManager.isRecipeCreated(recipe, createdRecipes: gameState.createdRecipes) {
            showAlert(.recipeError(
                message: "You already made \(recipe.emoji) \(recipe.name)! Try a different combination."
            ))
            clearBowl()
            return
        }
        
        let message = recipeManager.createRecipe(recipe, in: gameState)
        showAlert(.recipeSuccess(message: message))
        clearBowl()
    }
    
    private func showAlert(_ alert: AlertType) {
        alertType = alert
        isAlertPresented = true
    }
    
    /// Dismisses the currently presented alert
    func dismissAlert() {
        isAlertPresented = false
        alertType = nil
    }
    
    // MARK: - Computed Properties for View Binding
    
    var availableIngredients: [FoodIngredient] {
        gameState.collectedIngredients.compactMap { name in
            FoodIngredient.allIngredients.first { $0.name == name }
        }
    }
    
    var bowlFoodItems: [FoodIngredient] {
        bowlIngredients.compactMap { name in
            FoodIngredient.allIngredients.first { $0.name == name }
        }
    }
    
    var createdRecipesList: [Recipe] {
        gameState.createdRecipes.compactMap { name in
            Recipe.availableRecipes.first { $0.name == name }
        }
    }
}
