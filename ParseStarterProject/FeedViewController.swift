//
//  FeedViewController.swift
//  PetWorldMap
//
//  Created by Mauricio Figueroa Olivares on 01-05-17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UIViewController {
    
    @IBOutlet var menuButton: UIBarButtonItem!
    
    @IBOutlet var tableView: UITableView!
        
    
    // Declaramos un objeto de la clase Post
    var posts : [Post] = []
    
    // Declaramos un objeto de la clase usuario
    var user: User?
    
    //Declaramos un Timer
    var timer = Timer()
    
    var filaSeleccionada: Int?
    
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
        self.tableView.refreshControl = UIRefreshControl()
        // Asignamos un titulo al refresh
        self.tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Tira para recargar nuevas Publicaciones")
        //Agregamos la vista y el metodo cargar Usuarios
        self.tableView.refreshControl?.addTarget(self, action: #selector(FeedViewController.requestPosts), for: .valueChanged)
        
       
        // Inicializamos el Timer
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(FeedViewController.askForDirectPhotos), userInfo: nil, repeats: true)
        
    }
    
    // Funcion para recuperar las fotos de mensajes
    func askForDirectPhotos() {
        
        // Declaramos una query
        let query = PFQuery(className: "DirectImage")
        // Filtramos para el usuario que recive
        query.whereKey("idUserReceiver", equalTo: (PFUser.current()?.objectId)!)
        
        do {
            // Obtenemos un array de resultados
            let images = try query.findObjects()
            
            // Si es mayor que 0
            if images.count > 0 {
                // Obtenemos la primera
                let image = images.first!
                
                var receiver : User? = nil
                // Comprobamos que exista el usuario que envia
                if let idUserSender = image["idUserSender"] as? String {
                    receiver = UserFactory.sharedInstance.findUser(idUser: idUserSender)
                }
                
                // Si existe imagen
                if let pfFile = image["image"] as? PFFile {
                    
                    // Obtenemos la imagen
                    pfFile.getDataInBackground(block: { (data, error) in
                        
                        // Si fue exitoso
                        if let imageData = data {
                            // Paramos el timer
                            self.timer.invalidate()
                            
                            // Eliminamos de Parse
                            image.deleteInBackground()
                            
                            // Si podemos mostrar la imagen
                            if let imageToShow = UIImage(data: imageData) {
                                
                                // Enviamos una alerta
                                let alert = UIAlertController(title: "Tienes un nuevo mensaje", message: "Has recibido un mensaje de: \(String(describing: (receiver?.name)!))", preferredStyle: .alert)
                                
                                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    
                                    // Declaramos un fondo
                                    let backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                                    // Asignamos el color negro
                                    backgroundImageView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                                    // Agregamos transparencia
                                    backgroundImageView.alpha = 0.8
                                    
                                    // Agregamos un tag como identificador
                                    backgroundImageView.tag = 20
                                    
                                    //Añadimos el fondo
                                    self.view.addSubview(backgroundImageView)
                                    
                                    // Definimos la zona de la imagen
                                    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                                    // Asignamos la imagen que recuperamos de Parse
                                    imageView.image = imageToShow
                                    imageView.contentMode = .scaleToFill  // Definimos un modo a la imagen
                                    imageView.clipsToBounds = true
                                    
                                    // Agregamos un identificador a la imagen
                                    imageView.tag = 20
                                    
                                    // Agregamos la imagen en pantalla
                                    self.view.addSubview(imageView)
                                    
                                    // Ejecutamos un timer para que elimine la imagen y el background de pantalla
                                    _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                                        
                                        // Reiniciamos el timer
                                          self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(FeedViewController.askForDirectPhotos), userInfo: nil, repeats: true)
                                        
                                        // Recorremos los elementos de la vista
                                        for v in self.view.subviews {
                                            // Si tienen el tag 20 se eliminan de la vista
                                            if v.tag == 20 {
                                                v.removeFromSuperview()
                                            }
                                        }
                                        
                                    })
                                    
                                })
                                
                                alert.addAction(alertAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        }
                        
                    })
                }
            }
            
        }catch {
            print("Ha habido un error")
        }
        
        
        
        
    }
    
    // Funcion para recuperar todos los Posts
    func requestPosts() {
        
        // Declaramos la query a la entidad Post de Parse
        let query = PFQuery(className: "Post")
        
        // Filtramos para que no se muestren los Post del usuario logueado
        query.whereKey("idUser", notEqualTo: (PFUser.current()?.objectId)!)
        
        // Ordenamos descendente por la fecha de creación
        query.order(byDescending: "createdAt")
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                // Si existe
                if let objects = objects {
                    
                    //Limpiamos todos los Post
                    self.posts.removeAll()
                    
                    // Recorremos los objetos
                    for object in objects {
                        
                        let objectID = object.objectId!
                        let creationDate = object.createdAt!
                        let message = object["Message"] as! String
                        
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
                         let postPosicion = self.posts.count
                        
                        // Agregamos los datos al array de Post
                        self.posts.append(post)
                        
                        let idUser = object["idUser"] as! String
                        
                        // Utilizamos la factoria de usuarios
                        // Buscamos el usuario con el metodo findUser
                        
                        // Si user no es nulo agregamos el usuario en el array
                        if let user = UserFactory.sharedInstance.findUser(idUser: idUser) {
                            
                            // Agregamos el usuario en el array de Post
                            // En la posicion donde estan los demas datos del Post
                            self.posts[postPosicion].user = user
                            
                            //Recargamos la tabla
                            //self.tableView.reloadData()
                       /* } else {
                            
                            // Si el usuario es nulo, quiere decir que es el usuario logueado
                            let UserName = PFUser.current()?.username?.components(separatedBy: "@")[0]
                            
                            // Agregamos el usuario en el array de Post
                            // En la posicion donde estan los demas datos del Post
                            self.posts[postPosicion].user = User(objectID: (PFUser.current()?.objectId)!, name: UserName!, email: (PFUser.current()?.username)!)
                        */
                        }
                        

                        // Asignamos la imagen de la entidad Post de Parse
                        let imageFile = object["imageFile"] as! PFFile
                        // Obtenemos la imagen desde Parse
                        imageFile.getDataInBackground(block: { (data, error) in
                            // Comprobamos que si hay datos
                            if let data = data {
                                let downloadedImage = UIImage(data: data)

                                // Agregamos la imagen en el array de Post
                                // En la posicion donde estan los demas datos del Post
                                self.posts[postPosicion].image = downloadedImage
                                
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
    
    // Se ejecuta cuando la vista aparece
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Mostramos la barra de navegacion
        self.navigationController?.navigationBar.isHidden = false
        
        // Agregamos un observador de la notificacion para saber si se cargaron los Usuarios
        // Si se cargaron los usuarios ejecutamos el metodo requestPosts
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.requestPosts), name: UserFactory.notificationName, object: nil)

        // Inicializamos la instancia compartida de Usuarios
        _ = UserFactory.sharedInstance.getUser()
        
    }
    
    
    // Se ejecuta cuando la vista esta a punto de desaparecer
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Le indicamos al centro de Notificaciones que ya no estaremos atentos a los usuarios cargados
        NotificationCenter.default.removeObserver(self, name: UserFactory.notificationName, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
 
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Si el identificador es showDetail
        if segue.identifier == "showPerfilUser" {
            // Asignamos el viewController de destino
            let destinationVC = segue.destination as! PublicProfileViewController
            
            let row = filaSeleccionada
            
            print("La fila perfil en segue es \(String(describing: row))")

            let Postss = self.posts[row!]
            let UserProfile = Postss.user
            
            // Pasamos el usuario de la fila seleccionada a la siguiente pantalla
            destinationVC.user = UserProfile

            
        }
        
        // Si el identificador es showComents
        if segue.identifier == "showComents" {
            // Asignamos el viewController de destino
            let destinationVC = segue.destination as! ComentsViewController
            
            let row = filaSeleccionada
            print("La fila comentario en segue es \(String(describing: row))")
            
            let Postss = self.posts[row!]
            
            // Pasamos el usuario de la fila seleccionada a la siguiente pantalla
            destinationVC.post = Postss
            
            
        }
    }

}

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCellInicio") as! FeedTableViewCell
        
        // Asignamos la fila del Post
        let post = self.posts[indexPath.row]
        //Creamos un formateador de fecha
        let formater = DateFormatter()
        //Damos el formato de fecha y hora
        formater.dateStyle = .medium
        formater.timeStyle = .short
        
        cell.dateLabel.text = formater.string(from: post.creationDate) // Asignamos la Fecha
        cell.contentLabel.text = post.message // Asignamos el mensaje
        
        //declaramos el delegado a la celda y la fila
        cell.delegate = self
        cell.row = indexPath.row
        
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
        
        // Enviamos la fila de Post a configuracion de la celda
        cell.configureCell(post: post)
        
        return cell
    
    }
    

}

extension FeedViewController: FeedCellProtocol {
    func takePictureUser(row: Int) {
        // Asignamos la fila seleccionada a la variable global
        self.filaSeleccionada = row
        performSegue(withIdentifier: "showPerfilUser", sender: self)
    }
    
    func takePicturePostUser(row: Int) {
        // Asignamos la fila seleccionada a la variable global
        self.filaSeleccionada = row
        performSegue(withIdentifier: "showComents", sender: self)
    }
}


    
    

