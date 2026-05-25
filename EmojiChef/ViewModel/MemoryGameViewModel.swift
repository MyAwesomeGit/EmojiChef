import SwiftUI
import Combine

class MemoryGameViewModel: ObservableObject {
    // MARK: - Types
    struct MemoryCard: Identifiable {
        let id = UUID()
        let ingredient: FoodIngredient
        var isMatched = false
    }
    
    // MARK: - Constants
    private enum Constants {
        static let targetPairsCount = 8
        static let matchDelay: TimeInterval = 0.5
        static let mismatchDelay: TimeInterval = 1.0
        static let columnsCount = 4
    }
    
    // MARK: - Published Properties
    @Published private(set) var cards: [MemoryCard] = []
    @Published private(set) var matchedPairs: Set<String> = []
    @Published private(set) var isGameCompleted = false
    @Published private(set) var isProcessing = false
    @Published private(set) var flippedIndices: Set<Int> = []
    
    // MARK: - Dependencies
    private var gameStateUpdater: GameStateUpdater?
    private var isConfigured = false
    
    // MARK: - Initialization
    init() {
        // No setup here – it will be done in configure(with:)
    }
    
    // MARK: - Configuration (must be called before use)
    func configure(with updater: GameStateUpdater) {
        guard !isConfigured else { return }
        self.gameStateUpdater = updater
        isConfigured = true
        
        // If the game was already completed in GameState, restore it
        if updater.isMemoryGameCompleted() {
            restoreCompletedGame()
        } else {
            setupGame()
        }
    }
    
    // MARK: - Public Methods
    func setupGame() {
        let allIngredients = FoodIngredient.allIngredients
        var newCards: [MemoryCard] = []
        
        for ingredient in allIngredients {
            newCards.append(MemoryCard(ingredient: ingredient))
            newCards.append(MemoryCard(ingredient: ingredient))
        }
        
        cards = newCards.shuffled()
        flippedIndices = []
        matchedPairs = []
        isGameCompleted = false
        isProcessing = false
        
        gameStateUpdater?.resetMemoryGameProgress()
    }
    
    func flipCard(at index: Int) {
        guard !isProcessing,
              !flippedIndices.contains(index),
              !cards[index].isMatched,
              flippedIndices.count < 2 else { return }
        
        flippedIndices.insert(index)
        
        if flippedIndices.count == 2 {
            handleCardMatch()
        }
    }
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: Constants.columnsCount)
    }
    
    // MARK: - Private Logic
    private func handleCardMatch() {
        isProcessing = true
        let indices = Array(flippedIndices)
        let card1 = cards[indices[0]]
        let card2 = cards[indices[1]]
        
        if card1.ingredient.name == card2.ingredient.name {
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.matchDelay) { [weak self] in
                self?.applyMatch(at: indices)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.mismatchDelay) { [weak self] in
                self?.resetFlippedCards()
            }
        }
    }
    
    private func applyMatch(at indices: [Int]) {
        guard indices.count == 2 else { return }
        
        cards[indices[0]].isMatched = true
        cards[indices[1]].isMatched = true
        
        let matchedIngredient = cards[indices[0]].ingredient
        matchedPairs.insert(matchedIngredient.name)
        
        gameStateUpdater?.addCollectedIngredient(matchedIngredient.name)
        
        flippedIndices.removeAll()
        isProcessing = false
        
        if matchedPairs.count == Constants.targetPairsCount {
            isGameCompleted = true
            gameStateUpdater?.completeMemoryGame()
        }
    }
    
    private func resetFlippedCards() {
        flippedIndices.removeAll()
        isProcessing = false
    }
    
    private func restoreCompletedGame() {
        // Restore the state from GameState (which already has all ingredients)
        let allIngredients = FoodIngredient.allIngredients
        var newCards: [MemoryCard] = []
        
        for ingredient in allIngredients {
            newCards.append(MemoryCard(ingredient: ingredient, isMatched: true))
            newCards.append(MemoryCard(ingredient: ingredient, isMatched: true))
        }
        
        cards = newCards.shuffled()
        flippedIndices = []
        matchedPairs = Set(allIngredients.map { $0.name })
        isGameCompleted = true
        isProcessing = false
        
        // No need to call updater methods – the game is already completed
    }
}

// MARK: - Helper extension for GameStateUpdater
extension GameStateUpdater {
    func isMemoryGameCompleted() -> Bool {
        // This method is not part of the protocol, so we need to cast.
        // But we can rely on the concrete GameState implementation.
        // Alternatively, we can extend the protocol with a default implementation.
        // For simplicity, we assume the updater is a GameState object.
        if let gameState = self as? GameState {
            return gameState.memoryGameCompleted
        }
        return false
    }
}
