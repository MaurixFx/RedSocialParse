//
//  PostViewController.swift
//  PetWorldMap
//
//  Created by Mauricio Figueroa Olivares on 02-05-17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var imagePost: UIImageView!
    
    var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Asignamos el delegado
        self.textView.delegate = self
        // Llamamos a la funcion que esconde el teclado cuando se presiona afuera
        self.hidesKeyboardWhenTappingArround()
        
     
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func uplodadImage(_ sender: UIButton) {
    
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
            self.imagePost.image = image
        }
        
        // Cerramos el imagePickerController
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func publish(_ sender: UIButton) {
        
        // Iniciamos el activity Indicator
        self.startActivityIndicator()
        
        // Declaramos el objeto de la entidad Post de Parse
        let post = PFObject(className: "Post")
        // Asignamos el usuario logueado que hace el POST
        post["idUser"] = PFUser.current()?.objectId
        // Asignamos el mensaje
        post["Message"] = self.textView.text
        
        // Declaramos la imagen como JPEG
        let imageData = UIImageJPEGRepresentation(self.imagePost.image!, 0.8)
        let imageFile = PFFile(name: "image.jpg", data: imageData!)
        
        post["imageFile"] = imageFile
        
        // Guardamos el Post en Parse
        post.saveInBackground { (success, error) in
            
            // Paramos el activity
            self.stopActivityIndicator()
            
            if error != nil {
                self.sendAlert(tittle: "No se ha guardado el Post", message: (error?.localizedDescription)!)
            } else {
                 self.sendAlert(tittle: "Imagen Publicada", message: "Tu Post se ha publicado correctamente")
                
                // Vaciamos el TextView y dejamos la imagen por defecto
                self.textView.text = ""
                self.imagePost.image = #imageLiteral(resourceName: "send-photo")
            }
        }
        
    }

    func sendAlert(tittle: String, message: String) {
        
        let alertController = UIAlertController(title: tittle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func startActivityIndicator() {
        // ActivityIndicator
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        // Lo centramos
        self.activityIndicator.center = self.view.center
        //Lo ocultamos cuando lo paremos
        self.activityIndicator.hidesWhenStopped = true
        // Le damos un estilo gris
        self.activityIndicator.activityIndicatorViewStyle = .whiteLarge
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

extension PostViewController {
    
    // Funcion para esconder el teclado al presionar afuera
    func hidesKeyboardWhenTappingArround() {
        // Declaramos un gestureRecognizer
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostViewController.dismissKeyboard))
        
        self.view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

// Implementamos la extension para que se oculte el teclado al presion intro
extension PostViewController : UITextViewDelegate {
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    
}
