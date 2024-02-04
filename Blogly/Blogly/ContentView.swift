//
//  ContentView.swift
//  Blogly
//
//  Created by tyler on 2/3/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var feeds: [RSSFeed]

    @State private var showingAlert = false
    @State private var rssFeed = ""
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(feeds) { feed in
                    NavigationLink {
                        Blog(rssFeedURL: feed.url)
                    } label: {
                        Text(feed.url)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        showingAlert.toggle()
                    }) {
                        Label("Add RSS", systemImage: "plus")
                    }.alert("Add an RSS Feed", isPresented: $showingAlert) {
                        TextField("RSS Feed URL:", text: $rssFeed)
                        Button("OK", action: addRSS)
                    }
                }
            }
        } detail: {
            Text("Select a Blog")
        }
    }

    private func addRSS() {
        withAnimation {
            let newItem = RSSFeed(url: rssFeed)
            rssFeed.removeAll()
            modelContext.insert(newItem)
            showingAlert.toggle()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(feeds[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: RSSFeed.self, inMemory: true)
}
