//
//  AsyncTicketManager.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 11/17/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import Foundation
import Parse

class AsyncTicketManager {
    
    static let sharedInstance = AsyncTicketManager()
    
    private let concurrentTicketQueue = dispatch_queue_create(
        "com.briskit.ticketQueue", DISPATCH_QUEUE_CONCURRENT)
    
    var pendingTickets = [PFObject]()
    var openTickets = [PFObject]()
    var solvedTickets = [PFObject]()
    
    var queueRef = [Int: [PFObject]]()
    
    var lock = NSLock()
    var updating = false
    
    var listener: UITableView!
    
    private init() {}
    
    private func clearTickets() {
        pendingTickets = []
        openTickets = []
        solvedTickets = []
        AppConstants.curTicketsNum = 0
    }
    
    private func updateGlobalTicketCount() {
        // only do this in a thread-safe area
        AppConstants.curTicketsNum = pendingTickets.count + openTickets.count + solvedTickets.count
    }
    
    func addTicket(object: PFObject, type: Int) -> Void{
        
        dispatch_barrier_async(concurrentTicketQueue) {
            print(String(format: "Adding ticket: %@", object.objectId!))
            let section = type
            var row = -1
            var newSection = false
            if type == 0 && self.pendingTickets.indexOf(object) < 0 {
                print("adding pending ticket")
                self.pendingTickets.append(object)
                row = self.pendingTickets.count - 1
                newSection = row == 0
            } else if type == 1 && self.openTickets.indexOf(object) < 0 {
                print("adding open ticket")
                self.openTickets.append(object)
                row = self.openTickets.count - 1
                newSection = row == 0
            } else if type == 2 && self.solvedTickets.indexOf(object) < 0 {
                print("adding solved ticket")
                self.solvedTickets.append(object)
                row = self.solvedTickets.count - 1
                newSection = row == 0
            } else {
                print("ticket already exists")
            }
            self.updateGlobalTicketCount()
            if row >= 0 {
                dispatch_async(GlobalMainQueue) {
                    let rowPath = NSIndexPath(forRow: row, inSection: section)
                    let sectionPath = NSIndexSet(index: section)
                    self.listener.beginUpdates()
                    
                    if newSection {
                        self.listener.insertSections(sectionPath, withRowAnimation: .Fade)
                    }
                    self.listener.insertRowsAtIndexPaths([rowPath], withRowAnimation: .Fade)
                    self.listener.endUpdates()
                }
            }

        }
        
    }
    
    func readdTicket(object: PFObject) -> Void {
        dispatch_barrier_async(concurrentTicketQueue) {
            if self.openTickets.contains(object) {
                print(String(format: "Readding ticket: %@", object.objectId!))
            } else {
                print(String(format: "Ticket %@ not open to be readded", object.objectId!))
                return
            }

            let sectionAdd = 0
            let sectionRemove = self.getSectionForQueue(&self.openTickets)
            let rowAdd = self.pendingTickets.count
            let rowRemove = self.openTickets.indexOf(object)
            
            self.pendingTickets.append(object)
            self.openTickets.removeAtIndex(rowRemove!)
            
            let removeOpen = self.openTickets.count == 0
            let addPending = self.pendingTickets.count == 1
            
            self.updateGlobalTicketCount()

            dispatch_async(GlobalMainQueue) {
                
                self.listener.beginUpdates()
                
                self.listener.deleteRowsAtIndexPaths([NSIndexPath(forRow: rowRemove!, inSection: sectionRemove!)], withRowAnimation: .Fade)
                if removeOpen {
                    self.listener.deleteSections(NSIndexSet(index: sectionRemove!), withRowAnimation: .Fade)
                }
                self.listener.insertRowsAtIndexPaths([NSIndexPath(forRow: rowAdd, inSection: sectionAdd)], withRowAnimation: .Fade)
                if addPending {
                    self.listener.insertSections(NSIndexSet(index: sectionAdd), withRowAnimation: .Fade)
                }
                
                self.listener.endUpdates()
            }
            
        }
    }
    
