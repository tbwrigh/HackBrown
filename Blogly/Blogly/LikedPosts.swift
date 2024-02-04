//
//  LikedPosts.swift
//  Blogly
//
//  Created by tyler on 2/4/24.
//

import SwiftUI
import FeedKit
import SwiftData

struct LikedPosts: View {
    
    private struct LikedPostRSSFeedItem {
        var rssFeedItem: RSSFeedItem
        var rssURL: String
    }
    
    @State private var feedItems: [LikedPostRSSFeedItem] = []
    @State private var isLoading = false
    @Environment(\.presentationMode) var presentationMode
    @Query private var likedArticles: [LikedArticle]
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                List(feedItems, id: \.rssFeedItem.title) { item in
                    NavigationLink(destination: WebViewWithToolbar(url: URL(string: item.rssFeedItem.link ?? "")!, rssFeed: item.rssURL)) {
                        VStack(alignment: .leading) {
                            Text(item.rssFeedItem.title ?? "Untitled").fontWeight(.bold)
                                .frame(minWidth: geometry.size.width*0.95, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                            Text(item.rssFeedItem.description ?? "No description")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(minWidth: geometry.size.width*0.95, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)

                        }
                    }
                    
                }
                .onAppear {
                    loadPosts()
                }
                .frame(minWidth: geometry.size.width, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
        }
    }
    
    func loadPosts() {
        var likedArticleURLS: Set<String> = []
        var likedArticleRSSFeeds: Set<String> = []
        for likedArticle in likedArticles {
            likedArticleURLS.insert(likedArticle.articleURL)
            likedArticleRSSFeeds.insert(likedArticle.rssURL)
        }
        
        isLoading = true
        
        for rssFeed in likedArticleRSSFeeds {
            parseRSSFeed(rssURL: rssFeed, likedUrls: likedArticleURLS)
        }
        
        isLoading = false
    }
    
    func parseRSSFeed(rssURL: String, likedUrls: Set<String>) {
        let data = fetchData(from: rssURL)!
        let parser = FeedParser(data: data)
        let result = parser.parse()
        switch result {
        case .success(let feed):
            if let rssItems = feed.rssFeed?.items {
                for rssItem in rssItems {
                    if (rssItem.link ?? "").isEmpty {
                        continue
                    }
                        
                    if likedUrls.contains(rssItem.link ?? "") {
                        feedItems.append(LikedPostRSSFeedItem(rssFeedItem: rssItem, rssURL: "LIKED") )
                    }
                }
            }
        case .failure(let error):
            print("An error occurred while parsing the feed: \(error.localizedDescription)")
        }
        
    }
    
    func fetchData(from urlString: String) -> Data? {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return nil
        }
        
        var resultData: Data?
        let semaphore = DispatchSemaphore(value: 0) // Create a semaphore with a count of 0
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            defer { semaphore.signal() } // Ensure semaphore signal is called
            
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                return
            }
            
            resultData = data // Store the received data
        }
        
        task.resume() // Start the task
        semaphore.wait() // Wait for the semaphore to be signaled
        
        return resultData
    }

}

#Preview {
    LikedPosts()
}
