//
//  ContentView.swift
//  Tabless
//
//  Created by Vladimir Grichina on 30.06.2020.
//  Copyright © 2020 Organization. All rights reserved.
//

import SwiftUI


struct ContentView: View {
    var names: [String] = ["World", "Universe", "Berkeley"]
    @State var searchText: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            SearchBar(text: $searchText)
            List(names.filter({ searchText.isEmpty || $0.contains(searchText) }), id: \.self) { name in
                VStack(alignment: .leading) {
                    Text("Hello")
                    Text(name)
                        .fontWeight(.bold)
                        .padding(.top)
                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
