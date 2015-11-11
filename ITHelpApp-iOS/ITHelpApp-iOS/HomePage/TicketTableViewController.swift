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
    
    var shouldDelete = NSIndexPath?()
    

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
//        self.hidesBottomBarWhenPushed = true
        self.tabBarController?.tabBar.hidden = false
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
        var numSections = 0
        if pendingTickets.count > 0 {
            numSections++
        }
        if openTickets.count > 0 {
            numSections++
        }

        if solvedTickets.count > 0 {
            numSections++
        }
        return numSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let ticketQueue = getTicketQueue(section)
        return ticketQueue.count + 1
    }
    
    func totalTicket() -> Int {
        return pendingTickets.count + openTickets.count + solvedTickets.count
    }
    
    func clearTickets() {
        pendingTickets = []
        openTickets = []
        solvedTickets = []
    }

    func getTicketQueue(section: Int) -> [PFObject] {
        if (section == 0) {
            if pendingTickets.count > 0 {
                return pendingTickets
            } else if (openTickets.count > 0) {
                return openTickets
            } else {
                return solvedTickets
            }
        } else if (section == 1) {
            if (openTickets.count > 0) {
                return openTickets
            } else {
                return solvedTickets
            }
        } else {
            return solvedTickets
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var tickets = getTicketQueue(indexPath.section)
        var qualifier: String
        if (tickets == pendingTickets) {
            qualifier = "Pending"
        } else if (tickets == openTickets) {
            qualifier = "Open"
        } else {
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
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("showing messages")
        if let indexPath = tableView.indexPathForSelectedRow {
            print("Section: %d Row: %d", indexPath.section, indexPath.row)
            
            var tickets = self.getTicketQueue(indexPath.section)
            
            if tickets.count > (indexPath.row - 1) {
                let ticketId = tickets[indexPath.row - 1]
                if ticketId["taken"] as! Int != 0 {
                    let msgViewController = segue.destinationViewController as! MessageViewController
                    msgViewController.ticket = ticketId;
                } else {
                    let controller = TicketOptionViewController()
                    segue.destinationViewController = controller
                    controller.ticket = ticketId
                }
            } else {
                print("Could not get ticketID")
            }
            
            //destination.blogName = swiftBlogs[blogIndex]
        } else {
            print("could not get ticket index")
        }
        //msgViewController.ticketID =
    }
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tickets = getTicketQueue(indexPath.section)
        let ticketId = tickets[indexPath.row - 1]
        self.tabBarController?.tabBar.hidden = true
        if ticketId["taken"] as! Int != 0 {
            goToMessagePage(ticketId)
        } else {
            goToOptionPage(ticketId)
        }
    }
    
    func goToMessagePage(ticket: PFObject) {
        let storyboard = UIStoryboard(name: "message", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("textTable") as! MessageViewController
        controller.ticket = ticket
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func goToOptionPage(ticket: PFObject) {
        let storyboard = UIStoryboard(name: "message", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("TicketOptions") as! TicketOptionViewController
        controller.ticket = ticket
        self.navigationController?.pushViewController(controller, animated: true)
    }

    /*
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    */
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return getTicketQueue(indexPath.section) == pendingTickets
    }
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let index = indexPath.row - 1
            switch (indexPath.section) {
            case 0:
                self.tableView.beginUpdates()
                handleTicketDeletion(pendingTickets[index], indexPath: indexPath)
                self.tableView.endUpdates()
                break
            default:
                break
            }
        } /*else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }   */
    }
    
    func handleTicketDeletion(ticket: PFObject, indexPath: NSIndexPath) {
        // TODO: try to delete ticket, and handle any errors, otherwise go back to ticket view
        self.view.userInteractionEnabled = false
        self.busyFrame = self.progressBarDisplayer("Deleting", indicator: true)
        shouldDelete = indexPath
        TicketHandler.deleteTicket(ticket, completion: self.checkDeletion)
    }
    
    func checkDeletion(isDeleted: Bool, error: NSError?) -> Void {
        if (isDeleted) {
            // go back to ticket view controller
            print("Succesfully deleted ticket")
            if let index = shouldDelete?.row {
                pendingTickets.removeAtIndex(index - 1)
                if pendingTickets.count == 0 {
                    tableView.deleteSections(NSIndexSet(index: shouldDelete!.section), withRowAnimation: .Fade)
                } else {
                    tableView.deleteRowsAtIndexPaths([shouldDelete!], withRowAnimation: .Fade)
                    self.tableView.reloadData()
                }
            }
            self.busyFrame?.removeFromSuperview()
            self.view.userInteractionEnabled = true
        } else if (error != nil) {
            if let err = error?.code {
                switch(err) {
                case 100:
                    self.presentAlert("Could Not Delete", message:  "No Network Connection", completion: nil)
                    break
                default:
                    self.presentAlert("Could Not Delete", message: "Please try again later", completion: nil)
                }
            } else {
                print("Failed to delete with no error code")
            }
            shouldDelete = nil
            self.busyFrame?.removeFromSuperview()
            self.view.userInteractionEnabled = true
        } else {
            shouldDelete = nil
            print("failed with no error")
            self.presentAlert("BriskIT Error", message: "Unable to delete ticket", completion: nil)
        }
    }

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
