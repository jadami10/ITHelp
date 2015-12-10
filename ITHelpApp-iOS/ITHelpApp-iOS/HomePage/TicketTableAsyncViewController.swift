//
//  TicketTableViewController.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/8/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import UIKit
import Parse

class TicketTableAsyncViewController: UITableViewController, UIBlockableProtocol {
    
    var busyFrame: UIView?
    var notAtRootView = 0
    var shouldDelete = NSIndexPath?()
    var manager = AsyncTicketManager.sharedInstance

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
        
        self.clearsSelectionOnViewWillAppear = true
        manager.listener = self.tableView
        self.fetchTickets()

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
        self.blockUI()
        manager.getAllTickets(self.checkGetTickets)
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return manager.getNumSections()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.getNumRowsInSection(section)
    }
    
    func totalTicket() -> Int {
        return manager.getNumTotalTickets()
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return manager.getTitleAtSection(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("TicketTableCell", forIndexPath: indexPath) as! TicketTableCellTableViewCell
        
        let ticketObject = manager.getTicketAtPath(indexPath)
        let qualifier = manager.getTicketType(indexPath.section)
        
        guard ticketObject != nil else {
            return cell
        }
        
        cell.ticket = ticketObject!
        cell.setCollectionViewAsSelf()
        cell.ticketTitleField.text = (ticketObject!["title"] as! String)
        
        if let curTicket = ticketObject!["helper"] as? PFUser, let curHelper = curTicket.username {
            cell.ticketStatusLabel.text = "Taken by " + curHelper
        } else if ticketObject!["helper"] != nil && (ticketObject!["helper"] as! PFUser).objectId != nil {
            cell.ticketStatusLabel.text = "Taken by " + (ticketObject!["helper"] as! PFUser).objectId!
        } else {
            cell.ticketStatusLabel.text = "Searching for help"
        }
        if let date = ticketObject!.createdAt {
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
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 125
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
        let ticket = manager.getTicketAtPath(indexPath)
        if ticket != nil {
            self.tabBarController?.tabBar.hidden = true
            if ticket!["taken"] as! Int != 0 {
                goToMessagePage(ticket!)
            } else {
                goToOptionPage(ticket!)
            }
        } else {
            print("Selected ticket out of bounds")
        }
        
    }
    
    func goToMessagePage(ticket: PFObject) {
        let storyboard = UIStoryboard(name: "message", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("textTable") as! MessageViewController
//        let controller = storyboard.instantiateViewControllerWithIdentifier("SlackMessage") as! SlackMessagingView
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
        return manager.getTicketType(indexPath.section) == TicketType.Pending
    }
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            switch (indexPath.section) {
            case 0:
                manager.deleteTicketAtPath(indexPath)
                break
            default:
                break
            }
        } /*else if editingStyle == .Insert {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }   */
    }
    
    func checkGetTickets(error: NSError?) {
        if let err = error?.code {
            switch(err) {
            case 100:
                self.presentAlert("Could not get tickets", message:  "No Network Connection", completion: nil)
                break
            default:
                self.presentAlert("Could not get tickets", message: "Please try again later", completion: nil)
            }
        }
        self.releaseUI()
    }
    
    func blockUI() {
        self.tableView.userInteractionEnabled = false
        self.busyFrame = self.progressBarDisplayer("Getting Tickets", indicator: true)
    }
    
    func releaseUI() {
        self.busyFrame?.removeFromSuperview()
        self.tableView.userInteractionEnabled = true
    }
    
    @IBAction func createNewTicketButton(sender: UIButton) {
        let toView = tabBarController?.viewControllers![1].view
        UIView.transitionFromView((tabBarController?.selectedViewController?.view)!, toView: toView!, duration: 0.2, options:UIViewAnimationOptions.TransitionFlipFromLeft) { (finished) -> Void in
            if finished{
                self.tabBarController?.selectedIndex = 1
            }
        }
//        let storyboard = UIStoryboard(name: "request", bundle: nil)
//        let controller = storyboard.instantiateViewControllerWithIdentifier("RequestViewController") as! RequestViewController
//        self.navigationController?.pushViewController(controller, animated: true)
//        notAtRootView = 1

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
