import Foundation

class PlayerStatsService {
    private let baseURL = "https://api.football-data.org/v4"
    private let teamId = 66 // Manchester United's ID
    private let apiKey = APIConfig.footballDataAPIKey
    private let decoder = JSONDecoder()
    private let rateLimitDelay: UInt64 = 1_000_000_000 // 1 second delay
    private let maxRetries = 3
    
    init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func fetchBasicSquadInfo() async throws -> [Player] {
        let endpoint = "/teams/\(teamId)"
        print("\nFetching squad info from: \(baseURL + endpoint)")
        
        let data = try await fetchData(from: endpoint)
        let teamResponse = try decoder.decode(FootballAPIResponse.Team.self, from: data)
        var updatedSquad: [Player] = []
        
        // Fetch detailed info for each player with retries
        for player in teamResponse.squad {
            var retryCount = 0
            var lastError: Error?
            
            repeat {
                do {
                    if retryCount > 0 {
                        print("Retry #\(retryCount) for player: \(player.name)")
                        // Exponential backoff: 1s, 2s, 4s
                        try await Task.sleep(nanoseconds: rateLimitDelay * UInt64(pow(2.0, Double(retryCount - 1))))
                    }
                    
                    print("Fetching details for player: \(player.name)")
                    let detailedPlayer = try await fetchPlayerDetails(playerId: player.id)
                    updatedSquad.append(detailedPlayer)
                    
                    // Success - wait standard delay before next request
                    try await Task.sleep(nanoseconds: rateLimitDelay)
                    break // Exit retry loop on success
                    
                } catch NetworkError.rateLimitExceeded {
                    lastError = NetworkError.rateLimitExceeded
                    retryCount += 1
                    print("Rate limit hit, waiting before retry...")
                } catch {
                    print("Error fetching details for \(player.name): \(error)")
                    updatedSquad.append(player)
                    break // Don't retry other errors
                }
            } while retryCount < maxRetries
            
            // If we exhausted retries, log and continue with basic player info
            if retryCount >= maxRetries {
                print("Failed to fetch details for \(player.name) after \(maxRetries) retries: \(lastError?.localizedDescription ?? "unknown error")")
                updatedSquad.append(player)
            }
        }
        
        return updatedSquad
    }
    
    private func fetchPlayerDetails(playerId: Int) async throws -> Player {
        let endpoint = "/persons/\(playerId)"
        print("Fetching player details from: \(baseURL + endpoint)")
        
        let data = try await fetchData(from: endpoint)
        if let responseString = String(data: data, encoding: .utf8) {
            print("Player API Response for ID \(playerId):")
            print(responseString)
        }
        
        var player = try decoder.decode(Player.self, from: data)
        
        // Initialize stats
        player.stats = PlayerStats(
            appearances: 0,
            goals: 0,
            assists: 0,
            cleanSheets: nil,
            minutesPlayed: 0
        )
        
        return player
    }
    
    func fetchPlayerStats(for players: [Player], progressUpdate: @escaping (Int, Player) -> Void) async {
        do {
            print("\n--- Starting Player Stats Update ---")
            
            // Fetch matches data
            let matchesEndpoint = "/teams/\(teamId)/matches?status=FINISHED&season=2024&competitions=PL"
            let matchesData = try await fetchData(from: matchesEndpoint)
            let matchesResponse = try decoder.decode(FootballAPIResponse.Matches.self, from: matchesData)
            
            // Fetch scorers data
            let scorersEndpoint = "/competitions/PL/scorers?season=2024&limit=100"
            let scorersData = try await fetchData(from: scorersEndpoint)
            let scorersResponse = try decoder.decode(ScorersResponse.self, from: scorersData)
            
            for (index, var player) in players.enumerated() {
                // Update scoring stats
                if let scorer = scorersResponse.scorers.first(where: { $0.player.id == player.id }) {
                    player.stats.goals = scorer.goals
                    player.stats.assists = scorer.assists ?? 0
                }
                
                // Update appearances
                player.stats.appearances = calculateAppearances(for: player.id, in: matchesResponse.matches)
                
                // Update goalkeeper stats
                if player.position?.lowercased().contains("goalkeeper") ?? false {
                    player.stats.cleanSheets = calculateCleanSheets(for: player.id, in: matchesResponse.matches)
                    player.stats.goalsConceded = calculateGoalsConceded(for: player.id, in: matchesResponse.matches)
                }
                
                progressUpdate(index, player)
            }
        } catch {
            print("Error fetching player stats: \(error)")
        }
    }
    
