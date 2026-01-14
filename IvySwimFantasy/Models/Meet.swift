import Foundation

struct Meet: Identifiable, Codable {
    let id: UUID
    let name: String
    let location: String
    let startDate: Date
    let endDate: Date
    var sessions: [MeetSession]
    var isLive: Bool

    var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        return "\(start) - \(end)"
    }
}

struct MeetSession: Identifiable, Codable {
    let id: UUID
    let name: String
    let date: Date
    let sessionType: SessionType
    var events: [MeetEvent]
    var isComplete: Bool
}

enum SessionType: String, Codable {
    case prelims = "Prelims"
    case finals = "Finals"
}

struct MeetEvent: Identifiable, Codable {
    let id: UUID
    let event: SwimEvent
    var results: [EventResult]
    var isComplete: Bool

    var topResult: EventResult? {
        results.min { $0.place < $1.place }
    }
}

extension Meet {
    var currentSession: MeetSession? {
        sessions.first { !$0.isComplete }
    }

    var completedEvents: Int {
        sessions.flatMap { $0.events }.filter { $0.isComplete }.count
    }

    var totalEvents: Int {
        sessions.flatMap { $0.events }.count
    }
}
