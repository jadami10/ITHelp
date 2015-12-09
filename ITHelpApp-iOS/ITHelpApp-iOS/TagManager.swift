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
    var defaultTags = [PFObject]()
    
    func getAvailableTags() throws {
        let query = PFQuery(className:"Tags")
        //query.whereKey("sender", equalTo:username)
        let objects = try query.findObjects()
        for object in objects {
            let tag = RequestTags(name: object["Name"] as! String, color: object["Color"] as! String, object: object)
            self.tags.append(tag)
            if object["Default"] as! Bool {
                self.defaultTags.append(object)
            }
        }
        /*
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                print("Tags retrieved \(objects!.count)")
                // Do something with the found objects
                if let objects = objects as [PFObject]! {
                    for object in objects {
                        let tag = RequestTags(name: object["Name"] as! String, color: object["Color"] as! String, object: object)
                        self.tags.append(tag)
                        if object["Default"] as! Bool {
                            self.defaultTags.append(object)
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!))")
            }
        }
        */
    }
    
    func getNumTags() -> Int {
        return tags.count
    }
    
    func getTag(path: NSIndexPath) -> RequestTags {
        return tags[path.row]
    }
    
    func getTagByRow(row: Int) -> RequestTags {
        return tags[row]
    }
    
    func getTagByID(id: String) -> RequestTags? {
        for tag in self.tags {
            if tag.tagObject.objectId == id {
                return tag
            }
        }
        return nil
    }
    
}

class RequestTags {
    var tagName: String
    var tagColor: UIColor
    var tagObject: PFObject
    
    init(name: String, color: String, object: PFObject) {
        tagName = name
        tagColor = UIColor.colorWithHexString(color)
        tagObject = object
    }
}