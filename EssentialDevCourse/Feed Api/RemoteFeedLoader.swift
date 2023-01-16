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
    
    public typealias Result = LoadFeedResult
   
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url, completion: { [weak self] result in
            // We use a static mapper function vs an instance method to avoid capture self.  However, that means this block will still execute if client was deallocated.  We don't know the implementtion of the client.  It might be a singleton that lives longer than the remote feed loader. Consumers of the remote feed loader might not expect the completion block to be invoked after the Remote Feeder has been deallocated causing a bug.
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                let result = FeedItemsMapper.map(data, from: response)
                return completion(result)
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }
    
}
