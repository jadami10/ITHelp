//
//  UnitTests.swift
//  ParseStarterProject-Swift
//
//  Created by Johan Adami on 10/4/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import XCTest
//@testable import

class UnitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testColorCreation() {
        let myColor = UIColor.redColor()
        let testColor = UIColor.colorWithRealValue(255, greenValue: 0, blueValue: 0, alpha: 1.0)
        XCTAssert(myColor == testColor)
    }
    
}