    func moveTicketToTaken(newTicket: PFObject) {
        let ticket = self.getTicketByID(newTicket.objectId!)
        
        if ticket != nil {
            dispatch_barrier_async(concurrentTicketQueue) {
                
                let fromIndex = self.pendingTickets.indexOf(ticket!)
                let toIndex = self.openTickets.count
                
                let removeFrom = (fromIndex >= 0 && self.pendingTickets.count == 1)
                let addTo = toIndex == 0
                
                dispatch_async(GlobalMainQueue) {
                    
                    let fromSection = self.getSectionForQueue(&self.pendingTickets)
                    if fromIndex >= 0 {
                        self.pendingTickets.removeAtIndex(fromIndex!)
                    }
                    self.openTickets.append(newTicket)
                    let toSection = self.getSectionForQueue(&self.openTickets)
                    
                    self.listener.beginUpdates()
                    if fromIndex >= 0 && fromSection != nil && toSection != nil {
                        
                        
                        self.listener.deleteRowsAtIndexPaths([NSIndexPath(forRow: fromIndex!, inSection: fromSection!)], withRowAnimation: .Fade)
                        if removeFrom {
                            self.listener.deleteSections(NSIndexSet(index: fromSection!), withRowAnimation: .Fade)
                        }
                        
                    } else {
                        print("ticket not in from or sections could not be found")
                    }
                    self.listener.insertRowsAtIndexPaths([NSIndexPath(forRow: toIndex, inSection: toSection!)], withRowAnimation: .Fade)
                    if addTo {
                        self.listener.insertSections(NSIndexSet(index: toSection!), withRowAnimation: .Fade)
                    }
                    self.listener.endUpdates()
                }
                
            }

        }
    }
    
    func moveTicketToSolved(newTicket: PFObject) {
        let ticket = self.getTicketByID(newTicket.objectId!)
        
        if ticket != nil {
            dispatch_barrier_async(concurrentTicketQueue) {
                
                let fromIndex = self.openTickets.indexOf(ticket!)
                let toIndex = self.solvedTickets.count
                
                let removeFrom = (fromIndex >= 0 && self.openTickets.count == 1)
                let addTo = toIndex == 0
                
                dispatch_async(GlobalMainQueue) {
                    
                    let fromSection = self.getSectionForQueue(&self.openTickets)
                    if fromIndex >= 0 {
                        self.openTickets.removeAtIndex(fromIndex!)
                    }
                    self.solvedTickets.append(newTicket)
                    let toSection = self.getSectionForQueue(&self.solvedTickets)
                    
                    self.listener.beginUpdates()
                    if fromIndex >= 0 && fromSection != nil && toSection != nil {
                        
                        
                        self.listener.deleteRowsAtIndexPaths([NSIndexPath(forRow: fromIndex!, inSection: fromSection!)], withRowAnimation: .Fade)
                        if removeFrom {
                            self.listener.deleteSections(NSIndexSet(index: fromSection!), withRowAnimation: .Fade)
                        }
                        
                    } else {
                        print("ticket not in from or sections could not be found")
                    }
                    self.listener.insertRowsAtIndexPaths([NSIndexPath(forRow: toIndex, inSection: toSection!)], withRowAnimation: .Fade)
                    if addTo {
                        self.listener.insertSections(NSIndexSet(index: toSection!), withRowAnimation: .Fade)
                    }
                    self.listener.endUpdates()
                }
                
            }
            
        }
    }
    
    
    /*
    func moveTicketToQueue(ticket: PFObject, fromInt: Int, toInt: Int) {
        dispatch_barrier_async(concurrentTicketQueue) {
            
            
            let fromIndex = from.indexOf(ticket)
            let toIndex = to.count
            
            let removeFrom = (fromIndex >= 0 && from.count == 1)
            let addTo = toIndex == 0
            
            let fromSection = self.getSectionForQueue(&from)
            from.removeAtIndex(fromIndex!)
            to.append(ticket)
            let toSection = self.getSectionForQueue(&to)
            
            print(self.pendingTickets == from)
            


            
            dispatch_async(GlobalMainQueue) {
                
                if fromIndex >= 0 && fromSection != nil && toSection != nil {
                    self.listener.beginUpdates()
                    
                    self.listener.deleteRowsAtIndexPaths([NSIndexPath(forRow: fromIndex!, inSection: fromSection!)], withRowAnimation: .Fade)
                    if removeFrom {
                        self.listener.deleteSections(NSIndexSet(index: fromSection!), withRowAnimation: .Fade)
                    }
                    self.listener.insertRowsAtIndexPaths([NSIndexPath(forRow: toIndex, inSection: toSection!)], withRowAnimation: .Fade)
                    if addTo {
                        self.listener.insertSections(NSIndexSet(index: toSection!), withRowAnimation: .Fade)
                    }
                    
                    self.listener.endUpdates()
                } else {
                    print("ticket not in from or sections could not be found")
                }
            }
        }
    }
    */
    
