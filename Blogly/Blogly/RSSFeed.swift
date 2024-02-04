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
    
    init(url: String) {
        self.url = url
    }
}
