//
//  Notebook.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 8/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//

import Foundation

struct _Notebook {
    let name: String
    let creationDate: Date
    let notes: [_Note]
    
    static let dummyNotebookModel: [_Notebook] = [
        _Notebook(name: "Prueba 1", creationDate: Date(), notes: _Note.dummyNotesModel),
        _Notebook(name: "Prueba 2", creationDate: Date().calculate(fromDaysBefore: 3), notes: _Note.dummyNotesModel),
        _Notebook(name: "Prueba 3", creationDate: Date().calculate(fromDaysBefore: 5), notes: _Note.dummyNotesModel),
        _Notebook(name: "Prueba 4", creationDate: Date().calculate(fromDaysBefore: 7), notes: _Note.dummyNotesModel),
        _Notebook(name: "Prueba 5", creationDate: Date().calculate(fromDaysBefore: 7), notes: _Note.dummyNotesModel),
        _Notebook(name: "Prueba 6", creationDate: Date().calculate(fromDaysBefore: 8), notes: _Note.dummyNotesModel),
        _Notebook(name: "Prueba 7", creationDate: Date().calculate(fromDaysBefore: 9), notes: _Note.dummyNotesModel),
        _Notebook(name: "Prueba 8", creationDate: Date().calculate(fromDaysBefore: 10), notes: _Note.dummyNotesModel),
        _Notebook(name: "Prueba 9", creationDate: Date().calculate(fromDaysBefore: 11), notes: _Note.dummyNotesModel)
    ]
}

extension Date {
    func calculate(fromDaysBefore days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -days, to: self) ?? Date()
    }
}
