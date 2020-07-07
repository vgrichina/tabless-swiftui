//
//  WebsiteView.swift
//  Tabless
//
//  Created by Vladimir Grichina on 05.07.2020.
//  Copyright © 2020 Organization. All rights reserved.
//

import SwiftUI

struct BrowserView: View {
    @ObservedObject var webViewModel : WebViewModel

    @State private var showHistory = false

    var body: some View {
        VStack {
            Text(webViewModel.title).padding(.all)
            WebView(viewModel: webViewModel)
            HStack {
                Button(action: {
                    self.showHistory = true
                }) {
                    Text("History")
                        .foregroundColor(.blue)
                        .padding(.all)
                }.sheet(isPresented: $showHistory) {
                    HistoryView(viewModel: HistoryViewModel(database: Current.database()),
                                showModal: $showHistory,
                                onEntrySelected: { historyEntry in
                                        webViewModel.url = historyEntry.url
                                        webViewModel.title = historyEntry.title
                                })
                }
            }
        }
    }
}

struct WebsiteView_Previews: PreviewProvider {
    static var previews: some View {
        BrowserView(webViewModel: WebViewModel(url: "https://google.com"))
    }
}
