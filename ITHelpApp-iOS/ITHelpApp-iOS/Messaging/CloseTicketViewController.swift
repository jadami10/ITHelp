//
//  CloseTicketViewController.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 11/1/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import UIKit

class CloseTicketViewController: UIViewController {

    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var backgroundImageEffect: UIVisualEffectView!
    @IBOutlet weak var backgroundImage: UIImageView!
    var image: UIImage?
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.tintColor = UIConstants.mainUIDarkerColor
        self.navigationController?.navigationBar.barTintColor = UIConstants.mainUIColor
        self.view.backgroundColor = UIConstants.mainUIColor
        self.tabBarController?.tabBar.hidden = true
        
        self.backgroundImage.image = image
        yesButton.backgroundColor = UIConstants.mainUIColor
        noButton.setTitleColor(UIConstants.mainUIColor, forState: .Normal)
        
        headerTitle.numberOfLines = 0
        headerTitle.sizeToFit()
    }
    
    @IBAction func backToTicketPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(false)
    }
}
