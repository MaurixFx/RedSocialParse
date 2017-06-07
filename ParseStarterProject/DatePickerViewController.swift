//
//  DatePickerViewController.swift
//  PetWorldMap
//
//  Created by Mauricio Figueroa Olivares on 05-05-17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {

    @IBOutlet var datePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveDate(_ sender: UIButton) {
    
        let birthDate = self.datePicker.date
        
        // Asignamos la fecha seleccionada
        UserFactory.sharedInstance.currentUser?.birthDate = birthDate
    
        // Volvemos hacia atras
        // Eliminamos el viewController actual
       self.navigationController?.popViewController(animated: true)
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
