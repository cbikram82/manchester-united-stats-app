import Foundation

@MainActor
class PlayerStatsViewModel: ObservableObject {
    @Published var players: [Player] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var loadingProgress: String = ""
    
    private let service = PlayerStatsService()
    
    // Computed properties for filtering players by position
    var goalkeepers: [Player] {
        players.filter { $0.position?.contains("Goalkeeper") ?? false }
            .sorted { $0.name < $1.name }
    }
    
    var defenders: [Player] {
        players.filter { 
            let position = $0.position?.lowercased() ?? ""
            return position.contains("back") || position.contains("defence")
        }.sorted { $0.name < $1.name }
    }
    
    var midfielders: [Player] {
        players.filter {
            let position = $0.position?.lowercased() ?? ""
            return position.contains("midfield")
        }.sorted { $0.name < $1.name }
    }
    
    var forwards: [Player] {
        players.filter {
            let position = $0.position?.lowercased() ?? ""
            return position.contains("winger") || position.contains("forward") || 
                   position.contains("striker") || position.contains("offence")
        }.sorted { $0.name < $1.name }
    }
    
    func loadPlayers() async {
        self.isLoading = true
        self.error = nil
        self.loadingProgress = "Fetching squad info..."
        
        do {
            // First load the basic squad info
            let initialPlayers = try await service.fetchBasicSquadInfo()
            self.players = initialPlayers
            
            // Log initial squad composition
            print("\nInitial squad composition:")
            print("Goalkeepers: \(goalkeepers.map { $0.name })")
            print("Defenders: \(defenders.map { $0.name })")
            print("Midfielders: \(midfielders.map { $0.name })")
            print("Forwards: \(forwards.map { $0.name })")
            
            // Then fetch detailed stats for each player
            self.loadingProgress = "Fetching player statistics..."
            await service.fetchPlayerStats(for: self.players) { index, updatedPlayer in
                if index < self.players.count {
                    self.players[index] = updatedPlayer
                    self.loadingProgress = "Loading stats: \(index + 1)/\(self.players.count)"
                }
            }
            
            // Log final stats
            print("\nFinal squad stats:")
            for player in self.players {
                if player.position?.contains("Goalkeeper") ?? false {
                    print("""
                        \(player.name):
                        - Position: \(player.position ?? "Unknown")
                        - Apps: \(player.stats.appearances)
                        - Clean sheets: \(player.stats.cleanSheets ?? 0)
                        - Goals conceded: \(player.stats.goalsConceded ?? 0)
                        ---
                        """)
                } else {
                    print("""
                        \(player.name):
                        - Position: \(player.position ?? "Unknown")
                        - Apps: \(player.stats.appearances)
                        - Goals: \(player.stats.goals)
                        - Assists: \(player.stats.assists)
                        ---
                        """)
                }
            }
            
            self.isLoading = false
            self.loadingProgress = ""
            
        } catch {
            print("Error loading players: \(error)")
            self.error = handleError(error)
            self.isLoading = false
            self.loadingProgress = ""
        }
    }
    
    private func handleError(_ error: Error) -> String {
        let errorMessage: String
        let nsError = error as NSError
        
        if nsError.domain == "API" {
            switch nsError.code {
            case 401:
                errorMessage = "Authentication failed. Please check the API key."
            case 403:
                errorMessage = "Access forbidden. Please check API subscription."
            case 429:
                errorMessage = "Too many requests. Please try again in a few minutes."
            default:
                errorMessage = nsError.localizedDescription
            }
        } else if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                errorMessage = "No internet connection. Please check your connection and try again."
            case .timedOut:
                errorMessage = "Request timed out. Please try again."
            default:
                errorMessage = "Network error: \(urlError.localizedDescription)"
            }
        } else {
            errorMessage = error.localizedDescription
        }
        
        print("Error details: \(error)")
        return errorMessage
    }
} 