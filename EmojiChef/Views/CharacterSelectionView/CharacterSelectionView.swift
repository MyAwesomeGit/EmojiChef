import SwiftUI

// MARK: - Character Selection View
struct CharacterSelectionView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Choose Your Character")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            HStack(spacing: 40) {
                ForEach(Character.allCases, id: \.self) { character in
                    Button(action: {
                        gameState.selectedCharacter = character
                        gameState.memoryGameCompleted = false
                        gameState.collectedIngredients = []
                        gameState.currentScreen = .memoryGame
                    }) {
                        VStack {
                            Text(character.emoji)
                                .font(.system(size: 60))
                            Text(character.rawValue)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .frame(width: 100, height: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(gameState.selectedCharacter == character ?
                                      AppColors.selectedCharacter(for: colorScheme) :
                                      AppColors.surfaceBackground(for: colorScheme))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(gameState.selectedCharacter == character ?
                                                Color.blue : Color.clear, lineWidth: 2)
                                )
                        )
                    }
                }
            }
            
            if let character = gameState.selectedCharacter {
                Text("Playing as \(character.emoji) \(character.rawValue)")
                    .font(.title3)
                    .foregroundColor(.primary)
                    .padding()
                    .background(AppColors.surfaceBackground(for: colorScheme))
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
