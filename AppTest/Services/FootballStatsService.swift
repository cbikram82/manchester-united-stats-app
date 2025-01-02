import Foundation

class FootballStatsService {
    private let apiKey = "c47f6919b38a4591a3593fefe3c4409f"
    private let baseURL = "https://api.football-data.org/v4"
    
    func fetchPremierLeagueStanding() async throws -> [LeagueStanding] {
        let endpoint = "/competitions/PL/standings?season=2024"
        let data = try await fetchData(from: endpoint)
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(StandingsResponse.self, from: data)
        
        guard let standings = response.standings.first(where: { $0.type == "TOTAL" }) else {
            return []
        }
        
        return standings.table.map { row in
            LeagueStanding(
                position: row.position,
                team: row.team.name ?? row.team.shortName,
                played: row.playedGames,
                won: row.won,
                drawn: row.draw,
                lost: row.lost,
                points: row.points,
                goalsFor: row.goalsFor,
                goalsAgainst: row.goalsAgainst,
                goalDifference: row.goalDifference
            )
        }
    }
    
    func fetchChampionsLeagueStanding() async throws -> [LeagueStanding] {
        // Return empty array since United isn't in Champions League this season
        return [
            LeagueStanding(
                position: 0,
                team: "Manchester United FC",
                played: 0,
                won: 0,
                drawn: 0,
                lost: 0,
                points: 0,
                goalsFor: 0,
                goalsAgainst: 0,
                goalDifference: 0
            )
        ]
    }
    
    func fetchUpcomingFixtures() async throws -> [Fixture] {
        let endpoint = "/teams/66/matches?status=SCHEDULED&limit=5&competitions=PL,CL"
        let data = try await fetchData(from: endpoint)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let response = try decoder.decode(FixturesResponse.self, from: data)
        
        return response.matches.map { match in
            Fixture(
                competition: match.competition.name,
                homeTeam: match.homeTeam.name ?? match.homeTeam.shortName,
                awayTeam: match.awayTeam.name ?? match.awayTeam.shortName,
                date: match.utcDate,
                venue: match.venue ?? "TBD"
            )
        }
    }
    
    private func fetchData(from endpoint: String) async throws -> Data {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Auth-Token")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if httpResponse.statusCode == 403 {
            print("API Key error: Unauthorized")
            throw NetworkError.unauthorized
        }
        
        if httpResponse.statusCode != 200 {
            print("HTTP Error: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response body: \(responseString)")
            }
            throw NetworkError.httpError(httpResponse.statusCode)
        }
        
        return data
    }
}

// Updated API Response Models
struct StandingsResponse: Codable {
    let standings: [Standing]
    
    struct Standing: Codable {
        let type: String
        let table: [TableRow]
    }
    
    struct TableRow: Codable {
        let position: Int
        let team: TeamInfo
        let playedGames: Int
        let won: Int
        let draw: Int
        let lost: Int
        let points: Int
        let goalsFor: Int
        let goalsAgainst: Int
        let goalDifference: Int
    }
}

struct FixturesResponse: Codable {
    let matches: [Match]
    
    struct Match: Codable {
        let competition: Competition
        let utcDate: Date
        let venue: String?
        let homeTeam: TeamInfo
        let awayTeam: TeamInfo
    }
    
    struct Competition: Codable {
        let name: String
    }
}

struct TeamInfo: Codable {
    let name: String?
    let shortName: String
}

//enum NetworkError: Error {
//    case invalidURL
//    case invalidResponse
//    case decodingError
//    case unauthorized
//    case httpError(Int)
//} 
