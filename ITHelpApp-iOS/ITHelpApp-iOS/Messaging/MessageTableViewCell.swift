//
//  MessageTableViewCell.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/27/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var leftPortrait: UIImageView!
    @IBOutlet weak var rightPortrait: UIImageView!
    
    func setMessageText(text: String, isSelf: Bool) {
        
        self.messageText.text = text
        if isSelf {
            self.messageText.backgroundColor = UIConstants.mainUIColor
            self.messageText.textColor = UIColor.whiteColor()
            self.messageText.textAlignment = NSTextAlignment.Right
        } else {
            self.messageText.backgroundColor = UIColor.grayColor()
            self.messageText.textColor = UIColor.blackColor()
            self.messageText.textAlignment = NSTextAlignment.Left
        }
        self.messageText.layer.cornerRadius = 8
        self.messageText.layer.masksToBounds = true
        self.messageText.adjustsFontSizeToFitWidth = false
        self.messageText.numberOfLines = 0

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
    
    func setPortrait(isMe: Bool) {
        if (isMe) {
            self.rightPortrait.image = UIImage(named: "person_blue.png")
        } else {
            self.leftPortrait.image = UIImage(named: "person_gray.png")
        }

    }
    
    func removePortrait() {
        self.rightPortrait.image = nil
        self.leftPortrait.image = nil
    }

}
