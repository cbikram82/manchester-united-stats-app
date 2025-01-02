import SwiftUI

struct PlayerStatsView: View {
    @StateObject private var viewModel = PlayerStatsViewModel()
    @State private var selectedPlayer: Player?
    
    var body: some View {
        NavigationView {
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
                
                VStack {
                    if viewModel.players.isEmpty && viewModel.isLoading {
                        ProgressView("Loading squad...")
                            .tint(.white)
                    } else if let error = viewModel.error {
                        ErrorView(error: error) {
                            Task {
                                await viewModel.loadPlayers()
                            }
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                if !viewModel.goalkeepers.isEmpty {
                                    PlayerPositionSection(
                                        title: "Goalkeepers",
                                        players: viewModel.goalkeepers,
                                        onPlayerTap: { selectedPlayer = $0 }
                                    )
                                }
                                
                                if !viewModel.defenders.isEmpty {
                                    PlayerPositionSection(
                                        title: "Defenders",
                                        players: viewModel.defenders,
                                        onPlayerTap: { selectedPlayer = $0 }
                                    )
                                }
                                
                                if !viewModel.midfielders.isEmpty {
                                    PlayerPositionSection(
                                        title: "Midfielders",
                                        players: viewModel.midfielders,
                                        onPlayerTap: { selectedPlayer = $0 }
                                    )
                                }
                                
                                if !viewModel.forwards.isEmpty {
                                    PlayerPositionSection(
                                        title: "Forwards",
                                        players: viewModel.forwards,
                                        onPlayerTap: { selectedPlayer = $0 }
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Squad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color(red: 0.8, green: 0, blue: 0), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .task {
                if viewModel.players.isEmpty {
                    await viewModel.loadPlayers()
                }
            }
        }
        .sheet(item: $selectedPlayer) { player in
            PlayerDetailView(player: player)
        }
    }
}

struct PlayerPositionSection: View {
    let title: String
    let players: [Player]
    let onPlayerTap: (Player) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            ForEach(players) { player in
                PlayerRow(player: player)
                    .onTapGesture {
                        onPlayerTap(player)
                    }
            }
        }
    }
}

struct PlayerRow: View {
    let player: Player
    
    var body: some View {
        HStack {
            Text(player.shirtNumber.map(String.init) ?? "-")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(player.name)
                    .font(.body)
                    .foregroundColor(.white)
                
                if let position = player.position {
                    Text(position)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}

struct PlayerDetailView: View {
    let player: Player
    @Environment(\.dismiss) private var dismiss
    
    private var isGoalkeeper: Bool {
        player.position?.contains("Goalkeeper") ?? false
    }
    
    private var rankEmoji: String {
        if player.stats.goals >= 10 { return "🌟" }
        if player.stats.goals >= 5 { return "⭐️" }
        if player.stats.assists >= 5 { return "🎯" }
        if player.stats.cleanSheets ?? 0 >= 5 { return "🛡️" }
        return "📈"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.8, green: 0, blue: 0)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Player Info
                        VStack(spacing: 10) {
                            if let number = player.shirtNumber {
                                Text("\(number)")
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text(player.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            if let position = player.position {
                                Text(position)
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            if player.stats.hasNoStats {
                                Text(rankEmoji)
                                    .font(.system(size: 40))
                                    .padding(.top)
                            }
                        }
                        .padding()
                        
                        if !player.stats.hasNoStats {
                            // Stats Grid
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 20) {
                                if player.stats.appearances > 0 {
                                    StatBox(title: "Appearances", value: "\(player.stats.appearances)")
                                }
                                
                                if isGoalkeeper {
                                    // Goalkeeper specific stats
                                    if let cleanSheets = player.stats.cleanSheets, cleanSheets > 0 {
                                        StatBox(title: "Clean Sheets", value: "\(cleanSheets)")
                                    }
                                    if let saves = player.stats.saves, saves > 0 {
                                        StatBox(title: "Saves", value: "\(saves)")
                                    }
                                    if let savePercentage = player.stats.savePercentage {
                                        StatBox(title: "Save %", value: String(format: "%.1f%%", savePercentage))
                                    }
                                    if let goalsConceded = player.stats.goalsConceded {
                                        StatBox(title: "Goals Conceded", value: "\(goalsConceded)")
                                    }
                                } else {
                                    // Outfield player stats
                                    if player.stats.goals > 0 {
                                        StatBox(title: "Goals", value: "\(player.stats.goals)")
                                    }
                                    if player.stats.assists > 0 {
                                        StatBox(title: "Assists", value: "\(player.stats.assists)")
                                    }
                                    if let passAccuracy = player.stats.passAccuracy {
                                        StatBox(title: "Pass Accuracy", value: String(format: "%.1f%%", passAccuracy))
                                    }
                                    if let tackles = player.stats.tacklesWon {
                                        StatBox(title: "Tackles Won", value: "\(tackles)")
                                    }
                                }
                            }
                            .padding()
                        }
                        
                        // Additional Info
                        VStack(spacing: 15) {
                            InfoRow(title: "Nationality", value: player.nationality)
                            InfoRow(title: "Age", value: "\(player.age)")
                            if player.stats.minutesPlayed > 0 {
                                InfoRow(title: "Minutes Played", value: "\(player.stats.minutesPlayed)")
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(value)
                .foregroundColor(.white)
        }
    }
}

struct ErrorView: View {
    let error: String
    let retry: () -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.yellow)
            Text(error)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
            Button("Retry", action: retry)
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
        }
        .padding()
    }
} 