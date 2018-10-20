//
//  NotesMapViewController.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 19/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class NotesMapViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    let notebook: Notebook
    let coreDataStack: CoreDataStack
    var fetchedResultsController: NSFetchedResultsController<Note>
    
    // MARK: - Initialization
    init(notebook: Notebook, coreDataStack: CoreDataStack, fetchedResultsController: NSFetchedResultsController<Note>) {
        self.notebook = notebook
        self.coreDataStack = coreDataStack
        self.fetchedResultsController = fetchedResultsController
        
        super.init(nibName: nil, bundle: nil)
        
        title = "Mapa"
        tabBarItem.image = UIImage(named: "map")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        updateAnnotations()
    }
    
    // MARK: - Annotations
    func updateAnnotations() {
        var annotations: [MKPointAnnotation] = []
        if let notes = fetchedResultsController.fetchedObjects {
            for note in notes {
                if note.location != nil {
                    let annotation = NoteAnnotation(with: note)
                    annotations.append(annotation)
                }
            }
        }
        
        if let mapView = mapView, annotations.count > 0 {
            mapView.layoutMargins = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
            mapView.showAnnotations(annotations, animated: true)
        }
    }
}

// MARK: - Note click
extension NotesMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? NoteAnnotation {
            let note = annotation.note
            let noteView = NoteDetailsViewController(action: .edit(note), managedContext: coreDataStack.managedContext)
            noteView.delegate = tabBarController as! NotesTabBarController
            self.navigationController?.pushViewController(noteView, animated: true)
        }
    }
}
