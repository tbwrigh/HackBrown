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
    @State private var rssFeedName = ""
    @State private var rssFeedURL = ""

    @State private var isEditing = false
    @State private var editingRSSFeedName = ""
    @State private var editingRSSFeedURL = ""
    
    @State private var selectedFeed: RSSFeed?
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(feeds) { feed in
                    NavigationLink {
                        Blog(rssFeedURL: feed.url).onAppear {
                            selectedFeed = feed
                        }

                    } label: {
                        Text(feed.name)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(
                        action: {
                            isEditing.toggle()
                            editingRSSFeedURL = (selectedFeed?.url)!
                            editingRSSFeedName = (selectedFeed?.name)!
                        }
                    ) {
                        Label(isEditing ? "Done" : "Edit", systemImage: isEditing ? "checkmark.circle" : "pencil.circle")
                    }.alert("Edit RSS Feed", isPresented: $isEditing) {
                        TextField("RSS Feed Name:", text: $editingRSSFeedName)
                        TextField("RSS Feed URL:", text: $editingRSSFeedURL)
                        Button("OK", action: editRSS)
                    }

                }
                ToolbarItem {
                    Button(action: {
                        showingAlert.toggle()
                    }) {
                        Label("Add RSS", systemImage: "plus")
                    }.alert("Add an RSS Feed", isPresented: $showingAlert) {
                        TextField("RSS Feed Name:", text: $rssFeedName)
                        TextField("RSS Feed URL:", text: $rssFeedURL)
                        Button("OK", action: addRSS)
                    }
                }
            }
        } detail: {
            Text("Select a Blog")
        }
    }
    
    private func editRSS() {
        let newItem = RSSFeed(name: editingRSSFeedName, url: editingRSSFeedURL)
        modelContext.delete(selectedFeed!)
        if editingRSSFeedName.isEmpty {
            return
        }
        if editingRSSFeedURL.isEmpty {
            return
        }
        selectedFeed = newItem
        modelContext.insert(newItem)
        editingRSSFeedName.removeAll()
        editingRSSFeedURL.removeAll()
        isEditing.toggle()
    }

    private func addRSS() {
        withAnimation {
            if rssFeedURL.isEmpty || rssFeedName.isEmpty {
                return
            }
            
            let newItem = RSSFeed(name: rssFeedName, url: rssFeedURL)
            rssFeedName.removeAll()
            rssFeedURL.removeAll()
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
