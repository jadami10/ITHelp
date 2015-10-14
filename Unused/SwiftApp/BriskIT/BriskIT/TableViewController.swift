//
//  TableViewController.swift
//  BriskIT
//
//  Created by X on 9/23/15.
//  Copyright © 2015 ITHelp. All rights reserved.
//  
//

import UIKit
import Alamofire
import SwiftyJSON

var allMessages: [NSDictionary] = []
var count = 0
var dict:NSDictionary = [:]
func getMessage(tv: UITableView){
    Alamofire.request(.GET, "http://127.0.0.1:8000/home/messaging/").responseJSON(){
        (data) in
        if (data.result.value != nil) {
            allMessages = data.result.value as! [NSDictionary]
            print (allMessages)
            tv.reloadData()
        }
        
    }
    //print(dict)
    
/*
    let queue = dispatch_queue_create("com.ITHelp.manager-response-queue", DISPATCH_QUEUE_CONCURRENT)
    
    let request = Alamofire.request(.GET, "http://localhost:3000/messages")
    request.response(queue: queue, responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments), completionHandler: { _, _, JSON, _ in
        
        // You are now running on the concurrent `queue` you created earlier.
        println("Parsing JSON on thread: \(NSThread.currentThread()) is main thread: \(NSThread.isMainThread())")
        
        // Validate your JSON response and convert into model objects if necessary
        println(JSON)
        
        // To update anything on the main thread, just jump back on like so.
        dispatch_async(dispatch_get_main_queue()) {
            println("Am I back on the main thread: \(NSThread.isMainThread())")
        }
        }
)
*/

}

func postMessage(message: String){
    var parameters: [String: AnyObject] = ["sender":"Maria", "text":message]
    var request = Alamofire.request(.POST, "http://127.0.0.1:8000/home/messaging/", parameters: parameters, encoding: .JSON)
    request.responseJSON { data in
        dict = data.result.value as! NSDictionary
        print(dict)
        //allMessages.addObject(dict)

    }
}


class TableViewController: UITableViewController {
    

    @IBOutlet weak var messageTextField: UITextField!
    @IBAction func sendButton(sender: UIButton) {
        if let message = messageTextField.text{
            postMessage(message)
            getMessage(self.tableView)
        }
        self.messageTextField.text = ""
        //tableView.reloadData()

    }
    @IBAction func refreshMessages(sender: UIButton) {
        getMessage(tableView)
    }
    @IBOutlet weak var tableTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         //self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
            count = allMessages.count
            return count
        }
        
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        }
        //let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        let data = allMessages[indexPath.row].valueForKey("text") as? String
        cell!.textLabel!.text = data
        cell!.detailTextLabel?.text = allMessages[indexPath.row].valueForKey("sender") as? String
        //cell!.textLabel!.text = self.data[indexPath.row]as? String
        //cell!.detailTextLabel?.text = self.data[indexPath.row]as? String

            return cell!
        }


/*
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(count)
        return self.count
    }

        
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        // Configure the cell...
        cell.textLabel?.text = self.dict.valueForKey("howdy") as? String
        print("dequeing cells")

        return cell
    }
*/
/*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
*/
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
 
}

