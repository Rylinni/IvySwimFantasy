import SwiftUI

struct TeamCard: View {
    let team: FantasyTeam

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("#\(team.rank ?? 0)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(rankColor)
                .frame(width: 30)

            // Avatar
            Circle()
                .fill(Color(hex: team.avatarColor))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(team.name.prefix(2)).uppercased())
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                )

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(team.name)
                    .font(.system(size: 15, weight: .semibold))
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
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.textMuted)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textMuted)
        }
        .padding(12)
        .cardStyle()
    }

    var rankColor: Color {
        switch team.rank {
        case 1: return AppTheme.gold
        case 2: return AppTheme.silver
        case 3: return AppTheme.bronze
        default: return AppTheme.textMuted
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        TeamCard(team: MockData.shared.fantasyTeams[0])
        TeamCard(team: MockData.shared.fantasyTeams[1])
    }
    .padding()
    .background(AppTheme.background)
}
