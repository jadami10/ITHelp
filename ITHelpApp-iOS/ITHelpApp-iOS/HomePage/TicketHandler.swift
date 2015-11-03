//
//  TicketHandler.swift
//  ITHelpApp-iOS
//
//  Created by Xinhe on 10/14/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import Foundation
import UIKit
import Parse

var petitions = [PFObject]()

class TicketHandler{
    static func getTickets(add: (PFObject -> Void), completion: () -> Void) -> Void{
        let query = PFQuery(className:"Request")
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
                        petitions.append(object)
                        //add(object)
                    }
                    for object in petitions{
                        add(object)
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!))")
            }
            completion()
        }
    }
    
    static func ticketTaken() -> Void {
        
    }
    
    static func getReqChannel() -> String {
        var reqChannel = "RequestChannel"
        let query = PFQuery(className:"Config")
        query.whereKey("key", equalTo:("RequestChannel"))
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if (error == nil && objects?.count > 0) {
                // The find succeeded.
                // Do something with the found objects
                reqChannel = objects![0]["val"] as! String
            } else {
                // Log details of the failure
                print("Error: \(error!))")
            }
        }
        return reqChannel
    }
}