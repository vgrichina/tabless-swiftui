import Combine
import GRDB

/// AppDatabase lets the application access the database.
///
/// It applies the pratices recommended at
/// https://github.com/groue/GRDB.swift/blob/master/Documentation/GoodPracticesForDesigningRecordTypes.md
final class AppDatabase {
    private let dbQueue: DatabaseQueue

    /// Creates an AppDatabase and make sure the database schema is ready.
    init(_ dbQueue: DatabaseQueue) throws {
        self.dbQueue = dbQueue
        try migrator.migrate(dbQueue)
    }

    /// The DatabaseMigrator that defines the database schema.
    ///
    /// See https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        #if DEBUG
        // Speed up development by nuking the database when migrations change
        // See https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md#the-erasedatabaseonschemachange-option
        migrator.eraseDatabaseOnSchemaChange = true
        #endif

        migrator.registerMigration("createHistory") { db in
            // Create a table
            // See https://github.com/groue/GRDB.swift#create-tables
            try db.create(table: "history") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("title", .text).notNull()
                    // Sort player names in a localized case insensitive fashion by default
                    // See https://github.com/groue/GRDB.swift/blob/master/README.md#unicode
                    .collate(.localizedCaseInsensitiveCompare)
                t.column("url", .text).notNull()
            }
        }

        // Migrations for future application versions will be inserted here:
        // migrator.registerMigration(...) { db in
        //     ...
        // }

        return migrator
    }
}

// MARK: - Database Access
//
// This extension defines methods that fulfill application needs, both in terms
// of writes and reads.
extension AppDatabase {
    // MARK: Writes

    /// Save (insert or update) a history entry.
    func saveHistoryEntry(_ entry: inout HistoryEntry) throws {
        try dbQueue.write { db in
            try entry.save(db)
        }
    }
//
//    /// Delete the specified players
//    func deletePlayers(ids: [Int64]) throws {
//        try dbQueue.write { db in
//            _ = try Player.deleteAll(db, keys: ids)
//        }
//    }
//
//    /// Delete all players
//    func deleteAllPlayers() throws {
//        try dbQueue.write { db in
//            _ = try Player.deleteAll(db)
//        }
//    }

    // MARK: Reads

//    /// Returns a publisher that tracks changes in players ordered by name
//    func playersOrderedByNamePublisher() -> AnyPublisher<[Player], Error> {
//        ValueObservation
//            .tracking(Player.all().orderedByName().fetchAll)
//            // Use the .immediate scheduling so that views do not have to wait
//            // until the players are loaded.
//            .publisher(in: dbQueue, scheduling: .immediate)
//            .eraseToAnyPublisher()
//    }
}

// MARK: - Support for Tests and Previews
#if DEBUG
extension AppDatabase {
    /// Returns an empty, in-memory database, suitable for testing and previews.
    static func empty() throws -> AppDatabase {
        try AppDatabase(DatabaseQueue())
    }

    /// Returns an in-memory database populated with random data
    static func random() throws -> AppDatabase {
        let database = try AppDatabase.empty()
        // TODO: try database.createRandomPlayersIfEmpty()
        return database
    }
}
#endif
