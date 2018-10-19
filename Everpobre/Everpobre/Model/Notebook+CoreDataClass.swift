//
//  Notebook+CoreDataClass.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 15/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Notebook)
public class Notebook: NSManagedObject {

}

extension Notebook {
    func csv() -> String {
        let exportedName = name ?? "Sin nombre"
        let exportedCreationDate = (creationDate as Date?)?.toLocaleString() ?? "---"
        
        var exportedNotes = ""
        if let notes = notes {
            for note in notes {
                if let note = note as? Note {
                    exportedNotes = "\(exportedNotes)\(note.csv())\n"
                }
            }
        }
        
        return "\(exportedCreationDate),\(exportedName)\n\(exportedNotes)"
    }
}
