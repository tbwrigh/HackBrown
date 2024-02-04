//
//  Blog.swift
//  Blogly
//
//  Created by tyler on 2/3/24.
//

import SwiftUI
import FeedKit

struct Blog: View {

    var rssFeedURL: String
    
    @State private var feedItems: [RSSFeedItem] = []
    @State private var isLoading = false
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                List(feedItems, id: \.title) { item in
                    NavigationLink(destination: WebViewWithToolbar(url: URL(string: item.link ?? "")!)) {
                        VStack(alignment: .leading) {
                            Text(item.title ?? "Untitled").fontWeight(.bold)
                                .frame(minWidth: geometry.size.width*0.95, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                            Text(item.description ?? "No description")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(minWidth: geometry.size.width*0.95, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)

                        }
                    }
                    
                }
                .onAppear {
                    loadRSSFeed()
                }
                .frame(minWidth: geometry.size.width, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
        }
    }
    
    func loadRSSFeed() {
        isLoading = true
        Task {
            await parseRSSFeed(rssURL: rssFeedURL)
            isLoading = false
        }
    }
    
    func parseRSSFeed(rssURL: String) async {
        let data = fetchData(from: rssURL)!
        let parser = FeedParser(data: data)
        let result = parser.parse()
        switch result {
        case .success(let feed):
            if let rssItems = feed.rssFeed?.items {
                DispatchQueue.main.async {
                    self.feedItems = rssItems
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
    Blog(rssFeedURL: "https://sumnerevans.com/index.xml")
}
