//
//  ReviewTableViewCell.swift
//  hw9
//
//  Created by GuJiarui on 4/24/18.
//  Copyright © 2018 GuJiarui. All rights reserved.
//

import UIKit
import Cosmos

class ReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var authorNameField: UILabel!
    
    @IBOutlet weak var starControl: CosmosView!
    
    @IBOutlet weak var timeField: UILabel!
    
    @IBOutlet weak var reviewContentField: UITextView!
    
    @IBOutlet weak var profilePhotoView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        starControl.settings.updateOnTouch = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
