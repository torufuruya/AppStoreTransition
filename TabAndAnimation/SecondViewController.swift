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
            CardContentViewModel(image: #imageLiteral(resourceName: "image1"), primary: "Card 1"),
            CardContentViewModel(image: #imageLiteral(resourceName: "image2"), primary: "Card 2")
        ],
        [
            CardContentViewModel(image: #imageLiteral(resourceName: "image1"), primary: "Card 1"),
            CardContentViewModel(image: #imageLiteral(resourceName: "image2"), primary: "Card 2"),
            CardContentViewModel(image: #imageLiteral(resourceName: "image1"), primary: "Card 3"),
            CardContentViewModel(image: #imageLiteral(resourceName: "image2"), primary: "Card 4"),
            CardContentViewModel(image: #imageLiteral(resourceName: "image1"), primary: "Card 5")
        ]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delaysContentTouches = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "\(CardCollectionTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "Card")
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
            return tableView.dequeueReusableCell(withIdentifier: "Card", for: indexPath)
        case 1:
            return tableView.dequeueReusableCell(withIdentifier: "SmallCard", for: indexPath)
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
        case 0:
            let cardHorizontalOffset = 32
            let cardHeightByWidthRatio: CGFloat = 0.6
            let width = tableView.bounds.width - CGFloat(2 * cardHorizontalOffset)
            let height: CGFloat = width * cardHeightByWidthRatio
            return height
        case 1: return 150
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
