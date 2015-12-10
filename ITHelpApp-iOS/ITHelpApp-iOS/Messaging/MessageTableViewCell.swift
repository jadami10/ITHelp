//
//  MessageTableViewCell.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/27/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageTextContainer: UIView!
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var portrait: UIImageView!
    
    func setMessageText(text: String, isSelf: Bool) {
        
        self.messageText.text = text
        if isSelf {
            self.messageTextContainer.backgroundColor = UIConstants.mainUIColor
            self.messageText.textColor = UIColor.whiteColor()
            self.messageText.textAlignment = NSTextAlignment.Left
        } else {
            self.messageTextContainer.backgroundColor = UIColor.lightGrayColor()
            self.messageText.textColor = UIColor.whiteColor()
            self.messageText.textAlignment = NSTextAlignment.Right
        }
        
        self.messageTextContainer.layer.cornerRadius = 4
        self.messageTextContainer.layer.masksToBounds = true
//        self.messageText.adjustsFontSizeToFitWidth = false
//        self.messageText.numberOfLines = 0
//        self.messageText.sizeToFit()
        
        //self.messageText.frame.width =
        //self.messageText = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 10000))
        /*
        self.messageText.numberOfLines = 100
        self.messageText.text = text
        if isSelf {
            self.messageText.backgroundColor = UIConstants.mainUIColor
            self.messageText.textColor = UIColor.whiteColor()
        } else {
            self.messageText.backgroundColor = UIColor.grayColor()
            self.messageText.textColor = UIColor.blackColor()
        }
        self.messageText.layer.cornerRadius = 8
        self.messageText.layer.masksToBounds = true
        */
    }
    
    func setMessagePortrait(isMe: Bool) {
        if (isMe) {
            self.portrait.image = UIImage(named: "person_blue.png")
        } else {
            self.portrait.image = UIImage(named: "person_gray.png")
        }

    }
    
    func removePortrait() {
        self.portrait.image = nil
        self.portrait.image = nil
    }

}
