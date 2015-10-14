//
//  RequestViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Johan Adami on 10/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class RequestViewController: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    @IBOutlet weak var requestTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imagePicker: UIImageView!
    
    var imagePickerView: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //adding photo functionality - need to test with real device
    @IBAction func takePhoto() {
            imagePickerView =  UIImagePickerController()
            imagePickerView.delegate = self
            imagePickerView.sourceType = .Camera
            
            presentViewController(imagePickerView, animated: true, completion: nil)

    }

    @IBAction func requestPressed(sender: AnyObject) {
        let currentUser = PFUser.currentUser()
        let requestObject = PFObject(className:"Request")
        requestObject["requester"] = currentUser?.username
        requestObject["requestMessage"] = requestTextView.text
        requestObject["title"] = titleTextField.text
        RequestHandler.postRequest(requestObject, completion: checkRequest)
    }

    
    func checkRequest(result: NSError?) -> Void {
        if let error = result {
            
            let errorString = error.userInfo["error"] as? NSString
            let errorCode = error.code
            
            switch errorCode {
            case 100:
                self.presentAlert("No Connection", message: "Please check network connection")
                break
            default:
                self.presentAlert("Error", message: "Please try again later")
                print(NSString(format: "Unhandled Error: %d", errorCode))
                break
            }
            print(errorString)
            
        }
        
    }
    
    func presentAlert(title: NSString, message: NSString) {
        let alertController = UIAlertController(title: title as String, message: message as String, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
