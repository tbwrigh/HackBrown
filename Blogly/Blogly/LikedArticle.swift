//
//  LikedArticale.swift
//  Blogly
//
//  Created by tyler on 2/4/24.
//

import Foundation
import SwiftData

@Model
final class LikedArticle {
    let id: UUID = UUID()
    var articleURL: String
    var rssURL: String
    
    init(articleURL: String, rssURL: String) {
        self.articleURL = articleURL
        self.rssURL = rssURL
    }
}
