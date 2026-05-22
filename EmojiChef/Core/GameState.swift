import SwiftUI
import Combine

// MARK: - Game State
class GameState: ObservableObject, Codable {
    @Published var selectedCharacter: Character?
    @Published var collectedIngredients: Set<String> = []
    @Published var createdRecipes: Set<String> = []
    @Published var currentScreen: GameScreen = .characterSelection
    @Published var memoryGameCompleted: Bool = false
    
    // New: Notification for reset events
    static let gameDidResetNotification = Notification.Name("gameDidReset")
    
    enum GameScreen: String, Codable {
        case characterSelection
        case memoryGame
        case mixingGame
    }
    
    enum CodingKeys: String, CodingKey {
        case selectedCharacter, collectedIngredients, createdRecipes, currentScreen, memoryGameCompleted
    }
    
    init() {}
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedCharacter = try container.decodeIfPresent(Character.self, forKey: .selectedCharacter)
        collectedIngredients = try container.decode(Set<String>.self, forKey: .collectedIngredients)
        createdRecipes = try container.decode(Set<String>.self, forKey: .createdRecipes)
        currentScreen = try container.decode(GameScreen.self, forKey: .currentScreen)
        memoryGameCompleted = try container.decode(Bool.self, forKey: .memoryGameCompleted)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(selectedCharacter, forKey: .selectedCharacter)
        try container.encode(collectedIngredients, forKey: .collectedIngredients)
        try container.encode(createdRecipes, forKey: .createdRecipes)
        try container.encode(currentScreen, forKey: .currentScreen)
        try container.encode(memoryGameCompleted, forKey: .memoryGameCompleted)
    }
    
    func resetGame() {
        selectedCharacter = nil
        collectedIngredients = []
        createdRecipes = []
        currentScreen = .characterSelection
        memoryGameCompleted = false
        saveGame()
        
        // Post notification for all observers to reset
        NotificationCenter.default.post(name: GameState.gameDidResetNotification, object: nil)
    }
    
    func saveGame() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "gameState")
        }
    }
    
    static func loadGame() -> GameState {
        if let data = UserDefaults.standard.data(forKey: "gameState"),
           let decoded = try? JSONDecoder().decode(GameState.self, from: data) {
            return decoded
        }
        return GameState()
    }
}

extension GameState: GameStateUpdater {
    func addCollectedIngredient(_ ingredient: String) {
        collectedIngredients.insert(ingredient)
        saveGame()
    }
    
    func completeMemoryGame() {
        memoryGameCompleted = true
        saveGame()
    }
    
    func resetMemoryGameProgress() {
        memoryGameCompleted = false
        collectedIngredients = []
        saveGame()
    }
}
