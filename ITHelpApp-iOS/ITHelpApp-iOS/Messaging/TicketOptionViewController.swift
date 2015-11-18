//
//  TicketOptionViewController.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 11/4/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import UIKit
import Parse

class TicketOptionViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var ticketActionButton: UIButton!
    @IBOutlet weak var requestSupportButton: UIButton!
    @IBOutlet weak var detailTableView: UITableView!
    var ticket: PFObject?
    var busyFrame: UIView?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.navigationBarHidden = false
        detailTableView.dataSource = self
        if ticket!["taken"] as! Int == 0 {
            self.ticketActionButton.setTitle("Cancel Ticket", forState: .Normal)
        } else {
            self.ticketActionButton.setTitle("Mark as Solved", forState: .Normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = true
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIConstants.mainUIColor
    }
    
    func tableView(textTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath)
        
        switch indexPath.row {
            case 0:
                cell.textLabel!.text = "Created"
                if let date = ticket!.createdAt {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "MM.dd.yy"
                    let dateString = dateFormatter.stringFromDate(date)
                    cell.detailTextLabel!.text = dateString
                }
            case 1:
                cell.textLabel?.text = "Current Helper"
                if let curTicket = ticket!["helper"] as? PFUser, let curHelper = curTicket.username {

                    cell.detailTextLabel?.text = curHelper
                } else {
                    cell.detailTextLabel?.text = "No one"
            }
            default:
                cell.textLabel?.text = "Something else"
        }
        
        return cell
        
    }
    
    @IBAction func requestSupportPressed(sender: AnyObject) {
        self.presentAlert("Not Available", message: "Support not yet available", completion: nil)
    }
    
    @IBAction func actionButtonPressed(sender: AnyObject) {
        if (ticket!["taken"] as! Int == 0) {
            print("deleting untaken ticket")
            handleTicketDeletion()
            
        } else {
            print("marking ticket as solved")
            handleTicketSolved()
        }
    }
    
    func handleTicketDeletion() {
        self.view.userInteractionEnabled = false
        self.busyFrame = self.progressBarDisplayer("Deleting", indicator: true)
        TicketHandler.deleteTicket(ticket!, completion: self.checkDeletion)
    }
    
    func checkDeletion(isDeleted: Bool, error: NSError?) -> Void {
        if (isDeleted) {
            // go back to ticket view controller
            print("Succesfully deleted ticket")
            TicketManager.sharedInstance.getTickets()
            self.busyFrame?.removeFromSuperview()
            self.view.userInteractionEnabled = true
            self.returnToTicketViewController()
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
                self.presentAlert("Could Not Delete", message: "Please try again later", completion: nil)
                print("Failed to delete with no error code")
            }
            self.busyFrame?.removeFromSuperview()
            self.view.userInteractionEnabled = true
        } else {
            print("failed with no error")
            self.presentAlert("BriskIT Error", message: "Unable to delete ticket", completion: nil)
        }
    }
    
    func handleTicketSolved() {
        self.view.userInteractionEnabled = false
        self.busyFrame = self.progressBarDisplayer("Closing", indicator: true)
        TicketHandler.markTicketSolved(ticket!, completion: self.checkSolved)
    }
    
    func checkSolved(isSolved: Bool, error: NSError?) -> Void {
        if (isSolved) {
            // go back to ticket view controller
            print("Succesfully closed ticket")
            self.busyFrame?.removeFromSuperview()
            self.view.userInteractionEnabled = true
            TicketManager.sharedInstance.getTickets()
            self.returnToTicketViewController()
        } else if (error != nil) {
            if let err = error?.code {
                switch(err) {
                case 100:
                    self.presentAlert("Could Not Mark Solved", message:  "No Network Connection", completion: nil)
                    break
                default:
                    self.presentAlert("Could Not Mark Solved", message: "Please try again later", completion: nil)
                }
            } else {
                self.presentAlert("Could Not Mark Solved", message: "Please try again later", completion: nil)
                print("Failed to delete with no error code")
            }
            self.busyFrame?.removeFromSuperview()
            self.view.userInteractionEnabled = true
        } else {
            print("failed with no error")
            self.presentAlert("BriskIT Error", message: "Unable to solve ticket", completion: nil)
        }

    }
    
    func refreshTicket() {
        // TODO: fetch the latest ticket and update UI. if latest is null, warn user and go back to ticket screen
    }
    
    func returnToTicketViewController() {
        print("go back to tickets")
        self.navigationController?.popToRootViewControllerAnimated(true)
//        let storyboard = UIStoryboard(name: "home", bundle: nil)
//        let controller = storyboard.instantiateViewControllerWithIdentifier("TicketTableViewController") as UIViewController
//        
//        self.presentViewController(controller, animated: false, completion: nil)
    }
    
}
