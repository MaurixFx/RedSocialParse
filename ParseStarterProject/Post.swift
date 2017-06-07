//
//  Post.swift
//  PetWorldMap
//
//  Created by Mauricio Figueroa Olivares on 03-05-17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class Post: NSObject {
    
    var objectID : String!
    var message: String?
    var image: UIImage?
    var user: User?
    var creationDate : Date!
    var numberLikes: Int?
    
    
    init(objectID: String, message: String, image: UIImage?, user: User?, creationDate: Date, numberLikes: Int?) {
        self.objectID = objectID
        self.message = message
        self.image = image
        self.user = user
        self.creationDate = creationDate
        self.numberLikes = numberLikes
    }

}
