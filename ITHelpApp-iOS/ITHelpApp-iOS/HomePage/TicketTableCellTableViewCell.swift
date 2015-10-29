//
//  TicketTableCellTableViewCell.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/7/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import UIKit

class TicketTableCellTableViewCell: UITableViewCell {

    @IBOutlet weak var ticketTitleField: UITextView!
    @IBOutlet weak var ticketStatusLabel: UILabel!
    @IBOutlet weak var ticketDateLabel: UILabel!
    @IBOutlet weak var ticketTriangleImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.portaitImageView.layer.borderColor = UIConstants.mainGreenColor.CGColor
        //self.portaitImageView.layer.borderWidth = 1.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
