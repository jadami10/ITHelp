//
//  TagManager.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 11/15/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import Foundation
import Parse

class TagManager {
    
    static let sharedInstance = TagManager()
    
    var tags = [RequestTags]()
    
    func getAvailableTags() {
        let query = PFQuery(className:"Tags")
        //query.whereKey("sender", equalTo:username)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                print("Tags retrieved \(objects!.count)")
                // Do something with the found objects
                if let objects = objects as [PFObject]! {
                    for object in objects {
                        let tag = RequestTags(name: object["Name"] as! String, color: object["Color"] as! String)
                        self.tags.append(tag)
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!))")
            }
        }
    }
    
    func getNumTags() -> Int {
        return tags.count
    }
    
    func getTag(path: NSIndexPath) -> RequestTags {
        return tags[path.row]
    }
    
}

class RequestTags {
    var tagName: String
    var tagColor: UIColor
    
    init(name: String, color: String) {
        tagName = name
        tagColor = UIColor.colorWithHexString(color)
    }
}