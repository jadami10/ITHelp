//
//  UIConstants.swift
//  ParseStarterProject-Swift
//
//  Created by Johan Adami on 10/3/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import Foundation
import UIKit

struct UIConstants {
    //static let mainGreenColor = UIColor(red: 171, green: 219, blue: 157, alpha: 0)
    static let mainUIColor = UIColor.colorWithRealValue(96.0, greenValue: 200.0, blueValue: 209.0, alpha: 1.0)
    static let mainUIDarkerColor = UIColor.colorWithRealValue(96.0, greenValue: 200.0, blueValue: 209.0, alpha: 1.0)
    static let errorRedColor = UIColor.colorWithRealValue(255.0, greenValue: 120.0, blueValue: 120.0, alpha: 1.0)
    static let cellInset: CGFloat = 10
}

extension UIColor {
    static func colorWithRealValue(redValue: CGFloat, greenValue: CGFloat, blueValue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: redValue/255.0, green: greenValue/255.0, blue: blueValue/255.0, alpha: alpha)
    }
}