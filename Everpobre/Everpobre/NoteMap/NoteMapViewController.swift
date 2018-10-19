//
//  NoteMapViewController.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 18/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//

import UIKit
import MapKit

protocol NoteMapViewControllerDelegate: class {
    func didChangeLocation(coordinate: CLLocationCoordinate2D)
}

class NoteMapViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    var location: Location?
    weak var delegate: NoteMapViewControllerDelegate?
    
    // MARK: - Initialization
    init(location: Location?) {
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Localización"
        
        var initialLocation: CLLocationCoordinate2D
        if let location = location {
            initialLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            addAnnotation(coordinate: initialLocation)
        } else {
            // TODO: Localize user position
            initialLocation = CLLocationCoordinate2D(latitude: 40.4192500, longitude: -3.6932700)
        }
        
        let regionRadius: CLLocationDistance = 1000
        
        let region = MKCoordinateRegion(
            center: initialLocation,
            latitudinalMeters: regionRadius,
            longitudinalMeters: 1000)
        
        mapView.setRegion(region, animated: true)
        
        mapView.delegate = self
    }
    
    private func addAnnotation(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Localización de la nota"
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
    }
       
    
    @IBAction func addPoint(_ sender: UILongPressGestureRecognizer) {
        let mapLocation = sender.location(in: mapView)
        let coordinate = self.mapView.convert(mapLocation, toCoordinateFrom: mapView)
        
        delegate?.didChangeLocation(coordinate: coordinate)
        
        addAnnotation(coordinate: coordinate)
    }
    
    // TODO: Remove location
}


extension NoteMapViewController: MKMapViewDelegate {

}
