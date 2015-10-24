//
//  LoginHandler.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/6/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import Foundation
import Parse

class LoginHandler {
    
    static func loginUserWithBlock(userName: String, pass:String, completion: (result: NSError?) -> Void){
        let err: NSError? = nil
        PFUser.logInWithUsernameInBackground(userName, password:pass) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                print("YAY Logged in!")
                completion(result: err)
            } else {
                if let error = error {
                    print("Error!")
                    completion(result: error)
                } else {
                    print("Login good")
                    completion(result: err)
                }
            }
        }

    }
    
    static func loginUser(userName: String, pass: String) -> NSError? {
        var err: NSError? = nil
        
        PFUser.logInWithUsernameInBackground(userName, password:pass) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                print("YAY Logged in!")
            } else {
                if let error = error {
                    print("Error!")
                    err = error
                    /*
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
                    */
                } else {
                    print("Login good")
                }
            }
        }
        return err
    }
    
    static func signUpUserWithBlock(user: PFUser, completion: (result: NSError?) -> Void) {
        let err: NSError? = nil
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                completion(result: error)
                /*
                let errorString = error.userInfo["error"] as? NSString
                let errorCode = error.code
                
                switch errorCode {
                case 100:
                self.presentAlert("No Connection", message: "Please check network connection")
                break
                case 202:
                self.presentAlert("Username Taken", message: "Please pick different username")
                break
                default:
                self.presentAlert("Error", message: "Please try again later")
                print(NSString(format: "Unhandled Error: %d", errorCode))
                break
                }
                print(errorString)
                */
            } else {
                print("Signup good")
                completion(result: err)
            }
        }

    }
    
    static func signUpUser(user: PFUser) -> NSError? {
        var err: NSError? = nil
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                err = error
                /*
                let errorString = error.userInfo["error"] as? NSString
                let errorCode = error.code
                
                switch errorCode {
                case 100:
                    self.presentAlert("No Connection", message: "Please check network connection")
                    break
                case 202:
                    self.presentAlert("Username Taken", message: "Please pick different username")
                    break
                default:
                    self.presentAlert("Error", message: "Please try again later")
                    print(NSString(format: "Unhandled Error: %d", errorCode))
                    break
                }
                print(errorString)
                */
            } else {
                print("Signup good")
            }
        }
        return err
        
    }
    
}