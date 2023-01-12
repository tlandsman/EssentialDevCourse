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
                // We use a static function on this helper to avoid capture self if it was an instance method.  this is key because if the instance of the Remote Feed Loader has been deallocated this block can still be invoked causing a bug.  We don't know the implementtion of the client.  It might be a singleton that lives longer than the remote feed loader. Consumers of the remote feed loader might not expect the completion block to be invoked after the Remote Feeder has been deallocated. 
                let result = FeedItemsMapper.map(data, from: response)
                return completion(result)
            case .failure:
                completion(.failure(.connectivity))
            }
        })
    }
    
}
