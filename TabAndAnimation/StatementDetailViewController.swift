//
//  StatementDetailViewController.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/23.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

class StatementDetailViewController: UIViewController {

    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var statementContentView: StatementContentView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dismissButton: UIButton!

    var viewModel: StatementViewModel? {
        didSet {
            self.statementContentView?.viewModel = viewModel
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.statementContentView.viewModel = self.viewModel
        // Expand the size of price label
        self.statementContentView.transformPriceLabel(toPointSize: self.statementContentView.priceLabel.font.pointSize)
    }

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
