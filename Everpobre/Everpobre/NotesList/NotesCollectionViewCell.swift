//
//  NotesCollectionViewCell.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 12/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//

import UIKit

class NotesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var item: Note!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with item: Note) {
        backgroundColor = .gray
        titleLabel.text = item.title
        creationDateLabel.text = (item.creationDate as Date?)?.toLocaleString()
        if let imageData = item.image, imageData.length > 0 {
            imageView.image = UIImage(data: imageData as Data)
        }
    }
}
