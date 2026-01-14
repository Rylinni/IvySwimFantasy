import Foundation

struct Swimmer: Identifiable, Codable, Hashable {
    let id: UUID
    let firstName: String
    let lastName: String
    let school: IvySchool
    let year: ClassYear
    let events: [SwimEvent]
    let photoURL: String?
    var fantasyPoints: Double
    var projectedPoints: Double

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var initials: String {
        let first = firstName.prefix(1)
        let last = lastName.prefix(1)
        return "\(first)\(last)"
    }
}

enum IvySchool: String, Codable, CaseIterable {
    case harvard = "Harvard"
    case yale = "Yale"
    case princeton = "Princeton"
    case columbia = "Columbia"
    case penn = "Penn"
    case brown = "Brown"
    case cornell = "Cornell"
    case dartmouth = "Dartmouth"

    var color: String {
        switch self {
        case .harvard: return "#A51C30"
        case .yale: return "#00356B"
        case .princeton: return "#FF6F00"
        case .columbia: return "#B9D9EB"
        case .penn: return "#011F5B"
        case .brown: return "#4E3629"
        case .cornell: return "#B31B1B"
        case .dartmouth: return "#00693E"
        }
    }

    var shortName: String {
        switch self {
        case .harvard: return "HAR"
        case .yale: return "YALE"
        case .princeton: return "PRIN"
        case .columbia: return "COL"
        case .penn: return "PENN"
        case .brown: return "BRO"
        case .cornell: return "COR"
        case .dartmouth: return "DAR"
        }
    }
}

enum ClassYear: String, Codable, CaseIterable {
    case freshman = "Fr."
    case sophomore = "So."
    case junior = "Jr."
    case senior = "Sr."
}

enum SwimEvent: String, Codable, CaseIterable {
    case free50 = "50 Free"
    case free100 = "100 Free"
    case free200 = "200 Free"
    case free500 = "500 Free"
    case free1000 = "1000 Free"
    case free1650 = "1650 Free"
    case back100 = "100 Back"
    case back200 = "200 Back"
    case breast100 = "100 Breast"
    case breast200 = "200 Breast"
    case fly100 = "100 Fly"
    case fly200 = "200 Fly"
    case im200 = "200 IM"
    case im400 = "400 IM"

    var shortName: String {
        switch self {
        case .free50: return "50 FR"
        case .free100: return "100 FR"
        case .free200: return "200 FR"
        case .free500: return "500 FR"
        case .free1000: return "1K FR"
        case .free1650: return "Mile"
        case .back100: return "100 BK"
        case .back200: return "200 BK"
        case .breast100: return "100 BR"
        case .breast200: return "200 BR"
        case .fly100: return "100 FL"
        case .fly200: return "200 FL"
        case .im200: return "200 IM"
        case .im400: return "400 IM"
        }
    }
}

struct EventResult: Identifiable, Codable {
    let id: UUID
    let swimmerId: UUID
    let event: SwimEvent
    let time: TimeInterval
    let place: Int
    let points: Double
    let isPrelim: Bool

    var formattedTime: String {
        let minutes = Int(time) / 60
        let seconds = time.truncatingRemainder(dividingBy: 60)
        if minutes > 0 {
            return String(format: "%d:%05.2f", minutes, seconds)
        } else {
            return String(format: "%.2f", seconds)
        }
    }
}
