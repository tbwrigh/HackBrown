//
//  RSSFeed.swift
//  Blogly
//
//  Created by tyler on 2/3/24.
//

import Foundation
import SwiftData

@Model
final class RSSFeed {
    var url: String
    var name: String
    
    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
}
