//
//  DetailViewController.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/18.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var cardContentView: CardContentView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!

    var viewModel: CardContentViewModel? {
        didSet {
            self.cardContentView?.viewModel = viewModel
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.cardContentView.viewModel = self.viewModel
    }

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
