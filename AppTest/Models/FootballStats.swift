import Foundation

struct LeagueStanding: Codable {
    let position: Int
    let team: String
    let played: Int
    let won: Int
    let drawn: Int
    let lost: Int
    let points: Int
    let goalsFor: Int
    let goalsAgainst: Int
    let goalDifference: Int
}

struct Fixture: Codable {
    let competition: String
    let homeTeam: String
    let awayTeam: String
    let date: Date
    let venue: String
}

enum Competition: String {
    case premierLeague = "Premier League"
    case championsLeague = "UEFA Champions League"
} 