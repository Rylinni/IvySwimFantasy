import Foundation

struct FantasyTeam: Identifiable, Codable {
    let id: UUID
    let name: String
    let ownerName: String
    let avatarColor: String
    var swimmers: [UUID]
    var totalPoints: Double
    var projectedPoints: Double

    var rank: Int?
}

struct FantasyLeague: Identifiable, Codable {
    let id: UUID
    let name: String
    let season: String
    var teams: [FantasyTeam]
    let draftCompleted: Bool
    let meetId: UUID?

    var sortedTeams: [FantasyTeam] {
        teams.sorted { $0.totalPoints > $1.totalPoints }
    }
}
