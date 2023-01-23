//
//  XCTTest+MemoryLeakTracking.swift
//  EssentialDevCourseTests
//
//  Created by Tanya Landsman on 1/23/23.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
