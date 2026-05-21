import SwiftUI

// Recipe Alert Modifier (Reusable)
struct RecipeAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    
    func body(content: Content) -> some View {
        content
            .alert("Cooking Result", isPresented: $isPresented) {
                Button("Yummy!") {}
            } message: {
                Text(message)
            }
    }
}

extension View {
    func recipeAlert(isPresented: Binding<Bool>, message: String) -> some View {
        modifier(RecipeAlertModifier(isPresented: isPresented, message: message))
    }
}
