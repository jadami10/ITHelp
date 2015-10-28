//
//  AboutViewController.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/8/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var iconLinkButton: UIButton!
    @IBOutlet weak var iconWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func iconButtonPressed(sender: AnyObject) {
        //let requestObj = NSURLRequest(URL: url!);
        //iconWebView.loadRequest(requestObj);
        if let url = NSURL (string: "https://icons8.com/") {
            UIApplication.sharedApplication().openURL(url)
        }
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
