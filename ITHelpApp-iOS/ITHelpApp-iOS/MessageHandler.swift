//
//  MessageHandler.swift
//  ITHelpApp-iOS
//
//  Created by Xinhe on 10/13/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import Foundation
import Parse


class MessageHandler {
    
    static let labelSpacing: CGFloat = 6
    
    func queryMessage(username:String){
        let query = PFQuery(className:"Message")
        //query.whereKey("sender", equalTo:username)
        query.whereKey("request", equalTo: ticket!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Messages retrieved \(objects!.count)")
                // Do something with the found objects
                if let objects = objects as [PFObject]! {
                    self.messages = []
                    for object in objects {
                        let newMessage = Message(sender: object["sender"] as! String, message: object["message"] as! String, time: object.createdAt!)
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
    
    static func postMessage(message: PFObject, completion: (result: NSError?) -> Void){
        
        message.saveInBackgroundWithBlock {
            // afterSave will send to pubnub
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("message sent!")
            } else {
                completion(result: error)
            }
        }
    }
    
    static func getMessageHeight(message: String, width: CGFloat) -> CGFloat {
        
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width - 2 * UIConstants.cellInset, height: CGFloat.max))
        messageLabel.text = message
        messageLabel.adjustsFontSizeToFitWidth = false
        messageLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        messageLabel.numberOfLines = 0
        messageLabel.sizeToFit()
        
        let cellHeight = UIConstants.cellInset + 2 * labelSpacing + messageLabel.frame.height + UIConstants.cellInset
        
        return cellHeight
    }
    

}