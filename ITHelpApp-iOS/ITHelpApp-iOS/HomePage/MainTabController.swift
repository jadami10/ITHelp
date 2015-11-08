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

class MainTabController: UITabBarController, PNObjectEventListener {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppConstants.requestHandler = PubnubHandler(pubKey: AppConstants.pubnubPubKey, subKey: AppConstants.pubnubSubKey, comChannel: (PFUser.currentUser()?.username)!)
        AppConstants.requestHandler!.addHandler(self)
        
        
    }
    
    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!) {

        if self.tabBar.selectedItem != self.tabBar.items![1] {
            AppConstants.shouldRefreshTickets = true
            if let badgeValue = (self.tabBar.items![1]).badgeValue, let badgeInt = Int(badgeValue) {
                (self.tabBar.items![1]).badgeValue = (badgeInt + 1).description
            } else {
                (self.tabBar.items![1]).badgeValue = "1"
            }
        }
        
        print("request notification!")
        
        /*
        if let curController = self.selectedViewController {
            if curController is TicketTableViewController
        }
        */

        if let requestID = message.data.message["requestID"] as? String, requestType = message.data.message["requestType"] as? String {
            print(message.data.message)
            print(String(format: "ID: %s Type: %s", requestID, requestType))
            self.presentAlert("Request Processed!", message: "Go to your tickets to begin chatting!", completion: nil)
        } else {
            print("bad message")
            print(message.data.message)
        }
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if self.tabBar.selectedItem == self.tabBar.items![1] {
            if let _ = self.tabBar.items?[1].badgeValue {
                self.tabBar.items![1].badgeValue = nil
            }
        }
    }
    
}