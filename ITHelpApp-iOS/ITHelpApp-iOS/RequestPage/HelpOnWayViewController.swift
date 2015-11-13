//
//  HelpOnWayViewController.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 11/12/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import UIKit

class HelpOnWayViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "goBackToRequestView")
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goBackToRequestView() {
        self.dismissViewControllerAnimated(true, completion: nil)
        /*
        let storyboard = UIStoryboard(name: "request", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("RequestViewController") as! RequestViewController
        controller.modalTransitionStyle = .CrossDissolve
        presentViewController(controller, animated: true, completion: nil)
*/
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