    func solveTicketByRequester(ticket: PFObject, isMe: Bool) {
        
        let solvedSection = self.getSectionForQueue(&self.solvedTickets)
        
        dispatch_barrier_async(concurrentTicketQueue) {
            if let index = self.solvedTickets.indexOf(ticket) {
                if isMe {
                    TicketHandler.solveTicketEventually(ticket)
                }
                dispatch_async(GlobalMainQueue) {
                    
                    let removeOpen = (index >= 0 && self.solvedTickets.count == 1)
                    
                    if index >= 0 {
                        self.listener.beginUpdates()
                        self.solvedTickets.removeAtIndex(index)
                        
                        self.listener.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: solvedSection!)], withRowAnimation: .Fade)
                        if removeOpen {
                            self.listener.deleteSections(NSIndexSet(index: solvedSection!), withRowAnimation: .Fade)
                        }
                        
                        self.listener.endUpdates()
                    }
                }
            }
            
        }
        
    }
    
    func acceptSolutionByRequester(ticket: PFObject) {
        let solvedSection = self.getSectionForQueue(&self.solvedTickets)
        
        dispatch_barrier_async(concurrentTicketQueue) {
            if let index = self.solvedTickets.indexOf(ticket) {
                TicketHandler.solveTicketEventually(ticket)
                dispatch_async(GlobalMainQueue) {
                    
                    let removeOpen = (index >= 0 && self.solvedTickets.count == 1)
                    
                    if index >= 0 {
                        self.listener.beginUpdates()
                        self.solvedTickets.removeAtIndex(index)
                        
                        self.listener.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: solvedSection!)], withRowAnimation: .Fade)
                        if removeOpen {
                            self.listener.deleteSections(NSIndexSet(index: solvedSection!), withRowAnimation: .Fade)
                        }
                        
                        self.listener.endUpdates()
                    }
                }
            }
            
        }
    }
    
    func declineSolutionByRequester(newTicket: PFObject, isMe: Bool) {
        let ticket = self.getTicketByID(newTicket.objectId!)
        
        if ticket != nil {
            dispatch_barrier_async(concurrentTicketQueue) {
                
                let fromIndex = self.solvedTickets.indexOf(ticket!)
                let toIndex = self.openTickets.count
                
                let removeFrom = (fromIndex >= 0 && self.solvedTickets.count == 1)
                let addTo = toIndex == 0
                
                if isMe {
                    TicketHandler.declineSolutionEventually(ticket!)
                }
                
                dispatch_async(GlobalMainQueue) {
                    
                    let fromSection = self.getSectionForQueue(&self.solvedTickets)
                    if fromIndex >= 0 {
                        self.solvedTickets.removeAtIndex(fromIndex!)
                    }
                    self.openTickets.append(newTicket)
                    let toSection = self.getSectionForQueue(&self.openTickets)
                    
                    self.listener.beginUpdates()
                    if fromIndex >= 0 && fromSection != nil && toSection != nil {
                        
                        
                        self.listener.deleteRowsAtIndexPaths([NSIndexPath(forRow: fromIndex!, inSection: fromSection!)], withRowAnimation: .Fade)
                        if removeFrom {
                            self.listener.deleteSections(NSIndexSet(index: fromSection!), withRowAnimation: .Fade)
                        }
                        
                    } else {
                        print("ticket not in from or sections could not be found")
                    }
                    self.listener.insertRowsAtIndexPaths([NSIndexPath(forRow: toIndex, inSection: toSection!)], withRowAnimation: .Fade)
                    if addTo {
                        self.listener.insertSections(NSIndexSet(index: toSection!), withRowAnimation: .Fade)
                    }
                    self.listener.endUpdates()
                }
                
            }
            
        }
    }
    

    // try to delete a ticket, then reload table
    func deleteTicket(ticket: PFObject) {
        dispatch_barrier_async(concurrentTicketQueue) {
            if let index = self.pendingTickets.indexOf(ticket) {
                TicketHandler.deleteTicketEventually(ticket)
                dispatch_async(GlobalMainQueue) {
                    self.listener.beginUpdates()
                    self.pendingTickets.removeAtIndex(index)
                    self.updateGlobalTicketCount()
                    if self.pendingTickets.count == 0 {
                        self.listener.deleteSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                    }
                    self.listener.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Fade)
                    self.listener.endUpdates()
                }
            } else {
                print("Ticket already deleted")
            }
            
        }
    }
    
    func deleteTicketAtPath(path: NSIndexPath) {
        dispatch_sync(concurrentTicketQueue) {
            if let ticket = self.getTicketAtPath(path) {
                self.deleteTicket(ticket)
            }

        }
    }
    
    func deleteTicketByID(id: String) {
        dispatch_sync(concurrentTicketQueue) {
            
            let ticket = self.getTicketByID(id)
            if ticket != nil {
                self.deleteTicket(ticket!)
            } else {
                print("Ticket already deleted")
            }
        }
    }
    
    func getTicketByID(id: String) -> PFObject? {
        var ticket: PFObject?
        dispatch_sync(concurrentTicketQueue) {
            for t in self.pendingTickets {
                if t.objectId == id {
                    ticket = t
                    break
                }
            }
            if ticket == nil {
                for t in self.openTickets {
                    if t.objectId == id {
                        ticket = t
                        break
                    }
                }
            }
            if ticket == nil {
                for t in self.solvedTickets {
                    if t.objectId == id {
                        ticket = t
                        break
                    }
                }
            }
        }
        return ticket
    }
    
    private func getSectionForQueue(inout q: [PFObject]) -> Int? {
        if q == self.pendingTickets {
            if self.pendingTickets.count > 0 {
                return 0
            } else {
                return nil
            }
        } else if (q == self.openTickets) {
            if self.openTickets.count == 0 {
                return nil
            } else if (self.pendingTickets.count == 0) {
                return 0
            } else {
                return 1
            }
        } else {
            if self.solvedTickets.count == 0 {
                return nil
            } else if (self.pendingTickets.count == 0 && self.openTickets.count == 0) {
                return 0
            } else if ((self.pendingTickets.count == 0 && self.openTickets.count > 0) ||
                (self.pendingTickets.count > 0 && self.openTickets.count == 0)) {
                    return 1
            } else {
                return 2
            }
        }
    }
    
    private func getQueueAtSection(section: Int) -> [PFObject] {
        var tickets:[PFObject]!
        dispatch_sync(concurrentTicketQueue) {
            if (section == 0) {
                if self.pendingTickets.count > 0 {
                    tickets = self.pendingTickets
                } else if (self.openTickets.count > 0) {
                    tickets = self.openTickets
                } else {
                    tickets = self.solvedTickets
                }
            } else if (section == 1) {
                if (self.pendingTickets.count > 0 && self.openTickets.count > 0) {
                    tickets = self.openTickets
                } else {
                    tickets = self.solvedTickets
                }
            } else {
                tickets = self.solvedTickets
            }
        }
        return tickets
    }
    
    func getTitleAtSection(section: Int) -> String {
        let q = self.getQueueAtSection(section)
        var qualifier = ""
        
        if q == self.pendingTickets {
            qualifier = "Pending"
        } else if q == self.openTickets {
            qualifier = "Open"
        } else {
            qualifier = "Solved"
        }
        return String(format: "%@ Tickets", qualifier)
//        if q.count == 1 {
//            return String(format: "1 %@ Ticket", qualifier)
//        } else {
//            return String(format: "%d %@ Tickets", q.count, qualifier)
//        }
    }
    
    func getNumRowsInSection(section: Int) -> Int {
        var rows = 0
        dispatch_sync(concurrentTicketQueue) {
            rows = self.getQueueAtSection(section).count
        }
        return rows
    }
    
    func getTicketAtPath(path: NSIndexPath) -> PFObject? {
        var ticket: PFObject?
        dispatch_sync(concurrentTicketQueue) {
            let q = self.getQueueAtSection(path.section)
            if path.row < q.count {
                ticket = q[path.row]
            } else {
                print("ticket path is out of bounds")
            }
        }
        return ticket
    }
    
    func getNumSections() -> Int {
        var numSections = 0
        dispatch_sync(concurrentTicketQueue) {
            if self.pendingTickets.count > 0 {
                numSections++
            }
            if self.openTickets.count > 0 {
                numSections++
            }
            
            if self.solvedTickets.count > 0 {
                numSections++
            }
        }
        return numSections
    }
    
    func getNumTotalTickets() -> Int {
        var count = 0
        dispatch_sync(concurrentTicketQueue) {
            count = self.pendingTickets.count + self.openTickets.count + self.solvedTickets.count
        }
        return count
    }
    
    func getAllTickets(release: (error: NSError?) -> Void) {
        
        dispatch_barrier_async(concurrentTicketQueue) {
            
            do {
                let tickets = try TicketHandler.getTicketsSync()
                self.clearTickets()
                for object in tickets {
                    if let type = object["taken"] as? Int, helperSolved = object["helperSolved"] as? Int, requesterSolved = object["requesterSolved"] as? Int {
                        if type == 0 {
                            self.pendingTickets.append(object)
                        } else if type >= 1 && (helperSolved != 1 || requesterSolved == 0) {
                            self.openTickets.append(object)
                        } else {
                            self.solvedTickets.append(object)
                        }
                    }
                }
                self.updateGlobalTicketCount()
                
                dispatch_async(GlobalMainQueue) {
                    self.listener.reloadData()
                    release(error: nil)
                }
            } catch let error as NSError {
                release(error: error)
            }
            
        }
    }
    
    func getTicketType(section: Int) -> TicketType {
        var type: TicketType!
        dispatch_sync(concurrentTicketQueue) {
            let q = self.getQueueAtSection(section)
            if  q == self.pendingTickets {
                type = TicketType.Pending
            } else if q == self.openTickets {
                type = TicketType.Open
            } else {
                type = TicketType.Solved
            }
        }
        return type
    }

}