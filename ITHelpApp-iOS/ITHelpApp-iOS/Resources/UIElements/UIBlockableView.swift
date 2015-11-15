//
//  UIBlockableView.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 11/15/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import Foundation

protocol UIBlockableProtocol {
    func blockUI()
    func releaseUI()
    func reloadData()
}