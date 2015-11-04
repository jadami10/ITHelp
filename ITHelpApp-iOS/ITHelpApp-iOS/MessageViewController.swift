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
    var busyFrame: UIView?

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var textTable: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    var lastHelperIndex = -1
    var lastUserIndex = -1
    
    var messages: [Message?] = []

    
    func refreshMessage() {
        self.view.userInteractionEnabled = false
        self.busyFrame = self.progressBarDisplayer("Getting Messages", indicator: true)
        if ticket != nil {
            MessageHandler.queryMessages(ticket!, addMessage: addMessage, completion: gotMessages)
        }
        self.view.userInteractionEnabled = true
    }
    
    func gotMessages() {
        self.textTable.reloadData()
        self.busyFrame?.removeFromSuperview()
        self.view.userInteractionEnabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.tintColor = UIConstants.mainUIDarkerColor
        self.navigationController?.navigationBar.barTintColor = UIConstants.mainUIColor
        changeSendButtonState(false)
        textTable.delegate = self
        textTable.dataSource = self
        if (messages.count) == 0 {
            messages = []
            self.refreshMessage()
        }
        
        let detailButton = UIBarButtonItem(title: "Details", style: .Plain, target: self, action: "goToClosedPage")
        self.navigationItem.rightBarButtonItem = detailButton
        
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let ticket = ticket {
            if (reqHandler == nil) {
                print("Joining channel: " + ticket.objectId!)
                reqHandler = PubnubHandler(pubKey: AppConstants.pubnubPubKey, subKey: AppConstants.pubnubSubKey, comChannel: ticket.objectId!)
                reqHandler?.addHandler(self)
            }
        } else {
            print("TODO: handle no ticketID")
        }
        self.tableViewScrollToBottom(true)

    }
    
    @IBAction func sendPressed(sender: AnyObject) {
        let currentUser = PFUser.currentUser()
        let messageObject = PFObject(className:"Message")
        messageObject["sender"] = currentUser?.username
        messageObject["message"] = messageTextField.text
        messageObject["request"] = ticket
        MessageHandler.postMessage(messageObject, completion: checkMessage)
        messageTextField.text = ""
        changeSendButtonState(false)
        self.tableViewScrollToBottom(true)
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
    
    func addMessage(message: Message) {
        if (messages.count == 0) {
            messages.append(nil)
            messages.append(message)
        } else {
            if let prevMessage = messages[messages.count - 1] {
                if prevMessage.sender == message.sender {
                    messages.append(message)
                } else {
                    messages.append(nil)
                    messages.append(message)
                }
            } else {
                messages.append(message)
            }
        }
        
        if (message.sender == PFUser.currentUser()?.username) {
            lastUserIndex = messages.count - 1
        } else {
            lastHelperIndex = messages.count - 1
        }
    }
    
    func tableView(textTable: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // self goes to right
        
        if let message = messages[indexPath.row]?.message {
            let cell = textTable.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageTableViewCell
            let isMe = messages[indexPath.row]!.sender == PFUser.currentUser()?.username
            
            cell.setMessageText(message, isSelf: isMe)
            
            //let count = messages.count
            let row = indexPath.row
            if (row == lastUserIndex) {
                cell.setPortrait(true)
            } else if (row == lastHelperIndex) {
                cell.setPortrait(false)
            } else {
                cell.removePortrait()
            }
            
            return cell

        } else {
           let cell = textTable.dequeueReusableCellWithIdentifier("LargeSpacer", forIndexPath: indexPath)
            return cell
        }

        
        /*
        //cell?.textLabel?.text = messages[indexPath.row].message
        //cell?.textLabel?.numberOfLines = 10
        //cell?.textLabel?.lineBreakMode =  NSLineBreakMode.ByWordWrapping
        //cell?.detailTextLabel?.text = messages[indexPath.row].sender
        
        //change text color based on sender - need to be written into a method or custom cell later
        if messages[indexPath.row].sender == PFUser.currentUser()?.username{
            cell?.detailTextLabel?.textColor = UIColor.grayColor()
            cell?.textLabel?.textColor = UIColor.grayColor()
            cell?.textLabel?.textAlignment = .Right
            //cell?.detailTextLabel?.textAlignment = .Right
        }
        else{
            cell?.detailTextLabel?.textColor = UIColor.blackColor()
            cell?.textLabel?.textColor = UIColor.blackColor()
            cell?.textLabel?.textAlignment = .Left
            //cell?.detailTextLabel?.textAlignment = .Left
        }
        */
        
    }
    
    func numberOfSectionsInTableView(textTable: UITableView) -> Int {
        return 1
    }
    
    
    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!) {
        print("new message!")
        if let sender = message.data.message["sender"] as? String, msg = message.data.message["message"] as? String {
            let newMessage = Message(sender: sender, message: msg, time: NSDate())
            addMessage(newMessage)
            textTable.reloadData()
            self.tableViewScrollToBottom(true)
        } else {
            print("bad message")
            print(message.data.message)
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
    
    func tableViewScrollToBottom(animated: Bool) {
        
        let delay = 0.2 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            
            let numberOfSections = self.textTable.numberOfSections
            let numberOfRows = self.textTable.numberOfRowsInSection(numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
                self.textTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
            }
            
        })
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let message = messages[indexPath.row]?.message {
        return MessageHandler.getMessageHeight(message, width: self.view.frame.width)
        } else {
            return 5
        }

    }
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("showing messages")
        if let cellIndex = tableView.indexPathForSelectedRow?.row {
            print("Index: %d", cellIndex)
            if tickets.count > (cellIndex - 1) {
                let ticketId = tickets[cellIndex - 1]
                let msgViewController = segue.destinationViewController as! MessageViewController
                msgViewController.ticket = ticketId;
            } else {
                print("Could not get ticketID")
            }
            
            //destination.blogName = swiftBlogs[blogIndex]
        } else {
            print("could not get ticket index")
        }
        //msgViewController.ticketID =
    }
    */
    
    func goToClosedPage() {
        
        //let cc = CloseTicketViewController()
        let storyboard = UIStoryboard(name: "message", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("ClosedTicket") as! CloseTicketViewController
        let image = self.screenShotMethod()
        controller.image = image
        navigationController?.pushViewController(controller, animated: false)
    }

}
