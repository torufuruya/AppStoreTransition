//
//  DetailViewController.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/18.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var cardContentView: CardContentView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
