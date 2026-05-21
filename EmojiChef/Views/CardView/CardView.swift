import SwiftUI

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
