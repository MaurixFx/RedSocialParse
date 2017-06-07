//
//  UserFactory.swift
//  PetWorldMap
//
//  Created by Mauricio Figueroa Olivares on 04-05-17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse


// Singleton
// Se reutiliza en varias zonas sin la necesidad de ser instanciada nuevamente

class UserFactory: NSObject {

    // Instancia compartida
    static let sharedInstance = UserFactory()
    
    //Hacemos compartida la Notificacion
    static let notificationName = Notification.Name(rawValue: "UsersLoaded")
    
    // Creamos un objeto User para el Usuario Logueado
    var currentUser : User?
    
    // Declaramos un array de la clase User
    var users : [User] = []
    
    override init() {
        
        super.init()
        
        //Llamamos la funcion de carga de Usuarios
        self.loadUsers()
        
        // Cargamos los datos del usuario logueado
        self.loadMainUser()
    }
    
    // Funcion que retorna todos los usuarios que son Amigos
    func getFriends() -> [User] {

        // Declaramos un array de Usuarios vacio
        var friends : [User] = []
        
        // Recorremos todos los usuarios
        for user in self.users {
            // Si no es amigo lo agregamos al array vacio
            if user.isFriend {
                friends.append(user)
            }
            
        }
        
        return friends
    }
    
    // Funcion que retorna todos los usuarios no Amigos
    func getUknowPeoPle()-> [User] {
        
        // Declaramos un array de Usuarios vacio
        var noFriends : [User] = []
        
         // Recorremos todos los usuarios
        for user in self.users {
            // Si es amigo lo agregamos al array vacio
            if !user.isFriend {
                noFriends.append(user)
            }
            
        }
        
        return noFriends
    }
    
    
    func getUser() -> [User] {
        self.loadUsers()
        self.loadMainUser()
        return self.users
    }
    
    //Cargamos los datos el usuario logueado
    func loadMainUser() {
        
        let pfUser = PFUser.current()
        let objectID = pfUser?.objectId!
        let defaultUserName = pfUser?.username?.components(separatedBy: "@")[0]
        let customUserName = pfUser?["nickname"] as? String
        let email = pfUser?.username
        //let imageFile = pfUser["imageFile"] as! PFFile
        
        
        self.currentUser = User(objectID: objectID!, name: ((customUserName == nil) ? defaultUserName : customUserName)!, email: email!)
   
    
        if let gender = pfUser?["gender"] as? Bool {
            self.currentUser!.gender = gender
        }
        
        if let birthday = pfUser?["birthdate"] as? Date {
            self.currentUser!.birthDate = birthday
        }
        
        // Asignamos el objeto de la imagen que viene de Parse de tipo PFFile
        if let imageArchivo = pfUser?["imageFile"] as? PFFile {
        
            // Obtenemos la imagen del usuario
            imageArchivo.getDataInBackground { (data, error) in
                // Comprobammos que haya resultado
                if let data = data {
                    // Asignamos la imagen que viene de Parse al objeto de usuario logueado
                    self.currentUser?.image = UIImage(data: data)
                }
            }
        }
        
        
        // Geoposicion en Parse
        // Obtenemos la posicion
        PFGeoPoint.geoPointForCurrentLocation { (point, error) in
            
            if let geopoint = point {
               
                // Asignamos los datos del geopoint en el objeto
                self.currentUser?.location = CLLocationCoordinate2D(latitude: geopoint.latitude, longitude: geopoint.longitude)
                
                PFUser.current()?["geopoint"] = geopoint
                PFUser.current()?.saveInBackground()
            }
        }
    
    }
    
