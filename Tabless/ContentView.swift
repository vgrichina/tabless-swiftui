//
//  ContentView.swift
//  Tabless
//
//  Created by Vladimir Grichina on 30.06.2020.
//  Copyright © 2020 Organization. All rights reserved.
//

import SwiftUI

struct Website: Identifiable, Hashable {
    var id: String {
        return self.url
    }
    var url: String
    var title: String
}

struct ContentView: View {
    var websites: [Website] = [
        Website(url: "https://google.com", title: "Google"),
        Website(url: "https://twitter.com", title: "Twitter"),
        Website(url: "https://reddit.com", title: "Reddit")
    ]

    @State var searchText: String = ""

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                SearchBar(text: $searchText)
                List(websites.filter({ searchText.isEmpty || $0.title.contains(searchText) }), id: \.self) { website in
                    NavigationLink(destination: BrowserView(webViewModel: WebViewModel(url: website.url))
                                        .navigationBarHidden(true)
                    ) {
                        WebsiteRow(website: website)
                    }
                }
            }
            .navigationBarTitle(Text("Sites"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct WebsiteRow: View {
    let website: Website
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(website.title)
                .font(.headline)
            Text(website.url)
                .font(.subheadline)
        }
    }
}
