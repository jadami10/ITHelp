//
//  InsetLabel.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/28/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import UIKit

class InsetLabel: UILabel {
    override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: UIConstants.cellInset, left: UIConstants.cellInset, bottom: UIConstants.cellInset, right: UIConstants.cellInset)))
    }
}