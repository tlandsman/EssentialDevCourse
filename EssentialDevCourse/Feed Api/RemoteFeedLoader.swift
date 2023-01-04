//
//  RemoteFeedLoader.swift
//  EssentialDevCourse
//
//  Created by Tanya Landsman on 12/20/22.
//

import Foundation

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
   
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url, completion: { error, response in
            if response != nil {
                completion(.invalidData)
            } else {
                completion(.connectivity)
            }
           
        })
    }
}


public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}

