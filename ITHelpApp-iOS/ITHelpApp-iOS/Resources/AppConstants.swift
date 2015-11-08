//
//  AppConstants.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/18/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import Foundation
import Parse

struct AppConstants {
    static let pubnubSubKey = "sub-c-bdfa77b2-793f-11e5-a643-02ee2ddab7fe"
    static let pubnubPubKey = "pub-c-23a2994a-72c2-43a3-a8e7-d63f3e382009"
    static var requestHandler: PubnubHandler?
    static var shouldRefreshTickets = false
    static var maxTickets: Int?
}