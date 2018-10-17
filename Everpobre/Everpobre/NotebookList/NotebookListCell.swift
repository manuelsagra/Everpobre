//
//  NotebookListCell.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 8/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//

import UIKit

class NotebookListCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    
    // MARK: - Functions
    override func prepareForReuse() {
        titleLabel.text = nil
        creationDateLabel.text = nil
        super.prepareForReuse()
    }
    
    func configure(with notebook: Notebook) {
        titleLabel.text = notebook.name
        creationDateLabel.text = (notebook.creationDate as Date?)?.toLocaleString() ?? ""
    }
}
