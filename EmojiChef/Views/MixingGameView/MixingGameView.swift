import SwiftUI
internal import UniformTypeIdentifiers

struct MixingGameView: View {
    @StateObject private var viewModel: MixingGameViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    init(gameState: GameState, recipeManager: RecipeManageable = RecipeManager()) {
        _viewModel = StateObject(
            wrappedValue: MixingGameViewModel(
                gameState: gameState,
                recipeManager: recipeManager
            )
        )
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
        .alert(
            viewModel.alertType?.title ?? "",
            isPresented: $viewModel.isAlertPresented,
            actions: {
                Button("Yummy!") {
                    viewModel.dismissAlert()
                }
            },
            message: {
                Text(viewModel.alertType?.message ?? "")
            }
        )
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
            Text("Your Ingredients: (\(viewModel.availableIngredients.count)/8)")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(viewModel.availableIngredients) { food in
                    IngredientItemView(food: food)
                        .onDrag {
                            NSItemProvider(object: food.name as NSString)
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
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                    )
                    .frame(minHeight: 120)
                    .onDrop(
                        of: [UTType.plainText.identifier],  // ✅ FIXED: Added isTargeted parameter
                        isTargeted: nil
                    ) { providers in
                        viewModel.handleDrop(providers)
                        return true
                    }
                
                if viewModel.bowlIngredients.isEmpty {
                    Text("Drag ingredients here to combine")
                        .foregroundColor(.secondary)
                } else {
                    VStack(spacing: 8) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.bowlFoodItems) { food in
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
                                    viewModel.removeIngredient(food.name)
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
                    viewModel.clearBowl()
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.canClearBowl)
                
                Spacer()
                
                Text("\(viewModel.ingredientCount) ingredient(s)")
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
        CreatedRecipesGridView(createdRecipes: viewModel.createdRecipesList.map { $0.name })
    }
}
