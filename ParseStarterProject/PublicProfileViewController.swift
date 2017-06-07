//
//  PublicProfileViewController.swift
//  PetWorldMap
//
//  Created by Mauricio Figueroa Olivares on 08-05-17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class PublicProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var userNameLabel: UILabel!
    
    @IBOutlet var birDateLabel: UILabel!

    @IBOutlet var friendButton: UIButton!
    
    @IBOutlet var tableView: UITableView!
    // Objeto de User
    var user: User?
    
    // Objeto de Posts
    var post: [Post] = []
    
    var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Si viene imagen en el objeto lo asignamos
        if let image = user?.image {
            self.userImageView.image = image
        } else {
            self.userImageView.image = #imageLiteral(resourceName: "no-friend")
        }
        
        // Asignamos el Username
        if let userName = user?.name {
            self.userNameLabel.text = userName
        }
        
        // Asignamos la fecha de nacimiento si es que tiene
        let formater = DateFormatter()
        formater.dateStyle = .medium
        formater.timeStyle = .none
        if let Birdate = user?.birthDate {
            self.birDateLabel.text = "Fecha de Nacimiento:" + formater.string(from: Birdate)
        } else {
            self.birDateLabel.text = "Fecha de nacimiento Desconocida"
        }
        
        // Asignamos el generp
        if let gender = user?.gender {
            if gender {
              self.friendButton.setImage(#imageLiteral(resourceName: "friend-male"), for: .normal)
            } else {
              self.friendButton.setImage(#imageLiteral(resourceName: "friend-female"), for: .normal)
            }
            
        }
        
        // Cargamos los Post del usuario
        self.requestPosts()

        // Creamos un refreshControl
        self.tableView.refreshControl = UIRefreshControl()
        // Asignamos un titulo al refresh
        self.tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Tira para recargar nuevas Publicaciones")
        //Agregamos la vista y el metodo cargar Usuarios
        self.tableView.refreshControl?.addTarget(self, action: #selector(PublicProfileViewController.requestPosts), for: .valueChanged)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Funcion para recuperar todos los Posts
    func requestPosts() {
        
        // Declaramos la query a la entidad Post de Parse
        let query = PFQuery(className: "Post")
        
        // Filtramos para que se muestren los Post del usuario logueado
        query.whereKey("idUser", equalTo: (user?.objectID)!)
        
        // Ordenamos descendente por la fecha de creación
        query.order(byDescending: "createdAt")
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                // Si existe
                if let objects = objects {
                    
                    //Limpiamos todos los Post
                    self.post.removeAll()
                    
                    // Recorremos los objetos
                    for object in objects {
                        
                        let objectID = object.objectId!
                        let creationDate = object.createdAt!
                        let message = object["Message"] as! String
                        
                        // Obtenemos los like del post
                        var likesPost: Int?
                        
                        if let numberLikes = object["numberLikes"] as? Int {
                            likesPost = numberLikes
                        } else {
                            likesPost = 0
                        }
                        
                        // Declaramos el objeto de la Clase Post
                        // Le pasamos los parametros Obligatorios
                        let post : Post = Post(objectID: objectID, message: message, image: nil, user: nil, creationDate: creationDate, numberLikes: likesPost)
                        
                        // Obtenemos la posicion que quedara el nuevo Post en el array
                        let postPosicion = self.post.count
                        
                        // Asignamos el usuario del Post
                        post.user = self.user
                        
                        // Agregamos los datos al array de Post
                        self.post.append(post)
                        
                        // Asignamos la imagen de la entidad Post de Parse
                        let imageFile = object["imageFile"] as! PFFile
                        // Obtenemos la imagen desde Parse
                        imageFile.getDataInBackground(block: { (data, error) in
                            // Comprobamos que si hay datos
                            if let data = data {
                                let downloadedImage = UIImage(data: data)
                                
                                // Agregamos la imagen en el array de Post
                                // En la posicion donde estan los demas datos del Post
                                self.post[postPosicion].image = downloadedImage
                                
                                // Paramos el refreshControl
                                self.tableView.refreshControl?.endRefreshing()
                                
                                //Recargamos la tabla
                                self.tableView.reloadData()
                            }
                        })
                        
                    }
                }
                
                
            }
            
            
        }
        
        
    }

    
    @IBAction func friendButton(_ sender: UIButton) {
        
        // Le indicamos que ya no somos amigos
        self.user?.isFriend = false
        
        // Declaramos la query
        let query = PFQuery(className: "UserFriends")
        
        // Filtramos Asignando el ID del usuario logueado
        query.whereKey("idUser", equalTo: (PFUser.current()?.objectId)!)
        
        // Asignamos el ID del usuario seleccionado que queremos ser amigo
        query.whereKey("idUserFriend", equalTo: (self.user?.objectID)!)
        
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
        
        // Como ya no somos amigos cambiamos la imagen del boton 
        self.friendButton.setImage(#imageLiteral(resourceName: "no-friend"), for: .normal)

    }
    
    @IBAction func chatFriend(_ sender: UIButton) {
    }
    
    
    @IBAction func findFriend(_ sender: UIButton) {
    }
    
    
    @IBAction func sendPicture(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Selecciona una imagen", message: "¿De donde deseas seleccionar la imagen?", preferredStyle: .actionSheet)
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action) in
            self.loadFromLibrary()
        }
        
        let CameraAction = UIAlertAction(title: "Toma una Foto", style: .default) { (action) in
            self.takePhoto()
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alertController.addAction(libraryAction)
        alertController.addAction(CameraAction)
        alertController.addAction(cancelAction)
        
        //Presentamos la alerta en pantalla
        self.present(alertController, animated: true, completion: nil)
    }
    
    func loadFromLibrary() {
        // Declaramos un imagePicker para la seleccion de las fotos
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self // Asignamos el delegado
        // Asignamos la libreria como source de donde se sacaran las fotos
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false // No dejamos editar
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func takePhoto() {
        // Declaramos un imagePicker para la seleccion de las fotos
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self // Asignamos el delegado
        // Asignamos como source la camara porque sacaremos la foto
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false // No dejamos editar
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    // Funcion que retorna la imagen seleccionada
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // Si la imagen no es nula
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            // Iniciamos el activityIndicator
            self.startActivityIndicator()
            
            // Asignamos la imagen
           // self.imagePost.image = image
            
            // Creamos la clase en Parse DirectImage
            let directImage = PFObject(className: "DirectImage")
            // Asignamos la imagen
            directImage["image"] = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(image, 0.8)!)
            // Usuario que envia el que esta logueado
            directImage["idUserSender"] = UserFactory.sharedInstance.currentUser?.objectID
            // Usuario que recibe
            directImage["idUserReceiver"] = self.user?.objectID
            
            // Configuramos los permisos
            let acl = PFACL()
            acl.getPublicReadAccess = true
            acl.getPublicWriteAccess = true
            directImage.acl = acl
            
            
            directImage.saveInBackground(block: { (success, error) in
                // Paramos el activityIndicator
                self.stopActivityIndicator()
                
                var title = "Envío Fallido"
                var message = "Por favor, inténtalo de nuevo más tarde"
               
                // Si hubo exito al enviar
                if success {
                    title = "Imagen enviada"
                    message = "Tu imagen se ha enviado correctamente"
                    self.sendAlert(tittle: title, message: message)
                } else {
                    self.sendAlert(tittle: title, message: message)
                }
            })
            
        }
        
        // Cerramos el imagePickerController
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // Funcion para enviar alertas
    func sendAlert(tittle: String, message: String) {
        let alertController = UIAlertController(title: tittle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func startActivityIndicator() {
        // ActivityIndicator
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        // Lo centramos
        self.activityIndicator.center = self.view.center
        //Lo ocultamos cuando lo paremos
        self.activityIndicator.hidesWhenStopped = true
        // Le damos un estilo gris
        self.activityIndicator.activityIndicatorViewStyle = .gray
        // Lo agregamos a la vista
        self.view.addSubview(self.activityIndicator)
        //Activamos el activityIndicator
        self.activityIndicator.startAnimating()
        
        
        // No permitimos que se ejecute otra accion en pantalla
        UIApplication.shared.beginIgnoringInteractionEvents()
        
    }
    
    func stopActivityIndicator(){
        self.activityIndicator.stopAnimating()
        // Activamos los eventos en pantalla
        UIApplication.shared.endIgnoringInteractionEvents()
    }

    // Funcion de segue para pasar a las otras pantallas
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showUserLocation" {
            // ViewController de destino
            let destinationVC = segue.destination as! UserLocationViewController
            // Le pasamos el usuario
            destinationVC.user = self.user
            
        }
    }
    
    
    
    
}


extension PublicProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.post.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCellPerfil", for: indexPath) as! FeedTableViewCell
        
        // Asignamos la fila del Post
        let post = self.post[indexPath.row]
        //Creamos un formateador de fecha
        let formater = DateFormatter()
        //Damos el formato de fecha y hora
        formater.dateStyle = .medium
        formater.timeStyle = .short
        
        cell.dateLabel.text = formater.string(from: post.creationDate) // Asignamos la Fecha
        cell.contentLabel.text = post.message // Asignamos el mensaje
        
        // Si el usuario del post no es nulo
        if post.user != nil {
            // Asignamos el nombre
            cell.nameUserLabel.text = post.user?.name.capitalized
            
            // Agregamos la imagen
            //Nos aseguramos que venga una imagen
            if let image = post.user?.image {
                cell.userImageView.image = image
                cell.userImageView.layer.cornerRadius = 25.0 // Se asigna la mitad del tamaño de la imagen de la celda
                cell.userImageView.clipsToBounds = true // Recorta los bordes de la imagen de la celda
                
            }
        }
        
        // Si la imagen del post no es nulo
        if post.image != nil {
            // Asignamos la imagen
            cell.postImageView.image = post.image
        }
        
  
        return cell
    
    }
}
