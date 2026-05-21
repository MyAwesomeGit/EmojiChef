import SwiftUI

// Recipe Status Indicator Component
struct RecipeStatusView: View {
    let canMake: Bool
    let alreadyMade: Bool
    
    var body: some View {
        Group {
            if alreadyMade {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            } else if canMake {
                Text("Make!")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            } else {
                Text("Need ingredients")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
}
