/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var headerImage: UIImageView!
    var goodToSegue = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        // Do any additional setup after loading the view, typically from a nib.
        let image = UIImage(named: "AuthHeader.png");
        headerImage.image = image;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logInPressed(sender: AnyObject) {
        if (checkTextFields()) {
            let userName = userTextField.text!
            let pass = passTextField.text!
            LoginHandler.loginUserWithBlock(userName, pass: pass, completion: checkLogin)
        }
    }
    
    func checkLogin(result: NSError?) -> Void {
        if let error = result {
            
            let errorString = error.userInfo["error"] as? NSString
            let errorCode = error.code
            
            switch errorCode {
            case 100:
                self.presentAlert("No Connection", message: "Please check network connection")
                break
            case 101:
                self.presentAlert("Invalid Username", message: "Incorrect Username or Password")
                break
            default:
                self.presentAlert("Error", message: "Please try again later")
                print(NSString(format: "Unhandled Error: %d", errorCode))
                break
            }
            print(errorString)
            
        } else {
            print("YAY!!")
        }

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
    
    func presentAlert(title: NSString, message: NSString) {
        let alertController = UIAlertController(title: title as String, message: message as String, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}
