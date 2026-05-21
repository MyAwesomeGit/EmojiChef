import SwiftUI

// MARK: - Main App
@main
struct CookingGameApp: App {
    @StateObject private var gameState = GameState.loadGame()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                GameView()
                    .environmentObject(gameState)
                    .preferredColorScheme(nil) // Follow system setting
            }
            .onChange(of: gameState.selectedCharacter) { _ in gameState.saveGame() }
            .onChange(of: gameState.collectedIngredients) { _ in gameState.saveGame() }
            .onChange(of: gameState.createdRecipes) { _ in gameState.saveGame() }
            .onChange(of: gameState.currentScreen) { _ in gameState.saveGame() }
            .onChange(of: gameState.memoryGameCompleted) { _ in gameState.saveGame() }
        }
    }
}
