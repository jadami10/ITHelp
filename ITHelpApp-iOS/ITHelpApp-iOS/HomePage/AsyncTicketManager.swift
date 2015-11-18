//
//  AsyncTicketManager.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 11/17/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import Foundation
import Parse

class AsyncTicketManager: NSObject{
    
    static let sharedInstance = AsyncTicketManager()
    
    var pendingTickets = [PFObject]()
    var openTickets = [PFObject]()
    var solvedTickets = [PFObject]()
    
    var lock = NSLock()
    var updating = false
    
    var listeners = [UITableView]()
    
    func clearTickets() {
        pendingTickets = []
        openTickets = []
        solvedTickets = []
        AppConstants.curTicketsNum = 0
    }
    
    func addticket() {
//        NSThread.performSelectorOnMainThread(<#T##aSelector: Selector##Selector#>, withObject: <#T##AnyObject?#>, waitUntilDone: <#T##Bool#>)
    }
    
    func getNumSections() -> Int {
        var numSections = 0
        if pendingTickets.count > 0 {
            numSections++
        }
        if openTickets.count > 0 {
            numSections++
        }
        
        if solvedTickets.count > 0 {
            numSections++
        }
        return numSections
    }
    
    func getNumTotalTickets() -> Int {
        return pendingTickets.count + openTickets.count + solvedTickets.count
    }
    
    func registerListener(tableview: UITableView) {
        listeners.append(tableview)
    }

}