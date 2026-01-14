import Foundation

class MockData {
    static let shared = MockData()

    let swimmers: [Swimmer]
    let fantasyTeams: [FantasyTeam]
    let league: FantasyLeague
    let meet: Meet

    private init() {
        // Create realistic Ivy League swimmers
        let swimmersData: [(String, String, IvySchool, ClassYear, [SwimEvent], Double, Double)] = [
            // Harvard
            ("Jake", "Mitchell", .harvard, .senior, [.free50, .free100], 45.5, 52.0),
            ("Marcus", "Chen", .harvard, .junior, [.back100, .back200], 38.0, 44.0),
            ("Tyler", "Brooks", .harvard, .sophomore, [.breast100, .breast200], 32.5, 38.0),
            ("Ryan", "O'Connor", .harvard, .senior, [.fly100, .fly200], 41.0, 47.0),
            ("David", "Park", .harvard, .freshman, [.im200, .im400], 28.0, 35.0),

            // Yale
            ("Chris", "Anderson", .yale, .senior, [.free200, .free500], 48.0, 55.0),
            ("Matt", "Williams", .yale, .junior, [.back100, .back200], 35.0, 41.0),
            ("James", "Taylor", .yale, .senior, [.breast100, .breast200], 42.0, 48.0),
            ("Andrew", "Johnson", .yale, .sophomore, [.fly100, .fly200], 30.0, 36.0),
            ("Kevin", "Lee", .yale, .junior, [.free50, .free100], 37.5, 43.0),

            // Princeton
            ("Michael", "Brown", .princeton, .senior, [.free500, .free1650], 52.0, 60.0),
            ("Daniel", "Garcia", .princeton, .junior, [.back100, .back200], 40.0, 46.0),
            ("Josh", "Martinez", .princeton, .senior, [.breast100, .breast200], 36.0, 42.0),
            ("Eric", "Wilson", .princeton, .sophomore, [.im200, .im400], 34.0, 40.0),
            ("Alex", "Thompson", .princeton, .freshman, [.fly100, .fly200], 26.0, 32.0),

            // Penn
            ("Brian", "Davis", .penn, .senior, [.free100, .free200], 44.0, 50.0),
            ("Nick", "Rodriguez", .penn, .junior, [.back200, .im400], 33.0, 39.0),
            ("Tom", "White", .penn, .senior, [.breast100, .breast200], 39.0, 45.0),
            ("Sam", "Harris", .penn, .sophomore, [.fly200, .im200], 31.0, 37.0),
            ("Jack", "Clark", .penn, .junior, [.free50, .free100], 36.0, 42.0),

            // Columbia
            ("Ethan", "Lewis", .columbia, .senior, [.free200, .free500], 43.0, 49.0),
            ("Connor", "Walker", .columbia, .junior, [.back100, .back200], 34.0, 40.0),
            ("Lucas", "Hall", .columbia, .sophomore, [.breast100, .breast200], 29.0, 35.0),
            ("Owen", "Allen", .columbia, .senior, [.fly100, .fly200], 38.0, 44.0),
            ("Ben", "Young", .columbia, .freshman, [.im200, .im400], 25.0, 31.0),

            // Brown
            ("Will", "King", .brown, .senior, [.free500, .free1000], 46.0, 52.0),
            ("Aaron", "Wright", .brown, .junior, [.back100, .im200], 32.0, 38.0),
            ("Zach", "Scott", .brown, .senior, [.breast200, .im400], 40.0, 46.0),
            ("Dylan", "Green", .brown, .sophomore, [.fly100, .fly200], 28.0, 34.0),
            ("Luke", "Adams", .brown, .junior, [.free50, .free100], 35.0, 41.0),

            // Cornell
            ("Max", "Nelson", .cornell, .senior, [.free100, .free200], 47.0, 53.0),
            ("Cole", "Carter", .cornell, .junior, [.back200, .im400], 37.0, 43.0),
            ("Ian", "Mitchell", .cornell, .senior, [.breast100, .breast200], 41.0, 47.0),
            ("Evan", "Roberts", .cornell, .sophomore, [.fly200, .im200], 33.0, 39.0),
            ("Chase", "Turner", .cornell, .freshman, [.free50, .free100], 24.0, 30.0),

            // Dartmouth
            ("Grant", "Phillips", .dartmouth, .senior, [.free200, .free500], 42.0, 48.0),
            ("Blake", "Campbell", .dartmouth, .junior, [.back100, .back200], 31.0, 37.0),
            ("Trevor", "Parker", .dartmouth, .senior, [.breast100, .im200], 38.0, 44.0),
            ("Nate", "Evans", .dartmouth, .sophomore, [.fly100, .fly200], 27.0, 33.0),
            ("Sean", "Edwards", .dartmouth, .junior, [.im200, .im400], 34.0, 40.0),
        ]

        var createdSwimmers: [Swimmer] = []
        for data in swimmersData {
            let swimmer = Swimmer(
                id: UUID(),
                firstName: data.0,
                lastName: data.1,
                school: data.2,
                year: data.3,
                events: data.4,
                photoURL: nil,
                fantasyPoints: data.5,
                projectedPoints: data.6
            )
            createdSwimmers.append(swimmer)
        }
        self.swimmers = createdSwimmers

        // Create fantasy teams with drafted swimmers
        let teamConfigs: [(String, String, String, [Int])] = [
            ("Chlorine Dreams", "Mike S.", "#FF6B6B", [0, 6, 12, 18, 24, 30, 36]),
            ("Splash Bros", "John D.", "#4ECDC4", [1, 7, 13, 19, 25, 31, 37]),
            ("Lane Legends", "Alex K.", "#45B7D1", [2, 8, 14, 20, 26, 32, 38]),
            ("The Deep End", "Chris M.", "#96CEB4", [3, 9, 15, 21, 27, 33, 39]),
            ("Swim Shady", "Ryan L.", "#FFEAA7", [4, 5, 10, 16, 22, 28, 34]),
            ("Aqua Squad", "Dave T.", "#DDA0DD", [11, 17, 23, 29, 35, 36, 37]),
        ]

        var teams: [FantasyTeam] = []
        for (index, config) in teamConfigs.enumerated() {
            let swimmerIds = config.3.compactMap { idx -> UUID? in
                guard idx < createdSwimmers.count else { return nil }
                return createdSwimmers[idx].id
            }
            let totalPoints = config.3.compactMap { idx -> Double? in
                guard idx < createdSwimmers.count else { return nil }
                return createdSwimmers[idx].fantasyPoints
            }.reduce(0, +)
            let projectedPoints = config.3.compactMap { idx -> Double? in
                guard idx < createdSwimmers.count else { return nil }
                return createdSwimmers[idx].projectedPoints
            }.reduce(0, +)

            var team = FantasyTeam(
                id: UUID(),
                name: config.0,
                ownerName: config.1,
                avatarColor: config.2,
                swimmers: swimmerIds,
                totalPoints: totalPoints,
                projectedPoints: projectedPoints
            )
            team.rank = index + 1
            teams.append(team)
        }

        // Sort teams by points and assign ranks
        teams.sort { $0.totalPoints > $1.totalPoints }
        for i in 0..<teams.count {
            teams[i].rank = i + 1
        }
        self.fantasyTeams = teams

        // Create league
        self.league = FantasyLeague(
            id: UUID(),
            name: "Ivy Swim Fantasy 2026",
            season: "2025-2026",
            teams: teams,
            draftCompleted: true,
            meetId: nil
        )

        // Create meet data
        let meetId = UUID()
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2026, month: 2, day: 26))!
        let endDate = calendar.date(from: DateComponents(year: 2026, month: 3, day: 1))!

        let sessions: [MeetSession] = [
            MeetSession(
                id: UUID(),
                name: "Day 1 - Prelims",
                date: startDate,
                sessionType: .prelims,
                events: [
                    MeetEvent(id: UUID(), event: .free500, results: [], isComplete: true),
                    MeetEvent(id: UUID(), event: .im200, results: [], isComplete: true),
                    MeetEvent(id: UUID(), event: .free50, results: [], isComplete: true),
                ],
                isComplete: true
            ),
            MeetSession(
                id: UUID(),
                name: "Day 1 - Finals",
                date: startDate,
                sessionType: .finals,
                events: [
                    MeetEvent(id: UUID(), event: .free500, results: [], isComplete: true),
                    MeetEvent(id: UUID(), event: .im200, results: [], isComplete: true),
                    MeetEvent(id: UUID(), event: .free50, results: [], isComplete: false),
                ],
                isComplete: false
            ),
            MeetSession(
                id: UUID(),
                name: "Day 2 - Prelims",
                date: calendar.date(byAdding: .day, value: 1, to: startDate)!,
                sessionType: .prelims,
                events: [
                    MeetEvent(id: UUID(), event: .back100, results: [], isComplete: false),
                    MeetEvent(id: UUID(), event: .breast100, results: [], isComplete: false),
                    MeetEvent(id: UUID(), event: .free200, results: [], isComplete: false),
                ],
                isComplete: false
            ),
        ]

        self.meet = Meet(
            id: meetId,
            name: "Ivy League Championships",
            location: "DeNunzio Pool, Princeton",
            startDate: startDate,
            endDate: endDate,
            sessions: sessions,
            isLive: true
        )
    }

    func swimmers(for team: FantasyTeam) -> [Swimmer] {
        team.swimmers.compactMap { id in
            swimmers.first { $0.id == id }
        }
    }

    func swimmer(withId id: UUID) -> Swimmer? {
        swimmers.first { $0.id == id }
    }
}
