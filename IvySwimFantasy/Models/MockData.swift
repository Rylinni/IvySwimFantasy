import Foundation

class MockData {
    static let shared = MockData()

    let swimmers: [Swimmer]           // Current season swimmers
    let swimmers2022: [Swimmer]       // 2021-2022 season swimmers (for testing with old results)
    let fantasyTeams: [FantasyTeam]
    let league: FantasyLeague
    let meet: Meet

    private init() {
        // Real Ivy League swimmers from SwimCloud (scraped data)
        let swimmersData: [(String, String, IvySchool, ClassYear, [SwimEvent])] = [
            // Harvard (27 swimmers)
            ("Joshua", "Chen", .harvard, .sophomore, [.breast100, .breast200]),
            ("Evan", "Croley", .harvard, .sophomore, [.free100, .free50]),
            ("Tristan", "Dalbey", .harvard, .junior, [.free50]),
            ("Marre", "Gattnar", .harvard, .sophomore, [.free100, .free200, .free50]),
            ("David", "Greeley", .harvard, .senior, [.free100, .free200, .free50]),
            ("Denny", "Gulia-Janovski", .harvard, .senior, [.free100, .free200]),
            ("Nicola", "Hensch", .harvard, .senior, [.back100, .back200, .free500]),
            ("Jack", "Holland", .harvard, .senior, [.free100, .free200]),
            ("Mark", "Iltsisin", .harvard, .freshman, [.free100, .free200]),
            ("Aykut", "Mert Iravul", .harvard, .sophomore, [.free100, .free200]),
            ("Filip", "Lanyi", .harvard, .junior, [.free1000, .free500]),
            ("Eric", "Lee", .harvard, .sophomore, [.back100, .back200, .breast200]),
            ("Pablo", "Martinez Palop", .harvard, .freshman, [.free100, .free200]),
            ("Maro", "Miknic", .harvard, .freshman, [.fly100, .free100, .free50]),
            ("William", "Mulgrew", .harvard, .freshman, [.free200, .free50, .free500]),
            ("Ross", "Noble", .harvard, .senior, [.back100, .back200, .im200]),
            ("Ognjen", "Pilipovic", .harvard, .freshman, [.free100, .free200]),
            ("Oliver", "Pilkinton", .harvard, .junior, [.back100, .fly100, .free100]),
            ("Richard", "Poplawski", .harvard, .sophomore, [.fly200, .im200, .im400]),
            ("Vito", "Rados", .harvard, .freshman, [.breast100, .breast200, .free500]),
            ("David", "Schmitt", .harvard, .junior, [.back100, .fly100, .fly200]),
            ("Saavan", "Shah", .harvard, .senior, [.breast100]),
            ("Chase", "Shipp", .harvard, .freshman, [.free100, .free200]),
            ("William", "Sullivan", .harvard, .sophomore, [.free100, .free200]),
            ("Raphael", "Tourette", .harvard, .senior, [.free100, .free200]),
            ("Rem", "Turatbekov", .harvard, .freshman, [.free100, .free200]),
            ("Sonny", "Wang", .harvard, .junior, [.fly100, .free100, .free50]),

            // Yale (18 swimmers)
            ("Ben", "Carpeal", .yale, .sophomore, [.breast200, .free50, .free500]),
            ("Tommy", "Collins", .yale, .freshman, [.fly100, .fly200]),
            ("Christian", "Connell", .yale, .junior, [.breast100, .breast200, .im200]),
            ("Rafael", "de Sousa", .yale, .freshman, [.free100, .free200]),
            ("Rafael", "DeSousa", .yale, .sophomore, [.free100, .free200, .free500]),
            ("Adrian", "Fikry Reina", .yale, .sophomore, [.fly100, .free100, .free50]),
            ("Braden", "Hain", .yale, .junior, [.back100, .free100, .free50]),
            ("Dan", "Hastings", .yale, .senior, [.fly100, .free100, .free200]),
            ("Troy", "Hickman", .yale, .freshman, [.back100, .back200, .free50]),
            ("Tyler", "Hill", .yale, .freshman, [.back200, .free200, .free50]),
            ("Jake", "Hillibush", .yale, .junior, [.breast100, .breast200, .free50]),
            ("Elijah", "Innis", .yale, .senior, [.fly100, .free100, .free50]),
            ("Andrew", "Ketler", .yale, .junior, [.fly200]),
            ("Andrew", "Kettler", .yale, .junior, [.fly100, .fly200, .free50]),
            ("Caleb", "Ludlow", .yale, .freshman, [.breast100, .breast200, .im200]),
            ("Matthew", "Shollenberger", .yale, .junior, [.back100, .free100, .free50]),
            ("Kasey", "Stanton", .yale, .sophomore, [.fly100, .free100, .free50]),
            ("Cade", "Tysinger", .yale, .freshman, [.fly100, .fly200, .free50]),

            // Princeton (26 swimmers)
            ("Alexander", "Crossing", .princeton, .senior, [.fly200, .free1000, .free500]),
            ("Damian", "Czartoryjski", .princeton, .sophomore, [.fly100, .free200]),
            ("Drew", "Davis", .princeton, .freshman, [.back100, .back200, .fly100]),
            ("Chase", "Ferguson", .princeton, .senior, [.back100, .back200]),
            ("Finn", "Franks", .princeton, .sophomore, [.free1000, .free500]),
            ("Drew", "Greene", .princeton, .junior, [.free100, .free50]),
            ("Caleb", "Hagadorn", .princeton, .sophomore, [.back100, .back200]),
            ("Jake", "Hagler", .princeton, .freshman, [.free100, .free200]),
            ("William", "Harpster", .princeton, .sophomore, [.breast100, .free100]),
            ("Evan", "Hepburn", .princeton, .freshman, [.breast100, .breast200]),
            ("Jason", "Kellerman", .princeton, .freshman, [.back200, .fly200, .im400]),
            ("Jack", "Krug", .princeton, .senior, [.free100, .free200]),
            ("Caleb", "Kubiak", .princeton, .junior, [.back100, .im400]),
            ("Avery", "Kuhn", .princeton, .sophomore, [.back100, .back200]),
            ("James", "Lombardi", .princeton, .junior, [.breast100, .breast200]),
            ("Finn", "Lukens", .princeton, .freshman, [.breast100, .breast200, .free50]),
            ("CJ", "Meier", .princeton, .freshman, [.breast200, .fly200]),
            ("Matt", "Raudabaugh", .princeton, .senior, [.breast100, .breast200]),
            ("Finn", "Russell", .princeton, .junior, [.fly100, .free50]),
            ("William", "Shoemaker", .princeton, .senior, [.free1000, .free500]),
            ("Colin", "Smith", .princeton, .junior, [.free100, .free200]),
            ("Sam", "Sweetser", .princeton, .senior, [.free100, .free200]),
            ("Connor", "Thurston", .princeton, .junior, [.free100, .free200]),
            ("Riley", "Twiss", .princeton, .junior, [.free100, .free200]),
            ("Jackson", "Vinarub", .princeton, .senior, [.free100, .free200]),
            ("Shane", "Wynne", .princeton, .senior, [.free100, .free200]),

            // Columbia (39 swimmers)
            ("Allen", "Cai", .columbia, .junior, [.back100, .fly100, .free100]),
            ("Lucas", "Canteros-Paz", .columbia, .senior, [.fly100, .free200]),
            ("Holden", "Carter", .columbia, .sophomore, [.back100, .fly100, .fly200]),
            ("Logan", "Cicman", .columbia, .senior, [.fly100, .free100, .free50]),
            ("Will", "Cooley", .columbia, .sophomore, [.free100, .free200]),
            ("Josh", "Corn", .columbia, .junior, [.breast200, .im200]),
            ("Dylan", "Dettloff", .columbia, .junior, [.fly100, .free100, .free200]),
            ("Will", "Dietz", .columbia, .junior, [.back100, .back200, .free100]),
            ("Sam", "Eckert", .columbia, .senior, [.breast100, .free100, .free50]),
            ("Ali", "Elmasry", .columbia, .senior, [.breast100, .breast200, .im200]),
            ("Derek", "Hitchens", .columbia, .freshman, [.back100, .fly100, .fly200]),
            ("Derek", "Hong", .columbia, .freshman, [.free100, .free200]),
            ("Nathan", "Jacobbe", .columbia, .freshman, [.fly200, .free200, .free50]),
            ("Zion", "James", .columbia, .senior, [.back100, .free100, .free50]),
            ("Bryce", "Key", .columbia, .sophomore, [.free200, .free50, .free500]),
            ("Kevin", "Kong", .columbia, .freshman, [.back100, .fly100, .free100]),
            ("Brian", "Lee", .columbia, .freshman, [.fly100, .free500]),
            ("Brian", "Lee", .columbia, .senior, [.fly100, .fly200, .free50]),
            ("Mackenzie", "Lu", .columbia, .freshman, [.free100, .free200]),
            ("Ryan", "Makouar", .columbia, .sophomore, [.back100, .fly100, .fly200]),
            ("Joseph", "Nicol", .columbia, .senior, [.free100, .free200]),
            ("Kevin", "Obochi", .columbia, .junior, [.fly100, .free100, .free200]),
            ("Ryan", "Pak", .columbia, .junior, [.breast100, .breast200, .im200]),
            ("Ivan", "Paligorov", .columbia, .junior, [.free100, .free200, .free50]),
            ("Alston", "Qin", .columbia, .freshman, [.breast100, .breast200, .free500]),
            ("Seth", "Roach", .columbia, .senior, [.fly100, .fly200, .free100]),
            ("David", "Sacca", .columbia, .junior, [.breast100, .breast200, .fly100]),
            ("Gian", "Santos", .columbia, .sophomore, [.breast200, .free200]),
            ("Paddy", "Troy", .columbia, .senior, [.free200, .free50, .free500]),
            ("Zach", "Vasser", .columbia, .junior, [.free200, .free50, .free500]),
            ("Jason", "Wang", .columbia, .freshman, [.back100, .fly100, .free100]),
            ("Kyle", "Won", .columbia, .freshman, [.back100, .back200, .free200]),
            ("Adam", "Wu", .columbia, .senior, [.fly200, .free100, .free200]),
            ("Jerry", "Yan", .columbia, .sophomore, [.back100, .fly100, .fly200]),
            ("Beri", "Yang", .columbia, .junior, [.breast100, .free100, .free200]),
            ("Ethan", "Zhang", .columbia, .freshman, [.fly100, .free100, .free200]),
            ("Michael", "Zhang", .columbia, .senior, [.breast100, .breast200, .im200]),
            ("Lucas", "Zhang", .columbia, .sophomore, [.fly100]),
            ("Stephen", "Zhukov", .columbia, .sophomore, [.free200, .free50, .free500]),

            // Penn (32 swimmers)
            ("Liam", "Campbell", .penn, .junior, [.free50]),
            ("James", "Curreri", .penn, .senior, [.back100, .back200]),
            ("Rohan", "D'Souza Larson", .penn, .freshman, [.breast100]),
            ("Victor", "Dang", .penn, .sophomore, [.free100, .free200]),
            ("Alex", "Fu", .penn, .senior, [.fly100, .free50]),
            ("Henry", "Guo", .penn, .freshman, [.fly100, .fly200]),
            ("Benji", "Ham", .penn, .junior, [.back100, .back200, .fly100]),
            ("Jack", "Handelman", .penn, .freshman, [.free100, .free200]),
            ("Xavier", "Hill", .penn, .senior, [.free100, .free200]),
            ("Jeffrey", "Hou", .penn, .sophomore, [.back100, .fly100, .im200]),
            ("Aaron", "Jia", .penn, .freshman, [.free1000, .free500]),
            ("Kevin", "Jiang", .penn, .sophomore, [.free100]),
            ("Eddie", "Jin", .penn, .sophomore, [.free200]),
            ("Pippin", "Kantakom", .penn, .freshman, [.im200]),
            ("Jonathan", "Koumendakos", .penn, .freshman, [.back100, .free100, .free50]),
            ("John", "Lieberman", .penn, .sophomore, [.free50]),
            ("Max", "Malakhovets", .penn, .sophomore, [.fly200]),
            ("Neo", "Matsuyama", .penn, .senior, [.free100, .free200]),
            ("Ryan", "McGuirk", .penn, .senior, [.free100]),
            ("Robert", "Melsom", .penn, .junior, [.free1000, .free500]),
            ("Watson", "Nguyen", .penn, .sophomore, [.breast100, .breast200]),
            ("Cooper", "Nicholson", .penn, .sophomore, [.free1000]),
            ("Aiden", "Rhee", .penn, .freshman, [.free100, .free200]),
            ("Henry", "Sheils", .penn, .senior, [.back100, .fly100, .fly200]),
            ("Evan", "Spagnoletti", .penn, .junior, [.fly100, .fly200]),
            ("Vincent", "Vinciguerra", .penn, .sophomore, [.free200]),
            ("Peter", "Whittington", .penn, .junior, [.breast200, .fly200, .im200]),
            ("Andrew", "Xie", .penn, .freshman, [.back100, .back200]),
            ("Can", "Yeniay", .penn, .sophomore, [.free100, .free200]),
            ("Colin", "Zhang", .penn, .sophomore, [.breast100, .breast200]),
            ("Weifan", "Zhang", .penn, .junior, [.free100, .free200, .free500]),
            ("Andy", "Zhou", .penn, .sophomore, [.free500]),

            // Brown (18 swimmers)
            ("Guilherme", "Caribé", .brown, .senior, [.free100, .free200]),
            ("Thomas", "Ciprik", .brown, .freshman, [.free100, .free200]),
            ("Mac", "Clark", .brown, .freshman, [.free1000, .free500]),
            ("Ethan", "Dumesnil", .brown, .freshman, [.free100, .free200]),
            ("Martin", "Espernberger", .brown, .senior, [.fly100, .fly200]),
            ("Bennett", "Greene", .brown, .sophomore, [.free100, .free200]),
            ("Aidan", "Hill", .brown, .sophomore, [.fly100, .fly200]),
            ("Tony", "Laurito", .brown, .sophomore, [.back200, .free200, .im200]),
            ("Jake", "McCoy", .brown, .freshman, [.breast200, .fly200, .im200]),
            ("Kamal", "Muhammad", .brown, .senior, [.breast200, .free50]),
            ("Gabe", "Nunziata", .brown, .freshman, [.breast100, .im200]),
            ("Grayson", "Nye", .brown, .sophomore, [.breast100, .breast200]),
            ("Owen", "Redfearn", .brown, .senior, [.free100, .free200]),
            ("Pedro", "Sansone Teixeira", .brown, .sophomore, [.free100, .free200]),
            ("Ulises", "Saravia", .brown, .freshman, [.back100, .back200]),
            ("Nick", "Simons", .brown, .senior, [.back100, .back200, .im200]),
            ("Nick", "Stone", .brown, .senior, [.free100, .free200]),
            ("Frazer", "Tavener", .brown, .freshman, [.free100, .free200]),

            // Cornell (21 swimmers)
            ("Diego", "Carrillo", .cornell, .junior, [.free100, .free200]),
            ("Ryan", "Foucault", .cornell, .junior, [.free100, .free200]),
            ("Timothée", "Garin-Coupillaud", .cornell, .freshman, [.free100, .free200]),
            ("Daniel", "Khmara", .cornell, .senior, [.fly100, .free100, .free50]),
            ("William", "LaCount", .cornell, .senior, [.fly100, .free50]),
            ("Jef", "Leroux", .cornell, .freshman, [.fly100, .free100, .free50]),
            ("Hudson", "Lowery", .cornell, .senior, [.fly100, .fly200, .free50]),
            ("Bazil", "Massotte", .cornell, .freshman, [.free100, .free200, .free50]),
            ("Nick", "Metzler", .cornell, .junior, [.breast100, .breast200, .im200]),
            ("Youssef", "Nahali", .cornell, .junior, [.fly100, .free100, .free50]),
            ("Leo", "Nolles", .cornell, .senior, [.free100, .free200]),
            ("Caleb", "Rice", .cornell, .senior, [.back100, .back200, .fly100]),
            ("Alex", "Richardson", .cornell, .junior, [.breast200]),
            ("Ian", "Rocheleau", .cornell, .senior, [.back100, .back200, .fly100]),
            ("Alessandro", "Rosatelli", .cornell, .junior, [.free100, .free200]),
            ("Rafael", "Schaub", .cornell, .freshman, [.fly100]),
            ("Tobie", "Stiles", .cornell, .senior, [.free100, .free200]),
            ("Aiden", "Strath", .cornell, .junior, [.free100, .free200]),
            ("Max", "Swiatkowski", .cornell, .senior, [.back100, .back200, .free50]),
            ("Andrew", "Tease", .cornell, .senior, [.breast100, .breast200, .fly100]),
            ("Travis", "Thornton", .cornell, .freshman, [.free100, .free200]),

            // Dartmouth (30 swimmers)
            ("Nico", "Cecchi", .dartmouth, .junior, [.back100, .back200, .fly100]),
            ("Mathias", "Christensen", .dartmouth, .sophomore, [.breast200, .fly200, .im200]),
            ("Kaiser", "Dominik", .dartmouth, .freshman, [.free100, .free200]),
            ("Marcos", "Egri-Martin", .dartmouth, .senior, [.breast100, .breast200]),
            ("Alex", "Heinrich", .dartmouth, .freshman, [.fly100, .fly200]),
            ("Mathew", "Iverson", .dartmouth, .junior, [.back100, .back200, .im200]),
            ("Walter", "Kueffer", .dartmouth, .freshman, [.free100, .free50]),
            ("Utku", "Kurtdere", .dartmouth, .senior, [.fly200, .free200]),
            ("Fred", "Lindholm", .dartmouth, .sophomore, [.free1000, .free500]),
            ("Daniel", "Listor", .dartmouth, .sophomore, [.breast100, .fly100]),
            ("Carlos", "Martinez", .dartmouth, .sophomore, [.free100, .free200]),
            ("Thomas", "Matheson", .dartmouth, .freshman, [.fly200, .free1000, .free500]),
            ("Liam", "O'Connor", .dartmouth, .freshman, [.breast100, .breast200]),
            ("Seneca", "Oddo", .dartmouth, .sophomore, [.breast100, .free50]),
            ("Gustav", "Olsson", .dartmouth, .junior, [.free100, .free200]),
            ("Jaka", "Pusnik", .dartmouth, .senior, [.back100, .back200]),
            ("Charlie", "Rennard", .dartmouth, .sophomore, [.fly100, .fly200]),
            ("Andrew", "Rich", .dartmouth, .junior, [.back200, .free200]),
            ("Logan", "Robinson", .dartmouth, .sophomore, [.free200]),
            ("Jack", "Rowell", .dartmouth, .freshman, [.free50]),
            ("Hayden", "Schroeder", .dartmouth, .sophomore, [.free100, .free200]),
            ("Tobias", "Schulrath", .dartmouth, .junior, [.fly100, .free50]),
            ("Max", "Shaver", .dartmouth, .freshman, [.free100, .free200]),
            ("Aidan", "Siers", .dartmouth, .sophomore, [.free100, .free200]),
            ("Ethan", "Silver", .dartmouth, .freshman, [.free100, .free200]),
            ("Jack", "Sparks", .dartmouth, .freshman, [.free100, .free200]),
            ("Noah", "Turner", .dartmouth, .sophomore, [.free100, .free200]),
            ("Carlos", "Vargas", .dartmouth, .freshman, [.free100, .free200]),
            ("Max", "Wilson", .dartmouth, .senior, [.free100, .free200]),
            ("Calvin", "Wise", .dartmouth, .freshman, [.free100, .free200]),
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
                fantasyPoints: 0,
                projectedPoints: 0
            )
            createdSwimmers.append(swimmer)
        }
        self.swimmers = createdSwimmers

