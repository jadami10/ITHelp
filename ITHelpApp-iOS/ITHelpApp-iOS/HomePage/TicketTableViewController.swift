//
//  TicketTableViewController.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/8/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import UIKit
import Parse

class TicketTableViewController: UITableViewController, UIBlockableProtocol {
    
    var busyFrame: UIView?
    
    var shouldDelete = NSIndexPath?()
    var manager = TicketManager.sharedInstance
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let path = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(path, animated: true)
        }

        navigationController?.setNavigationBarHidden(true, animated: true)
//        self.tabBarController?.tabBar.hidden = false
//        self.hidesBottomBarWhenPushed = true
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        AppConstants.ticketNavController = self.navigationController
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        manager.registerListener(self)
        manager.getTickets()
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
        manager.getTickets()
        refreshControl.endRefreshing()
    }
    
    func blockUI() {
        self.tableView.userInteractionEnabled = false
        self.busyFrame = self.progressBarDisplayer("Getting Tickets", indicator: true)
    }
    
    func releaseUI() {
        self.busyFrame?.removeFromSuperview()
        self.tableView.userInteractionEnabled = true
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return manager.getNumSections()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let ticketQueue = manager.getTicketQueue(section)
        return ticketQueue.count + 1
    }
    
    func totalTicket() -> Int {
        return manager.getNumTotalTickets()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var tickets = manager.getTicketQueue(indexPath.section)
        let qualifier = manager.getTicketType(indexPath.section, row: indexPath.row)
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("TicketTitleCell", forIndexPath: indexPath)
            if tickets.count == 1 {
            cell.textLabel?.text = String(format: "1 %@ Ticket", qualifier.rawValue)
            } else {
            cell.textLabel?.text = String(format: "%d %@ Tickets", tickets.count, qualifier.rawValue)
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
                switch(qualifier) {
                case .Pending:
                    cell.ticketTriangleImage.image = UIImage(named: "redTriangle")
                    break
                case .Open:
                    cell.ticketTriangleImage.image = UIImage(named: "blueTriangle")
                    break
                case .Solved:
                    cell.ticketTriangleImage.image = UIImage(named: "greenTriangle")
                    break
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
        let tickets = manager.getTicketQueue(indexPath.section)
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
        return manager.getTicketType(indexPath.section, row: indexPath.row) == TicketType.Pending
    }
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            switch (indexPath.section) {
            case 0:
                self.tableView.beginUpdates()
                self.view.userInteractionEnabled = false
                self.busyFrame = self.progressBarDisplayer("Deleting", indicator: true)
                shouldDelete = indexPath
//                TicketHandler.deleteTicket(ticket, completion: self.checkDeletion)
                manager.handleTicketDeletion(indexPath, checkDeletion: self.checkDeletion)
                self.tableView.endUpdates()
                break
            default:
                break
            }
        } /*else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }   */
    }
    
    func checkDeletion(isDeleted: Bool, error: NSError?) -> Void {
        if (isDeleted) {
            // go back to ticket view controller
            print("Succesfully deleted ticket")
            AppConstants.curTicketsNum--
            if let index = shouldDelete?.row {
                let count = manager.ticketDeleted(index)
                if count == 0 {
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
