import SwiftUI
internal import UniformTypeIdentifiers

struct IngredientItemView: View {
    let food: FoodIngredient
    
    var body: some View {
        VStack {
            Text(food.emoji)
                .font(.largeTitle)
            Text(food.name)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(4)
        .contentShape(Rectangle())
        .onDrag {
            // Use UTType with explicit string representation
            return NSItemProvider(object: food.name as NSString)
        }
    }
}
