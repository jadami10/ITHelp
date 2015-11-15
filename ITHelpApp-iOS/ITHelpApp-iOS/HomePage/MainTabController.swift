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
            print(String(format: "ID: %s Type: %s", requestID, requestType))
            if requestType == "RequestTaken" {
                alertedTicketId = requestID
                TicketManager.sharedInstance.getTicketsWithCallback(self.handleTicketTaken)
            } else if requestType == "RequestSolved" {
                TicketManager.sharedInstance.getTickets()
                self.presentYesNoAlert("Request Solved!", message: "Go check your solution!", completion: nil)
            } else if requestType == "RequestReleased" {
                TicketManager.sharedInstance.getTickets()
            } else {
                print(String(format:"Unhandled request type: %s", requestType))
            }
        } else {
            print("bad message")
            print(message.data.message)
        }
    }
    
    func handleTicketTaken() {
        if alertedTicketId != nil {
            alertedTicket = TicketManager.sharedInstance.getTicketById(alertedTicketId!)
            incrementRequestBadge()
            self.presentYesNoAlert("Someone is here to help!", message: "Go to your ticket?", completion: self.goToTicketTaken)
        } else {
            print("no ticket id")
        }
    }
    
    func goToTicketTaken(_: UIAlertAction) -> Void {
        if alertedTicket == nil {
            print("Could not redirect to ticket")
        } else {
            let storyboard = UIStoryboard(name: "message", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("textTable") as! MessageViewController
            controller.ticket = alertedTicket
            AppConstants.ticketNavController?.pushViewController(controller, animated: true)
            if self.tabBarController != nil {
                self.tabBarController?.selectedIndex = AppConstants.ticketsTabIndex
            } else {
                print("no tabbar controller to change")
            }
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
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if self.tabBar.selectedItem == self.tabBar.items![AppConstants.ticketsTabIndex] {
            if let _ = self.tabBar.items?[AppConstants.ticketsTabIndex].badgeValue {
                self.tabBar.items![AppConstants.ticketsTabIndex].badgeValue = nil
            }
        }
    }
    
}