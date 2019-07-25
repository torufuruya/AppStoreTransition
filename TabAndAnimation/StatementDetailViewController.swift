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
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension StatementDetailViewController: UITableViewDelegate, UITableViewDataSource {
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
        cell.textLabel?.text = "Row \(self.data[indexPath.row])"
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
