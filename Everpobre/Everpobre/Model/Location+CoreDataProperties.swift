//
//  Location+CoreDataProperties.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 18/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var note: Note?

}
