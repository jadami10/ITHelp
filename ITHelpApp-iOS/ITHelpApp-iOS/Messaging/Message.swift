//
//  Message.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/20/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import Foundation

class Message {
    var sender: String
    var message: String
    var time: NSDate
    var solution = false
    
    init(sender: String, message: String, time: NSDate) {
        self.sender = sender
        self.message = message
        self.time = time
    }
}