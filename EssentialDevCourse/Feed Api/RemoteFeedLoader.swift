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
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
   
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url, completion: { result in
            switch result {
            case let .success(data, response):
                let result = FeedItemsMapper.map(data, from: response)
                return completion(result)
            case .failure:
                completion(.failure(.connectivity))
            }
        })
    }
    
}
