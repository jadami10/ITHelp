//
//  TicketTableCellTableViewCell.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/7/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import UIKit
import Parse

class TicketTableCellTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var ticketTitleField: UITextView!
    @IBOutlet weak var ticketStatusLabel: UILabel!
    @IBOutlet weak var ticketDateLabel: UILabel!
    @IBOutlet weak var ticketTriangleImage: UIImageView!
    @IBOutlet weak var tagViewCollection: UICollectionView!
    @IBOutlet weak var ticket: PFObject!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.portaitImageView.layer.borderColor = UIConstants.mainGreenColor.CGColor
        //self.portaitImageView.layer.borderWidth = 1.0
    }

//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (ticket["tags"] == nil || section > 0) ? 0 : ticket["tags"].count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TicketTagCell", forIndexPath: indexPath) as! RequestTagCell
        if indexPath.section == 0 {
            let row = indexPath.row
            if row <= ticket["tags"].count {
                let tag = TagManager.sharedInstance.getTagByID(ticket["tags"][row].objectId!!)
                cell.tagVal.text = tag?.tagName
                cell.backgroundColor = tag?.tagColor
            } else {
                print(String(format: "Tag out of index at %d", row))
                cell.backgroundColor = UIColor.whiteColor()
            }
        } else {
            print(String(format: "Seciton out of index at %d", indexPath.section))
            cell.backgroundColor = UIColor.whiteColor()
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let myHeight : CGFloat = 20
        var myWidth:CGFloat
        
        let tagNum = TagManager.sharedInstance.getNumTags()
        if tagNum > 0 {
            myWidth = collectionView.frame.width/CGFloat(tagNum) - 5
        } else {
            myWidth = 0
        }
        
        return CGSizeMake(myWidth, myHeight)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func setCollectionViewAsSelf() {
        tagViewCollection.delegate = self
        tagViewCollection.dataSource = self
        tagViewCollection.reloadData()
    }


}
