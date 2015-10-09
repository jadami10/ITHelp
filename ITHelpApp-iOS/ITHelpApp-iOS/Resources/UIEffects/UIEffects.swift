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
