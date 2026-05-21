import SwiftUI

// MARK: - Memory Game View
struct MemoryGameView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.colorScheme) private var colorScheme
    @State private var cards: [MemoryCard] = []
    @State private var flippedIndices: Set<Int> = []
    @State private var matchedPairs: Set<String> = []
    @State private var isProcessing = false
    
    struct MemoryCard: Identifiable {
        let id = UUID()
        let ingredient: FoodIngredient
        var isMatched: Bool = false
    }
    
    // Use 4 columns for 16 cards (8 pairs)
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    
    var body: some View {
        ScrollView {
            VStack {
                if gameState.memoryGameCompleted {
                    VStack(spacing: 20) {
                        Text("🎉 Memory Game Complete! 🎉")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                        
                        Text("You collected all 8 ingredients!")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Pairs found: \(matchedPairs.count)/8")
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
                                setupGame()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                        }
                    }
                    .padding()
                } else {
                    VStack(spacing: 10) {
                        Text("Match the Food Pairs!")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Found: \(matchedPairs.count)/8 pairs")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                                CardView(
                                    emoji: card.ingredient.emoji,
                                    isFlipped: flippedIndices.contains(index) || card.isMatched,
                                    isMatched: card.isMatched
                                ) {
                                    flipCard(at: index)
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                }
            }
        }
        .onAppear {
            if cards.isEmpty {
                setupGame()
            }
        }
    }
    
    func setupGame() {
        // Use ALL 8 ingredients for 8 pairs (16 cards)
        let selectedIngredients = FoodIngredient.allIngredients // All 8 ingredients
        var newCards: [MemoryCard] = []
        
        // Create pairs for each ingredient
        for ingredient in selectedIngredients {
            newCards.append(MemoryCard(ingredient: ingredient))
            newCards.append(MemoryCard(ingredient: ingredient))
        }
        
        cards = newCards.shuffled()
        flippedIndices = []
        matchedPairs = []
        gameState.collectedIngredients = []
        gameState.memoryGameCompleted = false
    }
    
    func flipCard(at index: Int) {
        guard !isProcessing,
              !flippedIndices.contains(index),
              !cards[index].isMatched,
              flippedIndices.count < 2 else { return }
        
        flippedIndices.insert(index)
        
        if flippedIndices.count == 2 {
            isProcessing = true
            let indices = Array(flippedIndices)
            let card1 = cards[indices[0]]
            let card2 = cards[indices[1]]
            
            if card1.ingredient.name == card2.ingredient.name {
                // Match found!
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    cards[indices[0]].isMatched = true
                    cards[indices[1]].isMatched = true
                    matchedPairs.insert(card1.ingredient.name)
                    gameState.collectedIngredients.insert(card1.ingredient.name)
                    flippedIndices.removeAll()
                    isProcessing = false
                    
                    // Check if game is complete (all 8 pairs found)
                    if matchedPairs.count == 8 {
                        gameState.memoryGameCompleted = true
                    }
                }
            } else {
                // No match
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    flippedIndices.removeAll()
                    isProcessing = false
                }
            }
        }
    }
}
