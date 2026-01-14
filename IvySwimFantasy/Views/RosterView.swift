import SwiftUI

struct RosterView: View {
    private let mockData = MockData.shared
    @State private var searchText = ""
    @State private var selectedSchool: IvySchool?
    @State private var sortBy: SortOption = .points

    enum SortOption: String, CaseIterable {
        case points = "Points"
        case name = "Name"
        case school = "School"
        case projected = "Projected"
    }

    var filteredSwimmers: [Swimmer] {
        var swimmers = mockData.swimmers

        if let school = selectedSchool {
            swimmers = swimmers.filter { $0.school == school }
        }

        if !searchText.isEmpty {
            swimmers = swimmers.filter {
                $0.fullName.localizedCaseInsensitiveContains(searchText) ||
                $0.school.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch sortBy {
        case .points:
            swimmers.sort { $0.fantasyPoints > $1.fantasyPoints }
        case .name:
            swimmers.sort { $0.lastName < $1.lastName }
        case .school:
            swimmers.sort { $0.school.rawValue < $1.school.rawValue }
        case .projected:
            swimmers.sort { $0.projectedPoints > $1.projectedPoints }
        }

        return swimmers
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filters
                VStack(spacing: 12) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppTheme.textMuted)

                        TextField("Search swimmers...", text: $searchText)
                            .foregroundColor(AppTheme.textPrimary)

                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppTheme.textMuted)
                            }
                        }
                    }
                    .padding(12)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(12)

                    // School filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "All", isSelected: selectedSchool == nil) {
                                selectedSchool = nil
                            }

                            ForEach(IvySchool.allCases, id: \.self) { school in
                                FilterChip(
                                    title: school.shortName,
                                    isSelected: selectedSchool == school,
                                    color: Color(hex: school.color)
                                ) {
                                    selectedSchool = school
                                }
                            }
                        }
                    }

                    // Sort options
                    HStack {
                        Text("Sort by:")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textMuted)

                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button {
                                withAnimation {
                                    sortBy = option
                                }
                            } label: {
                                Text(option.rawValue)
                                    .font(.system(size: 12, weight: sortBy == option ? .semibold : .regular))
                                    .foregroundColor(sortBy == option ? AppTheme.accent : AppTheme.textSecondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(sortBy == option ? AppTheme.accent.opacity(0.2) : Color.clear)
                                    .cornerRadius(8)
                            }
                        }

                        Spacer()
                    }
                }
                .padding()
                .background(AppTheme.background)

                // Swimmers list
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredSwimmers) { swimmer in
                            NavigationLink(destination: SwimmerDetailView(swimmer: swimmer)) {
                                SwimmerCard(swimmer: swimmer, compact: false)
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Swimmers")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = AppTheme.accent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? color : AppTheme.cardBackground)
                .cornerRadius(16)
        }
    }
}

#Preview {
    RosterView()
}
