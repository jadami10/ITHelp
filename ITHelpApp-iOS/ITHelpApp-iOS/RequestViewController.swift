//
//  RequestViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Johan Adami on 10/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class RequestViewController: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate , UITextFieldDelegate, UITextViewDelegate{

    @IBOutlet weak var requestTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imagePicker: UIImageView!
    var imagePickerView: UIImagePickerController!
    var photoFile: NSData!

    var busyFrame: UIView?
    
    @IBOutlet weak var titleTextFieldCount: UILabel!
    @IBOutlet weak var requestTextViewCount: UILabel!
    let maxTitleLength = 100
    let maxRequestLength = 500
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        titleTextField.delegate = self
        requestTextView.delegate = self
        self.getMaxTickets()
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePickerView.dismissViewControllerAnimated(true, completion: nil)
        imagePicker.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }



    @IBAction func requestPressed(sender: AnyObject) {
        
        var goodRequest = true
        let ticketTitle = titleTextField.text
        let ticketMsg = requestTextView.text
        
        if (ticketTitle == nil || ticketTitle!.isEmpty) {
            goodRequest = false
            titleTextField.shakeTextField()
        }
        if (ticketMsg == nil || ticketMsg!.isEmpty) {
            goodRequest = false
            requestTextView.shakeTextView()
        }
        
        if (goodRequest) {

            self.asyncBlockingAction("Sending Request", taskToRun: sendRequest)

        }
    }
    
    func sendRequest(activityFrame:UIView) -> Void {
        self.busyFrame = activityFrame
        let ticketTitle = titleTextField.text
        let ticketMsg = requestTextView.text
        let currentUser = PFUser.currentUser()
        let requestObject = PFObject(className:"Request")
        if (imagePicker.image != nil){
            var file = PFFile(name: "image", data: UIImageJPEGRepresentation(imagePicker.image!, 0.5)!)
            requestObject["photoFile"] = file
        }
        requestObject["requester"] = currentUser?.username
        requestObject["requestMessage"] = ticketMsg
        requestObject["title"] = ticketTitle
        requestObject["taken"] = 0
        
        RequestHandler.postRequest(requestObject, completion: self.checkRequest)
    }

    
    func checkRequest(result: NSError?) -> Void {
        if let error = result {
            
            let errorString = error.userInfo["error"] as? NSString
            let errorCode = error.code
            
            switch errorCode {
            case 100:
                self.presentAlert("No Connection", message: "Please check network connection", completion: nil)
                break
            case 142:
                if errorString != nil && errorString == "Too many open requests" {
                    self.presentAlert("Too many requests", message: String(format: "At max requests: %d", AppConstants.maxTickets!), completion: nil)
                } else {
                    print(NSString(format: "Unhandled Error: %d", errorCode))
                    self.presentAlert("Error", message: "Please try again later", completion: nil)
                }
                break
            default:
                self.presentAlert("Error", message: "Please try again later", completion: nil)
                print(NSString(format: "Unhandled Error: %d", errorCode))
                break
            }
            print(errorString)
            
        } else {
            self.clearUI()
        }
        self.releaseUI()
    }
    
    @IBAction func titleTextFieldChanged(sender: AnyObject) {
        if (sender as! NSObject == titleTextField) {
            titleTextFieldCount.text = String(format: "%d/%d", (titleTextField.text?.characters.count)!, maxTitleLength)
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text!
        let newString: NSString =
        currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxTitleLength
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        let curLength = textView.text.characters.count + text.characters.count - range.length
        if (curLength <= maxRequestLength) {
            requestTextViewCount.text = String(format: "%d/%d", curLength, maxRequestLength)
            return true
        } else {
            return false
        }

    }
    
    func getMaxTickets() {
        if let maxTickets = PFUser.currentUser()?.valueForKey("MaxTickets") as? Int {
            AppConstants.maxTickets = maxTickets
        } else {
            AppConstants.maxTickets = 5
        }
        print(String(format: "Max Tickets: %d", AppConstants.maxTickets!))
    }
    
    func clearUI() {
        requestTextView.text = ""
        titleTextField.text = ""
        imagePicker.image = nil
    }
    
    func releaseUI() {
        self.view.userInteractionEnabled = true
        self.busyFrame?.removeFromSuperview()
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
