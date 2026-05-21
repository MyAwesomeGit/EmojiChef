import Foundation

// MARK: - Protocol for updating GameState (Interface Segregation)
protocol GameStateUpdater {
    func addCollectedIngredient(_ ingredient: String)
    func completeMemoryGame()
    func resetMemoryGameProgress()
}
