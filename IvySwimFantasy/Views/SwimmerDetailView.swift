import SwiftUI

struct SwimmerDetailView: View {
    let swimmer: Swimmer

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection

                // Stats
                statsSection

                // Events
                eventsSection

                // Recent results placeholder
                recentResultsSection
            }
            .padding()
        }
        .background(AppTheme.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    var headerSection: some View {
        VStack(spacing: 16) {
            // Photo placeholder
            ZStack {
                Circle()
                    .fill(Color(hex: swimmer.school.color))
                    .frame(width: 100, height: 100)

                if swimmer.photoURL != nil {
                    // Would load actual photo here
                    Text(swimmer.initials)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text(swimmer.initials)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .overlay(
                Circle()
                    .stroke(AppTheme.cardBackgroundLight, lineWidth: 4)
            )

            VStack(spacing: 4) {
                Text(swimmer.fullName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                HStack(spacing: 8) {
                    Text(swimmer.school.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: swimmer.school.color))

                    Text("•")
                        .foregroundColor(AppTheme.textMuted)

                    Text(swimmer.year.rawValue)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding(.vertical)
    }

    var statsSection: some View {
        HStack(spacing: 0) {
            statItem(title: "POINTS", value: String(format: "%.1f", swimmer.fantasyPoints), color: AppTheme.accent)

            Divider()
                .frame(height: 40)
                .background(AppTheme.cardBackgroundLight)

            statItem(title: "PROJECTED", value: String(format: "%.1f", swimmer.projectedPoints), color: AppTheme.textSecondary)

            Divider()
                .frame(height: 40)
                .background(AppTheme.cardBackgroundLight)

            statItem(title: "EVENTS", value: "\(swimmer.events.count)", color: AppTheme.accentSecondary)
        }
        .padding(.vertical, 16)
        .cardStyle()
    }

    func statItem(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(AppTheme.textMuted)

            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }

    var eventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EVENTS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppTheme.textMuted)
                .padding(.horizontal, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(swimmer.events, id: \.self) { event in
                    HStack {
                        Text(event.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    .padding(12)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(10)
                }
            }
        }
    }

    var recentResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT RESULTS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppTheme.textMuted)
                .padding(.horizontal, 4)

            VStack(spacing: 8) {
                placeholderResult(event: "200 Free", time: "1:38.45", place: 2, points: 17)
                placeholderResult(event: "100 Free", time: "44.21", place: 5, points: 14)
                placeholderResult(event: "500 Free", time: "4:22.89", place: 3, points: 16)
            }
            .padding()
            .cardStyle()
        }
    }

    func placeholderResult(event: String, time: String, place: Int, points: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(event)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                Text("Ivy Champs 2026")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textMuted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(time)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(AppTheme.textPrimary)

                HStack(spacing: 4) {
                    Text("\(place)\(placeSuffix(place))")
                        .font(.system(size: 12))
                        .foregroundColor(placeColor(place))

                    Text("•")
                        .foregroundColor(AppTheme.textMuted)

                    Text("+\(points) pts")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.accent)
                }
            }
        }
    }

    func placeSuffix(_ place: Int) -> String {
        switch place {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
        }
    }

    func placeColor(_ place: Int) -> Color {
        switch place {
        case 1: return AppTheme.gold
        case 2: return AppTheme.silver
        case 3: return AppTheme.bronze
        default: return AppTheme.textSecondary
        }
    }
}

#Preview {
    NavigationStack {
        SwimmerDetailView(swimmer: MockData.shared.swimmers[0])
    }
}
