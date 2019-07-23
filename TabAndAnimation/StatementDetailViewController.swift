//
//  StatementDetailViewController.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/23.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

class StatementDetailViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!

    var viewModel: StatementViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.containerView.alpha = 0.0
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.payButton.layer.cornerRadius = self.payButton.bounds.height/2
    }

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
