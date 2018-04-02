//
//  TrainDataTableViewCell.swift
//  Commute2
//
//  Created by Derek Doherty on 31/03/2018.
//  Copyright © 2018 Derek Doherty. All rights reserved.
//

import UIKit

// Using a custom class here for the display cell
//
class TrainDataTableViewCell: UITableViewCell {

    @IBOutlet weak var minutes: UILabel!
    @IBOutlet weak var info: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
