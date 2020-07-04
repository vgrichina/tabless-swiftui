//
//  WebView.swift
//  Tabless
//
//  Created by Vladimir Grichina on 30.06.2020.
//  Copyright © 2020 Organization. All rights reserved.
//

import SwiftUI
import WebKit

struct WebView : UIViewRepresentable {
    let request: URLRequest

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
}

class Coordinator: NSObject, WKNavigationDelegate {
    var webView: WebView

    init(_ webView: WebView) {
        self.webView = webView
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("start load: \(webView.url!) \(webView.title ?? "< none >")")
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
        WebView(request: URLRequest(url: URL(string: "http://example.com")!))
    }
}
