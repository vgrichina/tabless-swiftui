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
        webView.uiDelegate = context.coordinator
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

    private var lastHistoryEntry: HistoryEntry?

    init(_ webView: WebView) {
        self.webView = webView
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("start load: \(webView.url!) \(webView.title ?? "< none >")")

        titleCancellable = webView.publisher(for: \.title)
            .sink { title in
                print("Title updated: \(title ?? "< none >")")
                self.webView.viewModel.title = title ?? ""
                self.recordHistoryIfNeeded(webView)
            }
        urlCancellable = webView.publisher(for: \.url)
            .sink { url in
                print("URL updated: \(url!)")
                self.webView.viewModel.url = url!.absoluteString
                self.recordHistoryIfNeeded(webView)

            }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish load: \(webView.url!) \(webView.title ?? "< none >")")
        self.recordHistoryIfNeeded(webView)
    }

    private func recordHistoryIfNeeded(_ webView: WKWebView) {
        let url = webView.url!.absoluteString
        let title = webView.title!

        var entry: HistoryEntry
        if lastHistoryEntry == nil || lastHistoryEntry!.url != url {
            entry = HistoryEntry.new(url: url, title: title)
        } else {
            entry = lastHistoryEntry!
            entry.url = url
            entry.title = title
        }

        try! Current.database().saveHistoryEntry(&entry)
        // TODO: Debounce stuff like URL changes when visiting Twitter

        print("recorded with id: \(entry.id!)")
        lastHistoryEntry = entry
    }
}

extension Coordinator: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

        // TODO: Should open new window sometimes?
        // TODO: Looks like can have distinction between JS and non-JS windows https://stackoverflow.com/a/36199278/341267
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil

    }
}

struct WebView_Previews : PreviewProvider {
    static var previews: some View {
        WebView(viewModel: WebViewModel(url: "http://example.com"))
    }
}