        // 2021-2022 Ivy League swimmers with events and times from SwimCloud
        let swimmers2022Data: [(String, String, IvySchool, ClassYear, [SwimEvent])] = [
            // Harvard (36 swimmers)
            ("Matthew", "Chung", .harvard, .freshman, [.fly100, .breast100]),
            ("Aayush", "Deshpande", .harvard, .freshman, [.fly100, .back100]),
            ("Pierce", "Dietze", .harvard, .junior, [.free50, .fly100, .back100]),
            ("Harris", "Durham", .harvard, .freshman, [.free50, .breast100]),
            ("Dean", "Farris", .harvard, .freshman, [.free50, .back100, .fly100]),
            ("Luke", "Foster", .harvard, .junior, [.free100, .free200]),
            ("Corby", "Furrer", .harvard, .freshman, [.fly100, .free100]),
            ("Will", "Grant", .harvard, .sophomore, [.back100, .breast100, .fly100]),
            ("Cameron", "Green", .harvard, .freshman, [.free50, .back100, .fly100]),
            ("Umit", "Gures", .harvard, .senior, [.fly100]),
            ("Quinn", "Harron", .harvard, .freshman, [.breast100, .fly100]),
            ("Luca", "Hensch", .harvard, .senior, [.free50, .back100, .free100]),
            ("Marcus", "Holmquist", .harvard, .sophomore, [.free50, .free100]),
            ("Jake", "Johnson", .harvard, .senior, [.fly100]),
            ("Arik", "Katz", .harvard, .freshman, [.free50]),
            ("Daniel", "Kim", .harvard, .senior, [.fly100, .breast100]),
            ("Cole", "Kuster", .harvard, .junior, [.free50, .back100, .free100]),
            ("Simon", "Lamar", .harvard, .senior, [.free100, .free200]),
            ("Ryan", "Linnihan", .harvard, .senior, [.free50, .fly100, .breast100]),
            ("Ben", "Littlejohn", .harvard, .freshman, [.free100]),
            ("Raphael", "Marcoux", .harvard, .freshman, [.free50, .fly100]),
            ("Emmanuel", "Ngbemeneh", .harvard, .senior, [.free50, .back100, .free100]),
            ("Nick", "Nocita", .harvard, .junior, [.free100, .free200]),
            ("Jonathan", "Novinski", .harvard, .freshman, [.free50, .breast100, .free100]),
            ("Alex", "Petty", .harvard, .junior, [.fly100, .breast100]),
            ("Daniel", "Puczko", .harvard, .senior, [.back100, .free100]),
            ("Will", "Raidt", .harvard, .freshman, [.free50, .fly100, .back100]),
            ("Mahlon", "Reihman", .harvard, .freshman, [.free50, .fly100, .free100]),
            ("Dylan", "Rhee", .harvard, .freshman, [.breast100]),
            ("Anthony", "Rincon", .harvard, .freshman, [.back100, .fly100, .free50]),
            ("Jared", "Simpson", .harvard, .senior, [.breast100]),
            ("Ryan", "Tierney", .harvard, .sophomore, [.free50, .fly100, .free100]),
            ("Shane", "Washart", .harvard, .freshman, [.free50, .fly100, .back100]),
            ("Hal", "Watts", .harvard, .freshman, [.free100, .free200]),
            ("Adam", "Wesson", .harvard, .freshman, [.free100, .free200]),
            ("Michael", "Zarian", .harvard, .freshman, [.fly100, .back100]),
            // Yale (11 swimmers)
            ("Richard", "Certuche", .yale, .freshman, [.free50, .fly100, .breast100]),
            ("Dylan", "Cossin", .yale, .freshman, [.breast100, .fly100]),
            ("Caleb", "Dankle", .yale, .senior, [.fly100, .free50, .back100]),
            ("Colton", "Dvorak", .yale, .freshman, [.free50, .fly100, .breast100]),
            ("Luke", "Edmonds", .yale, .junior, [.free50, .fly100, .free100]),
            ("Aaron", "Frederick", .yale, .freshman, [.free50, .breast100, .free100]),
            ("Gerardo", "Gonzalez", .yale, .sophomore, [.back100]),
            ("Bear", "Kinney", .yale, .junior, [.free50, .fly100, .breast100]),
            ("Sean", "Mitcho", .yale, .freshman, [.free50, .fly100, .back100]),
            ("Kevin", "Morgan", .yale, .junior, [.free50, .fly100, .breast100]),
            ("Jacob", "Neal", .yale, .sophomore, [.fly100, .free50, .back100]),
            // Princeton (14 swimmers)
            ("William", "Cadwallader", .princeton, .senior, [.free100, .free200]),
            ("Kevin", "Crane", .princeton, .sophomore, [.fly100, .breast100, .free50]),
            ("Justin", "DiSanto", .princeton, .freshman, [.free50, .fly100]),
            ("Andy", "Dorsel", .princeton, .freshman, [.breast100, .fly100]),
            ("Christopher", "Fabian", .princeton, .sophomore, [.fly100, .back100, .free50]),
            ("John", "Gehrig", .princeton, .sophomore, [.fly100]),
            ("Nick", "Haddad", .princeton, .senior, [.fly100, .back100, .free100]),
            ("Ryaan", "Hatoum", .princeton, .junior, [.free50, .breast100]),
            ("Will", "Hedges", .princeton, .freshman, [.free50, .breast100]),
            ("Garrett", "Kiesel", .princeton, .junior, [.free50, .back100, .free100]),
            ("Derek", "Knight", .princeton, .senior, [.free50, .free100]),
            ("Chris", "Kopac", .princeton, .freshman, [.breast100, .fly100]),
            ("Leo", "Kuyl", .princeton, .junior, [.free50, .fly100, .breast100]),
            ("Connor", "Martin", .princeton, .sophomore, [.free50, .fly100, .back100]),
            // Columbia (29 swimmers)
            ("Michael", "Chang", .columbia, .junior, [.fly100, .breast100]),
            ("Jonathan", "Cheng", .columbia, .senior, [.free50, .breast100]),
            ("Josh", "Cho", .columbia, .freshman, [.back100, .fly100]),
            ("Ian", "Choi", .columbia, .freshman, [.free50, .fly100, .free100]),
            ("Noah", "Czelusta", .columbia, .sophomore, [.fly100, .breast100]),
            ("Demirkan", "Demir", .columbia, .freshman, [.breast100]),
            ("Keegan", "Drew", .columbia, .junior, [.free50, .fly100]),
            ("Jack", "Engel", .columbia, .freshman, [.free50, .fly100]),
            ("Jackson", "England", .columbia, .senior, [.free50, .fly100, .breast100]),
            ("Casey", "Fellows", .columbia, .junior, [.free100, .free200]),
            ("Andrew", "Fouty", .columbia, .freshman, [.free100, .free200]),
            ("Albert", "Gwo", .columbia, .freshman, [.free100, .free200]),
            ("Andy", "Huang", .columbia, .sophomore, [.free100, .free200]),
            ("Jonas", "Nervil Kistorp", .columbia, .senior, [.free100, .free200]),
            ("Nolan", "Kopp", .columbia, .sophomore, [.free100, .free200]),
            ("Hunter", "Kroll", .columbia, .sophomore, [.free100, .free200]),
            ("John", "Laidlaw", .columbia, .freshman, [.free100, .free200]),
            ("Nick", "Leavell", .columbia, .junior, [.free100, .free200]),
            ("Stanford", "Li", .columbia, .sophomore, [.free100, .free200]),
            ("Joey", "Licht", .columbia, .senior, [.free100, .free200]),
            ("Hayden", "Liu", .columbia, .senior, [.free100, .free200]),
            ("Tristan", "Pragnell", .columbia, .freshman, [.free100, .free200]),
            ("Thomas", "Shepanzyk", .columbia, .junior, [.free100, .free200]),
            ("Ike", "Shirakata", .columbia, .junior, [.free100, .free200]),
            ("Rene", "Strezenicky", .columbia, .sophomore, [.free100, .free200]),
            ("Jonathan", "Suckow", .columbia, .freshman, [.free100, .free200]),
            ("David", "Wang", .columbia, .senior, [.free100, .free200]),
            ("Kyle", "Won", .columbia, .freshman, [.free100, .free200]),
            ("Ray", "Yang", .columbia, .junior, [.free100, .free200]),
            // Penn (30 swimmers)
            ("Andrew", "Dai", .penn, .sophomore, [.fly100]),
            ("Keanan", "Dols", .penn, .junior, [.back100, .breast100, .free50]),
            ("Sam", "Donchi", .penn, .sophomore, [.fly100, .back100]),
            ("Vlad", "Elizarov", .penn, .junior, [.free50, .fly100, .free100]),
            ("Matt", "Fallon", .penn, .freshman, [.breast100]),
            ("Billy", "Fallon", .penn, .senior, [.free200, .back200, .im200]),
            ("Ben", "Feldman", .penn, .sophomore, [.fly100, .breast100, .free100]),
            ("Michael", "Foley", .penn, .freshman, [.free50, .free100, .fly100]),
            ("Daniel", "Gallagher", .penn, .freshman, [.free100, .back100, .free200]),
            ("Jack", "Hamilton", .penn, .freshman, [.free50, .back100, .breast100]),
            ("CJ", "Hinckley", .penn, .senior, [.free100, .free200]),
            ("Cody", "Hopkins", .penn, .freshman, [.free100, .free200]),
            ("Will", "Kamps", .penn, .senior, [.free100, .free200]),
            ("Kevin", "Keil", .penn, .sophomore, [.free100, .free200]),
            ("Matthew", "Leblanc", .penn, .sophomore, [.free100, .free200]),
            ("Peter", "Lee", .penn, .junior, [.free100, .free200]),
            ("Thomas", "Lewis", .penn, .freshman, [.free100, .free200]),
            ("Jack", "Loveless", .penn, .senior, [.free100, .free200]),
            ("Nicholas", "Malchow", .penn, .freshman, [.free100, .free200]),
            ("Mark", "McCrary", .penn, .junior, [.free100, .free200]),
            ("Trevor", "Nelson", .penn, .junior, [.free100, .free200]),
            ("Jaden", "Olson", .penn, .freshman, [.free100, .free200]),
            ("Tate", "Park", .penn, .freshman, [.free100, .free200]),
            ("Aaron", "Rosen", .penn, .freshman, [.free100, .free200]),
            ("Jason", "Schreiber", .penn, .junior, [.free100, .free200]),
            ("Neil", "Simpson", .penn, .junior, [.free100, .free200]),
            ("Daniel", "Trincher", .penn, .freshman, [.free100, .free200]),
            ("Eric", "Wang", .penn, .junior, [.free100, .free200]),
            ("Jack", "Williams", .penn, .sophomore, [.free100, .free200]),
            ("Luke", "Williams", .penn, .freshman, [.free100, .free200]),
            // Brown (30 swimmers)
            ("Micah", "Chambers", .brown, .sophomore, [.free50, .fly100, .back100]),
            ("Brett", "Champlin", .brown, .junior, [.breast100, .back100]),
            ("Jordan", "Crooks", .brown, .freshman, [.free50, .fly100]),
            ("Jarel", "Dillard", .brown, .senior, [.free50, .breast100]),
            ("Duncan", "Drysdale", .brown, .freshman, [.free50, .back100, .breast100]),
            ("Lyubomir", "Epitropov", .brown, .senior, [.breast100]),
            ("Jack", "Flanagan", .brown, .freshman, [.free50, .fly100, .free100]),
            ("Joel", "Giraudeau", .brown, .junior, [.fly100, .free50, .breast100]),
            ("Griffin", "Hadley", .brown, .freshman, [.back100, .fly100]),
            ("Bryden", "Hattie", .brown, .sophomore, [.free100, .free200]),
            ("Thomas", "Horne", .brown, .sophomore, [.free100, .free200]),
            ("Michael", "Houlie", .brown, .senior, [.free100, .free200]),
            ("Will", "Jackson", .brown, .sophomore, [.free100, .free200]),
            ("Joseph", "Jordan", .brown, .sophomore, [.free100, .free200]),
            ("Bjorn", "Kammann", .brown, .freshman, [.free100, .free200]),
            ("Harrison", "Lierz", .brown, .sophomore, [.free100, .free200]),
            ("Kayky", "Marquart Mota", .brown, .senior, [.free100, .free200]),
            ("Nicholas", "McCann", .brown, .junior, [.free100, .free200]),
            ("Jake", "Narvid", .brown, .sophomore, [.free100, .free200]),
            ("Rafael", "Ponce De Leon", .brown, .sophomore, [.free100, .free200]),
            ("Jacob", "Reasor", .brown, .sophomore, [.free100, .free200]),
            ("Dillon", "Richardson", .brown, .sophomore, [.free100, .free200]),
            ("Dain", "Ripol", .brown, .sophomore, [.free100, .free200]),
            ("Gus", "Rothrock", .brown, .freshman, [.free100, .free200]),
            ("Scott", "Scanlon", .brown, .junior, [.free100, .free200]),
            ("Jack", "Stelter", .brown, .freshman, [.free100, .free200]),
            ("Aleksey", "Tarasenko", .brown, .senior, [.free100, .free200]),
            ("Joey", "Tepper", .brown, .sophomore, [.free100, .free200]),
            ("Joaquin", "Vargas", .brown, .freshman, [.free100, .free200]),
            ("Matt", "Wade", .brown, .senior, [.free100, .free200]),
            // Cornell (21 swimmers)
            ("Niels", "Callewaert", .cornell, .sophomore, [.free50, .fly100, .breast100]),
            ("Roberto", "Camera", .cornell, .senior, [.free50, .breast100]),
            ("Grant", "Combs", .cornell, .senior, [.free50]),
            ("Jackson", "Cotter", .cornell, .freshman, [.free50, .back100, .free100]),
            ("Freddie", "Deweese", .cornell, .sophomore, [.breast100]),
            ("Conor", "Graydon", .cornell, .senior, [.free50, .fly100, .back100]),
            ("Carter", "Hill", .cornell, .freshman, [.free50, .breast100]),
            ("Erikas", "Kapočius", .cornell, .junior, [.back100, .free200]),
            ("Ryan", "Leach", .cornell, .junior, [.free100, .free200]),
            ("Felipe", "Lemos", .cornell, .senior, [.free50, .fly100, .breast100]),
            ("Levi", "Lewis", .cornell, .senior, [.back100, .free100, .free200]),
            ("Ryan", "Lund", .cornell, .sophomore, [.free100, .free200]),
            ("Luke", "Pettinger", .cornell, .sophomore, [.free100, .free200]),
            ("Jasper", "Pullinen", .cornell, .sophomore, [.free100, .free200]),
            ("Ross", "Raatz", .cornell, .junior, [.free100, .free200]),
            ("Dean", "Ramsbottom", .cornell, .freshman, [.free100, .free200]),
            ("Ben", "Stolberg", .cornell, .senior, [.free100, .free200]),
            ("Nathan", "True", .cornell, .freshman, [.free100, .free200]),
            ("James", "Werwie", .cornell, .freshman, [.free100, .free200]),
            ("Marty", "Wolmarans", .cornell, .freshman, [.free100, .free200]),
            ("Ondřej", "Zach", .cornell, .junior, [.free100, .free200]),
            // Dartmouth (38 swimmers)
            ("Rush", "Clark", .dartmouth, .sophomore, [.free50, .fly100]),
            ("Telly", "Coleman", .dartmouth, .sophomore, [.free50, .fly100]),
            ("Ian", "Cooper", .dartmouth, .junior, [.free50, .back100, .fly100]),
            ("Rian", "Covington", .dartmouth, .freshman, [.free50, .fly100]),
            ("Josh", "Davidson", .dartmouth, .freshman, [.free100, .free200]),
            ("Domen", "Demsar", .dartmouth, .junior, [.free50, .fly100]),
            ("Aziz", "Ghaffari", .dartmouth, .junior, [.free50, .free100]),
            ("Brennan", "Hammond", .dartmouth, .junior, [.fly100, .breast100]),
            ("Tyler", "Hanley", .dartmouth, .freshman, [.fly100, .back100, .free50]),
            ("Jesco", "Helling", .dartmouth, .sophomore, [.free100, .free200]),
            ("Mason", "Herbet", .dartmouth, .sophomore, [.back100, .fly100, .breast100]),
            ("Jokubas", "Keblys", .dartmouth, .freshman, [.free100, .free200]),
            ("Matthew", "Kowalski", .dartmouth, .sophomore, [.free100, .free200]),
            ("Jakub", "Ksiazek", .dartmouth, .senior, [.free100, .free200]),
            ("Ian", "Lauritzen", .dartmouth, .sophomore, [.free100, .free200]),
            ("Conner", "Lowery", .dartmouth, .sophomore, [.free100, .free200]),
            ("Jason", "Martindale", .dartmouth, .freshman, [.free100, .free200]),
            ("Nick", "Mason", .dartmouth, .junior, [.free100, .free200]),
            ("Max", "McCusker", .dartmouth, .senior, [.free100, .free200]),
            ("Dominic", "Miller", .dartmouth, .freshman, [.free100, .free200]),
            ("Tre'V", "Monroe", .dartmouth, .freshman, [.free100, .free200]),
            ("Blake", "Moran", .dartmouth, .junior, [.free100, .free200]),
            ("Darwin", "Nolasco", .dartmouth, .sophomore, [.free100, .free200]),
            ("Auben", "Nugent", .dartmouth, .freshman, [.free100, .free200]),
            ("Arijus", "Pavlidi", .dartmouth, .freshman, [.free100, .free200]),
            ("Tiago", "Pereira", .dartmouth, .freshman, [.free100, .free200]),
            ("David", "Quirie", .dartmouth, .sophomore, [.free100, .free200]),
            ("Quinn", "Scholz", .dartmouth, .junior, [.free100, .free200]),
            ("Jackson", "Seith", .dartmouth, .freshman, [.free100, .free200]),
            ("Miguel", "Sierra", .dartmouth, .freshman, [.free100, .free200]),
            ("Noah", "Smith", .dartmouth, .junior, [.free100, .free200]),
            ("Zachary", "Smith", .dartmouth, .sophomore, [.free100, .free200]),
            ("Tanker", "Speck", .dartmouth, .sophomore, [.free100, .free200]),
            ("Cam", "Taddonio", .dartmouth, .junior, [.free100, .free200]),
            ("David", "Vargas Garcia", .dartmouth, .sophomore, [.free100, .free200]),
            ("Peter", "Varjasi", .dartmouth, .junior, [.free100, .free200]),
            ("Nevada", "Wood", .dartmouth, .senior, [.free100, .free200]),
            ("Yordan", "Yanchev", .dartmouth, .sophomore, [.free100, .free200]),
        ]

