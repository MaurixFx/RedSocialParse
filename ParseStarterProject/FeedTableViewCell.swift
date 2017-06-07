//
//  FeedTableViewCell.swift
//  PetWorldMap
//
//  Created by Mauricio Figueroa Olivares on 03-05-17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

protocol FeedCellProtocol: class {
    func takePictureUser(row: Int)
    
    func takePicturePostUser(row: Int)
}

class FeedTableViewCell: UITableViewCell {

    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var nameUserLabel: UILabel!
    
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var contentLabel: UILabel!
    
    @IBOutlet var postImageView: UIImageView!
    
    @IBOutlet var likeButton: UIButton!
    
    @IBOutlet var numberLikesLabel: UILabel!
    
    weak var delegate: FeedCellProtocol?
    
    var row: Int?
    
    var post: Post?
    
    var find: Bool? = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Creamos un gestureRecognizer
        let takePictureGesture = UITapGestureRecognizer(target: self, action: #selector(FeedTableViewCell.takePictureUser))
        
        // Lo añadimos a la imagen para que cuando se toque la foto se tome como una accion
        self.userImageView.addGestureRecognizer(takePictureGesture)
        // Le damos interaccion
        self.userImageView.isUserInteractionEnabled = true
        
        // Creamos un gestureRecognizer
        let takePicturePostGesture = UITapGestureRecognizer(target: self, action: #selector(FeedTableViewCell.takePicturePostUser))
        
        // Lo añadimos a la imagen para que cuando se toque la foto se tome como una accion
        self.postImageView.addGestureRecognizer(takePicturePostGesture)
        // Le damos interaccion
        self.postImageView.isUserInteractionEnabled = true

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Funcion para cuando toque la foto del Usuario
   /* func takePictureUser() {
        print("Llegue")
 //       performSegue(withIdentifier: "showPerfilUser", sender: self)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPerfilUser"), object: nil)
    }*/
    
    
    func configureCell(post: Post) {
        self.post = post
        
        let userId = UserFactory.sharedInstance.currentUser?.objectID
        
        let query = PFQuery(className: "UserLikePost")
        query.whereKey("idUser", equalTo: userId!)
        query.whereKey("idPost", equalTo: (self.post?.objectID)!)
        
        // Buscamos por los filtros para eliminar
        query.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                // Comprobamos que hay resultado
                if let objects = objects {
                    
                    if objects.count > 0 {
                        // Mostramos la imagen del  Like
                        self.likeButton.setImage(#imageLiteral(resourceName: "007-bone"), for: .normal)
                    } else {
                        // Mostramos la imagen del no Like
                        self.likeButton.setImage(#imageLiteral(resourceName: "008-dog-bone"), for: .normal)
                    }
                }
            }
        })
        
        if let numberLikes = self.post?.numberLikes {
            self.numberLikesLabel.text = "Likes: \(numberLikes)"
        } else {
            self.numberLikesLabel.text = "Likes: 0"
        }

        
    }

    
    
    @IBAction func takePictureUser() {
        
        guard let row = row else { return }
        print("la fila en celda perfil \(row)")
        delegate?.takePictureUser(row: row)
        
    }
    
    @IBAction func takePicturePostUser() {
        
        guard let row = row else { return }
        
        print("la fila en celda comentario \(row)")
        delegate?.takePicturePostUser(row: row)
        
    }
    
    func getNumberLikes() {
        
    }
    
    @IBAction func likePost(_ sender: UIButton) {

        let postId = self.post?.objectID
        print("\(postId)")
        
        let userId = UserFactory.sharedInstance.currentUser?.objectID
        
        let query = PFQuery(className: "UserLikePost")
        query.whereKey("idUser", equalTo: userId!)
        query.whereKey("idPost", equalTo: (self.post?.objectID)!)
        
        
        // Buscamos por los filtros para eliminar
        query.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                // Comprobamos que hay resultado
                if let objects = objects {
                    
                    if objects.count > 0 {
                        
                        for object in objects {
                            
                            self.likeButton.setImage(#imageLiteral(resourceName: "008-dog-bone"), for: .normal)
                            // Eliminamos
                            object.deleteInBackground()
                            
                            // Descontamos el like del Post
                            let query = PFQuery(className:"Post")
                            
                            query.whereKey("objectId", equalTo: (self.post?.objectID)!)
                            
                            query.findObjectsInBackground(block: { (objects, error) in
                                
                                if let objects = objects {
                                    if objects.count > 0 {
                                        
                                        for object in objects {
                                            
                                            // Contamos los Likes
                                            let ContLikes = self.post?.numberLikes
                                            
                                            // Si es mayor a 0 le descontamos 1
                                            if ContLikes! > 0 {
                                                object["numberLikes"] = ContLikes! - 1
                                                object.saveInBackground()
                                            
                                                // Actualizamos el Label de los Likes
                                                self.numberLikesLabel.text = "Likes: \(ContLikes!)"
                                            } else {
                                                
                                                object["numberLikes"] = 0
                                                object.saveInBackground()
                                                
                                                // Actualizamos el Label de los Likes
                                                self.numberLikesLabel.text = "Likes: 0"
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                            })

                        }
                    } else {
                        // Agregamos el Like
                        self.likeButton.setImage(#imageLiteral(resourceName: "007-bone"), for: .normal)
                        
                        // Declaramos el objeto de la entidad de parse UserLikePost
                        let likePost = PFObject(className: "UserLikePost")
                        
                        // Asignamos el ID del usuario logueado
                        likePost["idUser"] = PFUser.current()?.objectId
                        
                        // Asignamos el ID del Post
                        likePost["idPost"] = self.post?.objectID
                        
                        //Creamos el objeto ACL
                        // Controlamos los permisos
                        let acl = PFACL()
                        //Asignamos permiso de lectura y escritura
                        acl.getPublicReadAccess = true
                        acl.getPublicWriteAccess = true
                        // Asignamos los permisos a nuestro objeto de likePost
                        likePost.acl = acl
                        
                        // Guardamos el Like
                        likePost.saveInBackground(block: { (success, error) in
                            if success {
                               let query = PFQuery(className:"Post")
                                let postID = self.post?.objectID
                                
                                query.whereKey("objectId", equalTo: postID!)
                                //here you would just find the results
                                query.findObjectsInBackground(block: { (objects, error) in
                                    
                                    if error == nil {
                                        for postLike in objects! {
                                            postLike["numberLikes"] = (self.post?.numberLikes)! + 1
      
                                            // Actualizamos el Like en el Post
                                            postLike.saveInBackground()
                                            
                                            // Actualizamos el Label de los Likes
                                            self.numberLikesLabel.text = "Likes: \((self.post?.numberLikes)! + 1)"
                                        }
                                        
                                    } else {
                                        print(error?.localizedDescription)
                                    }

                                })
                                
                                
                            } else {
                                print(error?.localizedDescription)
                            }
                        })
                    }
                }
            }
        })
    }

}
