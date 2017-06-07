//
//  UserLocationViewController.swift
//  PetWorldMap
//
//  Created by Mauricio Figueroa Olivares on 10-05-17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import MapKit

class UserLocationViewController: UIViewController {
    
    
    @IBOutlet var mapView: MKMapView!
    
    // Declaramos el objeto de la clase User
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Declaramos un radio de 1000 metros
        let regionRadius: CLLocationDistance = 1000
        
        // Construimos la region a partir de las coordenadas del usuario y el radio de 1000 metros
        let coordinateRegion = MKCoordinateRegionMakeWithDistance((self.user?.location)!, regionRadius, regionRadius)
        
        // La asignamos la region al Mapa
        self.mapView.setRegion(coordinateRegion, animated: true)
    
        // Declaramos una anotacion
        let annotation = MKPointAnnotation()
        annotation.title = self.user?.name
        annotation.subtitle = "\(String(describing: self.user?.location!))"
        annotation.coordinate = (self.user?.location)!  // Asignamos las coordenadas a la anotacion
        // Asignamos las coordenadas al Mapa
        self.mapView.showAnnotations([annotation], animated: true)
        // Seleccionamos la anotation en el mapa
        self.mapView.selectAnnotation(annotation, animated: true)
    
        
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

extension UserLocationViewController: MKMapViewDelegate {
    
    // Configuramos los pinchos del Mapa
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "MyPin"
        
        // Si es la anotacion propia del usuario no hacemos nada
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        var annotationView : MKPinAnnotationView? = self.mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            // Creamos la annotationView
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        }
        
        // Creamos la imagen para el pincho y asignamos la del usuario
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 52, height: 52))
        imageView.image = self.user?.image
        // Asignamos la imagen al pincho
        annotationView?.leftCalloutAccessoryView = imageView
    
        return annotationView
    }
    
}
