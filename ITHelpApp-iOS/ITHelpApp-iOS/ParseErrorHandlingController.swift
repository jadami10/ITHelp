//
//  ParseErrorHandlingController.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/22/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import Foundation
import Parse

class ParseErrorHandlingController {
    class func handleParseError(error: NSError) -> UIAlertController? {
        if error.domain != PFParseErrorDomain {
            return nil
        }
        
        switch (error.code) {
        case PFErrorCode.ErrorInvalidSessionToken.rawValue:
            return handleInvalidSessionTokenError()
            
            //... // Other Parse API Errors that you want to explicitly handle.
        default:
            return nil
        }
    }
    
    private class func handleInvalidSessionTokenError() -> UIAlertController {
        //--------------------------------------
        // Option 1: Show a message asking the user to log out and log back in.
        //--------------------------------------
        // If the user needs to finish what they were doing, they have the opportunity to do so.
        //
        let alertController = UIAlertController(
            title: "Invalid Session",
            message: "Session is no longer valid, please log out and log in again.",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        return alertController
//        alertView
        
        //--------------------------------------
        // Option #2: Show login screen so user can re-authenticate.
        //--------------------------------------
        // You may want this if the logout button is inaccessible in the UI.
        //
        // let presentingViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        // let logInViewController = PFLogInViewController()
        // presentingViewController?.presentViewController(logInViewController, animated: true, completion: nil)
    }
}