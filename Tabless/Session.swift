import GRDB

struct Session: Identifiable {
    var id: Int64?
    var title: String
}

extension Session {
    static func new(title: String = "") -> Session {
        Session(id: nil, title: title)
    }

    private static let samples = [
        Session.new(title: "New Session"),
    ]

    static func newRandom() -> Session {
        samples.randomElement()!
    }
}


// MARK: - Persistence

extension Session: Codable, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "session"

    static let entries = hasMany(SessionEntry.self)

    fileprivate enum Columns {
        static let title = Column(CodingKeys.title)
    }

    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

// MARK: - Session Database Requests

extension DerivableRequest where RowDecoder == Session {

    func orderedByTitle() -> Self {
        order(Session.Columns.title)
    }
}
