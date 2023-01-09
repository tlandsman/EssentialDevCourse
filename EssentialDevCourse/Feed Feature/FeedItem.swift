//
//  FeedItem.swift
//  EssentialDevCourse
//
//  Created by Tanya Landsman on 12/19/22.
//

import Foundation


public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
