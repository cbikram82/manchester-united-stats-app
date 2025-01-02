import Foundation

@MainActor
class StatsViewModel: ObservableObject {
    @Published var plStanding: [LeagueStanding] = []
    @Published var clStanding: [LeagueStanding] = []
    @Published var upcomingFixtures: [Fixture] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let service = FootballStatsService()
    
    func loadAllStats() async {
        isLoading = true
        error = nil
        
        do {
            // Load each type of data separately to handle individual failures
            do {
                plStanding = try await service.fetchPremierLeagueStanding()
            } catch {
                print("Premier League error: \(error)")
            }
            
            do {
                clStanding = try await service.fetchChampionsLeagueStanding()
            } catch {
                print("Champions League error: \(error)")
            }
            
            do {
                upcomingFixtures = try await service.fetchUpcomingFixtures()
            } catch {
                print("Fixtures error: \(error)")
            }
            
            if plStanding.isEmpty && clStanding.isEmpty && upcomingFixtures.isEmpty {
                error = "Unable to load any data. Please try again later."
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
} 