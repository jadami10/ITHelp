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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tagViewCollection.delegate = self
        tagViewCollection.dataSource = self
        // Initialization code
        //self.portaitImageView.layer.borderColor = UIConstants.mainGreenColor.CGColor
        //self.portaitImageView.layer.borderWidth = 1.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TagManager.sharedInstance.getNumTags()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TagCell", forIndexPath: indexPath) as! RequestTagCell
        if indexPath.section == 0 {
            let tag = TagManager.sharedInstance.getTag(indexPath)
            cell.tagVal.text = tag.tagName
            cell.backgroundColor = tag.tagColor
            //            cell.tagVal.sizeToFit()
        } else {
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


}
