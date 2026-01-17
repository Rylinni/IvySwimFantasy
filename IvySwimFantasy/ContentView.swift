import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .myTeam

    enum Tab: String, CaseIterable {
        case myTeam = "My Team"
        case standings = "Standings"
        case results = "Results"
        case swimmers = "Swimmers"
        case apiTest = "API Test"  // Add this line

        var icon: String {
            switch self {
            case .myTeam: return "person.2.fill"
            case .standings: return "trophy.fill"
            case .results: return "list.number"
            case .swimmers: return "figure.pool.swim"
            case .apiTest: return "network"  // Add this line
            }
        }
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Content
                Group {
                    switch selectedTab {
                    case .myTeam:
                        TeamsView()
                    case .standings:
                        StandingsView()
                    case .results:
                        ResultsView()
                    case .swimmers:
                        RosterView()
                    case .apiTest:
                        APITestView()  // Add this case
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Custom Tab Bar
                customTabBar
            }
        }
    }

    var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20))
                            .frame(height: 24)

                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(selectedTab == tab ? AppTheme.accent : AppTheme.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
        .background(AppTheme.cardBackground)
    }
}

#Preview {
    ContentView()
}
