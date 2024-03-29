//
//  StatementContentView.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/23.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

enum Status {
    case created, paid, overdue, other
}

class StatementViewModel: ViewModel {
    let month: String
    let price: String
    let dueDate: String
    let status: Status

    init(month: String, price: String, dueDate: String, status: Status = .other) {
        self.month = month
        self.price = price
        self.dueDate = dueDate
        self.status = status
    }
}

class StatementContentView: UIView, NibLoadable {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!

    // Constraints
    @IBOutlet weak var iconToTop: NSLayoutConstraint!
    @IBOutlet weak var iconHeight: NSLayoutConstraint!
    @IBOutlet weak var monthLabelToIcon: NSLayoutConstraint!
    @IBOutlet weak var messageLabelToMonthLabel: NSLayoutConstraint!
    @IBOutlet weak var priceLabelToMessageLabel: NSLayoutConstraint!
    @IBOutlet weak var dueDateLabelToPriceLabel: NSLayoutConstraint!
    @IBOutlet weak var payButtonToDueDateLabel: NSLayoutConstraint!

    private let priceLabelFontSize: CGFloat = 28
    private let priceLabelSmallFontSize: CGFloat = 16

    var viewModel: StatementViewModel? {
        didSet {
            self.monthLabel.text = viewModel?.month
            self.priceLabel.text = viewModel?.price
            self.dueDateLabel.text = "支払い期日: \(viewModel?.dueDate ?? "")"

            // Hide pay button
            if ![.created, .overdue].contains(self.viewModel?.status) {
                self.payButton.isHidden = true
                self.payButtonToDueDateLabel.constant = 0
            }
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
        self.messageLabel.isHidden = true
        self.priceLabel.font = UIFont.systemFont(ofSize: self.priceLabelFontSize, weight: .bold)
        self.payButton.layer.cornerRadius = self.payButton.bounds.height/2
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.payButton.layer.cornerRadius = self.payButton.bounds.height/2
    }

    func makeMonthFontRegular() {
        self.monthLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    }

    func shrinkPriceLabel() {
        let factor: CGFloat = self.priceLabelSmallFontSize / self.priceLabelFontSize
        let transform = CGAffineTransform(scaleX: factor, y: factor)
        self.priceLabel.transform = transform
    }
}
