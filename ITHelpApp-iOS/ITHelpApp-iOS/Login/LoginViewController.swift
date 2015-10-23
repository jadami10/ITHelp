/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    var goodToSegue = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        // Do any additional setup after loading the view, typically from a nib.
        //let image = UIImage(named: "AuthHeader.png");
        //headerImage.image = image;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logInPressed(sender: AnyObject) {
        if (checkTextFields()) {
            let userName = userTextField.text!
            let pass = passTextField.text!
            self.view.userInteractionEnabled = false;
            let messageFrame = self.progressBarDisplayer("Logging In", indicator: true)
            dispatch_async(dispatch_get_main_queue()) {
                LoginHandler.loginUserWithBlock(userName, pass: pass, completion: self.checkLogin)
                dispatch_async(dispatch_get_main_queue()) {
                    messageFrame.removeFromSuperview()
                }
            }

            //LoginHandler.loginUserWithBlock(userName, pass: pass, completion: checkLogin)
        }
    }
    
    /*
    saveButton.enabled = false
    progressBarDisplayer("Saving Image", true)
    dispatch_async(dispatch_get_main_queue()) {
    self.saveImage()
    dispatch_async(dispatch_get_main_queue()) {
    self.messageFrame.removeFromSuperview()
    self.saveButton.enabled = true
    }
    }
*/
    
    func checkLogin(result: NSError?) -> Void {
        if let error = result {
            
            let errorString = error.userInfo["error"] as? NSString
            let errorCode = error.code
            
            switch errorCode {
            case PFErrorCode.ErrorConnectionFailed.rawValue:
                self.presentAlert("No Connection", message: "Please check network connection", completion: nil)
                break
            case PFErrorCode.ErrorObjectNotFound.rawValue:
                self.presentAlert("Invalid Username", message: "Incorrect Username or Password", completion: nil)
                break
            default:
                self.presentAlert("Error", message: "Please try again later", completion: nil)
                print(NSString(format: "Unhandled Error: %d", errorCode))
                print (PFErrorCode.init(rawValue: errorCode).debugDescription)
                break
            }
            print(errorString)
            self.view.userInteractionEnabled = true
        } else {
            goToMainPage()
        }

    }
    
    func enableButtons() {
        self.loginButton.enabled = true
        self.signupButton.enabled = true
    }
    
    func disableButtons() {
        self.loginButton.enabled = false
        self.signupButton.enabled = false
    }
    
    func checkTextFields() -> Bool {
        var good = true
        if (userTextField.text!.isEmpty) {
            userTextField.shakeTextField()
            good = false
        }
        if (passTextField.text!.isEmpty) {
            passTextField.shakeTextField()
            good = false
        }
        return good
    }
    
    func presentAlert(title: NSString, message: NSString, completion: (() -> Void)?) {
        let alertController = UIAlertController(title: title as String, message: message as String, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: completion)
    }
    
    func goToMainPage() {
        
        let storyboard = UIStoryboard(name: "home", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("MainTabController") as! UITabBarController
        self.presentViewController(vc, animated: true, completion: nil)
    }
}
