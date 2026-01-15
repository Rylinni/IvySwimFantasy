import SwiftUI

struct SwimmerDetailView: View {
    let swimmer: Swimmer
    @State private var selectedCourse: SwimCourse = .scy

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection

                // Stats
                statsSection

                // Personal Best Times
                if !swimmer.times.isEmpty {
                    timesSection
                }

                // Events
                eventsSection
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

    var timesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("PERSONAL BEST TIMES")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppTheme.textMuted)

                Spacer()

                // Course selector
                Menu {
                    ForEach(SwimCourse.allCases, id: \.self) { course in
                        Button {
                            selectedCourse = course
                        } label: {
                            HStack {
                                Text(course.displayName)
                                if course == selectedCourse {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedCourse.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(AppTheme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.accent.opacity(0.15))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 4)

            let filteredTimes = swimmer.times.filter { $0.course == selectedCourse }

            if filteredTimes.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "stopwatch")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.textMuted)
                        Text("No \(selectedCourse.displayName) times available")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    .padding(.vertical, 24)
                    Spacer()
                }
                .cardStyle()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(filteredTimes.enumerated()), id: \.offset) { index, swimTime in
                        timeRow(swimTime: swimTime)

                        if index < filteredTimes.count - 1 {
                            Divider()
                                .background(AppTheme.cardBackgroundLight)
                        }
                    }
                }
                .cardStyle()
            }
        }
    }

    func timeRow(swimTime: SwimTime) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(swimTime.event)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                Text(swimTime.course.displayName)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textMuted)
            }

            Spacer()

            Text(swimTime.formattedTime)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(AppTheme.accent)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }

}

#Preview {
    NavigationStack {
        // Use swimmers2022 to preview swimmer with times data
        SwimmerDetailView(swimmer: MockData.shared.swimmers2022.first { !$0.times.isEmpty } ?? MockData.shared.swimmers2022[0])
    }
}
