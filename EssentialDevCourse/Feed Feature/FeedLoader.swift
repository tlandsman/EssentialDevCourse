//
//  FeedItem.swift
//  EssentialDevCourse
//
//  Created by Tanya Landsman on 12/19/22.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
