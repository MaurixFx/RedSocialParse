//
//  TinderViewController.swift
//  PetWorldMap
//
//  Created by Mauricio Figueroa Olivares on 01-05-17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class TinderViewController: UIViewController {
    
    
    @IBOutlet var menuButton: UIBarButtonItem!
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var userNameLabel: UILabel!

    // Declaramos un objeto de array de Usuarios vacio
    var users: [User] = []
    
    // Variable de iniciación del array
    var idx = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Si es distinto de nulo
        if self.revealViewController() != nil {
            
            // Le asignamos el revealViewController al menu
            self.menuButton.target = self.revealViewController()
            // Le agregamos el menu a la izquierda
            self.menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            // Asignamos el deslizamiento lateral con el dedo al menu
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        // Asignamos todos los usuarios que no son amigosa
        users = UserFactory.sharedInstance.getUknowPeoPle()

        // Recargamos los usuarios
        self.reloadView()
        
        // Declaramos el gestureRecognizer que sera la accion de deslizamiento.
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TinderViewController.imageDragged(gestureRecognizer:)))
        
        
        // Permitimos que la imagen tenga interactuacion
        self.userImageView.isUserInteractionEnabled = true
        // Agregamos el gestureRecognizer a la imagen
        self.userImageView.addGestureRecognizer(gestureRecognizer)
        
        // Do any additional setup after loading the view.
    }
    
    func reloadView(){
        
        idx += 1
        
        if idx >= self.users.count {
            idx = 0
        }

        let user = users[idx]
        
        self.userNameLabel.text = user.name
        
        // Si no tiene imagen le asignamos una por defecto
        if let image = user.image {
            self.userImageView.image = image
        } else {
            self.userImageView.image = #imageLiteral(resourceName: "no-friend")
        }
        
        
    }
    
    func imageDragged(gestureRecognizer: UIPanGestureRecognizer) {
        // Creamos la translacion
        let translation = gestureRecognizer.translation(in: self.view)
        
        // Obtenemos la imageView que contiene el gestureRecognizer
        let imageView = gestureRecognizer.view!
        
        // Agregamos el movimiento a la imagen
        imageView.center = CGPoint(x: self.view.bounds.width/2 + translation.x, y: self.view.bounds.height/2 + translation.y)
        
        // Creamos el angulo de rotacion
        let rotationAngle = (imageView.center.x - self.view.bounds.width/2) / 180.0
        
        // Creamos una rotacion
        var rotation = CGAffineTransform(rotationAngle: rotationAngle)
        
        // Factor de escalado y rotacion
        let scaleFactor = min(80/abs(imageView.center.x - self.view.bounds.width/2),1)
        
        // Creamos la rotacion y escalado
        var scaleAndRotate = rotation.scaledBy(x: scaleFactor, y: scaleFactor)
        
        // Agregamos la transformacion de rotacion y escalado a la imagen
        imageView.transform = scaleAndRotate
        
        // Si acabo el desplazamiento de la imagen en pantalla
        if gestureRecognizer.state == .ended {
            
            if imageView.center.x < 100 {
                print("Debemos rechazar al usuario")
                self.reloadView()
            }
            
            if imageView.center.x > self.view.bounds.width - 100 {
               
                // Le indicamos que ya somos amigos
                self.users[idx].isFriend = true
                
                // Declaramos el objeto de la entidad de parse UserFriends
                let friendship = PFObject(className: "UserFriends")
                
                // Asignamos el ID del usuario logueado
                friendship["idUser"] = PFUser.current()?.objectId
                
                // Asignamos el ID del usuario seleccionado que queremos ser amigo
                friendship["idUserFriend"] = self.users[idx].objectID
                
                //Creamos el objeto ACL
                // Controlamos los permisos
                let acl = PFACL()
                //Asignamos permiso de lectura y escritura
                acl.getPublicReadAccess = true
                acl.getPublicWriteAccess = true
                // Asignamos los permisos a nuestro objeto de amistades
                friendship.acl = acl
                
                // Guardamos la amistad
                friendship.saveInBackground()

                // Volvemos a obtener los usuarios que no son amigos y los asignamos al array
                self.users = UserFactory.sharedInstance.getUknowPeoPle()
                
                // Recargamos y pasamos al siguiente usuario
                self.reloadView()
            }

            // Volvemos la rotacion a 0
            rotation = CGAffineTransform(rotationAngle: 0)
            scaleAndRotate  = rotation.scaledBy(x: 1, y: 1)
            // Asignamos la rotacion y escalado a la imagen
            imageView.transform = scaleAndRotate
            imageView.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
        }
     
       
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
