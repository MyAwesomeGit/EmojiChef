import SwiftUI

// MARK: - Main Game View
struct GameView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.colorScheme) private var colorScheme
    @State private var resetKey = UUID() // Force view recreation on reset
    
    var body: some View {
        VStack(spacing: 0) {
            // Screen Switcher
            Picker("Screen", selection: $gameState.currentScreen) {
                Text("Character").tag(GameState.GameScreen.characterSelection)
                Text("Memory Game").tag(GameState.GameScreen.memoryGame)
                    .disabled(gameState.selectedCharacter == nil)
                Text("Mix Food").tag(GameState.GameScreen.mixingGame)
                    .disabled(!gameState.memoryGameCompleted)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Character Display
            if let character = gameState.selectedCharacter {
                HStack {
                    Text("Character: \(character.emoji)")
                        .font(.title2)
                    Spacer()
                    Text("Ingredients: \(gameState.collectedIngredients.count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.surfaceBackground(for: colorScheme))
                        .cornerRadius(8)
                    Text("Recipes: \(gameState.createdRecipes.count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.surfaceBackground(for: colorScheme))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            
            // Screen Content
            switch gameState.currentScreen {
            case .characterSelection:
                CharacterSelectionView()
            case .memoryGame:
                MemoryGameView()
                    .id(resetKey) // Force view recreation on reset
            case .mixingGame:
                MixingGameView(gameState: gameState)
                    .id(resetKey) // Force view recreation on reset
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("EmojiChef")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Reset") {
                    gameState.resetGame()
                    resetKey = UUID() // Force all child views to recreate
                }
                .foregroundColor(.red)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: GameState.gameDidResetNotification)) { _ in
            resetKey = UUID() // Force view recreation when reset notification is received
        }
    }
}
