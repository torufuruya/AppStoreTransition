//
//  SecondViewController.swift
//  TabAndAnimation
//
//  Created by Toru Furuya on 2019/07/18.
//  Copyright © 2019 Toru Furuya. All rights reserved.
//

import UIKit

class SecondViewController: StatusBarAnimatableViewController {

    @IBOutlet weak var tableView: UITableView!

    override var statusBarAnimatableConfig: StatusBarAnimatableConfig {
        return .init(prefersHidden: false, animation: .slide)
    }

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
        ],
        [
            CardContentViewModel(image: #imageLiteral(resourceName: "image1"), primary: "Paidyとは", secondary: ""),
            CardContentViewModel(image: #imageLiteral(resourceName: "image2"), primary: "請求と支払いについて", secondary: "")
        ]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delaysContentTouches = false
        self.tableView.contentInset = .init(top: 200, left: 0, bottom: 0, right: 0)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "\(StatementCollectionTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "StatementCard")
        self.tableView.register(UINib(nibName: "\(StatementSmallCollectionTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "StatementSmallCard")
        self.tableView.register(UINib(nibName: "\(SmallCardCollectionTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "SmallCard")
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
        case 2:
            return tableView.dequeueReusableCell(withIdentifier: "SmallCard", for: indexPath)
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: .init(x: 0, y: 0, width: tableView.bounds.width, height: 50))
        let label = UILabel(frame: .init(x: 32, y: 0, width: 100, height: 40))
        let font: UIFont
        if section == 0 {
            font = UIFont.systemFont(ofSize: 28, weight: .bold)
        } else {
            font = UIFont.systemFont(ofSize: 20, weight: .bold)
        }
        label.font = font
        label.text = "Title \(section + 1)"
        header.addSubview(label)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 50.0
        default: return 40.0
        }
    }
}

extension SecondViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 280
        default: return 176
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
