//
//  StatementContentView.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/23.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

class StatementViewModel: ViewModel {
    let month: String
    let price: String
    let dueDate: String

    init(month: String, price: String, dueDate: String) {
        self.month = month
        self.price = price
        self.dueDate = dueDate
    }
}

class StatementContentView: UIView, NibLoadable {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!

    var viewModel: StatementViewModel? {
        didSet {
            self.monthLabel.text = viewModel?.month
            self.priceLabel.text = viewModel?.price
            self.dueDateLabel.text = "支払い期日: \(viewModel?.dueDate ?? "")"
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
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.payButton.layer.cornerRadius = self.payButton.bounds.height/2
    }
}
