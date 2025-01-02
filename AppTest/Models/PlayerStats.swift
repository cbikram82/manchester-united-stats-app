import Foundation

struct PlayerStats: Codable {
    var appearances: Int
    var goals: Int
    var assists: Int
    var cleanSheets: Int?
    var minutesPlayed: Int
    var saves: Int?
    var goalsConceded: Int?
    var savePercentage: Double?
    var passAccuracy: Double?
    var tacklesWon: Int?
    
    var hasNoStats: Bool {
        appearances == 0 && 
        goals == 0 && 
        assists == 0 && 
        cleanSheets == nil && 
        minutesPlayed == 0 &&
        saves == nil &&
        goalsConceded == nil
    }
    
    init(appearances: Int = 0,
         goals: Int = 0,
         assists: Int = 0,
         cleanSheets: Int? = nil,
         minutesPlayed: Int = 0,
         saves: Int? = nil,
         goalsConceded: Int? = nil,
         savePercentage: Double? = nil,
         passAccuracy: Double? = nil,
         tacklesWon: Int? = nil) {
        self.appearances = appearances
        self.goals = goals
        self.assists = assists
        self.cleanSheets = cleanSheets
        self.minutesPlayed = minutesPlayed
        self.saves = saves
        self.goalsConceded = goalsConceded
        self.savePercentage = savePercentage
        self.passAccuracy = passAccuracy
        self.tacklesWon = tacklesWon
    }
} 