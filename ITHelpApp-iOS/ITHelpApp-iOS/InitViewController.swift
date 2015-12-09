//
//  InitViewController.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/7/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import UIKit
import Parse

class InitViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try TagManager.sharedInstance.getAvailableTags()
        } catch let error as NSError {
            print("could not get tags")
            print(error)
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let loggedIn = defaults.boolForKey("stayLoggedIn")
        let curUser = PFUser.currentUser()
        if loggedIn && curUser != nil && curUser?.username != nil {
            print("already logged in. going home.")
            goToHomePage()
        } else {
            print("going to login")
            self.goToLoginPage()
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToLoginPage() {
        let storyboard = UIStoryboard(name: "login", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("LoginNavController") as UIViewController
        
        self.presentViewController(controller, animated: false, completion: nil)
    }
    
    func goToHomePage() {
        let storyboard = UIStoryboard(name: "home", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("MainTabController") as UIViewController
        
        self.presentViewController(controller, animated: false, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
