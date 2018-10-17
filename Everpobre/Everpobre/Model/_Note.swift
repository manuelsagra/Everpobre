//
//  Note.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 8/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//

import Foundation

struct _Note {
    let title: String
    let text: String?
    let tags: [String]?
    let creationDate: Date
    let lastSeenDate: Date?
    
    static let dummyNotesModel: [_Note] = [
        _Note(title: "Primera nota", text: nil, tags: nil, creationDate: Date(), lastSeenDate: nil),
        _Note(title: "Segunda nota", text: "Test", tags: nil, creationDate: Date(), lastSeenDate: nil),
        _Note(title: "Tercera nota", text: "Texto de prueba", tags: ["Uno", "Dos"], creationDate: Date(), lastSeenDate: nil),
        _Note(title: "Cuarta nota", text: "Algo de contenido", tags: nil, creationDate: Date(), lastSeenDate: nil),
        _Note(title: "Quinta nota", text: nil, tags: nil, creationDate: Date(), lastSeenDate: nil)
    ]
}
