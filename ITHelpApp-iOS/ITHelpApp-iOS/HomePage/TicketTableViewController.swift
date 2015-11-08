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
    
    var pendingTickets = [PFObject]()
    var openTickets = [PFObject]()
    var solvedTickets = [PFObject]()
    var busyFrame: UIView?
    

    override func viewWillAppear(animated: Bool) {
        // FIXME: store tickets so you don't reload every time. Causes issues with bad network conditions
        if totalTicket() == 0 || AppConstants.shouldRefreshTickets {
            //self.asyncBlockingAction("Fetching Tickets", taskToRun: fetchTickets)
            AppConstants.shouldRefreshTickets = false
            self.fetchTickets()
        } else {
            if let path = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRowAtIndexPath(path, animated: true)
            }
        }
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //TicketHandler.getTickets(addTickets)
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.fetchTickets()
        refreshControl.endRefreshing()
    }
    
    func fetchTickets() {
        //self.view.userInteractionEnabled = false
        self.tableView.userInteractionEnabled = false
        self.busyFrame = self.progressBarDisplayer("Getting Tickets", indicator: true)
        clearTickets()
        TicketHandler.getTickets(addTickets, completion: gotTickets)

    }
    
    func gotTickets() -> Void {
        self.tableView.reloadData()
        self.busyFrame?.removeFromSuperview()
        self.tableView.userInteractionEnabled = true
        //self.view.userInteractionEnabled = true
    }
    
    func addTickets(object: PFObject, type: Int) -> Void{
        if type == 0 {
            pendingTickets.append(object)
        } else if type == 1 {
            openTickets.append(object)
        } else {
            solvedTickets.append(object)
        }
        //print(object)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return pendingTickets.count + 1
        } else if (section == 1) {
            return openTickets.count + 1
        } else {
            return solvedTickets.count + 1
        }
    }
    
    func totalTicket() -> Int {
        return pendingTickets.count + openTickets.count + solvedTickets.count
    }
    
    func clearTickets() {
        pendingTickets = []
        openTickets = []
        solvedTickets = []
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var tickets: [PFObject]
        var qualifier: String
        if (indexPath.section == 0) {
            tickets = pendingTickets
            qualifier = "Pending"
        } else if (indexPath.section == 1) {
            tickets = openTickets
            qualifier = "Open"
        } else {
            tickets = solvedTickets
            qualifier = "Solved"
        }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("TicketTitleCell", forIndexPath: indexPath)
            
            if tickets.count == 1 {
            cell.textLabel?.text = String(format: "1 %@ Ticket", qualifier)
            } else {
            cell.textLabel?.text = String(format: "%d %@ Tickets", tickets.count, qualifier)
            }
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            cell.userInteractionEnabled = false
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("TicketTableCell", forIndexPath: indexPath) as! TicketTableCellTableViewCell
            if (tickets.count > indexPath.row - 1) {
                let ticketObject = tickets[indexPath.row - 1]
                
                cell.ticketTitleField.text = (ticketObject["title"] as! String)
                
                if let curTicket = ticketObject["helper"] as? PFUser, let curHelper = curTicket.username {
                    cell.ticketStatusLabel.text = "Taken by " + curHelper
                } else if ticketObject["helper"] != nil && (ticketObject["helper"] as! PFUser).objectId != nil {
                    cell.ticketStatusLabel.text = "Taken by " + (ticketObject["helper"] as! PFUser).objectId!
                } else {
                    cell.ticketStatusLabel.text = "Searching for help"
                }
                if let date = ticketObject.createdAt {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "MM.dd.yy"
                    let dateString = dateFormatter.stringFromDate(date)
                    cell.ticketDateLabel.text = dateString
                }
            } else {
                print(String(format: "Index: %d, Tickets: %d", indexPath.row-1, tickets.count))
            }
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 20
        } else {
            return 125
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("showing messages")
        if let indexPath = tableView.indexPathForSelectedRow {
            print("Section: %d Row: %d", indexPath.section, indexPath.row)
            
            var tickets: [PFObject]
            if (indexPath.section == 0) {
                tickets = pendingTickets
            } else if (indexPath.section == 1) {
                tickets = openTickets
            } else {
                tickets = solvedTickets
            }
            
            if tickets.count > (indexPath.row - 1) {
                let ticketId = tickets[indexPath.row - 1]
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
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
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
