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

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, PNObjectEventListener {
   
    var reqHandler: PubnubHandler?
    var ticket: PFObject?
    var busyFrame: UIView?

    @IBOutlet weak var messageTextField: UITextView!
    @IBOutlet weak var textTable: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    var lastHelperIndex = -1
    var lastUserIndex = -1
    
    var keyboardShowing: Bool!
    
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
        changeSendButtonState(false)
        textTable.delegate = self
        textTable.dataSource = self
        if (messages.count) == 0 {
            messages = []
            self.refreshMessage()
        }
        
        
//        self.tabBarController?.tabBar.hidden = true
        
        
//        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.keyboardShowing = false
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: self.view.window)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: self.view.window)
//        self.automaticallyAdjustsScrollViewInsets = false
        
        self.hidesBottomBarWhenPushed = true

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIConstants.mainUIColor
        let optionButton = UIBarButtonItem(title: "Options", style: .Plain, target: self, action: "goToOptionPage")
        self.navigationItem.rightBarButtonItem = optionButton
        
        if let ticket = ticket {
            if (reqHandler == nil) {
                print("Joining channel: " + ticket.objectId!)
                reqHandler = PubnubHandler(pubKey: AppConstants.pubnubPubKey, subKey: AppConstants.pubnubSubKey, comChannel: ticket.objectId!)
                reqHandler?.addHandler(self)
            }
        } else {
            self.presentAlert("No Ticket", message: "Can't find ticket", completion: self.goToTicketPage)
        }
        self.tableViewScrollToBottom(true)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.setupMessageView()
    
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.dismissKeyboard()
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    func setupMessageView() {
        
//        messageView.sizeToFit()
//        messageTextField.sizeToFit()
        messageTextField.layer.cornerRadius = 8
        messageTextField.layer.borderWidth = 1
        messageTextField.layer.borderColor = UIConstants.mainUIColor.CGColor
        //messageTextField.scrollEnabled = false
        
//        let border = CALayer()
//        border.frame = CGRectMake(0, 0, CGRectGetWidth(messageView.frame), 1.0)
//        border.backgroundColor = UIConstants.mainUIColor.CGColor
//        messageView.layer.addSublayer(border)
        messageTextField.delegate = self
        
        // size message field correctly
//        let fixedWidth : CGFloat = messageTextField.frame.size.width
//        let newSize : CGSize = messageTextField.sizeThatFits(CGSizeMake(fixedWidth, CGFloat(MAXFLOAT)))
//        var newFrame : CGRect = messageTextField.frame
//        newFrame.size = CGSizeMake(CGFloat(fmaxf((Float)(newSize.width), (Float)(fixedWidth))),newSize.height)
//        
//        messageTextField.frame = newFrame
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
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"
        {
            textView.resignFirstResponder()
            sendPressed(textView)
            return false
        }
        let curLength = textView.text.characters.count + text.characters.count - range.length
        if curLength == 0 {
            changeSendButtonState(false)
        } else {
            changeSendButtonState(true)
        }
        return true
    }
    /*
    func textViewDidChange(textView: UITextView) {
        let fixedWidth : CGFloat = textView.frame.size.width
        let newSize : CGSize = textView.sizeThatFits(CGSizeMake(fixedWidth, CGFloat(MAXFLOAT)))
        var newFrame : CGRect = textView.frame
        newFrame.size = CGSizeMake(CGFloat(fmaxf((Float)(newSize.width), (Float)(fixedWidth))),newSize.height)
        
        textView.frame = newFrame
        print(newFrame.size)

    }
    */
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
            let isMe = messages[indexPath.row]!.sender == PFUser.currentUser()?.username
            let cell = isMe ? textTable.dequeueReusableCellWithIdentifier("SendMessageCell", forIndexPath: indexPath) as! MessageTableViewCell :
                textTable.dequeueReusableCellWithIdentifier("ReceiveMessageCell", forIndexPath: indexPath) as! MessageTableViewCell
            
            cell.setMessageText(message, isSelf: isMe)
            
            //let count = messages.count
            let row = indexPath.row
            if (row == lastUserIndex) {
                cell.setMessagePortrait(true)
            } else if (row == lastHelperIndex) {
                cell.setMessagePortrait(false)
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
        if (active && ticket!["taken"] as! Int != 0) {
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
                self.textTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: animated)
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
    
    func goToTicketPage(alert: UIAlertAction) {
        print("go back to ticket page")
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func goToClosedPage() {
        
        //let cc = CloseTicketViewController()
        let storyboard = UIStoryboard(name: "message", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("ClosedTicket") as! CloseTicketViewController
        let image = self.screenShotMethod()
        controller.image = image
        navigationController?.pushViewController(controller, animated: false)
    }
    
    func goToOptionPage() {
        let storyboard = UIStoryboard(name: "message", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("TicketOptions") as! TicketOptionViewController
        controller.ticket = ticket
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func keyboardWillHide(sender: NSNotification) {
        
        if keyboardShowing == true {
            print("keyboard will hide")
            let userInfo: [NSObject : AnyObject] = sender.userInfo!
            let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
//            self.view.frame.origin.y += keyboardSize.height
            self.sendButton.frame.origin.y += keyboardSize.height
            self.messageTextField.frame.origin.y += keyboardSize.height
            keyboardShowing = false
        } else {
            print("keyboard already hidden")
        }
        
    }
    
    func keyboardWillShow(sender: NSNotification) {
        
        
        if keyboardShowing == false {
            print("Keyboard will show")
        } else {
            print("keyboard already showing")
        }
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        
        if keyboardSize.height == offset.height {
            if self.view.frame.origin.y == 0 {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
//                    self.view.frame.origin.y -= keyboardSize.height
                    self.sendButton.frame.origin.y -= keyboardSize.height
                    self.messageTextField.frame.origin.y -= keyboardSize.height
                })
            }
        } else {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
//                self.view.frame.origin.y += keyboardSize.height - offset.height
                self.sendButton.frame.origin.y  += keyboardSize.height - offset.height
                self.messageTextField.frame.origin.y += keyboardSize.height - offset.height
            })
        }
//        print(self.view.frame.origin.y)
        keyboardShowing = true
        //        } else {
        //            print("keyboard already showing")
        //        }
    }

}
