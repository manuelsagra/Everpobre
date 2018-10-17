//
//  Date+Utils.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 9/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//

import Foundation

extension Date {
    func toLocaleString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "es")
        
        return "\(dateFormatter.string(from: self))"
    }
}
