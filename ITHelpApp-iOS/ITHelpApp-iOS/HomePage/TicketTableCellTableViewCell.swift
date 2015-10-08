//
//  TicketTableCellTableViewCell.swift
//  ITHelpApp-iOS
//
//  Created by Johan Adami on 10/7/15.
//  Copyright © 2015 Johan Adami. All rights reserved.
//

import UIKit

class TicketTableCellTableViewCell: UITableViewCell {

    @IBOutlet weak var portaitImageView: UIImageView!
    @IBOutlet weak var ticketTitleField: UILabel!
    @IBOutlet weak var ticketTextArea: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
