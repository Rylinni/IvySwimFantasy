import SwiftUI

struct SwimmerCard: View {
    let swimmer: Swimmer
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: swimmer.school.color))
                    .frame(width: compact ? 36 : 44, height: compact ? 36 : 44)

                Text(swimmer.initials)
                    .font(.system(size: compact ? 12 : 14, weight: .bold))
                    .foregroundColor(.white)
            }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(swimmer.fullName)
                    .font(.system(size: compact ? 14 : 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                HStack(spacing: 6) {
                    Text(swimmer.school.shortName)
                        .font(.system(size: compact ? 11 : 12, weight: .medium))
                        .foregroundColor(Color(hex: swimmer.school.color))

                    if !compact {
                        Text("•")
                            .foregroundColor(AppTheme.textMuted)

                        Text(swimmer.year.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)

                        Text("•")
                            .foregroundColor(AppTheme.textMuted)

                        Text(swimmer.events.first?.shortName ?? "")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
            }

            Spacer()

            // Points
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f", swimmer.fantasyPoints))
                    .font(.system(size: compact ? 14 : 16, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                if !compact {
                    Text("pts")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.textMuted)
                }
            }

            if !compact {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textMuted)
            }
        }
        .padding(compact ? 8 : 12)
        .background(compact ? Color.clear : AppTheme.cardBackground)
        .cornerRadius(compact ? 0 : 12)
    }
}

#Preview {
    VStack(spacing: 8) {
        SwimmerCard(swimmer: MockData.shared.swimmers[0], compact: false)
        SwimmerCard(swimmer: MockData.shared.swimmers[1], compact: true)
    }
    .padding()
    .background(AppTheme.background)
}
