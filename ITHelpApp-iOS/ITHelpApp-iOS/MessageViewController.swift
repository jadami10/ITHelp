//
//  messaging.swift
//  ITHelpApp-iOS
//
//  Created by Xinhe on 10/13/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import UIKit
import Parse
import PubNub

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PNObjectEventListener {
   
    var reqHandler: PubnubHandler?
    var ticket: PFObject?

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var textTable: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    var messages: [Message] = []

    
    @IBAction func refreshMessage() {
        queryMessage((PFUser.currentUser()?.username)!)
        //textTable.reloadData()
        //print(messages)


    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        changeSendButtonState(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textTable.delegate = self
        textTable.dataSource = self
        refreshMessage()
        
        if let ticket = ticket {
            if (reqHandler == nil) {
                print("Joining channel: " + ticket.objectId!)
                reqHandler = PubnubHandler(pubKey: AppConstants.pubnubPubKey, subKey: AppConstants.pubnubSubKey, comChannel: ticket.objectId!)
                reqHandler?.addHandler(self)
            }
        } else {
            print("TODO: handle no ticketID")
        }

    }
    
    @IBAction func sendPressed(sender: AnyObject) {
        let currentUser = PFUser.currentUser()
        let messageObject = PFObject(className:"Message")
        messageObject["sender"] = currentUser?.username
        messageObject["message"] = messageTextField.text
        messageObject["request"] = ticket
        MessageHandler.postMessage(messageObject, completion: checkMessage)
        //refreshMessage()
        messageTextField.text = ""
        changeSendButtonState(false)
    }
    


    func checkMessage(result: NSError?) -> Void {
        if let error = result {
            
            let errorString = error.userInfo["error"] as? NSString
            let errorCode = error.code
            
            switch errorCode {
            case 100:
                //self.presentAlert("No Connection", message: "Please check network connection")
                break
            default:
                //self.presentAlert("Error", message: "Please try again later")
                print(NSString(format: "Unhandled Error: %d", errorCode))
                break
            }
            print(errorString)
            
        }
        
    }
    

    
    func tableView(textTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count

    }
    
    func tableView(textTable: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //
        let cell = textTable.dequeueReusableCellWithIdentifier("cell")
        cell?.textLabel?.text = messages[indexPath.row].message
        cell?.detailTextLabel?.text = messages[indexPath.row].sender
        return cell!
        
    }
    
    func numberOfSectionsInTableView(textTable: UITableView) -> Int {
        return 1
    }
    
    
    func queryMessage(username:String){
        let query = PFQuery(className:"Message")
        query.whereKey("sender", equalTo:username)
        query.whereKey("request", equalTo: ticket!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count)")
                // Do something with the found objects
                if let objects = objects as [PFObject]! {
                    self.messages = []
                    for object in objects {
                        let newMessage = Message(sender: object["sender"] as! String, message: object["message"] as! String)
                        self.messages.append(newMessage)
                    }
                }
                self.textTable.reloadData()
            } else {
                // Log details of the failure
                print("Error: \(error!))")
            }
        }
    }
    
    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!) {
        print("new message!")
        if let sender = message.data.message["sender"] as? String, msg = message.data.message["message"] as? String {
            let newMessage = Message(sender: sender, message: msg)
            messages.append(newMessage)
            textTable.reloadData()
        } else {
            print("bad message")
        }
    }
    
    @IBAction func messageEditingFinished(sender: AnyObject) {
        if let msg = messageTextField.text {
            if !msg.isEmpty {
                changeSendButtonState(true)
                return
            }
        }
        changeSendButtonState(false)
    }
    
    func changeSendButtonState(active: Bool) {
        if (active) {
            sendButton.enabled = true
        } else {
            sendButton.enabled = false
        }
    }
    

}
