import Foundation

class DataService: ObservableObject {
    static let shared = DataService()

    @Published var swimmers: [Swimmer] = []
    @Published var fantasyTeams: [FantasyTeam] = []
    @Published var currentMeet: Meet?
    @Published var isLoading = false
    @Published var error: Error?

    private let baseURL = "https://your-api-server.com/api"

    private init() {
        // Initialize with mock data for now
        loadMockData()
    }

    func loadMockData() {
        let mock = MockData.shared
        swimmers = mock.swimmers2022  // Using 2021-2022 roster for testing
        fantasyTeams = mock.fantasyTeams
        currentMeet = mock.meet
    }

    // MARK: - API Methods (for future implementation)

    func fetchSwimmers() async throws -> [Swimmer] {
        // TODO: Implement actual API call
        // let url = URL(string: "\(baseURL)/swimmers")!
        // let (data, _) = try await URLSession.shared.data(from: url)
        // return try JSONDecoder().decode([Swimmer].self, from: data)
        return MockData.shared.swimmers2022  // Using 2021-2022 roster for testing
    }

    func fetchMeetResults() async throws -> Meet {
        // TODO: Implement actual API call to fetch Hy-Tek results
        // let url = URL(string: "\(baseURL)/meet/results")!
        // let (data, _) = try await URLSession.shared.data(from: url)
        // return try JSONDecoder().decode(Meet.self, from: data)
        return MockData.shared.meet
    }

    func fetchLeagueStandings() async throws -> FantasyLeague {
        // TODO: Implement actual API call
        return MockData.shared.league
    }

    func refreshData() async {
        await MainActor.run {
            isLoading = true
        }

        do {
            let newSwimmers = try await fetchSwimmers()
            let newMeet = try await fetchMeetResults()

            await MainActor.run {
                swimmers = newSwimmers
                currentMeet = newMeet
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
            }
        }
    }
}

// MARK: - API Response Models

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
}

struct MeetResultsResponse: Codable {
    let meet: Meet
    let lastUpdated: Date
}
