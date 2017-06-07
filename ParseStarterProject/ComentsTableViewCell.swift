//
//  ComentsTableViewCell.swift
//  PetWorldMap
//
//  Created by Mauricio Figueroa Olivares on 13-05-17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class ComentsTableViewCell: UITableViewCell {

    @IBOutlet var imageUserView: UIImageView!
    
    @IBOutlet var nameUserLabel: UILabel!
    
    @IBOutlet var contentPostText: UITextView!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
