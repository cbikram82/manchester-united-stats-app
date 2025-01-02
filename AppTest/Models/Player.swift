import Foundation

struct Player: Codable, Identifiable {
    let id: Int
    let name: String
    var shirtNumber: Int?
    let nationality: String
    let dateOfBirth: String?
    var position: String?
    var stats: PlayerStats
    
    // Additional properties from /persons endpoint
    let firstName: String?
    let lastName: String?
    let lastUpdated: String?
    let currentTeam: CurrentTeam?
    
    var age: Int {
        guard let dateString = dateOfBirth else { return 0 }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return 0 }
        let calendar = Calendar.current
        return calendar.dateComponents([.year], from: date, to: Date()).year ?? 0
    }
    
    // Nested types
    struct CurrentTeam: Codable {
        let id: Int
        let name: String
        let shortName: String?
        let tla: String?
        let crest: String?
    }
    
    // Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case firstName
        case lastName
        case shirtNumber = "jerseyNumber"
        case nationality
        case dateOfBirth
        case position
        case lastUpdated
        case currentTeam
        case stats
    }
    
    // Decoder init
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        nationality = try container.decode(String.self, forKey: .nationality)
        
        // Optional fields
        dateOfBirth = try container.decodeIfPresent(String.self, forKey: .dateOfBirth)
        position = try container.decodeIfPresent(String.self, forKey: .position)
        shirtNumber = try container.decodeIfPresent(Int.self, forKey: .shirtNumber)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        lastUpdated = try container.decodeIfPresent(String.self, forKey: .lastUpdated)
        currentTeam = try container.decodeIfPresent(CurrentTeam.self, forKey: .currentTeam)
        
        // Initialize empty stats if not present in JSON
        stats = try container.decodeIfPresent(PlayerStats.self, forKey: .stats) ?? PlayerStats()
        
        print("""
            Decoded player:
            - Name: \(name)
            - ID: \(id)
            - Position: \(position ?? "Unknown")
            - Jersey Number: \(shirtNumber?.description ?? "nil")
            - First Name: \(firstName ?? "nil")
            - Last Name: \(lastName ?? "nil")
            - Team: \(currentTeam?.name ?? "nil")
            """)
    }
    
    // Custom initializer
    init(id: Int, 
         name: String, 
         shirtNumber: Int? = nil, 
         nationality: String, 
         dateOfBirth: String? = nil, 
         position: String? = nil, 
         firstName: String? = nil, 
         lastName: String? = nil, 
         currentTeam: CurrentTeam? = nil,
         stats: PlayerStats = PlayerStats()) {
        self.id = id
        self.name = name
        self.shirtNumber = shirtNumber
        self.nationality = nationality
        self.dateOfBirth = dateOfBirth
        self.position = position
        self.firstName = firstName
        self.lastName = lastName
        self.lastUpdated = nil
        self.currentTeam = currentTeam
        self.stats = stats
    }
}

// Preview helper
extension Player {
    static var preview: Player {
        Player(
            id: 1,
            name: "Marcus Rashford",
            shirtNumber: 10,
            nationality: "England",
            dateOfBirth: "1997-10-31",
            position: "Forward",
            firstName: "Marcus",
            lastName: "Rashford",
            currentTeam: CurrentTeam(
                id: 66,
                name: "Manchester United FC",
                shortName: "Man United",
                tla: "MUN",
                crest: "https://crests.football-data.org/66.png"
            )
        )
    }
} 