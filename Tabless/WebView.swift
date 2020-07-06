//
//  WebView.swift
//  Tabless
//
//  Created by Vladimir Grichina on 30.06.2020.
//  Copyright © 2020 Organization. All rights reserved.
//

import SwiftUI
import WebKit
import Combine

class WebViewModel: ObservableObject {
    @Published var url: String
    @Published var title: String = ""

    init(url: String) {
        print("WebViewModel.init \(url)")
        self.url = url
    }
}

struct WebView : UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url == nil || uiView.url!.absoluteString != viewModel.url {
            let request = URLRequest(url: URL(string: viewModel.url)!)
            uiView.load(request)
        }
    }
}

class Coordinator: NSObject, WKNavigationDelegate {
    var webView: WebView

    private var titleCancellable: Cancellable?
    private var urlCancellable: Cancellable?

    init(_ webView: WebView) {
        self.webView = webView
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {

        print("start load: \(webView.url!) \(webView.title ?? "< none >")")

        titleCancellable = webView.publisher(for: \.title)
            .sink { title in
                print("Title updated: \(title ?? "< none >")")
                self.webView.viewModel.title = title ?? ""
            }
        urlCancellable = webView.publisher(for: \.url)
            .sink { url in
                print("URL updated: \(url!)")
                self.webView.viewModel.url = url!.absoluteString;
            }
        // TODO
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish load: \(webView.url!) \(webView.title ?? "< none >")")

        var entry = HistoryEntry.new(url: webView.url!.absoluteString, title: webView.title!)
        try! Current.database().saveHistoryEntry(&entry)
        print("inserted with id: \(entry.id!)")
    }
}

struct WebView_Previews : PreviewProvider {
    static var previews: some View {
        WebView(viewModel: WebViewModel(url: "http://example.com"))
    }
}
