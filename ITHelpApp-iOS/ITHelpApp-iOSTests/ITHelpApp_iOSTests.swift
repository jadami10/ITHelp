//
//  ITHelpApp_iOSTests.swift
//  ITHelpApp-iOSTests
//
//  Created by Johan Adami on 10/6/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import XCTest
import Parse
@testable import ITHelpApp_iOS

class ITHelpApp_iOSTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Initialize Parse
        Parse.setApplicationId("Dxf9sHTC4H9iQoYP7FUPmkX8o99KTTJ01O1tBhjK",
            clientKey:"gOg8aKBfmnT1jkEPJB9AoiP85Za0Ob9GTOGcwu0k")
        
        PFUser.enableAutomaticUser()

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    /*
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
    */
    func testColorMaker() {
        let redColor = UIColor.redColor()
        let testColor = UIColor.colorWithRealValue(255, greenValue: 0, blueValue: 0, alpha: 1.0)
        XCTAssertTrue(redColor == testColor)
    }
    
    func testGoodLogin() {
        LoginHandler.loginUserWithBlock("jadami", pass: "testpass") {
            (result) -> Void in
            if let error = result {
                
                let errorString = error.userInfo["error"] as? NSString
                let errorCode = error.code
                
                switch errorCode {
                case 100:
                    //self.presentAlert("No Connection", message: "Please check network connection")
                    break
                case 101:
                    //self.presentAlert("Invalid Username", message: "Incorrect Username or Password")
                    break
                default:
                    //self.presentAlert("Error", message: "Please try again later")
                    print(NSString(format: "Unhandled Error: %d", errorCode))
                    break
                }
                print(errorString)
                
            } else {
                XCTAssert(PFUser.currentUser() != nil)
                print("YAY!!")
            }
        }
    }
    
    func testBadLogin() {
        LoginHandler.loginUserWithBlock("jadami", pass: "testpass") {
            (result) -> Void in
            if let error = result {
                
                let errorString = error.userInfo["error"] as? NSString
                let errorCode = error.code
                
                switch errorCode {
                case 100:
                    //self.presentAlert("No Connection", message: "Please check network connection")
                    break
                case 101:
                    //self.presentAlert("Invalid Username", message: "Incorrect Username or Password")
                    break
                default:
                    //self.presentAlert("Error", message: "Please try again later")
                    print(NSString(format: "Unhandled Error: %d", errorCode))
                    break
                }
                print(errorString)
                XCTAssert(errorCode > 0)
            } else {
                XCTAssert(PFUser.currentUser() == nil)
                print("YAY!!")
            }
        }
    }
    
    func testSignUp() {

        let user = PFUser()
        user.username = "jadami10"
        user.password = "testpass"
        user.email = "j10"
        user["first"] = "johan"
        user["last"] = "adami"
        // other fields can be set just like with PFObject
        //user["phone"] = "415-392-0202"
        LoginHandler.signUpUserWithBlock(user) {
            (result) -> Void in
            if let error = result {
                XCTAssert(error.code > 0)
            } else {
                XCTAssert(false)
            }
        }

    }

    
}