        var created2022Swimmers: [Swimmer] = []
        for data in swimmers2022Data {
            // Lookup times from the times dictionary
            let fullName = "\(data.0) \(data.1)"
            let swimmerTimes = SwimmerTimesData.times2022[fullName] ?? []

            let swimmer = Swimmer(
                id: UUID(),
                firstName: data.0,
                lastName: data.1,
                school: data.2,
                year: data.3,
                events: data.4,  // Real events from SwimCloud
                photoURL: nil,
                fantasyPoints: 0,
                projectedPoints: 0,
                times: swimmerTimes  // Personal best times from SwimCloud
            )
            created2022Swimmers.append(swimmer)
        }
        self.swimmers2022 = created2022Swimmers

        // Create empty fantasy teams (no swimmers drafted yet)
        let teamConfigs: [(String, String, String)] = [
            ("Chlorine Dreams", "Mike S.", "#FF6B6B"),
            ("Splash Bros", "John D.", "#4ECDC4"),
            ("Lane Legends", "Alex K.", "#45B7D1"),
            ("The Deep End", "Chris M.", "#96CEB4"),
            ("Swim Shady", "Ryan L.", "#FFEAA7"),
            ("Aqua Squad", "Dave T.", "#DDA0DD"),
        ]

        var teams: [FantasyTeam] = []
        for (index, config) in teamConfigs.enumerated() {
            var team = FantasyTeam(
                id: UUID(),
                name: config.0,
                ownerName: config.1,
                avatarColor: config.2,
                swimmers: [],  // No swimmers drafted
                totalPoints: 0,
                projectedPoints: 0
            )
            team.rank = index + 1
            teams.append(team)
        }
        self.fantasyTeams = teams

        // Create league
        self.league = FantasyLeague(
            id: UUID(),
            name: "Ivy Swim Fantasy 2026",
            season: "2025-2026",
            teams: teams,
            draftCompleted: false,  // Draft not completed
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
                    MeetEvent(id: UUID(), event: .free500, results: [], isComplete: false),
                    MeetEvent(id: UUID(), event: .im200, results: [], isComplete: false),
                    MeetEvent(id: UUID(), event: .free50, results: [], isComplete: false),
                ],
                isComplete: false
            ),
            MeetSession(
                id: UUID(),
                name: "Day 1 - Finals",
                date: startDate,
                sessionType: .finals,
                events: [
                    MeetEvent(id: UUID(), event: .free500, results: [], isComplete: false),
                    MeetEvent(id: UUID(), event: .im200, results: [], isComplete: false),
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
            isLive: false
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
