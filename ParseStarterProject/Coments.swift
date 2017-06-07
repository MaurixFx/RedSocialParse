//
//  Coments.swift
//  PetWorldMap
//
//  Created by Mauricio Figueroa Olivares on 13-05-17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class Coments: NSObject {
    
    var objectID : String!
    var message: String?
    var user: User?
    var post: Post?
    var creationDate : Date!
    
    init(objectID: String, message: String, user: User?, post: Post?, creationDate: Date) {
        self.objectID = objectID
        self.message = message
        self.user = user
        self.post = post
        self.creationDate = creationDate
    }

}
