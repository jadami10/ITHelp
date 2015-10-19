//
//  ProfileViewController.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/7/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController {

    @IBOutlet weak var logInToggle: UISwitch!
    @IBOutlet weak var portraitImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let curUser = PFUser.currentUser()?.username {
            self.nameLabel.text = curUser
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        let loggedIn = defaults.boolForKey("stayLoggedIn")
        if loggedIn {
            logInToggle.setOn(true, animated: false)
        }
        
    }
    
    @IBAction func tapGesturePressed(sender: AnyObject) {
        presentAlert("Hardware issue", message: "Camera not available")
    }
    
    func presentAlert(title: NSString, message: NSString) {
        let alertController = UIAlertController(title: title as String, message: message as String, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func stayLoggedInToggled(sender: AnyObject) {
        if logInToggle.on {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: "stayLoggedIn")
        } else {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(false, forKey: "stayLoggedIn")
        }
    }

}