    func loadUsers() {
        // Declaramos un objeto query de la entidad User de Parse
        let query = PFUser.query()
        
        // Filtramos para que no tome en cuenta nuestro Usuario logueado
        query?.whereKey("objectId", notEqualTo: (PFUser.current()?.objectId)!)
        
        // Obtenemos el geopoint del usuario logueado
       // let geopoint = PFUser.current()?["geopoint"] as? PFGeoPoint
        
        // Filtramos por la posicion del geopoint
       /* query?.whereKey("geopoint", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: (geopoint?.latitude)!-1, longitude: (geopoint?.longitude)!-1), toNortheast: PFGeoPoint(latitude: (geopoint?.latitude)!+1, longitude: (geopoint?.longitude)!+1))*/
        
        // Ejecutamos la consulta en segundo plano
        query?.findObjectsInBackground(block: { (objects, error) in
            
            // Si el error es distinto de nulo
            if error != nil {
                print(error?.localizedDescription)
            } else {
                
                // Limpiamos el array antes de cargar
                self.users.removeAll()
                
                // Recorremos los usuarios
                for object in objects! {
                    
                    // Si podemos asignar el objeto
                    if let user = object as? PFUser {
                        
                        // Si el usuario es distinto del logueado lo mostramos como amigo
                        if user.objectId != PFUser.current()?.objectId {
                            
                            // Asignamos el email
                            
                            //let email = user.email!
                            let email = user.username!
                            
                            // Asignamos el nombre
                            let defaultUserName = user.username?.components(separatedBy: "@")[0]
                            let customUserName = user["nickname"] as? String
                            
                            // Asignamos el objectID
                            let objectID = user.objectId!
                            
                            // Instanciamos la clase User y le pasamos los parametros obtenidos
                            let myUser = User(objectID: objectID, name: ((customUserName == nil) ? defaultUserName?.capitalized : customUserName?.capitalized)!, email: email)
                            
                            // Asignamos la geoposicion del usuario
                            if let geopoint = user["geopoint"] as? PFGeoPoint {
                                let location = CLLocationCoordinate2D(latitude: geopoint.latitude, longitude: geopoint.longitude)
                                myUser.location = location
                            }

                            
                            // Si tiene genero lo asignamos
                            if let gender = user["gender"] as? Bool {
                                myUser.gender = gender
                            }
                            
                            // Si tiene fecha de nacimiento la asignamos
                            if let birthdate = user["birthdate"] as? Date {
                                myUser.birthDate = birthdate
                            }
                            
                            
                            // Asignamos el objeto de la imagen que viene de Parse de tipo PFFile
                            if let imageArchivo = user["imageFile"] as? PFFile {
                                
                                // Obtenemos la imagen del usuario
                                imageArchivo.getDataInBackground { (data, error) in
                                    // Comprobammos que haya resultado
                                    if let data = data {
                                        // Asignamos la imagen que viene de Parse al objeto de usuario logueado
                                        myUser.image = UIImage(data: data)
                                    }
                                }
                            }

                            
                            // Declaramos una query para la entidad UserFriend de Parse
                            let query = PFQuery(className: "UserFriends")
                            
                            //Filtramos por el Usuario asignando el usuario logueado
                            query.whereKey("idUser", equalTo:(PFUser.current()?.objectId)!)
                            
                            //Filtramos por el Usuario asignando el usuario que viene en myUser
                            query.whereKey("idUserFriend", equalTo: myUser.objectID)
                            
                            // Realizamos la consulta
                            query.findObjectsInBackground(block: { (objects, error) in
                                
                                if error != nil {
                                    print(error?.localizedDescription)
                                } else {
                                    
                                    // Comprobamos que vengan resultados
                                    if let objects = objects {
                                        
                                        if objects.count > 0 {
                                            // Si es mayor a 0 significa que son amigos
                                            myUser.isFriend = true
                                        }
                                        
                                        // Recargamos la tabla
                                        //self.tableView.reloadData()
                                        
                                        // Paramos el refreshControl
                                        //self.refreshControl?.endRefreshing()
                                        
                                    }
                                    
                                }
                                
                                
                            })
                            
                            // Agregamos el array de usuarios en Parse al aRRAY de la clase Users
                            self.users.append(myUser)
                            
                        }
                        
                    }
                }
                
                // Enviamos una notificacion que los usuarios ya estan cargados
                NotificationCenter.default.post(name: UserFactory.notificationName, object: nil)
                
                // Recargamos la tabla
                //self.tableView.reloadData()
                
            }
            
        })
        
    }

    // Funcion para buscar un usuario
    func findUser(idUser: String) -> User? {
        
        // Recorremos el array de usuarios
        for user in self.users {
            
            // Si el id del usuario es el que viene en e for lo retornamos
            if user.objectID == idUser {
                return user
            }
            
            
        }
        
        return nil
    }
    
    // Funcion que devuelve un usuario dada una posicion
    func findUserAt(index: Int) -> User? {
        
        if index>=0 && index < self.users.count {
            return self.users[index]
        }
        
        return nil
    }
    
    
}
