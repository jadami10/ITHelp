////
////  textTableViewController.swift
////  ITHelpApp-iOS
////
////  Created by Xinhe on 10/14/15.
////  Copyright © 2015 Johan Adami. All rights reserved.
////
//
//import UIKit
//
//var allMessages = [String]()
//func queryMessage(username:String){
//    var query = PFQuery(className:"Message")
//    //query.whereKey("sender", equalTo:username)
//    query.findObjectsInBackgroundWithBlock {
//        (objects: [PFObject]?, error: NSError?) -> Void in
//        
//        if error == nil {
//            // The find succeeded.
//            print("Successfully retrieved \(objects!.count)")
//            // Do something with the found objects
//            if let objects = objects as [PFObject]! {
//                for object in objects {
//                    allMessages.append((object.valueForKey("message")! as? String)!)
//                }
//            }
//        } else {
//            // Log details of the failure
//            print("Error: \(error!))")
//        }
//    }
//}
//
//class textTableViewController: UITableViewController {
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.reloadData()
//    }
//    
//   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return allMessages.count
//        
//    }
//   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        //
//        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
//        cell?.textLabel?.text = "hi"//allMessages[indexPath.row]
//        return cell!
//        
//    }
//    
//   override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    
//    
//}
