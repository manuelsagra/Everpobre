//
//  NotePointAnnotation.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 19/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//

import Foundation
import MapKit

class NoteAnnotation: MKPointAnnotation {
    var note: Note
    
    init(with note: Note) {
        self.note = note
        
        super.init()
        
        self.coordinate = CLLocationCoordinate2D(latitude: note.location!.latitude, longitude: note.location!.longitude)
        self.title = note.title
    }
}
