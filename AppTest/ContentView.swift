//
//  ContentView.swift
//  AppTest
//
//  Created by Bikram Chatterjee on 30/12/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var showingSplash = true
    
    var body: some View {
        ZStack {
            if showingSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
            
            TabView {
                QuizView()
                    .tabItem {
                        Label("Quiz", systemImage: "questionmark.circle")
                    }
                
                StatsView()
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar")
                    }
                
                PlayerStatsView()
                    .tabItem {
                        Label("Squad", systemImage: "person.3")
                    }
            }
            .accentColor(.red)
        }
        .onAppear {
            // Dismiss splash screen after 2.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showingSplash = false
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
