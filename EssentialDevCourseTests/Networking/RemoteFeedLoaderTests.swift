//
//  RemoteFeedLoaderTests.swift
//  EssentialDevCourseTests
//
//  Created by Tanya Landsman on 12/19/22.
//

import Foundation
import XCTest
import EssentialDevCourse


class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .failure(.connectivity)) {
            let clientError = NSError(domain: "test", code: 0)
            client.complete(with: clientError, at: 0)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJson = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJsonList() {
        let (sut, client) = makeSUT()

        
        expect(sut, toCompleteWith: .success([])) {
            let emptyJsonList = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyJsonList)
        }
    }
    
    //Happy path
    
    func test_load_deliversItemsOn200HTTPResponseWithJsonItems() {
        let item1Json = [
            "id": FeedItem.item1.id.uuidString,
            "image": FeedItem.item1.imageURL.absoluteString
        ]
        
        let item2Json = [
            "id": FeedItem.item2.id.uuidString,
            "description": FeedItem.item2.description,
            "location": FeedItem.item2.location,
            "image": FeedItem.item2.imageURL.absoluteString
        ]
        
        let itemsJson = [
            "items": [item1Json, item2Json]
        ]
        
        
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([FeedItem.item1, FeedItem.item2])) {
            let json = try! JSONSerialization.data(withJSONObject: itemsJson)
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    
    //MARK: Helpers

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        return (RemoteFeedLoader(url: url, client: client), client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedResult = [RemoteFeedLoader.Result]()
        sut.load { capturedResult.append($0) }
        action()
        XCTAssertEqual(capturedResult, [result], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs:[URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int) {
            messages[index].completion(.failure(error))
        }
        
   
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }

}


private extension FeedItem {
    static let item1 = FeedItem(id: UUID(),
                            description: nil,
                            location: nil,
                            imageURL: URL(string: "http://a-url.com")!)
    static let item2 = FeedItem(id: UUID(),
                            description: "a description",
                            location: "a location",
                            imageURL: URL(string: "http://another-url.com")!)
}
