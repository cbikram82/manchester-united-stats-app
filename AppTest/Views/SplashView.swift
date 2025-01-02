import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Manchester United themed background
            LinearGradient(
                colors: [
                    Color(red: 0.8, green: 0, blue: 0),
                    Color(red: 0.6, green: 0, blue: 0),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App Title
                Text("Manchester United")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                
                Text("Fan Hub")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                
                Spacer()
                
                // name with a subtle animation
                Text("Developed by")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .opacity(isAnimating ? 1 : 0)
                
                Text("Bikram Chatterjee")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1 : 0)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                isAnimating = true
            }
        }
    }
} 
