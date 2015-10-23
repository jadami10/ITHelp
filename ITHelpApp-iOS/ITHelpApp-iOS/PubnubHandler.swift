//
//  PubnubHandler.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/18/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import Foundation
import PubNub

class PubnubHandler {

    var client : PubNub
    var config : PNConfiguration
    var channel: String
    
    init(pubKey: String, subKey: String, comChannel: String) {
        print("Connecting to: " + comChannel)
        config = PNConfiguration(
            publishKey: pubKey,
            subscribeKey: subKey
        )
        
        client = PubNub.clientWithConfiguration(config)
        channel = comChannel
        subscribeToChannel(comChannel)
    }
    
    private func subscribeToChannel(channel: String!) {
        client.subscribeToChannels([channel], withPresence: false)
    }
    
    func addHandler(listener: PNObjectEventListener!) {
        client.addListener(listener)
    }
    
    func sendMessage(message: String) {
        client.publish(message, toChannel: channel, compressed: false, withCompletion: nil)
    }

}