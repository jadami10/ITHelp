//
//  RequestViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Johan Adami on 10/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class RequestViewController: UIViewController {

    @IBOutlet weak var requestTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func requestPressed(sender: AnyObject) {
        let currentUser = PFUser.currentUser()
        let requestObject = PFObject(className:"Request")
        requestObject["requester"] = currentUser?.username
        requestObject["requestMessage"] = requestTextView.text
        requestObject["title"] = titleTextField.text
        requestObject.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("good!")
            } else {
                print(error?.description)
            }
        }
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
