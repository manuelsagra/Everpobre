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
    var currentLocation: CLLocation?
    weak var delegate: NoteMapViewControllerDelegate?
    let locationManager = CLLocationManager()
    
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
        
        if let location = location {
            let initialLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            addAnnotation(coordinate: initialLocation)
            centerMap(at: initialLocation)
        } else {
            // Locate user
            if CLLocationManager.locationServicesEnabled() {
                locationManager.requestWhenInUseAuthorization()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    private func centerMap(at coordinate: CLLocationCoordinate2D) {
        let regionRadius: CLLocationDistance = 1000
        
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: 1000)
        
        mapView.setRegion(region, animated: true)
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
}

// MARK: - User Location
extension NoteMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            if let userLocation = locations.last {
                centerMap(at: userLocation.coordinate)
            }
        }
    }
}
