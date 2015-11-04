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
    var busyFrame: UIView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        // Do any additional setup after loading the view, typically from a nib.
        //let image = UIImage(named: "AuthHeader.png");
        //headerImage.image = image;
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.userTextField.textColor = UIConstants.mainUIColor
        self.passTextField.textColor = UIConstants.mainUIColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logInPressed(sender: AnyObject) {
        if (checkTextFields()) {
            
            self.asyncBlockingAction("Logging In", taskToRun:performLogin)

        }
    }
    
    func performLogin(activityFrame: UIView) -> Void {
        self.busyFrame = activityFrame
        let userName = userTextField.text!
        let pass = passTextField.text!
        LoginHandler.loginUserWithBlock(userName, pass: pass, completion: self.checkLogin)
        return;
    }
    
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
            self.releaseUI()
        } else {
            self.releaseUI()
            goToMainPage()
        }

    }
    
    func releaseUI() {  
        self.busyFrame?.removeFromSuperview()
        self.view.userInteractionEnabled = true
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
    
    func goToMainPage() {
        
        let storyboard = UIStoryboard(name: "home", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("MainTabController") as! UITabBarController
        self.presentViewController(vc, animated: true, completion: nil)
    }
}
