//
//  MainTabController.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/7/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import UIKit
import PubNub
import Parse

var alertedTicketId: String?
var alertedTicket: PFObject?

class MainTabController: UITabBarController, PNObjectEventListener {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppConstants.requestHandler = PubnubHandler(pubKey: AppConstants.pubnubPubKey, subKey: AppConstants.pubnubSubKey, comChannel: (PFUser.currentUser()?.username)!)
        AppConstants.requestHandler!.addHandler(self)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.hidden = false
    }
    
    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!) {

        
        print("request notification!")
        
        /*
        if let curController = self.selectedViewController {
            if curController is TicketTableViewController
        }
        */
        
        // RequestTaken: someone just took your request
        // RequestSolved: someone just solved your request

        if let requestID = message.data.message["requestID"] as? String, requestType = message.data.message["requestType"] as? String {
            print(message.data.message)
//            print(String(format: "ID: %@ Type: %@", requestID, requestType))
            if requestType == "RequestTaken" {
                alertedTicketId = requestID
                print("moving ticket to taken")
//                AsyncTicketManager.sharedInstance.moveTicketToTakenById(requestID)
                TicketHandler.getTicketByID(requestID, completion: self.handleTicketTaken)
//                self.handleTicketTaken()
            } else if requestType == "RequestSolved" {
                print("Received notice to solve ticket")
                if AsyncTicketManager.sharedInstance.getTicketByID(requestID) != nil {
                    TicketHandler.getTicketByID(requestID, completion: self.handleTicketSolved)
                } else {
                    print("Could not find solved ticket")
                }
            } else if requestType == "TicketSolved" {
                print("Received notice I solved ticket")

                if let ticket = AsyncTicketManager.sharedInstance.getTicketByID(requestID) {
                    if let msgController = lookingAtTicket(ticket) {
                        msgController.navigationController?.popToRootViewControllerAnimated(true)
                    }
                    AsyncTicketManager.sharedInstance.acceptSolutionByRequester(ticket, isMe: false)
                } else {
                    print("Could not find solved ticket")
                }
            } else if requestType == "SolutionDeclined" {
                print("Received notice I declined solution")
                if let ticket = AsyncTicketManager.sharedInstance.getTicketByID(requestID) {
                    if let msgController = lookingAtTicket(ticket) {
                        msgController.solutionWasDeclined()
                    }
                    AsyncTicketManager.sharedInstance.declineSolutionByRequester(ticket, isMe: false)
                } else {
                    print("Could not find solved ticket")
                }
            } else if requestType == "RequestReleased" {
                // TODO: Handle ticket being released
                TicketHandler.getTicketByID(requestID, completion: self.handleTicketReadded)
            } else if requestType == "RequestAdded" {
                print("Received notice to add ticket")
                if AsyncTicketManager.sharedInstance.getTicketByID(requestID) == nil {
                    TicketHandler.getTicketByID(requestID, completion: self.handleTicketAdded)
                } else {
                    print("Could not find added ticket")
                }
            } else if requestType == "RequestDeleted" {
                AsyncTicketManager.sharedInstance.deleteTicketByID(requestID)
            } else {
                print(String(format:"Unhandled request type: %s", requestType))
            }
        } else {
            print("bad message")
            print(message.data.message)
        }
    }
    
    func handleTicketAdded(ticket: PFObject?, error: NSError?) -> Void {
        if ticket != nil {
            print("Adding new ticket")
            let type = ticket!["taken"] as! Int
            AsyncTicketManager.sharedInstance.addTicket(ticket!, type: type)
        } else if (error != nil) {
            print("Could not add ticket")
            print(error)
        } else {
            print("Failed to add ticket with no error")
        }
    }
    
    func handleTicketReadded(ticket: PFObject?, error: NSError?) -> Void {
        if ticket != nil {
            print("Readding new ticket")
            AsyncTicketManager.sharedInstance.readdTicket(ticket!)
            self.handleTicketReleased(ticket!)
        } else if (error != nil) {
            print("Could not readd ticket")
            print(error)
        } else {
            print("Failed to readd ticket with no error")
        }
    }
    
    func pushToTicketTaken(requestID: String) {
        do {
            alertedTicket = try TicketHandler.getTicketByIDSync(requestID)
            let storyboard = UIStoryboard(name: "message", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("textTable") as! MessageViewController
            controller.ticket = alertedTicket
            AppConstants.ticketNavController?.pushViewController(controller, animated: true)
            self.tabBar.items![AppConstants.ticketsTabIndex].badgeValue = nil
            self.selectedIndex = AppConstants.ticketsTabIndex
        } catch _ {
            print ("Could not get ticket")
        }
        
    }
    
    func handleTicketTaken(ticket: PFObject?, error: NSError?) -> Void {
        
        if ticket != nil {
            print("ticket has been taken")
            AsyncTicketManager.sharedInstance.moveTicketToTaken(ticket!)
            incrementRequestBadge()
            alertedTicket = ticket
            if let _ = lookingAtTicket(alertedTicket!) {
                return
            }
            self.presentYesNoAlert("Someone is here to help!", message: "Go to your ticket?", completion: self.goToTicket)
        } else if (error != nil) {
            print("Could not take ticket")
            print(error)
        } else {
            print("Failed to take ticket with no error")
        }
        
    }
    
    func handleTicketSolved(ticket: PFObject?, error: NSError?) -> Void {
        
        if ticket != nil {
            print("ticket has been solved")
            AsyncTicketManager.sharedInstance.moveTicketToSolved(ticket!)
            incrementRequestBadge()
            alertedTicket = ticket!
            if let curController = lookingAtTicket(ticket!) {
                curController.ticketWasSolved()
            } else {
                self.presentYesNoAlert("Request Solved!", message: "Go check your solution!", completion: self.goToTicket)
            }
        } else if (error != nil) {
            print("Could not solve ticket")
            print(error)
        } else {
            print("Failed to solve ticket with no error")
        }
        
    }
    
    func handleTicketReleased(ticket: PFObject) {
        if let curController = lookingAtTicket(ticket) {
            curController.navigationController?.popToRootViewControllerAnimated(true)
        }
        self.presentAlert("Your helper canceled", message: "A new helper will be on the way soon!", completion: nil)
    }
    
    func goToTicket(_: UIAlertAction) -> Void {
        if alertedTicket == nil {
            print("Could not redirect to ticket")
        } else {
            let storyboard = UIStoryboard(name: "message", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("textTable") as! MessageViewController
            controller.ticket = alertedTicket
            AppConstants.ticketNavController?.pushViewController(controller, animated: true)
            self.tabBar.items![AppConstants.ticketsTabIndex].badgeValue = nil
            self.selectedIndex = AppConstants.ticketsTabIndex
        }
    }
    
    func incrementRequestBadge() {
        if self.tabBar.selectedItem != self.tabBar.items![AppConstants.ticketsTabIndex] {

            if let badgeValue = (self.tabBar.items![AppConstants.ticketsTabIndex]).badgeValue, let badgeInt = Int(badgeValue) {
                (self.tabBar.items![AppConstants.ticketsTabIndex]).badgeValue = (badgeInt + 1).description
            } else {
                (self.tabBar.items![AppConstants.ticketsTabIndex]).badgeValue = "1"
            }
        } /*else {
            if let controller = self.viewControllers?[AppConstants.ticketsTabIndex] as? UINavigationController {
                print("refresh ticekts now")
                if let ticketController = controller.viewControllers[0] as? TicketTableViewController {
                    ticketController.fetchTickets()
                } else {
                    print(controller.viewControllers)
                }
            } else {
                print(self.viewControllers)
                print("could not find ticket view controller")
            }
        }*/
    }
    
    func lookingAtTicket(incomingTicket: PFObject) -> MessageViewController? {
        if self.tabBar.selectedItem == self.tabBar.items![AppConstants.ticketsTabIndex] {
            if let topController = UIApplication.topViewController() {
                if topController .isKindOfClass(MessageViewController) {
                    print ("looking at a message view")
                    let msgView = topController as! MessageViewController
                    if (msgView.ticket?.objectId == incomingTicket.objectId) {
                        return msgView
                    } else {
                        print("in a different message view")
                    }
                } else {
                    print("in a different view in right tab")
                }
            }
            self.tabBar.items![AppConstants.ticketsTabIndex].badgeValue = nil
        } else {
            print ("Tickets tab not selected")
        }
        return nil
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if self.tabBar.selectedItem == self.tabBar.items![AppConstants.ticketsTabIndex] {
            self.tabBar.items![AppConstants.ticketsTabIndex].badgeValue = nil
        }
    }
    
}