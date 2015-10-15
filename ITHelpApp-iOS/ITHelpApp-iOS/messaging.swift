//
//  messaging.swift
//  ITHelpApp-iOS
//
//  Created by Xinhe on 10/13/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import UIKit


var allMessages = [String]()

class messaging: UIViewController, UITableViewDelegate, UITableViewDataSource {
   

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var textTable: UITableView!
    @IBAction func sendPressed(sender: AnyObject) {
        let currentUser = PFUser.currentUser()
        let messageObject = PFObject(className:"Message")
        messageObject["sender"] = currentUser?.username
        messageObject["message"] = messageTextField.text
        MessageHandler.postMessage(messageObject, completion: checkMessage)
        refreshMessage()
        messageTextField.text = ""
    }
    
    var petitions: [PFObject] = []

    
    @IBAction func refreshMessage() {
        queryMessage((PFUser.currentUser()?.username)!)
        textTable.reloadData()
        print(petitions)


    }
    
    override func viewDidLoad() {
        queryMessage((PFUser.currentUser()?.username)!)
        super.viewDidLoad()
        textTable.delegate = self
        textTable.dataSource = self

    }


    func checkMessage(result: NSError?) -> Void {
        if let error = result {
            
            let errorString = error.userInfo["error"] as? NSString
            let errorCode = error.code
            
//            switch errorCode {
//            case 100:
//                self.presentAlert("No Connection", message: "Please check network connection")
//                break
//            default:
//                self.presentAlert("Error", message: "Please try again later")
//                print(NSString(format: "Unhandled Error: %d", errorCode))
//                break
//            }
            print(errorString)
            
        }
        
    }
    

    
    func tableView(textTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMessages.count

    }
    func tableView(textTable: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //
        var cell = textTable.dequeueReusableCellWithIdentifier("cell")
        cell?.textLabel?.text = allMessages[indexPath.row]
        cell?.detailTextLabel?.text = petitions[indexPath.row].valueForKey("sender") as! String
        return cell!
        
    }
    
    func numberOfSectionsInTableView(textTable: UITableView) -> Int {
        return 1
    }
    
    
    func queryMessage(username:String){
        var query = PFQuery(className:"Message")
        query.whereKey("sender", equalTo:username)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count)")
                // Do something with the found objects
                if let objects = objects as [PFObject]! {
                    self.petitions = []
                    for object in objects {
                            self.petitions.append(object)
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!))")
            }
        }
        allMessages = []
        for objects in petitions{
            allMessages.append(objects.valueForKey("message") as! String)
        }
    }

}
