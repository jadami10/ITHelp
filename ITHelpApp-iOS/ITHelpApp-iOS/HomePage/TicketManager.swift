//
//  TicketManager.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 11/15/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import Foundation
import Parse

class TicketManager {
    
    static let sharedInstance = TicketManager()
    
    var pendingTickets = [PFObject]()
    var openTickets = [PFObject]()
    var solvedTickets = [PFObject]()
    
    var listeners = [UIBlockableProtocol]()
    
    func clearTickets() {
        pendingTickets = []
        openTickets = []
        solvedTickets = []
    }
    
    func getTickets() {
        for listener in listeners {
            listener.blockUI()
        }
        self.clearTickets()
        var completions:[()->()] = []
        completions.append(self.alertListeners)
        TicketHandler.getTickets(addTickets, completions: completions)
    }
    
    func getTicketsWithCallback(gotTickets: (() -> Void)?) {
        for listener in listeners {
            listener.blockUI()
        }
        self.clearTickets()
        var completions:[()->()] = []
        completions.append(self.alertListeners)
        if (gotTickets != nil) {
            completions.append(gotTickets!)
        }
        TicketHandler.getTickets(addTickets, completions: completions)
    }
    
    func addTickets(object: PFObject, type: Int) -> Void{
        if type == 0 {
            pendingTickets.append(object)
        } else if type == 1 {
            openTickets.append(object)
        } else {
            solvedTickets.append(object)
        }
        AppConstants.curTicketsNum = pendingTickets.count + openTickets.count + solvedTickets.count
        //print(object)
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
    
    func getTicketType(section: Int, row: Int) -> TicketType {
        let q = getTicketQueue(section)
        if  q == pendingTickets {
            return TicketType.Pending
        } else if q == openTickets {
            return TicketType.Open
        } else {
            return TicketType.Solved
        }
    }
    
    func getTicketQueue(section: Int) -> [PFObject] {
        //print(String(format: "P: %d O: %d S: %d", pendingTickets.count, openTickets.count, solvedTickets.count))
        if (section == 0) {
            if pendingTickets.count > 0 {
                return pendingTickets
            } else if (openTickets.count > 0) {
                return openTickets
            } else {
                return solvedTickets
            }
        } else if (section == 1) {
            if (pendingTickets.count > 0 && openTickets.count > 0) {
                return openTickets
            } else {
                return solvedTickets
            }
        } else {
            return solvedTickets
        }
    }
    
    func handleTicketDeletion(indexPath: NSIndexPath, checkDeletion: (isDeleted: Bool, error: NSError?) -> Void) {
        let q = getTicketQueue(indexPath.section)
        let ticket = q[indexPath.row - 1]
        TicketHandler.deleteTicket(ticket, completion: checkDeletion)
    }
    
    func ticketDeleted(index: Int) -> Int {
        pendingTickets.removeAtIndex(index - 1)
        return pendingTickets.count
    }
    
    func getTicketById(requestID: String) -> PFObject? {
        for ticket in pendingTickets {
            if ticket.objectId == requestID {
                return ticket
            }
        }
        for ticket in openTickets {
            if ticket.objectId == requestID {
                return ticket
            }
        }
        for ticket in solvedTickets {
            if ticket.objectId == requestID {
                return ticket
            }
        }
        return nil
    }
    
    func registerListener(listener: UIBlockableProtocol) {
        listeners.append(listener)
    }
    
    func alertListeners() {
        for listener in listeners {
            listener.reloadData()
            listener.releaseUI()
        }
    }
    
}

enum TicketType: String {
    case Pending
    case Open
    case Solved
}