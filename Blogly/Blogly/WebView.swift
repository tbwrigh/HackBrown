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
    
    var body: some View {
        VStack {
            WebView(url: url)
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    // Your action for back navigation
                }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
}
