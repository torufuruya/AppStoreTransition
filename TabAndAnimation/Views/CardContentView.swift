//
//  CardContentView.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/18.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

struct CardContentViewModel {
    let image: UIImage
    let primary: String
}

class CardContentView: UIView, NibLoadable {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var primaryLabel: UILabel!

    var viewModel: CardContentViewModel? {
        didSet {
            self.imageView.image = viewModel?.image
            self.primaryLabel.text = viewModel?.primary
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fromNib()
        self.commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        fromNib()
        self.commonSetup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonSetup()
    }

    private func commonSetup() {
        // *Make the background image stays still at the center while we animationg,
        // else the image will get resized during animation.
//        imageView.contentMode = .center
        imageView.contentMode = .scaleAspectFill
    }
}
