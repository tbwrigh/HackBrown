import SwiftUI
import WebKit
import AppKit

// Define your WebView wrapper here
struct WebView: NSViewRepresentable {
    let url: URL?
    
    func makeNSView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }
    func updateNSView(_ nsView: WKWebView, context: Context) {
        guard let myURL = url else {
            return
        }
        let request = URLRequest(url: myURL)
        nsView.load(request)
    }
}

struct WebViewWithToolbar: View {
    var url: URL?
    var rssFeed: String
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateBack = false
    
    var body: some View {
        VStack {
            WebView(url: url)
            NavigationLink(destination: Blog(rssFeedURL: rssFeed), isActive: $navigateBack) { EmptyView() }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    navigateBack.toggle()
                }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .navigationTitle("Reading Mode")
    }
}
