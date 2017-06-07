//
//  ComentsViewController.swift
//  PetWorldMap
//
//  Created by Mauricio Figueroa Olivares on 11-05-17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse



class ComentsViewController: UITableViewController {
    
    
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var sendComent: UIButton!
    
    // Declaramos un objeto de la clase Post con el cual recibimos de la pantalla FeedViewController
    var post: Post?
    
    // Declaramos un objeto array de la clase Comments
    var coments : [Coments] = []
    
    
    let placeholder : String =  "Añade un comentario"
    let placeholderColor : UIColor = UIColor.lightGray
    let textviewColor: UIColor = UIColor.black
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        textView.delegate = self
        textView.text = placeholder
        textView.textColor = placeholderColor
        
        // Cargamos los comentarios
        self.requestComents()
        
        tableView.estimatedRowHeight = 140.0 // Declaramos un tamaño por defecto a la celda
        
        tableView.rowHeight = UITableViewAutomaticDimension  // Agregamos esto para que se autodimensione de forma automatica
        
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.estimatedRowHeight = 140.0 // Declaramos un tamaño por defecto a la celda
        
        self.tableView.rowHeight = UITableViewAutomaticDimension  // Agregamos esto para que se autodimensione de forma automatica
    }
    
    func requestComents() {
        // Declaramos la query a la entidad Coments de Parse
        let query = PFQuery(className: "Coments")
        
        // Filtramos para que no se muestren los Post del usuario logueado
        query.whereKey("idPost", equalTo: (self.post?.objectID)!)
        
        // Ordenamos ascendente por la fecha de creación
        query.order(byAscending: "createdAt")
        
        
        query.findObjectsInBackground { (objects, error) in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                // Si existe
                if let objects = objects {
                    
                    //Limpiamos todos los Post
                    self.coments.removeAll()
                    
                    // Recorremos los objetos
                    for object in objects {
                        
                        let objectID = object.objectId!
                        let creationDate = object.createdAt!
                        let message = object["Message"] as! String
                        
                        // Declaramos el objeto de la Clase Coments
                        // Le pasamos los parametros Obligatorios
                        let coment : Coments = Coments(objectID: objectID, message: message, user: nil, post: self.post, creationDate: creationDate)
                        
                        // Obtenemos la posicion que quedara el nuevo comentario en el array
                        let comentPosicion = self.coments.count
                        
                        // Agregamos los datos al array de comentarios
                        self.coments.append(coment)
                        
                        // Asignamos el id del usuario
                        let idUser = object["idUser"] as! String
                        
                       
                        // Si es el usuario logueado lo obtenemos del currentUser
                        if idUser == UserFactory.sharedInstance.currentUser?.objectID {
                            // Agregamos el usuario en el array de Comentarios
                            // En la posicion donde estan los demas datos del comentario
                            self.coments[comentPosicion].user = UserFactory.sharedInstance.currentUser
                        } else {
                            
                            // Utilizamos la factoria de usuarios
                            // Buscamos el usuario con el metodo findUser
                            // Si user no es nulo agregamos el usuario en el array
                            if let user = UserFactory.sharedInstance.findUser(idUser: idUser) {
                                
                                // Agregamos el usuario en el array de Comentarios
                                // En la posicion donde estan los demas datos del comentario
                                self.coments[comentPosicion].user = user
                                
                            }
                        }
                        
                        
                        // Paramos el refreshControl
                        self.tableView.refreshControl?.endRefreshing()
                        
                        //Recargamos la tabla
                        self.tableView.reloadData()
                        
                        
                    }
                }
                
                
            }
            
            
        }


    }
    
    
    @IBAction func sendComents(_ sender: Any) {
        
        // Declaramos el objeto de la entidad Coments de Parse
        let coments = PFObject(className: "Coments")
        
        // Asignamos el usuario logueado que hace el comentario
        coments["idUser"] = PFUser.current()?.objectId
        
        // Asignamos el usuario logueado que hace el comentario
        coments["idPost"] = self.post?.objectID

        // Asignamos el mensaje
        coments["Message"] = self.textView.text
        
        
        // Guardamos el Post en Parse
        coments.saveInBackground { (success, error) in
            
            if error != nil {
                (error?.localizedDescription)!
            } else {
                // Vaciamos el TextView y dejamos la imagen por defecto
                self.textView.text = ""
                self.requestComents()
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComentsCell") as! ComentsTableViewCell
        
        cell.nameUserLabel.text = self.coments[indexPath.row].user?.name
        cell.imageUserView.image = self.coments[indexPath.row].user?.image
        
        cell.imageUserView.layer.cornerRadius = 30.0
        cell.imageUserView.clipsToBounds = true
        cell.contentPostText.text = self.coments[indexPath.row].message

        return cell
        
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

extension ComentsViewController : UITextViewDelegate {
    
    // Justo cuando el usuario empieza a editar
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == placeholder {
            textView.text = ""
            textView.textColor = textviewColor
        }
        
        textView.becomeFirstResponder()
        
    }
    
    // Cuando finaliza la edicion del textField
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            textView.text = placeholder
            textView.textColor = placeholderColor
        }
        
        // Hemos acabado la edicion
        textView.resignFirstResponder()
        
    }
    
    
}




