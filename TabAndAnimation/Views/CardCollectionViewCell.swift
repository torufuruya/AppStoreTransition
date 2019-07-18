//
//  CardCollectionViewCell.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/18.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cardContentView: CardContentView!

    override func awakeFromNib() {
        cardContentView.layer.cornerRadius = 16
        cardContentView.layer.masksToBounds = true
        backgroundColor = .clear
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .init(width: 0, height: 4)
        layer.shadowRadius = 12
    }
}
