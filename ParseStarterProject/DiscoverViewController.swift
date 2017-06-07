//
//  DiscoverViewController.swift
//  PetWorldMap
//
//  Created by Mauricio Figueroa Olivares on 01-05-17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import MapKit

class DiscoverViewController: UIViewController {

    @IBOutlet var menuButton: UIBarButtonItem!
    
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


        // Do any additional setup after loading the view.
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
