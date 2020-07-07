//
//  HistoryView.swift
//  Tabless
//
//  Created by Vladimir Grichina on 05.07.2020.
//  Copyright © 2020 Organization. All rights reserved.
//

import SwiftUI
import Combine

struct HistoryView: View {
    @ObservedObject var viewModel: HistoryViewModel
    @Binding var showModal: Bool
    let onEntrySelected: (HistoryEntry) -> Void

    var body: some View {
        List(viewModel.entries) { historyEntry in
            Button(action: {
                self.showModal = false
                onEntrySelected(historyEntry)
            }) {
                VStack(alignment: .leading) {
                    Text(historyEntry.title)
                    Text(historyEntry.url)
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
            }
        }
    }
}

class HistoryViewModel: ObservableObject {
    @Published var entries: [HistoryEntry] = []
    private var entriesCancellable: AnyCancellable?
    private let database: AppDatabase

    init(database: AppDatabase) {
        self.database = database
        entriesCancellable = entriesPublisher(in: database).sink { [weak self] entries in
            self?.entries = entries
        }
    }

    // MARK: - Private

    /// Returns a publisher of the entries in the list
    private func entriesPublisher(in database: AppDatabase) -> AnyPublisher<[HistoryEntry], Never> {
        database.entriesOrderedByLatestFirst()
            // Turn database errors into an empty list.
            // TODO: Eventual error presentation is left as an exercise for the reader.
            .catch { error in
                Just<[HistoryEntry]>([])
            }
//            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = try! HistoryViewModel(database: .random())
        return HistoryView(viewModel: viewModel, showModal: .constant(true), onEntrySelected: {_ in })
    }
}
