import GRDB

/// The HistoryEntry struct.
///
/// Identifiable conformance supports SwiftUI list animations
struct HistoryEntry: Identifiable {
    /// Int64 is the recommended type for auto-incremented database ids.
    /// Use nil for records that are not inserted yet in the database.
    var id: Int64?
    var url: String
    var title: String
}

extension HistoryEntry {
    /// Creates a new entry with given URL and title
    static func new(url: String, title: String = "") -> HistoryEntry {
        HistoryEntry(id: nil, url: url, title: title)
    }
}

// MARK: - Persistence
/// Make HistoryEntry a Codable Record.
///
/// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension HistoryEntry: Codable, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "history"

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

// MARK: - HistoryEntry Database Requests
/// Define some player requests used by the application.
///
/// See https://github.com/groue/GRDB.swift/blob/master/README.md#requests
/// See https://github.com/groue/GRDB.swift/blob/master/Documentation/GoodPracticesForDesigningRecordTypes.md
extension DerivableRequest where RowDecoder == HistoryEntry {
    /// A request of entries ordered by title
    ///
    /// For example:
    ///
    ///     let entries = try dbQueue.read { db in
    ///         try HistoryEntry.all().orderedByTitle().fetchAll(db)
    ///     }
    func orderedByTitle() -> Self {
        order(HistoryEntry.Columns.title)
    }
}
