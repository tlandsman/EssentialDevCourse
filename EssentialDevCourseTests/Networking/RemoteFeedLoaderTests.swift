//
//  RemoteFeedLoaderTests.swift
//  EssentialDevCourseTests
//
//  Created by Tanya Landsman on 12/19/22.
//

import Foundation
import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        let _ = RemoteFeedLoader()
        XCTAssertNil(client.requestedURL)
    }
    
    
}

