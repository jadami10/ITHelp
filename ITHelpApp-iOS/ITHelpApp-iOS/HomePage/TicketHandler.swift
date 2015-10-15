//
//  TicketHandler.swift
//  ITHelpApp-iOS
//
//  Created by Xinhe on 10/14/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import Foundation
import UIKit
var petitions = [PFObject]()

class TicketHandler{
    static func getTickets(add: (PFObject -> Void)) -> Void{
        var query = PFQuery(className:"Request")
        query.whereKey("requester", equalTo:(PFUser.currentUser()?.username)!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Tickets retrieved: \(objects!.count)")
                // Do something with the found objects
                if let objects = objects as [PFObject]! {
                    petitions = []
                    for object in objects {
                        add(object)
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!))")
            }
        }
    }
}