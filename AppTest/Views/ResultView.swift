import SwiftUI

struct ResultView: View {
    let score: Int
    let total: Int
    let onRestart: () -> Void
    
    private var rank: (title: String, message: String) {
        RankSystem.getRank(score: score, total: total)
    }
    
    var body: some View {
        VStack(spacing: 25) {
            // Score Circle
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.3)
                    .foregroundColor(.red)
                
                Circle()
                    .trim(from: 0, to: CGFloat(score) / CGFloat(total))
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .foregroundColor(.red)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: score)
                
                VStack {
                    Text("\(score)/\(total)")
                        .font(.system(size: 44, weight: .bold))
                    Text("Score")
                        .font(.system(size: 20))
                }
                .foregroundColor(.white)
            }
            .frame(width: 200, height: 200)
            
            // Rank Title
            Text(rank.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Rank Message
            Text(rank.message)
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Play Again Button
            Button(action: onRestart) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Play Again")
                }
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.8))
        )
        .padding()
    }
} 