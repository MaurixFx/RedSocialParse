//
//  UserTableViewCell.swift
//  PetWorldMap
//
//  Created by Mauricio Figueroa Olivares on 08-05-17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var nickNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
