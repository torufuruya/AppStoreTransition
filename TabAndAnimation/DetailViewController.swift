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
    @IBOutlet weak var tableView: UITableView!

    var viewModel: CardContentViewModel? {
        didSet {
            self.cardContentView?.viewModel = viewModel
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.cardContentView.viewModel = self.viewModel
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var newFrame = self.tableView.frame
        let height = self.view.bounds.height - self.cardContentView.bounds.height
        newFrame.size.height = height
        self.tableView.frame = newFrame
        self.tableView.setNeedsLayout()
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    var data: [Int] {
        return [1,2,3,4,5,6,7,8,9,10]
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(self.data[indexPath.row])"
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
