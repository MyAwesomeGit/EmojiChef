// ContentView.swift
import SwiftUI
internal import Combine

// MARK: - Data Models
struct FoodIngredient: Identifiable, Codable, Hashable {
    let id = UUID()
    let emoji: String
    let name: String
    
    static let allIngredients: [FoodIngredient] = [
        FoodIngredient(emoji: "🍅", name: "Tomato"),
        FoodIngredient(emoji: "🧀", name: "Cheese"),
        FoodIngredient(emoji: "🥬", name: "Lettuce"),
        FoodIngredient(emoji: "🍞", name: "Bread"),
        FoodIngredient(emoji: "🥩", name: "Meat"),
        FoodIngredient(emoji: "🍄", name: "Mushroom"),
        FoodIngredient(emoji: "🧅", name: "Onion"),
        FoodIngredient(emoji: "🥚", name: "Egg")
    ]
}

struct Recipe: Identifiable, Codable {
    let id = UUID()
    let name: String
    let emoji: String
    let ingredients: [String]
    
    static let availableRecipes: [Recipe] = [
        Recipe(name: "Sandwich", emoji: "🥪", ingredients: ["Bread", "Lettuce", "Tomato"]),
        Recipe(name: "Omelette", emoji: "🍳", ingredients: ["Egg", "Cheese", "Mushroom"]),
        Recipe(name: "Burger", emoji: "🍔", ingredients: ["Bread", "Meat", "Lettuce"]),
        Recipe(name: "Salad", emoji: "🥗", ingredients: ["Lettuce", "Tomato", "Onion"]),
        Recipe(name: "Steak", emoji: "🥩", ingredients: ["Meat", "Mushroom", "Onion"]),
        Recipe(name: "Cheese Toast", emoji: "🧀", ingredients: ["Bread", "Cheese"]),
        Recipe(name: "Meat Omelette", emoji: "🥘", ingredients: ["Egg", "Meat", "Onion"]),
    ]
}

enum Character: String, Codable, CaseIterable {
    case dog = "Dog"
    case toddler = "Toddler"
    case frog = "Frog"
    
    var emoji: String {
        switch self {
        case .dog: return "🐶"
        case .toddler: return "👶"
        case .frog: return "🐸"
        }
    }
}

// MARK: - Game State
class GameState: ObservableObject, Codable {
    @Published var selectedCharacter: Character?
    @Published var collectedIngredients: Set<String> = []
    @Published var createdRecipes: Set<String> = []
    @Published var currentScreen: GameScreen = .characterSelection
    @Published var memoryGameCompleted: Bool = false
    
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

// MARK: - Color Theme Manager
struct AppColors {
    static func cardBack(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.indigo.opacity(0.8) : Color.blue
    }
    
    static func cardMatched(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.green.opacity(0.4) : Color.green.opacity(0.3)
    }
    
    static func selectedCharacter(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.blue.opacity(0.3) : Color.blue.opacity(0.2)
    }
    
    static func surfaceBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(.systemGray6) : Color.gray.opacity(0.1)
    }
    
    static func cardFaceUp(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(.systemGray5) : Color.white
    }
}

// MARK: - Main App
@main
struct CookingGameApp: App {
    @StateObject private var gameState = GameState.loadGame()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
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

// MARK: - Main Game View
struct GameView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.colorScheme) private var colorScheme
    
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
            case .mixingGame:
                MixingGameView()
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("EmojiChef")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Reset") {
                    gameState.resetGame()
                }
                .foregroundColor(.red)
            }
        }
    }
}

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

struct CardView: View {
    let emoji: String
    let isFlipped: Bool
    let isMatched: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isMatched ?
                          AppColors.cardMatched(for: colorScheme) :
                          (isFlipped ? AppColors.cardFaceUp(for: colorScheme) : AppColors.cardBack(for: colorScheme)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isMatched ? Color.green : Color.blue.opacity(0.8), lineWidth: 2)
                    )
                    .aspectRatio(1, contentMode: .fit)
                
                if isFlipped || isMatched {
                    Text(emoji)
                        .font(.system(size: 40))
                        .minimumScaleFactor(0.5)
                } else {
                    Text("?")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .disabled(isMatched)
    }
}

