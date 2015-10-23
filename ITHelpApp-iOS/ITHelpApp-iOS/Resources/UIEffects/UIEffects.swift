//
//  UIEffects.swift
//  ParseStarterProject-Swift
//
//  Created by Johan Adami on 10/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation
import UIKit


extension UITextField {
    
    // Source: http://stackoverflow.com/questions/27987048/shake-animation-for-uitextfield-uiview-in-swift
    func shakeTextField() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(self.center.x - 5, self.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(self.center.x + 5, self.center.y))
        self.layer.addAnimation(animation, forKey: "position")
    }
    
}

extension UITextView {
    
    // Source: http://stackoverflow.com/questions/27987048/shake-animation-for-uitextfield-uiview-in-swift
    func shakeTextView() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(self.center.x - 5, self.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(self.center.x + 5, self.center.y))
        self.layer.addAnimation(animation, forKey: "position")
    }
    
}

extension UIViewController {
    
    // Source: http://stackoverflow.com/questions/28785715/how-to-display-an-activity-indicator-with-text-on-ios-8-with-swift
    func progressBarDisplayer(msg:String, indicator:Bool ) -> UIView {
        print(msg)
        let strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.whiteColor()
        let messageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25 , width: 180, height: 50))
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        if indicator {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        messageFrame.addSubview(strLabel)
        view.addSubview(messageFrame)
        return messageFrame
    }
}