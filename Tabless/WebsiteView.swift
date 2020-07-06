//
//  WebsiteView.swift
//  Tabless
//
//  Created by Vladimir Grichina on 05.07.2020.
//  Copyright © 2020 Organization. All rights reserved.
//

import SwiftUI

struct WebsiteView: View {
    @ObservedObject var webViewModel : WebViewModel

    var body: some View {
        VStack {
            WebView(viewModel: webViewModel)
                .navigationBarTitle(Text(webViewModel.title), displayMode: .inline)
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
        WebsiteView(webViewModel: WebViewModel(url: "https://google.com"))
    }
}
