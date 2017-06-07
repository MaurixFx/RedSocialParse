//
//  PerfilViewController.swift
//  PetWorldMap
//
//  Created by Mauricio Figueroa Olivares on 01-05-17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class PerfilViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet var menuButton: UIBarButtonItem!
    
    @IBOutlet var imagePerfil: UIImageView!
    
    @IBOutlet var nameTextfield: UITextField!
    
    @IBOutlet var sexo: UISwitch!
    
    @IBOutlet var genderLabel: UILabel!
    
    @IBOutlet var birthdayLabel: UIButton!
    
    var user: User?
    
    var activityIndicator: UIActivityIndicatorView!
    
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
        
        // Asignamos el delegado al textfiELD
        self.nameTextfield.delegate = self
        
        // Declaramos el usuario y lo obtenemos el usuario logueado desde la factoria
        user = UserFactory.sharedInstance.currentUser!
        
        self.nameTextfield.text = user?.name
        
        // Si existe imagen la asignamos
        if let image = user?.image {
            self.imagePerfil.image = image
        }else {
            self.imagePerfil.image = #imageLiteral(resourceName: "no-friend")
        }
        
        // Si la fecha de nacimiento no es nula la asignamos
        if let birthday =  user?.birthDate {
            self.birthdayLabel.setTitle("\(String(describing: birthday))", for: .normal)
        } else {
            self.birthdayLabel.setTitle("Desconocida", for: .normal)
        }
        
        // Si el genero es distinto de nulo lo asignamos
        if let gender = user?.gender {
            
            // Si es hombre
            if gender == true {
                self.sexo.isOn = true
                self.genderLabel.text = "Hombre"
            } else {
                self.sexo.isOn = false
                self.genderLabel.text = "Mujer"
            }
        } else {
            self.genderLabel.text = "Desconocido"
        }
        
        self.nameTextfield.text = user?.name
        
        self.imagePerfil.layer.cornerRadius = 120.0 // Se asigna la mitad del tamaño de la imagen de la celda
        self.imagePerfil.clipsToBounds = true // Recorta los bordes de la imagen de la celda
        
        // Do any additional setup after loading the view.
    }
    
    // Cuando aparesca la pantalla
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Declaramos el usuario y lo obtenemos el usuario logueado desde la factoria
        user = UserFactory.sharedInstance.currentUser!
            
        // Si existe imagen la asignamos
        if let image = user?.image {
            self.imagePerfil.image = image
        }else {
            self.imagePerfil.image = #imageLiteral(resourceName: "no-friend")
        }
        
        // Si la fecha de nacimiento no es nula la asignamos
        if let birthday =  user?.birthDate {
            // Formateamos la fecha
            let formater = DateFormatter()
            formater.dateStyle = .short
            formater.timeStyle = .none
            
            self.birthdayLabel.setTitle("\(String(describing: formater.string(from: birthday)))", for: .normal)
        } else {
            self.birthdayLabel.setTitle("Desconocida", for: .normal)
        }
        
        // Si el genero es distinto de nulo lo asignamos
        if let gender = user?.gender {
            
            // Si es hombre
            if gender == true {
                self.sexo.isOn = true
                self.genderLabel.text = "Hombre"
            } else {
                self.sexo.isOn = false
                self.genderLabel.text = "Mujer"
            }
        } else {
            self.genderLabel.text = "Desconocido"
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        PFUser.logOut()
        performSegue(withIdentifier: "Logout", sender: nil)
        
    }
    
    
    @IBAction func newPhoto(_ sender: UIButton) {
        
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
            // Asignamos la imagen
            //self.imagePerfil.image = image
            self.user?.image = image
        }
        
        // Cerramos el imagePickerController
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // Accion que se ejecuta cuando se mueve el switch
    @IBAction func swichGender(_ sender: UISwitch) {
        self.user?.gender = self.sexo.isOn
        
        if self.sexo.isOn {
            self.genderLabel.text = "Hombre"
        } else {
            self.genderLabel.text = "Mujer"
        }
    
    }
    
    
    @IBAction func saveToPerfil(_ sender: UIButton) {
        
        //Iniciamos el ActiviIndicator
        self.startActivityIndicator()
        
        // Declaramos un objeto de la clase User de Parse
        let pfuser = PFUser.current()!
        
        // Llenamos los datos a actualizar
        pfuser["nickname"] = self.nameTextfield.text!
        pfuser["gender"] = self.user?.gender
        pfuser["birthdate"] = user?.birthDate
        
        // Pasamos la imagen a Data
        let imageData = UIImageJPEGRepresentation(self.imagePerfil.image!, 0.8)
        // Transformamos la imagen a tipo PFFile de Parse
        let imageFile = PFFile(name: pfuser.username!+".jpg", data: imageData!)
        pfuser["imageFile"] = imageFile
        
        
        pfuser.saveInBackground { (success, error) in
            
            //Paramos el ActiviIndicator
            self.stopActivityIndicator()
            
            // Si el guardado fue exitoso
            if success {
                let alert = UIAlertController(title: "Usuario Actualizado", message: "El perfil ha sido actualizado.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    func startActivityIndicator() {
        // ActivityIndicator
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
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



}

// Implementamos esta extension para esconder el teclado
extension PerfilViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
