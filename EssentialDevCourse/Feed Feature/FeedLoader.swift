//
//  FeedItem.swift
//  EssentialDevCourse
//
//  Created by Tanya Landsman on 12/19/22.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}


protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
