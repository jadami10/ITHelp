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
    
    private static var ticketQuery: PFQuery {
        let _query = PFQuery(className:"Request")
        _query.whereKey("requesterPointer", equalTo:PFUser.currentUser()!)
        _query.whereKey("requesterSolved", notEqualTo: 1)
        _query.includeKey("helper")
        _query.includeKey("tags")
        return _query
    }
    
    static func getTicketByID(id: String, completion: ((PFObject?, NSError?) -> Void)?) {
        let _query = PFQuery(className: "Request")
        _query.includeKey("helper")
        _query.includeKey("tags")
        _query.getObjectInBackgroundWithId(id, block: completion)
    }
    
    static func getTicketByIDSync(id: String) throws -> PFObject {
        let _query = PFQuery(className: "Request")
        _query.includeKey("helper")
        _query.includeKey("tags")
        return try _query.getObjectWithId(id)
    }
    
    static func getTickets(add: ((PFObject, Int) -> Void), completions: [() -> Void]) -> Void{
        ticketQuery.findObjectsInBackgroundWithBlock {
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
                        if object["taken"] as! Int == 0 {
                            add(object, 0)
                        } else if (object["helperSolved"] as! Int != 1) {
                            add(object, 1)
                        } else {
                            add(object, 2)
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!))")
            }
            for completion in completions {
                completion()
            }
        }
    }
    
    static func getTicketsSync() throws -> [PFObject] {
        return try ticketQuery.findObjects()
    }
    
    static func deleteTicketSync(ticket: PFObject) throws {
        try ticket.delete()
    }
    
    static func deleteTicket(ticket: PFObject, completion: PFBooleanResultBlock) {
        ticket.deleteInBackgroundWithBlock(completion)
    }
    
    static func deleteTicketEventually(ticket: PFObject) {
        ticket.deleteEventually()
    }
    
    static func markTicketSolved(ticket: PFObject, completion: PFBooleanResultBlock) {
        ticket.setValue(1, forKey: "requesterSolved")
        ticket.saveInBackgroundWithBlock(completion)
    }
    
    static func solveTicketEventually(ticket: PFObject) {
        ticket.setValue(1, forKey: "requesterSolved")
        ticket.saveEventually()
    }
    
    static func declineSolutionEventually(ticket: PFObject) {
        ticket.setValue(0, forKey: "requesterSolved")
        ticket.saveEventually()
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