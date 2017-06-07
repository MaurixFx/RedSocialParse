//
//  FriendsViewController.swift
//  PetWorldMap
//
//  Created by Mauricio Figueroa Olivares on 01-05-17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class FriendsViewController: UITableViewController {
    
    
    @IBOutlet var menuButton: UIBarButtonItem!
    
    // Declaramos un diccionario de la clase User
    var users : [User] = []

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
        
        // Creamos un refreshControl
        self.refreshControl = UIRefreshControl()
        // Asignamos un titulo al refresh
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Tira para recargar amigos")
        //Agregamos la vista y el metodo cargar Usuarios
        self.refreshControl?.addTarget(self, action: #selector(FriendsViewController.loadUsers), for: .valueChanged)
 
        // Llamamos la funcion para crear Bots
        //self.createBots()
        
        // Llamamos a la funcion que carga los usuarios
        self.loadUsers()
        
    }
    
    // Funcion que se ejecuta justo antes de aparecer en pantalla
    // Recargamos los usuarios
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadUsers()
    }
    
    func createBots() {
        // Creamos los usuarios BOTS
        let urls = ["Esteban": "http://static.emol.cl/emol50/Fotos/2015/10/02/file_20151002131535.jpg",
                    "Matias": "http://www.todofutbol.cl/wp-content/uploads/2015/11/dalealbo-assets.s3.amazonaws.jpg",
                    "Cristiano": "http://cdn8.larepublica.pe/sites/default/files/styles/img_620/public/imagen/2017/02/12/cristiano-ronaldo-Noticia-847835.jpg",
                    "Lucas": "http://cdn.elperiscopio.cl/wp-content/uploads/2016/12/lucasbarrios.jpg",
                    "Scarlet": "http://www.ideal.es/ideal/granada/multimedia/201402/07/media/sc.jpg",
                    "Dennise" : "https://s-media-cache-ak0.pinimg.com/736x/ab/b7/e4/abb7e4543f28849c73afbd3854f0209a.jpg",
                    "Lagertha": "https://s-media-cache-ak0.pinimg.com/736x/f0/91/d7/f091d7ca0937515cb1af39eb265e52c2.jpg",
                    "MonLaferte": "https://1.bp.blogspot.com/-bucs4Wi4i8Y/V2eL57uptTI/AAAAAAAAPeY/RWK8nlPVk9Eazv1WX82UAdViVcsYy8uogCLcB/s1600/Mon%2BLaferte.jpg"]
        
        // Recorremos del diccionario
        for (name, profileUrl) in urls {
            let user = PFUser()
            user.username = name + "@bot.com"
            user.email = name + "@bot.com"
            user.password = "bot1234"
            user["gender"] = false
            
            let formater = DateFormatter()
            formater.dateFormat = "dd-MM-yyyy"
            user["birthdate"] = formater.date(from: "01-01-1987")
            user["nickname"] = name
            
            // Configuramos los permisos
            let acl = PFACL()
            acl.getPublicWriteAccess = true
            acl.getPublicReadAccess = true
            user.acl = acl
            
            
            let url = URL(string: profileUrl)
            
            do {
                let data = try Data(contentsOf: url!)
                user["imageFile"] = PFFile(name: "bot.jpg", data: data)
                
                user.signUpInBackground(block: { (success, error) in
                    if success {
                        print("perfil bot creado")
                    }
                })
                
                
            } catch {
                print("No hemos podido cargar la imagen")
            }
            
        }
        

    }
    
    func loadUsers() {
        
        // Asignamos al array de User, la obtencion de los usuarios amigos
        self.users = UserFactory.sharedInstance.getFriends()
        
        // Paramos el refreshControl
        self.refreshControl?.endRefreshing()
        
        //Recargamos la tabla
        self.tableView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Si el identificador es showDetail
        if segue.identifier == "showDetail" {
            // Asignamos el viewController de destino
            let destinationVC = segue.destination as! PublicProfileViewController
            // Pasamos el usuario de la fila seleccionada a la siguiente pantalla
            destinationVC.user = self.users[(self.tableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    // Retornamos el numero de secciones
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Retornamos el numero de filas
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    // Configuramos la celda
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Declaramos la celda con el identificador
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath) as! UserTableViewCell
        
        // Obtenemos el usuario por posicion
        let user = self.users[indexPath.row]
        
        // Asignamos el nombre a la celda
        cell.nickNameLabel.text = user.name
        
        // Si el usuario tiene imagen la asignamos
        if let image = user.image {
            cell.userImageView.image = image
        } else {
            cell.userImageView.image = #imageLiteral(resourceName: "no-friend")
        }
        
        // Dejamos la imagen en circular
        cell.userImageView.layer.cornerRadius = 30
        cell.userImageView.clipsToBounds = true
        
        // Preguntamos si el usuario es amigo, le ponemos el check
       /* if self.users[indexPath.row].isFriend {
            
            // Agregamos el check
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }*/
        
        return cell
    }
    
    // Funcion para las celdas seleccionadas
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Recuperamos la celda
        let cell = tableView.cellForRow(at: indexPath)
        
        // Si la celda seleccionada ya es amigo
        // Se elimina de la entidad UserFriends
     /*   if self.users[indexPath.row].isFriend {
            // Quitamos el checkmark
            cell?.accessoryType = .none
            
            // Le indicamos que ya no somos amigos
            self.users[indexPath.row].isFriend = false
            
            // Declaramos la query
            let query = PFQuery(className: "UserFriends")
            
            // Filtramos Asignando el ID del usuario logueado
            query.whereKey("idUser", equalTo: (PFUser.current()?.objectId)!)
            
            // Asignamos el ID del usuario seleccionado que queremos ser amigo
            query.whereKey("idUserFriend", equalTo: self.users[indexPath.row].objectID)
            
            // Buscamos por los filtros para eliminar
            query.findObjectsInBackground(block: { (objects, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    // Comprobamos que hay resultado
                    if let objects = objects {
                        for object in objects {
                            // Eliminamos
                            object.deleteInBackground()
                        }
                    }
                }
            })
            
        } else {
            // Se crea la amistad
         
            // Agregamos un check
            cell?.accessoryType = .checkmark
            
            // Le indicamos que ya somos amigos
            self.users[indexPath.row].isFriend = true
            
            // Declaramos el objeto de la entidad de parse UserFriends
            let friendship = PFObject(className: "UserFriends")
            
            // Asignamos el ID del usuario logueado
            friendship["idUser"] = PFUser.current()?.objectId
            
            // Asignamos el ID del usuario seleccionado que queremos ser amigo
            friendship["idUserFriend"] = self.users[indexPath.row].objectID
            
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
        } */
        
        
    }

}
