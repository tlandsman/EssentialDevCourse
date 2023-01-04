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
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load { capturedError.append($0) }
        
        let clientError = NSError(domain: "test", code: 0)
        client.complete(with: clientError, at: 0)
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    //MARK: Helpers

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        return (RemoteFeedLoader(url: url, client: client), client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var completions = [(Error)-> Void]()
        
        func get(from url: URL, completion: @escaping(Error) -> Void) {
            requestedURLs.append(url)
            completions.append(completion)
        }
        
        func complete(with error: Error, at index: Int) {
            completions[index](error)
        }
    }

}

