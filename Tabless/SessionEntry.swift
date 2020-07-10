import GRDB

/// The SessionEntry struct.
///
/// Identifiable conformance supports SwiftUI list animations
struct SessionEntry: Identifiable {
    /// Int64 is the recommended type for auto-incremented database ids.
    /// Use nil for records that are not inserted yet in the database.
    var id: Int64?
    var url: String
    var title: String
}

extension SessionEntry {
    /// Creates a new entry with given URL and title
    static func new(url: String, title: String = "") -> SessionEntry {
        SessionEntry(id: nil, url: url, title: title)
    }

    private static let samples = [
        SessionEntry.new(url: "http://example.com", title: "Example"),
        SessionEntry.new(url: "http://reddit.com", title: "Reddit"),
        SessionEntry.new(url: "http://google.com", title: "Google"),
    ]

    static func newRandom() -> SessionEntry {
        samples.randomElement()!
    }
}


// MARK: - Persistence
/// Make SessionEntry a Codable Record.
///
/// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension SessionEntry: Codable, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "sessionEntry"

    static let session = belongsTo(Session.self)

    // Define database columns from CodingKeys
    fileprivate enum Columns {
        static let url = Column(CodingKeys.url)
        static let title = Column(CodingKeys.title)
    }

    /// Updates a player id after it has been inserted in the database.
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

// MARK: - SessionEntry Database Requests
/// Define some player requests used by the application.
///
/// See https://github.com/groue/GRDB.swift/blob/master/README.md#requests
/// See https://github.com/groue/GRDB.swift/blob/master/Documentation/GoodPracticesForDesigningRecordTypes.md
extension DerivableRequest where RowDecoder == SessionEntry {
    /// A request of entries ordered by title
    ///
    /// For example:
    ///
    ///     let entries = try dbQueue.read { db in
    ///         try SessionEntry.all().orderedByTitle().fetchAll(db)
    ///     }
    func orderedByTitle() -> Self {
        order(SessionEntry.Columns.title)
    }
}
