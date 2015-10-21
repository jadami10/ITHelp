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
        print("request notification!")
        print(message.data.message)
        self.presentAlert("Request Processed!", message: "Go to your tickets to begin chatting!")
        /*
        if let curController = self.selectedViewController {
            if curController is TicketTableViewController
        }
        */
    }
    
    func presentAlert(title: NSString, message: NSString) {
        let alertController = UIAlertController(title: title as String, message: message as String, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}