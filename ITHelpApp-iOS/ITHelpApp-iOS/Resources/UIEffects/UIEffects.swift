//
//  UIEffects.swift
//  ParseStarterProject-Swift
//
//  Created by Johan Adami on 10/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation
import UIKit
import Parse


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
    
    func presentAlert(title: NSString, message: NSString, completion: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title as String, message: message as String, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: completion)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func presentYesNoAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title as String, message: message as String, preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "Yes", style: .Default, handler: completion)
        let noAction = UIAlertAction(title: "No", style: .Default, handler: nil)
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Source: http://stackoverflow.com/questions/28785715/how-to-display-an-activity-indicator-with-text-on-ios-8-with-swift
    func progressBarDisplayer(msg:String, indicator:Bool ) -> UIView {
        print(msg)
        let strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 300, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.whiteColor()
        //let messageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25 , width: 50, height: 50))
        let messageFrame = UIView(frame: CGRect(x: view.frame.midX - 25, y: view.frame.midY - 25 , width: 50, height: 50))
        messageFrame.userInteractionEnabled = false
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        if indicator {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        //messageFrame.addSubview(strLabel)
        //messageFrame.sizeToFit()
        self.view.addSubview(messageFrame)
        return messageFrame
    }
    
    // Magic function that blocks UI and displays busy message
    // Don't forget to renable UI when completed!
    func asyncBlockingAction(message: String, taskToRun: ((UIView) -> Void)) {
        self.view.userInteractionEnabled = false;
        let messageFrame = self.progressBarDisplayer(message, indicator: true)
        dispatch_async(dispatch_get_main_queue()) {
            taskToRun(messageFrame)
            //NSThread.sleepForTimeInterval(3)
            //messageFrame.removeFromSuperview()
            /*
            dispatch_async(dispatch_get_main_queue()) {
                //NSThread.sleepForTimeInterval(3)
                messageFrame.removeFromSuperview()
            }
            */
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func screenShotMethod() -> UIImage {
        //Create the UIImage
        //UIGraphicsBeginImageContext(view.frame.size)
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, scale);
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func keyboardWillHide(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        self.view.frame.origin.y += keyboardSize.height
    }
    
    func keyboardWillShow(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        
        if keyboardSize.height == offset.height {
            if self.view.frame.origin.y == 0 {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.view.frame.origin.y -= keyboardSize.height
                })
            }
        } else {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height - offset.height
            })
        }
        print(self.view.frame.origin.y)
    }
    
}