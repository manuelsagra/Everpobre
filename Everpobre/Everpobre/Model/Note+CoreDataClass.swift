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

enum Tag: Int16, CaseIterable, CustomStringConvertible {
    case Personal   = 1
    case TODO       = 2
    case Info       = 3
    case Otros      = 4
    
    var description: String {
        switch self {
        case .Personal: return "Personal"
        case .TODO: return "TODO"
        case .Info: return "Info"
        case .Otros: return "Otros"
        }
    }
}
