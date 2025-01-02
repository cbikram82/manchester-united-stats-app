import Foundation

// Rename to be more specific
struct FootballAPIResponse {
    struct Team: Codable {
        let squad: [Player]
        let name: String
        let shortName: String
        let tla: String
        let crest: String
    }
    
    struct Matches: Codable {
        let matches: [Match]
        let resultSet: ResultSet
        
        struct ResultSet: Codable {
            let count: Int
            let played: Int
            let first: String
            let last: String
        }
        
        struct Match: Codable {
            let id: Int
            let homeTeam: Team
            let awayTeam: Team
            let score: Score
            let status: String
            let matchday: Int
            let stage: String
            let season: Season
            let lineups: [Lineup]?
            
            struct Team: Codable {
                let id: Int
                let name: String
                let shortName: String
                let tla: String
                let crest: String
            }
            
            struct Score: Codable {
                let winner: String?
                let duration: String?
                let fullTime: ScoreDetail
                let halfTime: ScoreDetail?
                
                struct ScoreDetail: Codable {
                    let home: Int?
                    let away: Int?
                }
            }
            
            struct Season: Codable {
                let id: Int
                let startDate: String
                let endDate: String
                let currentMatchday: Int
                let winner: String?
            }
            
            struct Lineup: Codable {
                let team: Team
                let startXI: [LineupPlayer]
                let substitutes: [LineupPlayer]
                let formation: String?
                
                struct LineupPlayer: Codable {
                    let id: Int
                    let name: String
                    let position: String?
                    let number: Int?
                }
            }
        }
    }
}

struct ScorersResponse: Codable {
    let count: Int
    let scorers: [Scorer]
    let competition: Competition
    let season: Season
    
    struct Scorer: Codable {
        let player: ScorerPlayer
        let team: Team
        let playedMatches: Int
        let goals: Int
        let assists: Int?
        let penalties: Int?
        
        struct ScorerPlayer: Codable {
            let id: Int
            let name: String
            let firstName: String?
            let lastName: String?
            let dateOfBirth: String?
            let nationality: String?
            let position: String?
            let section: String?
        }
        
        struct Team: Codable {
            let id: Int
            let name: String
            let shortName: String
            let tla: String
            let crest: String
        }
    }
    
    struct Competition: Codable {
        let id: Int
        let name: String
        let code: String
        let type: String
        let emblem: String
    }
    
    struct Season: Codable {
        let id: Int
        let startDate: String
        let endDate: String
        let currentMatchday: Int
        let winner: String?
    }
} 