import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Manchester United themed background (same as quiz)
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
                
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            StandingsSection(
                                title: "Premier League",
                                standings: viewModel.plStanding
                            )
                            
                            StandingsSection(
                                title: "Champions League",
                                standings: viewModel.clStanding
                            )
                            
                            FixturesSection(fixtures: viewModel.upcomingFixtures)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("United Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color(red: 0.8, green: 0, blue: 0), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .task {
                await viewModel.loadAllStats()
            }
        }
    }
}

struct StandingsSection: View {
    let title: String
    let standings: [LeagueStanding]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                StandingsTable(standings: standings)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}

struct StandingsTable: View {
    let standings: [LeagueStanding]
    
    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 8) {
            // Table header
            GridRow {
                Text("Pos")
                Text("Team")
                Text("P")
                Text("W")
                Text("D")
                Text("L")
                Text("GD")
                Text("Pts")
            }
            .font(.caption.bold())
            .foregroundColor(.white)
            
            // Table rows
            ForEach(standings, id: \.position) { standing in
                GridRow {
                    Text("\(standing.position)")
                    Text(standing.team)
                    Text("\(standing.played)")
                    Text("\(standing.won)")
                    Text("\(standing.drawn)")
                    Text("\(standing.lost)")
                    Text("\(standing.goalDifference)")
                    Text("\(standing.points)")
                }
                .foregroundColor(.white)
                .font(.caption)
            }
        }
    }
}

struct FixturesSection: View {
    let fixtures: [Fixture]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Upcoming Fixtures")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(fixtures, id: \.date) { fixture in
                FixtureRow(fixture: fixture)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}

struct FixtureRow: View {
    let fixture: Fixture
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(fixture.competition)
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                Text(fixture.homeTeam)
                Text("vs")
                    .foregroundColor(.gray)
                Text(fixture.awayTeam)
            }
            .font(.body)
            .foregroundColor(.white)
            
            Text(fixture.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 5)
    }
} 