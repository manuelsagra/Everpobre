//
//  Note+CoreDataProperties.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 15/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var lastSeenDate: NSDate?
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var image: NSData?
    @NSManaged public var notebook: Notebook?

}
