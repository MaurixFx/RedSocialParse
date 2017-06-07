/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    
    @IBOutlet var emailTextfield: UITextField!
    
    @IBOutlet var passwordTextfield: UITextField!
    
    var activityIndicator : UIActivityIndicatorView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Descomenta esta linea para probar que Parse funciona correctamente
        //self.testParseSave()
        
        // Declaramos una variable de objeto para Users
     /*   let user = PFObject(className: "Users")
        
        user["name"] = "Mauricio"
        
        user.saveInBackground { (success, error) in
            // Si hubo exito en la conexion
            if success {
                print("El usuario se guardo correctamente")
            } else {
                
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    print("Error desconocido")
                }
                
                
            }
        }*/
        
        // Devuelve todos los objetos de la clase Users
       /* let query = PFQuery(className: "Users")
        
        
        // Esto se ejecuta en segundo plano
        query.getObjectInBackground(withId: "FgSaszR3uD") { (object, error) in
            
            if error != nil {
                print(error?.localizedDescription)
            } else {
                
                // Si el objeto de User no es nulo asignamos
                if let user = object {
                    print(user)
                    print(user["name"])
                    
                    user["name"] = "Esteban Paredes"
                    
                    user.saveInBackground(block: { (success, error) in
                        
                        if success {
                            
                            print("Se modifico el nombre correctamente")
                            print(user["name"])
                        }
                    })
                    
                    
                }
            }
            
        }*/
        
        
    }
    
    // Esto se ejecuta cuando entramos en la app y aun tenemos session
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Comprobamos si tiene sesion
        if PFUser.current()?.username != nil {
            self.performSegue(withIdentifier: "goToMainVC", sender: nil)
        }
        
        // Ocultamos la barra de navegacion
        self.navigationController?.navigationBar.isHidden = true
        
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        
        if infoCompleted() {
        
            // Procedemos a registrar al usuario
        
            // Iniciamos el ActivityIndicator
            self.startActivityIndicator()

            // Declaramos el objeto de la clase user
            let user = PFUser()
            
            // Mapeamos el objeto
            user.username = self.emailTextfield.text
            user.email = self.emailTextfield.text
            user.password = self.passwordTextfield.text
            
            // Configuramos los permisos al usuario
            let acl = PFACL()
            acl.getPublicReadAccess = true
            acl.getPublicWriteAccess = true
            user.acl = acl

            // Logueamos el usuario
            user.signUpInBackground(block: { (success, error) in
                
                // Paramos el activityIndicator
               self.stopActivityIndicator()
                
                
                // Si el error es distinto de nulo lo mostramos
                if error != nil {
                    
                    var errorMessage = "Intentalo de nuevo, a habido un error de registro"
                    
                    if let parseError = error?.localizedDescription {
                        errorMessage = parseError
                    }
                    
                    // Enviamos la alerta
                    self.createAlert(title: "Error de registro", message: errorMessage)
                    
                } else {
                    print("usuario registrado correctamente")
                    self.performSegue(withIdentifier: "goToMainVC", sender: nil)
                }
                
            })
            
            
            
        }
    }
    

    @IBAction func loginPressed(_ sender: UIButton) {
        
        if infoCompleted() {
            
            // Iniciamos el activity Indicator
            self.startActivityIndicator()
            
            // Procedemos a loguear al usuario
            PFUser.logInWithUsername(inBackground:self.emailTextfield.text!, password: self.passwordTextfield.text!, block: { (user, error) in
                
                // Detenemos el activity Indicator
                self.stopActivityIndicator()
                
                // Si el error es distinto de nil lo mostramos
                if error != nil {
                    
                    var errorMessage = "Intentalo de nuevo, a habido un error de login"
                    
                    if let parseError = error?.localizedDescription {
                        errorMessage = parseError
                    }
                    
                    // Enviamos la alerta
                    self.createAlert(title: "Error de login", message: errorMessage)

                    
                } else {
                    
                    print("Hemos entrado al sistema")
                    self.performSegue(withIdentifier: "goToMainVC", sender: nil)
                }
            })
            
        }
    }
    
    func createAlert(title: String, message: String) {
        // Creamos la alerta
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        // Presentamos la alerta
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
    
    
    @IBAction func recoveryPassword(_ sender: UIButton) {
    }
    
    
    func infoCompleted() -> Bool {
        
        var infocompleted = true
        
        // Si no escribe un email o contraseña
        if self.emailTextfield.text == "" || self.passwordTextfield.text == "" {
            infocompleted = false
            
            // Enviamos la alerta
            self.createAlert(title: "Verifica tus datos", message: "Asegurate de escribir un email y una contraseña")
        }
        
        return infocompleted
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

// Implementamos esta extension para esconder el teclado
extension LoginViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
