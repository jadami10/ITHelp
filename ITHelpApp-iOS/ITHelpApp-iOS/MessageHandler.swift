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
    

}