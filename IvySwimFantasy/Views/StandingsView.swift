import SwiftUI

struct StandingsView: View {
    private let mockData = MockData.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Top 3 podium
                    podiumView

                    // Full standings
                    standingsListView
                }
                .padding()
            }
            .background(AppTheme.background)
            .navigationTitle("Standings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    var podiumView: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // 2nd place
            if mockData.fantasyTeams.count > 1 {
                podiumSpot(team: mockData.league.sortedTeams[1], place: 2, height: 90)
            }

            // 1st place
            if !mockData.fantasyTeams.isEmpty {
                podiumSpot(team: mockData.league.sortedTeams[0], place: 1, height: 120)
            }

            // 3rd place
            if mockData.fantasyTeams.count > 2 {
                podiumSpot(team: mockData.league.sortedTeams[2], place: 3, height: 70)
            }
        }
        .padding(.vertical, 20)
    }

    func podiumSpot(team: FantasyTeam, place: Int, height: CGFloat) -> some View {
        VStack(spacing: 8) {
            // Medal/Crown
            if place == 1 {
                Image(systemName: "crown.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.gold)
            }

            // Avatar
            Circle()
                .fill(Color(hex: team.avatarColor))
                .frame(width: place == 1 ? 60 : 50, height: place == 1 ? 60 : 50)
                .overlay(
                    Text(String(team.name.prefix(2)).uppercased())
                        .font(.system(size: place == 1 ? 18 : 14, weight: .bold))
                        .foregroundColor(.white)
                )
                .overlay(
                    Circle()
                        .stroke(placeColor(place), lineWidth: 3)
                )

            Text(team.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)

            Text(String(format: "%.1f pts", team.totalPoints))
                .font(.system(size: 11))
                .foregroundColor(AppTheme.textSecondary)

            // Podium
            RoundedRectangle(cornerRadius: 8)
                .fill(placeColor(place).opacity(0.3))
                .frame(height: height)
                .overlay(
                    Text("\(place)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(placeColor(place))
                )
        }
        .frame(maxWidth: .infinity)
    }

    func placeColor(_ place: Int) -> Color {
        switch place {
        case 1: return AppTheme.gold
        case 2: return AppTheme.silver
        case 3: return AppTheme.bronze
        default: return AppTheme.textSecondary
        }
    }

    var standingsListView: some View {
        VStack(spacing: 8) {
            ForEach(Array(mockData.league.sortedTeams.enumerated()), id: \.element.id) { index, team in
                standingsRow(team: team, rank: index + 1)
            }
        }
        .padding()
        .cardStyle()
    }

    func standingsRow(team: FantasyTeam, rank: Int) -> some View {
        HStack(spacing: 12) {
            // Rank
            Text("\(rank)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(rank <= 3 ? placeColor(rank) : AppTheme.textMuted)
                .frame(width: 24)

            // Avatar
            Circle()
                .fill(Color(hex: team.avatarColor))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(team.name.prefix(2)).uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                )

            // Team info
            VStack(alignment: .leading, spacing: 2) {
                Text(team.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(team.ownerName)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            // Points
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f", team.totalPoints))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text("pts")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textMuted)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    StandingsView()
}
