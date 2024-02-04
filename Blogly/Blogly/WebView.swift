import SwiftUI
import WebKit
import AppKit
import SwiftData

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

    @State private var navigateBack = false
    @State private var liked = false
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @Query private var likedArticles: [LikedArticle]
    
    
    var body: some View {
        VStack {
            WebView(url: url)
            if rssFeed == "LIKED" {
                NavigationLink(destination: LikedPosts(), isActive: $navigateBack) { EmptyView() }
            }else if rssFeed == "ALL" {
                NavigationLink(destination: AllPosts(), isActive: $navigateBack) { EmptyView() }
            }else {
                NavigationLink(destination: Blog(rssFeedURL: rssFeed), isActive: $navigateBack) { EmptyView() }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    let url_string = url?.absoluteString
                    if !(url_string ?? "").isEmpty {
                        if !liked{
                            let likedArticle = LikedArticle(articleURL: url_string ?? "", rssURL: rssFeed)
                            modelContext.insert(likedArticle)
                            liked = true
                            
                        }else {
                            for likedArticle in likedArticles {
                                if likedArticle.articleURL == (url_string ?? "") {
                                    modelContext.delete(likedArticle)
                                }
                                liked = false
                            }
                        }
                    }
                }) {
                    if liked {
                        Image(systemName: "heart.fill")
                    }else {
                        Image(systemName: "heart")
                    }
                }
                Button(action: {
                    navigateBack.toggle()
                }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .navigationTitle("Reading Mode")
        .onAppear(){
            loadLiked()
        }
    }
    
    func loadLiked() {
        let url_string = url?.absoluteString
        for likedArticle in likedArticles {
            if likedArticle.articleURL == url_string {
                liked = true
                break
            }
        }
        
    }
}
