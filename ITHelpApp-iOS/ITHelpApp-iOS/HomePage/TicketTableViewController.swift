//
//  TicketTableViewController.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/8/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import UIKit
import Parse

class TicketTableViewController: UITableViewController {
    
    var tickets = [PFObject]()
    var busyFrame: UIView?
    

    override func viewWillAppear(animated: Bool) {
        // FIXME: store tickets so you don't reload every time. Causes issues with bad network conditions
        
        self.asyncBlockingAction("Fetching Tickets", taskToRun: fetchTickets)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //TicketHandler.getTickets(addTickets)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.fetchTickets(nil)
        // TODO: Handle swipe down to refresh
        refreshControl.endRefreshing()
    }
    
    func fetchTickets(activityFrame: UIView?) {
        print("disabled")
        self.tableView.userInteractionEnabled = false
        tickets = []
        TicketHandler.getTickets(addTickets)
        print("coming back")
        activityFrame?.removeFromSuperview()
        self.tableView.userInteractionEnabled = true
        self.view.userInteractionEnabled = true
    }
    
    func addTickets(object: PFObject) -> Void{
        tickets.append(object)
        //print(object)
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tickets.count + 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("TicketTitleCell", forIndexPath: indexPath)
            if tickets.count == 1 {
            cell.textLabel?.text = "1 Ticket"
            } else {
            cell.textLabel?.text = String(format: "%d Tickets", arguments: [tickets.count])
            }
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            cell.userInteractionEnabled = false
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("TicketTableCell", forIndexPath: indexPath) as! TicketTableCellTableViewCell
            let ticketObject = tickets[indexPath.row - 1]
            cell.ticketTitleField.text = ticketObject["title"] as! String
            cell.ticketTextArea.text = ticketObject["requestMessage"] as! String
            if ticketObject["helper"] != nil {
                cell.takenImageView.image = UIImage(named: "forward.png")
            } else {
                cell.takenImageView.image = nil
            }
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 40
        } else {
            return 125
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("showing messages")
        if let cellIndex = tableView.indexPathForSelectedRow?.row {
            print("Index: %d", cellIndex)
            if tickets.count > (cellIndex - 1) {
                let ticketId = tickets[cellIndex - 1]
                let msgViewController = segue.destinationViewController as! MessageViewController
                msgViewController.ticket = ticketId;
            } else {
                print("Could not get ticketID")
            }
            
            //destination.blogName = swiftBlogs[blogIndex]
        } else {
            print("could not get ticket index")
        }
        //msgViewController.ticketID =
    }
    
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
