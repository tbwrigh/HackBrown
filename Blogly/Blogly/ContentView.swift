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

    @State private var canEdit = false
    
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
                NavigationLink(destination: AllPosts()
                    .onAppear {canEdit = false}) {
                    HStack {
                        Text("All Posts")

                        Image(systemName: "house.fill")
                            .foregroundColor(.white)
                    }
                }
                NavigationLink(destination: LikedPosts()
                    .onAppear {canEdit = false}) {
                    HStack {
                        Text("Liked Posts")

                        Image(systemName: "heart.fill")
                            .foregroundColor(.white)
                    }
                }
                NavigationLink(destination: Search()
                    .onAppear {canEdit = false}) {
                    HStack {
                        Text("Search")

                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                    }
                }
                Section(header: Text("Subscribed")) {
                    ForEach(feeds) { feed in
                        NavigationLink(destination: Blog(rssFeedURL: feed.url).onAppear {
                            canEdit = true
                            selectedFeed = feed
                            print("Switch")
                        }) {
                            Text(feed.name)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationSplitViewColumnWidth(min: 185, ideal: 205)
            .toolbar {
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

                if canEdit{
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
                }
            }
        } detail: {
            AllPosts().onAppear {
                canEdit = false
            }
        }
    }
    
    private func editRSS() {
        let newItem = RSSFeed(name: editingRSSFeedName, url: editingRSSFeedURL)
        modelContext.delete(selectedFeed!)
        if editingRSSFeedName.isEmpty {
            print("empty")
            return
        }
        if editingRSSFeedURL.isEmpty {
            print("empty")
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
