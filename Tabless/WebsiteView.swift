//
//  WebsiteView.swift
//  Tabless
//
//  Created by Vladimir Grichina on 05.07.2020.
//  Copyright © 2020 Organization. All rights reserved.
//

import SwiftUI

struct WebsiteView: View {
    let website: Website

    var body: some View {
        VStack {
            WebView(request: URLRequest(url: URL(string: website.url)!))
                .navigationBarTitle(Text(website.title), displayMode: .inline)
            HStack {
                NavigationLink(
                    destination: HistoryView(viewModel: HistoryViewModel(database: Current.database())) ) {
                    Text("History")
                        .foregroundColor(.blue)
                        .padding(.all)
                }
            }
        }
    }
}

struct WebsiteView_Previews: PreviewProvider {
    static var previews: some View {
        WebsiteView(website: Website(url: "https://google.com", title: "Google"))
    }
}
