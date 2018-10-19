//
//  Note+CoreDataClass.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 15/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {

}

extension Note {
    func csv() -> String {
        let exportedTitle = title ?? "Sin título"
        let exportedText = text ?? ""
        let exportedCreationDate = (creationDate as Date?)?.toLocaleString() ?? "---"
        
        return "\(exportedCreationDate),\(exportedTitle),\(exportedText)"
    }
}
