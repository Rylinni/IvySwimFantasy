import SwiftUI

struct TeamsView: View {
    @State private var selectedTeam: FantasyTeam?
    private let mockData = MockData.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with meet status
                    meetStatusCard

                    // My Team Card (first team as user's team)
                    if let myTeam = mockData.fantasyTeams.first {
                        myTeamSection(team: myTeam)
                    }

                    // League Teams
                    leagueTeamsSection
                }
                .padding()
            }
            .background(AppTheme.background)
            .navigationTitle("My Team")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    var meetStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(AppTheme.success)
                            .frame(width: 8, height: 8)
                        Text("LIVE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.success)
                    }

                    Text(mockData.meet.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text(mockData.meet.location)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(mockData.meet.dateRange)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)

                    Text("\(mockData.meet.completedEvents)/\(mockData.meet.totalEvents) Events")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textMuted)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.cardBackgroundLight)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.accent)
                        .frame(width: geometry.size.width * CGFloat(mockData.meet.completedEvents) / CGFloat(max(1, mockData.meet.totalEvents)), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding()
        .cardStyle()
    }

    func myTeamSection(team: FantasyTeam) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Team Avatar
                Circle()
                    .fill(Color(hex: team.avatarColor))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(team.name.prefix(2)).uppercased())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(team.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text(team.ownerName)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("#\(team.rank ?? 1)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.accent)

                    Text("Rank")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textMuted)
                }
            }

            Divider()
                .background(AppTheme.cardBackgroundLight)

            // Points display
            HStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("POINTS")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.textMuted)

                    Text(String(format: "%.1f", team.totalPoints))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("PROJECTED")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.textMuted)

                    Text(String(format: "%.1f", team.projectedPoints))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()
            }

            // Roster preview
            VStack(alignment: .leading, spacing: 12) {
                Text("ROSTER")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppTheme.textMuted)

                let swimmers = mockData.swimmers(for: team)
                ForEach(swimmers.prefix(5)) { swimmer in
                    SwimmerCard(swimmer: swimmer, compact: true)
                }

                if swimmers.count > 5 {
                    Text("+ \(swimmers.count - 5) more")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textMuted)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .cardStyle()
    }

    var leagueTeamsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LEAGUE TEAMS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppTheme.textMuted)
                .padding(.horizontal, 4)

            ForEach(Array(mockData.fantasyTeams.dropFirst())) { team in
                TeamCard(team: team)
            }
        }
    }
}

#Preview {
    TeamsView()
}
