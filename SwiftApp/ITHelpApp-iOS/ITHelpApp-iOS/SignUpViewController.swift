//
//  SignUpViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Johan Adami on 10/4/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
    var checkTextFieldsList = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        // Do any additional setup after loading the view, typically from a nib.
        let image = UIImage(named: "AuthHeader.png");
        headerImage.image = image;
        
        checkTextFieldsList.append(firstNameTextField)
        checkTextFieldsList.append(lastNameTextField)
        checkTextFieldsList.append(emailTextField)
        checkTextFieldsList.append(userTextField)
        checkTextFieldsList.append(passTextField)
    }

    @IBAction func signUpPressed(sender: AnyObject) {
        if (checkTextFields()) {
            let user = PFUser()
            user.username = userTextField.text
            user.password = passTextField.text
            user.email = emailTextField.text
            user["first"] = firstNameTextField.text
            user["last"] = lastNameTextField.text
            // other fields can be set just like with PFObject
            //user["phone"] = "415-392-0202"
            LoginHandler.signUpUserWithBlock(user, completion: checkSignUp)

        }
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
            default:
                self.presentAlert("Error", message: "Please try again later")
                print(NSString(format: "Unhandled Error: %d", errorCode))
                break
            }
            print(errorString)
        } else {
            self.presentAlert("Success", message: "Signup Successful")
        }
    }
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        let text = sender.text!
        if (text.isEmpty) {
            sender.backgroundColor = UIColor.whiteColor()
        } else if (sender == passTextField) {
            if text.characters.count < 6 {
                sender.backgroundColor = UIColor.redColor()
            }
        } else if (sender == userTextField) {
            /*if !checkAvailableUsernames(text) {
                sender.backgroundColor = UIColor.redColor()
            }*/
        }else {
            sender.backgroundColor = UIConstants.mainGreenColor
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
}
