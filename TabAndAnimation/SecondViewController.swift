//
//  SecondViewController.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/18.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var viewModels = [
        [
            StatementViewModel(month: "5月", price: "¥25,000", dueDate: "6月10日", status: .overdue),
            StatementViewModel(month: "6月", price: "¥12,300", dueDate: "7月10日")
        ],
        [
            StatementViewModel(month: "3月", price: "¥3,400", dueDate: "4月10日", status: .paid),
            StatementViewModel(month: "4月", price: "¥120,000", dueDate: "5月10日", status: .paid),
            StatementViewModel(month: "5月", price: "¥25,000", dueDate: "6月10日", status: .overdue),
            StatementViewModel(month: "6月", price: "¥12,300", dueDate: "7月10日"),
            StatementViewModel(month: "7月", price: "¥7,700", dueDate: "8月10日")
        ]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delaysContentTouches = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "\(StatementCollectionTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "StatementCard")
        self.tableView.register(UINib(nibName: "\(StatementSmallCollectionTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "StatementSmallCard")
    }
}

extension SecondViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: "StatementCard", for: indexPath)
        case 1:
            return tableView.dequeueReusableCell(withIdentifier: "StatementSmallCard", for: indexPath)
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: .init(x: 0, y: 0, width: tableView.bounds.width, height: 50))
        let label = UILabel(frame: .init(x: 32, y: 0, width: 100, height: 50))
        let font: UIFont
        if section == 0 {
            font = UIFont.systemFont(ofSize: 30, weight: .bold)
        } else {
            font = UIFont.systemFont(ofSize: 24, weight: .bold)
        }
        label.font = font
        label.text = "Label \(section + 1)"
        header.addSubview(label)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 50.0
        case 1: return 40.0
        default: return .zero
        }
    }
}

extension SecondViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 280
        case 1: return 176
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let viewModels = self.viewModels[indexPath.section]

        guard var cell = cell as? CardTableViewCell else {
            return
        }
        cell.viewModels = viewModels
        cell.viewController = self
    }
}
