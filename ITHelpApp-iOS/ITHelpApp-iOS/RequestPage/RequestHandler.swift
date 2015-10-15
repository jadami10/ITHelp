//
//  RequestHandler.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/13/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import Foundation

class RequestHandler {
    
    static func postRequest(request: PFObject, completion: (result: NSError?) -> Void, successfullySavedRequest: (request: PFObject) -> Void){
        
        request.saveInBackgroundWithBlock {
            // afterSave will send to pubnub
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("good request!")
                successfullySavedRequest(request: request)
            } else {
                completion(result: error)
            }
        }
    }

}