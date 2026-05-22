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
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupGame()
        setupResetObserver()
    }
    
    // MARK: - Reset Observer
    private func setupResetObserver() {
        NotificationCenter.default.publisher(for: GameState.gameDidResetNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleAppReset()
            }
            .store(in: &cancellables)
    }
    
    private func handleAppReset() {
        // Force a complete reset of the view model
        setupGame()
        // Clear any game state updater reference
        gameStateUpdater = nil
    }
    
    // MARK: - Configuration
    func configure(with updater: GameStateUpdater) {
        self.gameStateUpdater = updater
        
        // Only sync if game is already completed
        if isGameCompleted {
            // Add all matched pairs as collected ingredients
            for ingredientName in matchedPairs {
                updater.addCollectedIngredient(ingredientName)
            }
        }
    }
    
    // MARK: - Public Methods
    func setupGame() {
        let allIngredients = FoodIngredient.allIngredients
        
        // If we have existing collected ingredients, only use those that aren't matched yet
        // but for a fresh game, use all ingredients
        var newCards: [MemoryCard] = []
        
        // Always start fresh with all ingredients
        for ingredient in allIngredients {
            newCards.append(MemoryCard(ingredient: ingredient))
            newCards.append(MemoryCard(ingredient: ingredient))
        }
        
        cards = newCards.shuffled()
        flippedIndices = []
        matchedPairs = []
        isGameCompleted = false
        isProcessing = false
        
        // Notify updater to reset progress
        gameStateUpdater?.resetMemoryGameProgress()
        
        // Also clear any existing ingredients in game state
        if let updater = gameStateUpdater {
            // Reset memory game progress clears collectedIngredients
            // But we want to ensure a fresh start
            updater.resetMemoryGameProgress()
        }
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
    
    // MARK: - Deinitialization
    deinit {
        cancellables.removeAll()
    }
}
