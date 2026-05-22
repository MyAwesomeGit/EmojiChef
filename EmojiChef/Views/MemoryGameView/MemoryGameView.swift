import SwiftUI

struct MemoryGameView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject private var viewModel = MemoryGameViewModel()
    @State private var isConfigured = false
    
    var body: some View {
        ScrollView {
            if viewModel.isGameCompleted {
                completionView
            } else {
                activeGameView
            }
        }
        .onAppear {
            // Configure only once
            if !isConfigured {
                viewModel.configure(with: gameState)
                isConfigured = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: GameState.gameDidResetNotification)) { _ in
            // This will automatically be handled by the viewModel's observer
            // But we also need to reset the configuration flag
            isConfigured = false
            // Force view to re-render
        }
    }
    
    private var activeGameView: some View {
        VStack(spacing: 10) {
            Text("Match the Food Pairs!")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Found: \(viewModel.matchedPairs.count)/8 pairs")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: viewModel.columns, spacing: 8) {
                ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                    CardView(
                        emoji: card.ingredient.emoji,
                        isFlipped: viewModel.flippedIndices.contains(index) || card.isMatched,
                        isMatched: card.isMatched
                    ) {
                        viewModel.flipCard(at: index)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 20) {
            Text("🎉 Memory Game Complete! 🎉")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            
            Text("You collected all 8 ingredients!")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Pairs found: \(viewModel.matchedPairs.count)/8")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(Array(gameState.collectedIngredients), id: \.self) { ingredient in
                    if let food = FoodIngredient.allIngredients.first(where: { $0.name == ingredient }) {
                        VStack {
                            Text(food.emoji)
                                .font(.largeTitle)
                            Text(food.name)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
            .background(AppColors.surfaceBackground(for: colorScheme))
            .cornerRadius(10)
            
            HStack(spacing: 20) {
                Button("Go to Mix Food") {
                    gameState.currentScreen = .mixingGame
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("Play Again") {
                    // This will reset the viewModel and trigger a full reset
                    viewModel.setupGame()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding()
    }
    
    @Environment(\.colorScheme) private var colorScheme
}
