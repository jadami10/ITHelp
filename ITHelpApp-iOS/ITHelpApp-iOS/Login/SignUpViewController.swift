//
//  SignUpViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Johan Adami on 10/4/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    var busyFrame: UIView?
    
    var checkTextFieldsList = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        // Do any additional setup after loading the view, typically from a nib.
        
        checkTextFieldsList.append(firstNameTextField)
        checkTextFieldsList.append(lastNameTextField)
        checkTextFieldsList.append(emailTextField)
        checkTextFieldsList.append(userTextField)
        checkTextFieldsList.append(passTextField)
    }
    
    @IBAction func signUpPressed(sender: AnyObject) {

        //LoginHandler.signUpUserWithBlock(user, completion: checkSignUp)
        if (checkTextFields()) {
            
            
            self.asyncBlockingAction("Signing Up", taskToRun: performSignUp)
        }
        
    }
    
    func performSignUp(activityFrame: UIView) -> Void {
        self.busyFrame = activityFrame
        let user = PFUser()
        user.username = self.userTextField.text
        user.password = self.passTextField.text
        user.email = self.emailTextField.text
        user["first"] = self.firstNameTextField.text
        user["last"] = self.lastNameTextField.text
        LoginHandler.signUpUserWithBlock(user, completion: self.checkSignUp)
    }
    
    func checkSignUp(result: NSError?) {
        if let error = result {
            let errorString = error.userInfo["error"] as? NSString
            let errorCode = error.code
            
            switch errorCode {
            case 100:
                self.presentAlert("No Connection", message: "Please check network connection")
                break
            case 125:
                self.presentAlert("Bad Email", message: "Bad email format")
                break
            case 202:
                self.presentAlert("Username Taken", message: "Please pick different username")
                break
            case 203:
                self.presentAlert("Email Taken", message: "Please pick different email")
                break
            default:
                self.presentAlert("Error", message: "Please try again later")
                print(NSString(format: "Unhandled Error: %d", errorCode))
                break
            }
            print(errorString)
            self.releaseUI()
        } else {
            self.presentAlert("Success", message: "Signup Successful")
            self.releaseUI()
            goToMainPage()
        }
    }
    
    func releaseUI() {
        self.busyFrame?.removeFromSuperview()
        self.view.userInteractionEnabled = true
    }
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        let text = sender.text!
        if (text.isEmpty) {
            sender.backgroundColor = UIColor.whiteColor()
        } else if (sender == passTextField) {
            if text.characters.count < 6 {
                sender.backgroundColor = UIConstants.errorRedColor
            } else {
                sender.backgroundColor = UIColor.whiteColor()
            }
        } else if (sender == userTextField) {
            /*if !checkAvailableUsernames(text) {
            sender.backgroundColor = UIColor.redColor()
            }*/
        }else {
            sender.backgroundColor = UIColor.whiteColor()
        }
    }
    
    
    @IBAction func alreadyUserPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func checkTextFields() ->Bool{
        var good = true
        for textField in checkTextFieldsList {
            let text = textField.text!
            if text.isEmpty {
                textField.shakeTextField()
                good = false
            } else if (textField == userTextField && good) {
                if !checkAvailableUsernames(text) {
                    good = false
                    let alertController = UIAlertController(title: "Username Taken", message: "Please pick different username", preferredStyle: .Alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    presentViewController(alertController, animated: true, completion: nil)
                }
            } else if (textField == passTextField && good) {
                if text.characters.count < 6 {
                    good = false
                    let alertController = UIAlertController(title: "Password too short", message: "Password must be at least 6 characters", preferredStyle: .Alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
        self.view.userInteractionEnabled = true
        return good
    }
    
    func checkAvailableUsernames(username: NSString) -> Bool {
        let query = PFUser.query()
        do {
            query!.whereKey("username", equalTo: username)
            let usernameP = try query!.findObjects()
            if usernameP.count > 0 {
                return false
            }
        } catch {
            return false
        }
        
        return true
    }
    
    func presentAlert(title: NSString, message: NSString) {
        let alertController = UIAlertController(title: title as String, message: message as String, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func goToMainPage() {
        let storyboard = UIStoryboard(name: "home", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("MainTabController") as! UITabBarController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    /*
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
    if (identifier == "MainTabController") {
    return true
    } else {
    return true
    }
    }
    */
}