    private func calculateAppearances(for playerId: Int, in matches: [FootballAPIResponse.Matches.Match]) -> Int {
        matches.filter { match in
            match.lineups?.contains { lineup in
                lineup.startXI.contains { $0.id == playerId } ||
                lineup.substitutes.contains { $0.id == playerId }
            } ?? false
        }.count
    }
    
    private func calculateCleanSheets(for playerId: Int, in matches: [FootballAPIResponse.Matches.Match]) -> Int {
        var cleanSheets = 0
        
        for match in matches {
            if let lineups = match.lineups {
                let wasStarting = lineups.contains { lineup in
                    lineup.startXI.contains { $0.id == playerId }
                }
                
                if wasStarting {
                    let isHomeTeam = match.homeTeam.id == teamId
                    let goalsAgainst = isHomeTeam ? match.score.fullTime.away ?? 0 : match.score.fullTime.home ?? 0
                    if goalsAgainst == 0 {
                        cleanSheets += 1
                    }
                }
            }
        }
        
        return cleanSheets
    }
    
    private func calculateGoalsConceded(for playerId: Int, in matches: [FootballAPIResponse.Matches.Match]) -> Int? {
        var goalsConceded = 0
        var hasPlayed = false
        
        for match in matches {
            if let lineups = match.lineups {
                let wasStarting = lineups.contains { lineup in
                    lineup.startXI.contains { $0.id == playerId }
                }
                
                if wasStarting {
                    hasPlayed = true
                    let isHomeTeam = match.homeTeam.id == teamId
                    let goalsAgainst = isHomeTeam ? match.score.fullTime.away ?? 0 : match.score.fullTime.home ?? 0
                    goalsConceded += goalsAgainst
                }
            }
        }
        
        return hasPlayed ? goalsConceded : nil
    }
    
    private func fetchData(from endpoint: String) async throws -> Data {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "X-Auth-Token")
        
        print("Requesting URL: \(url.absoluteString)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("Response status code: \(httpResponse.statusCode)")
        
        switch httpResponse.statusCode {
        case 200:
            return data
        case 400:
            if let errorString = String(data: data, encoding: .utf8) {
                print("API Error Response: \(errorString)")
            }
            throw NetworkError.invalidRequest
        case 401:
            throw NetworkError.unauthorized
        case 429:
            throw NetworkError.rateLimitExceeded
        default:
            if let errorString = String(data: data, encoding: .utf8) {
                print("API Error Response: \(errorString)")
            }
            throw NetworkError.httpError(httpResponse.statusCode)
        }
    }
}

// Models for Premier League API response
struct PLPlayerResponse: Codable {
    let name: String
    let position: String
    let club: String
    let keyStats: [String]
    let nationality: String
    let dateOfBirth: String
    let height: String?
    let completeStats: [String]
    
    enum CodingKeys: String, CodingKey {
        case name
        case position
        case club
        case keyStats = "key_stats"
        case nationality = "Nationality"
        case dateOfBirth = "Date of Birth"
        case height
        case completeStats = "complete stats"
    }
}

// Update the API response model
extension FootballAPIResponse {
    struct Squad: Codable {
        let squad: [Player]
        let count: Int
        
        enum CodingKeys: String, CodingKey {
            case squad
            case count = "count"
        }
    }
} 
