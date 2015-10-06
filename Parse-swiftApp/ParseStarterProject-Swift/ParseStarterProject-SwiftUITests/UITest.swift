//
//  UITest.swift
//  ParseStarterProject-Swift
//
//  Created by Johan Adami on 10/4/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import XCTest

class UITest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testLogin() {
        
        let app = XCUIApplication()
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("jadami")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("testpass")
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        app.buttons["Login"].tap()
        app.alerts["Invalid Username"].collectionViews.buttons["OK"].tap()
       
    }
    
    func testSignup() {
        
        let app = XCUIApplication()
        let signUpButton = app.buttons["Sign Up"]
        signUpButton.tap()
        
        let firstTextField = app.textFields["First"]
        firstTextField.tap()
        firstTextField.typeText("jadami")
        
        let lastTextField = app.textFields["Last"]
        lastTextField.tap()
        lastTextField.typeText("jd")
        
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText("fffffff")
        
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("ffffffffff")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("frfffffff")
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        signUpButton.tap()
        app.alerts["Username Taken"].collectionViews.buttons["OK"].tap()
        
    }
    
    func testReturnToSignIn() {
        
        let app = XCUIApplication()
        let signUpButton = app.buttons["Sign Up"]
        signUpButton.tap()
        
        let alreadyAUserButton = app.buttons["Already a User"]
        alreadyAUserButton.tap()
        signUpButton.tap()
        alreadyAUserButton.tap()
        app.textFields["Username"].typeText("test")
        app.secureTextFields["Password"].typeText("test")
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        signUpButton.tap()
        alreadyAUserButton.tap()
        
    }
    
}
